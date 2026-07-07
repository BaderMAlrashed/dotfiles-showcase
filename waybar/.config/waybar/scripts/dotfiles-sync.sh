#!/usr/bin/env bash

cd ~/.dotfiles || exit 1

echo "--- Dotfiles status ---"
git status -s

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to commit."
  sleep 2
  exit 0
fi

git add -A
echo ""
read -rp "Commit message: " msg
[ -z "$msg" ] && msg="update dotfiles"

git commit -m "$msg"

read -rp "Push to origin? [y/N] " push_confirm
if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
  git push
else
  echo "Skipped push."
fi

sleep 2
