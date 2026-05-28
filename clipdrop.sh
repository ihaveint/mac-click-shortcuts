#!/bin/bash
STACK=~/.clipboard_stack
if [ ! -s "$STACK" ]; then exit 0; fi
sed -i '' '$d' "$STACK"
count=$(wc -l < "$STACK" | tr -d ' ')
/opt/homebrew/bin/clipnotify drop "$count" &
