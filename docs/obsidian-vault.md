# Obsidian Vault

The owner keeps an Obsidian vault for the things they read themselves:
project overviews, decisions and weekly digests. It is synced to their phone.

- macOS path: `~/Obsidian/Obsidian Vault`. If the vault is not on this
  machine, skip every rule in this file and say so once.
- Project notes live under `專案/<project folder>/`. Use the existing folder
  for the project; create one only when the owner asks.

## What Goes Where

- **The repo's `docs/`** is the specification. Never copy a spec into the
  vault; link to it by repo-relative path in inline code.
- **Agent memory** holds how the agent should work (machine-facing).
- **The vault** holds what the owner wants to read: decisions with their
  reasons, an overview, digests. Write it in Traditional Chinese.

## Decision Log

When the owner makes, reverses or rejects a product, design, art, backend or
release decision during a session, add one decision note before the final
summary of that turn, and mention it in the summary.

Do not log routine implementation choices the agent made itself, standing
approvals given to the agent, or anything the owner has not actually decided.
A proposal the owner has not answered is logged only as `評估中`.

Each note is `專案/<project folder>/決策/YYYY-MM-DD 標題.md` with exactly this
frontmatter:

```yaml
---
date: 2026-11-13
area: 產品
status: 採用
summary: 一行摘要
---
```

- `area` is one of `產品`, `美術`, `3D`, `後端`, `發佈`.
- `status` is one of `採用`, `否決`, `評估中`.
- These values are matched exactly by the project's `決策日誌.base`; a new
  spelling silently drops the note from its views.
- `summary` is one line with no `:` and no `"`.
- The file name has no `.` and none of `/ : # ^ [ ] |`, so a version number
  cannot go in the title.
- Body sections as needed: `## 決定`, `## 經過` or `## 背景`, `## 界線`,
  `## 相關` (wikilinks to related decisions), `## 來源` (repo paths).
- When a decision replaces an earlier one, add a new note and link the two.
  Change the old note's `status` only if the owner reversed it.

Content rules:

- Give the owner's reason only in their own recorded words. If they gave
  none, write `沒有另外說理由`. Never present the agent's guess as their reason.
- The vault is synced: no secrets, key or account identifiers, credential
  paths, commit SHAs or branch names.
- Date-stamp anything that will go stale (release status, live switches).

If the project has no `決策/` folder yet, create the folder and the note, and
tell the owner the project has no decision-log base yet.

## Git Backup

The vault is a local git repository with no remote. It exists to give a
restore point around automated writes; Obsidian Sync does not carry `.git`,
so the history lives only on the machine where it was created.

- Before writing to the vault, run `git status --short` there. If the owner
  has uncommitted edits, commit them first as their own snapshot (`chore:
  snapshot the owner's edits before an automated write`), so their changes
  and the agent's stay in separate commits.
- After writing, commit exactly the files you added or changed, with a
  message that says what was written.
- Never add a remote to the vault or push it; it holds private notes.
- Never rewrite its history (no amend, rebase or `reset --hard`). To undo an
  automated write, use `git revert` or `git restore` on the affected paths
  and tell the owner.
- If the vault is not a git repository on this machine, write as usual and
  say so once.

## Writing to the Vault

- Automated writes only add notes, in the folders named above. Never edit a
  note the owner wrote.
- Never overwrite an existing note; pick a new name or stop and say so.
- Never move, rename or delete a note with shell commands (`mv`, `git mv`,
  `rm`). Obsidian only updates links for renames it performs itself, so a
  shell move breaks every `[[link]]` to the note. When the owner asks for one,
  use `obsidian rename`, `obsidian move` or `obsidian delete` (which moves the
  note to the trash) with the app running. Reorganising folders is the
  owner's decision.
- Never touch `.obsidian/`; it holds the app's own settings.
- Sort a base by `file.name`, not by the `date` property: a `date` sort had
  no effect in `obsidian base:query` (Obsidian 1.14.5, checked 2026-11-13).
- The `obsidian` CLI works only while the Obsidian app is running. Use it to
  check work (`obsidian unresolved`, `obsidian base:query`); write notes with
  the normal file tools so a closed app does not block the task.
