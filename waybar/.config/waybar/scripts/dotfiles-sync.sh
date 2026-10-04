#!/usr/bin/env bash
# Commit (and optionally push) dotfiles changes, from the Waybar click.
# Stages tracked changes only. New files are listed and need an explicit yes,
# so a stray secret or cache file dropped into a package is never swept in.

cd ~/.dotfiles || exit 1

echo "--- Dotfiles status ($(git branch --show-current)) ---"
git status -s

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to commit."
  sleep 2
  exit 0
fi

git add -u

mapfile -t untracked < <(git ls-files --others --exclude-standard)
if [ "${#untracked[@]}" -gt 0 ]; then
  echo ""
  echo "New, untracked files:"
  printf '  %s\n' "${untracked[@]}"
  read -rp "Add these too? [y/N] " add_new
  if [[ "$add_new" =~ ^[Yy]$ ]]; then
    git add -- "${untracked[@]}"
  fi
fi

if git diff --cached --quiet; then
  echo "Nothing staged."
  sleep 2
  exit 0
fi

echo ""
git diff --cached --stat
read -rp "Commit message (empty = cancel): " msg
if [ -z "$msg" ]; then
  git reset -q
  echo "Cancelled; nothing committed."
  sleep 2
  exit 0
fi

git commit -m "$msg"

read -rp "Push to origin? [y/N] " push_confirm
if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
  git push
else
  echo "Skipped push."
fi

sleep 2
