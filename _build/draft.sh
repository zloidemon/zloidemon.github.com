#!/bin/sh
title="$1"
posts_dir="$2"
layouts_dir="$3"

if [ -z "$title" ]; then
    echo "Usage: $(basename "$0") \"Post Title\" [_posts/] [_layouts/]" >&2
    exit 1
fi
if [ -z "$posts_dir" ]; then
    posts_dir="_posts"
fi
if [ -z "$layouts_dir" ]; then
    layouts_dir="_layouts"
fi

slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')
date=$(date +%Y-%m-%d)
file="${posts_dir}/${date}-${slug}.md"

if [ -f "$file" ]; then
    echo "Error: $file already exists" >&2
    exit 1
fi

tmpm4=$(mktemp)
printf "changequote([[, ]])dnl\n" > "$tmpm4"
printf "define([[_draft_title]], [[%s]])dnl\n" "$title" >> "$tmpm4"
printf "include([[${layouts_dir}/draft.m4]])dnl\n" >> "$tmpm4"
m4 "$tmpm4" 2>/dev/null > "$file"
rm -f "$tmpm4"
echo "$file"
