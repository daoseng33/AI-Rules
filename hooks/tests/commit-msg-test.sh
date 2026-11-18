#!/usr/bin/env bash
# Tests hooks/commit-msg through real `git commit`, with the hook installed by
# scripts/install-macos.sh into a throwaway HOME. Nothing outside the temp
# directory is read or written: not the real ~/.gitconfig, ~/.claude or
# ~/.codex.
#
# Usage: hooks/tests/commit-msg-test.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

export HOME="${WORK_DIR}/home"
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME="Test" GIT_AUTHOR_EMAIL="test@example.com"
export GIT_COMMITTER_NAME="Test" GIT_COMMITTER_EMAIL="test@example.com"
export GIT_EDITOR=true
unset GIT_CONFIG_GLOBAL XDG_CONFIG_HOME CLAUDE_CONFIG_DIR CODEX_HOME
# Run from inside a git hook, these would point every git command below at
# the real repository.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_PREFIX
mkdir -p "${HOME}"

readonly HOOK_NAME="ai-rules-verified"
readonly CO_AUTHOR="Co-Authored-By: Some Agent <agent@example.com>"
failures=0
cases=0

fail() {
  failures=$((failures + 1))
  echo "FAIL: $1"
  if [[ -n "${2:-}" ]]; then
    printf '      %s\n' "${2//$'\n'/$'\n      '}"
  fi
}

# The session running this suite may itself be an agent session, so every case
# sets or clears the markers explicitly.
as_agent() { env AI_AGENT="test-agent" CLAUDECODE="1" "$@"; }
as_human() { env -u AI_AGENT -u CLAUDECODE "$@"; }
with_only_ai_agent() { env -u CLAUDECODE AI_AGENT="test-agent" "$@"; }
with_only_claudecode() { env -u AI_AGENT CLAUDECODE="1" "$@"; }

# commit <who> <message> [git commit args...]: stages a new change and commits
# it with the message. Sets `status` and `output` (stdout and stderr).
change=0
commit() {
  local who="$1" message="$2"
  shift 2
  change=$((change + 1))
  echo "${change}" >"change-${change}.txt"
  git add -A
  printf '%s\n' "${message}" >"${WORK_DIR}/message"
  status=0
  output="$("${who}" git commit -q -F "${WORK_DIR}/message" "$@" 2>&1)" || status=$?
  if [[ "${status}" -ne 0 ]]; then
    git reset -q
    rm -f "change-${change}.txt"
  fi
}

passes() {
  local name="$1"
  shift
  cases=$((cases + 1))
  commit "$@"
  [[ "${status}" -eq 0 ]] || fail "${name}: expected the commit to pass" "${output}"
}

blocks() {
  local name="$1" expected="$2"
  shift 2
  cases=$((cases + 1))
  commit "$@"
  if [[ "${status}" -eq 0 ]]; then
    fail "${name}: expected the commit to be blocked"
  elif [[ "${output}" != *"${expected}"* ]]; then
    fail "${name}: expected the message to contain '${expected}'" "${output}"
  fi
}

check() {
  local name="$1"
  shift
  cases=$((cases + 1))
  output="$("$@" 2>&1)" || fail "${name}" "${output}"
}

# --- Install -----------------------------------------------------------------

if ! git -c hook.probe.event=commit-msg -c hook.probe.command=true \
  -C "${REPO_DIR}" hook list commit-msg >/dev/null 2>&1; then
  echo "FAIL: $(git --version) does not run config-based hooks (needs 2.54 or later)."
  exit 1
fi

"${REPO_DIR}/scripts/install-macos.sh" >/dev/null
"${REPO_DIR}/scripts/install-macos.sh" >/dev/null
check "installing twice leaves one event entry" \
  test "$(git config --global --get-all "hook.${HOOK_NAME}.event")" = "commit-msg"
check "the installed hook is executable" test -x "${HOME}/.ai-rules/hooks/commit-msg"

git init -q "${WORK_DIR}/repo"
cd "${WORK_DIR}/repo"
as_human git commit -q --allow-empty -m "root"

# --- Who is held to the stamp --------------------------------------------------

passes "a commit by hand needs no stamp" as_human "feat: by hand"
blocks "an agent commit with no stamp" "has no 'Verified:' trailer" as_agent "feat: no stamp"
blocks "the message names the line to add" "Verified: tests, run" as_agent "feat: no stamp"
blocks "AI_AGENT alone marks an agent session" "has no 'Verified:' trailer" with_only_ai_agent "feat: no stamp"
blocks "CLAUDECODE alone marks an agent session" "has no 'Verified:' trailer" with_only_claudecode "feat: no stamp"

# --- Stamps that pass --------------------------------------------------------

