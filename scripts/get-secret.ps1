# Prints the password of a generic credential in the Windows Credential
# Manager, the Windows counterpart of `security find-generic-password -w`.
# Run it only inside a capture (see docs/api-keys.md): it writes the secret to
# stdout. Run it with PowerShell 7 (`pwsh`): its default execution policy
# allows local scripts, while Windows PowerShell 5.1 often blocks them.
#
# Exit codes: 0 found, 2 no such credential, 3 the credential has no password,
# 1 any other failure.
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Target
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ExitNotFound = 2
$ExitEmpty = 3
$ExitFailed = 1

# cmdkey can store a generic credential but cannot read one back, so read it
# through CredReadW. Unused CREDENTIALW pointers stay IntPtr to skip marshaling.
if (-not ("AiRules.CredMan" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace AiRules {
    public static class CredMan {
        [StructLayout(LayoutKind.Sequential)]
        private struct Credential {
            public uint Flags;
            public uint Type;
            public IntPtr TargetName;
            public IntPtr Comment;
            public uint LastWrittenLow;
            public uint LastWrittenHigh;
            public uint CredentialBlobSize;
            public IntPtr CredentialBlob;
            public uint Persist;
            public uint AttributeCount;
            public IntPtr Attributes;
            public IntPtr TargetAlias;
            public IntPtr UserName;
        }

        private const uint CredTypeGeneric = 1;

        [DllImport("advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredRead(string target, uint type, uint flags, out IntPtr credential);

        [DllImport("advapi32.dll")]
        private static extern void CredFree(IntPtr buffer);

        // Returns 0 and the password, or the Win32 error code and null.
        // cmdkey and the Credential Manager UI store the password as UTF-16.
        public static int ReadGeneric(string target, out string password) {
            password = null;
            IntPtr pointer;
            if (!CredRead(target, CredTypeGeneric, 0, out pointer)) {
                return Marshal.GetLastWin32Error();
            }
            try {
                Credential credential = (Credential)Marshal.PtrToStructure(pointer, typeof(Credential));
                password = credential.CredentialBlob == IntPtr.Zero
                    ? ""
                    : Marshal.PtrToStringUni(credential.CredentialBlob, (int)(credential.CredentialBlobSize / sizeof(char)));
                return 0;
            } finally {
                CredFree(pointer);
            }
        }
    }
}
"@
}

$ErrorNotFound = 1168
$Password = $null
$ErrorCode = [AiRules.CredMan]::ReadGeneric($Target, [ref]$Password)

# Messages go to stderr and never include the value, so a failed capture
# leaves the variable empty and the reason visible.
if ($ErrorCode -eq $ErrorNotFound) {
    [Console]::Error.WriteLine("No generic credential named '$Target' in the Windows Credential Manager. Add it in Control Panel > Credential Manager > Windows Credentials > Add a generic credential, or run in PowerShell: cmdkey /generic:$Target /user:api /pass")
    exit $ExitNotFound
}
if ($ErrorCode -ne 0) {
    $Reason = (New-Object System.ComponentModel.Win32Exception $ErrorCode).Message
    [Console]::Error.WriteLine("Could not read credential '$Target': Win32 error $ErrorCode ($Reason).")
    exit $ExitFailed
}
if ([string]::IsNullOrEmpty($Password)) {
    [Console]::Error.WriteLine("Credential '$Target' has no password. Edit it in Control Panel > Credential Manager > Windows Credentials.")
    exit $ExitEmpty
}

# Write-Output, not [Console]::Out: an in-process caller (`$x = & script`)
# captures only the pipeline, so a console write would print the secret.
Write-Output $Password
