#!/usr/bin/env bash
# Links the shared AI rules into Claude Code and Codex.
# Symlinks keep both tools on this clone: edit or `git pull` here and the next
# session picks it up. Safe to re-run.
set -euo pipefail

# `pwd -P` resolves symlinks: run as ~/.ai-rules/scripts/install-macos.sh, a
# logical path would make the clone look like the ~/.ai-rules link itself.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
RULES_LINK="${HOME}/.ai-rules"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
# Legacy path that some projects' rules reference literally.
LEGACY_DOCS_LINK="${HOME}/.claude/docs"
BACKUP_SUFFIX="bak.$(date +%Y%m%d-%H%M%S)"
# The commit hook's name in the global git config (`hook.<name>.*`).
HOOK_NAME="ai-rules-verified"
# Kept literal: the shell that runs the hook expands $HOME, and Git appends
# the hook's arguments to the last command. A clone with no runnable hook
# file (an older checkout, a lost execute bit) warns and lets the commit
# through, so it can never block every repo on the machine.
# shellcheck disable=SC2016
HOOK_COMMAND='h="$HOME/.ai-rules/hooks/commit-msg"; [ -x "$h" ] || { echo "ai-rules: $h is missing or not executable; the Verified: trailer is not checked" >&2; exit 0; }; "$h"'

# link <target> <link_path>: points link_path at target. A real file or
# directory there is backed up first; if linking fails, the previous file or
# link is put back. A path that already is the target is left alone.
link() {
  local target="$1" link_path="$2" backup="" old_target=""
  if [[ ! -L "${link_path}" && -e "${link_path}" && "${link_path}" -ef "${target}" ]]; then
    echo "Skipped ${link_path}: it already is ${target}"
    return
  fi
  mkdir -p "$(dirname "${link_path}")"
  if [[ -L "${link_path}" ]]; then
    old_target="$(readlink "${link_path}")"
  elif [[ -e "${link_path}" ]]; then
    backup="${link_path}.${BACKUP_SUFFIX}"
    mv "${link_path}" "${backup}"
    echo "Backed up ${link_path} -> ${backup}"
  fi
  if ! ln -sfn "${target}" "${link_path}"; then
    if [[ -n "${backup}" ]]; then
      mv "${backup}" "${link_path}"
    elif [[ -n "${old_target}" ]]; then
      ln -sfn "${old_target}" "${link_path}"
    fi
    echo "Failed to link ${link_path}; left it as it was." >&2
    return 1
  fi
  echo "Linked ${link_path} -> ${target}${old_target:+ (was -> ${old_target})}"
}

link "${REPO_DIR}" "${RULES_LINK}"
link "${REPO_DIR}/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"
link "${REPO_DIR}/AGENTS.md" "${CODEX_DIR}/AGENTS.md"
link "${REPO_DIR}/docs" "${LEGACY_DOCS_LINK}"

if [[ -e "${CODEX_DIR}/AGENTS.override.md" ]]; then
  echo "Warning: ${CODEX_DIR}/AGENTS.override.md exists; Codex reads it instead of AGENTS.md." >&2
fi

# Commit hook: checks the `Verified:` trailer (docs/git-conventions.md) on
# commits made from an agent session, in every repo on this machine. It is a
# config-based hook, so each repo's own .git/hooks keep running beside it.
# Setting the same keys again replaces them, so re-running adds no duplicate.
if ! command -v git >/dev/null 2>&1; then
  echo "Warning: git was not found; the commit hook was not installed." >&2
else
  git config --global "hook.${HOOK_NAME}.event" commit-msg
  git config --global "hook.${HOOK_NAME}.command" "${HOOK_COMMAND}"
  echo "Installed the commit-msg hook (git config --global hook.${HOOK_NAME}.*)"
  # Git runs config-based hooks from 2.54 on; an older Git ignores the keys.
  if ! git -C "${REPO_DIR}" -c hook.probe.event=commit-msg -c hook.probe.command=true \
    hook list commit-msg >/dev/null 2>&1; then
    echo "Warning: $(git --version) does not run config-based hooks (needs 2.54 or later); the Verified: trailer is not checked until Git is updated." >&2
  fi
fi