passes "one step" as_agent $'feat: a\n\nVerified: tests'
passes "several steps" as_agent $'feat: b\n\n- a bullet\n\nVerified: tests, build, run, review'
passes "stamp before another trailer" as_agent $'feat: c\n\nVerified: run\n'"${CO_AUTHOR}"
passes "stamp after another trailer" as_agent $'feat: d\n\n'"${CO_AUTHOR}"$'\nVerified: run'
passes "none with a reason" as_agent $'docs: e\n\nVerified: none (docs only)'
passes "a --- line in the body" as_agent $'feat: f\n\nbefore\n---\nafter\n\nVerified: tests'
passes "comment lines after the stamp" as_agent $'feat: g\n\nVerified: tests\n# a comment' --cleanup=strip
passes "an autosquash commit" as_agent "fixup! feat: a"
# `-v -e` puts the diff under a scissors line in the message file; the stamp
# above it must still read as the last block.
passes "a stamp above the commit -v diff" as_agent $'feat: v\n\nVerified: tests' -v -e

# --- Stamps that are blocked -------------------------------------------------

blocks "an unknown step" "'yes' is not one of" as_agent $'feat: h\n\nVerified: yes'
blocks "one unknown step among known ones" "'lint' is not one of" as_agent $'feat: h\n\nVerified: tests, lint'
blocks "none without a reason" "needs its reason" as_agent $'feat: i\n\nVerified: none'
blocks "none with an empty reason" "needs its reason" as_agent $'feat: i\n\nVerified: none ()'
blocks "an empty stamp" "Verified:" as_agent $'feat: j\n\nVerified:'
blocks "no space after the colon" "on one line as" as_agent $'feat: k\n\nVerified:tests'
blocks "a lowercase key" "has no 'Verified:' trailer" as_agent $'feat: l\n\nverified: tests'
blocks "a stamp outside the last block" "has no 'Verified:' trailer" as_agent $'feat: m\n\nVerified: tests\n\nmore body text'
blocks "two stamps" "more than one" as_agent $'feat: n\n\nVerified: tests\nVerified: run'
blocks "a trailing comma" "ends with a comma" as_agent $'feat: s\n\nVerified: tests,'
blocks "a leading comma" "is not one of" as_agent $'feat: s\n\nVerified: , tests'
blocks "a stamp under the bullets with no blank line" "after a blank line" as_agent $'feat: t\n\n- one\n- two\n- three\nVerified: tests'

# --- Other ways a commit is made ---------------------------------------------

cases=$((cases + 1))
status=0
output="$(as_agent git commit -q --amend -m "feat: amended without a stamp" 2>&1)" || status=$?
[[ "${status}" -ne 0 ]] || fail "an amend with no stamp is blocked"

git checkout -q -b side HEAD~1
echo side >side.txt
git add -A
as_human git commit -q -m "feat: on a side branch"
git checkout -q -

check "a merge commit needs no stamp" as_agent git merge -q --no-ff -m "Merge side" side

git checkout -q -b topic HEAD~2
echo topic >topic.txt
git add -A
as_human git commit -q -m "feat: made before the rule"
check "a rebase with reword is not trapped" \
  as_agent env GIT_SEQUENCE_EDITOR="sed -i.bak 1s/^pick/reword/" git rebase -q -i HEAD~1
check "a revert is not trapped" as_agent git revert --no-edit HEAD
check "a cherry-pick is not trapped" as_agent git cherry-pick side
git checkout -q -

# A cherry-pick that stops on a conflict runs the hook when it continues.
echo base >clash.txt
git add -A
as_human git commit -q -m "feat: base of the clash"
git checkout -q -b clash
echo theirs >clash.txt
git add -A
as_human git commit -q -m "feat: made before the rule, will conflict"
git checkout -q -
echo ours >clash.txt
git add -A
as_human git commit -q -m "feat: our side of the clash"
as_agent git cherry-pick clash >/dev/null 2>&1 || true
echo resolved >clash.txt
git add -A
check "a cherry-pick continued after a conflict is not trapped" as_agent git cherry-pick --continue

# --- Beside a repo's own hook, and switched off ------------------------------

cat >.git/hooks/commit-msg <<'EOF'
#!/bin/sh
echo ran >"$(git rev-parse --git-dir)/own-hook-ran"
EOF
chmod +x .git/hooks/commit-msg
passes "a stamped commit in a repo with its own hook" as_agent $'feat: o\n\nVerified: tests'
check "the repo's own commit-msg hook still runs" test -f .git/own-hook-ran
blocks "the stamp is still required beside the repo's own hook" "has no 'Verified:' trailer" as_agent "feat: p"
rm .git/hooks/commit-msg

git config "hook.${HOOK_NAME}.enabled" false
passes "switched off in one repo" as_agent "feat: q"
git config --unset "hook.${HOOK_NAME}.enabled"

# --- A clone with no hook file -----------------------------------------------

rm "${HOME}/.ai-rules"
mkdir "${HOME}/.ai-rules"
passes "a missing hook file lets the commit through" as_agent "feat: r"
cases=$((cases + 1))
[[ "${output}" == *"is missing"* ]] || fail "a missing hook file is said on stderr" "${output}"

echo "${cases} cases, ${failures} failed"
[[ "${failures}" -eq 0 ]]
