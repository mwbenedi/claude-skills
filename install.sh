#!/usr/bin/env bash
# Symlink every skill in ./skills into ~/.claude/skills so edits here take effect immediately.
set -euo pipefail

src_dir="$(cd "$(dirname "$0")/skills" && pwd)"
dest_dir="$HOME/.claude/skills"
mkdir -p "$dest_dir"

for path in "$src_dir"/*/; do
  name="$(basename "$path")"
  dest="$dest_dir/$name"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "skip $name: $dest exists and is not a symlink (move it aside first)" >&2
    continue
  fi
  ln -s "${path%/}" "$dest"
  echo "linked $name -> ${path%/}"
done
