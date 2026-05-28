#!/bin/bash
STACK=~/.clipboard_stack
pbpaste | base64 >> "$STACK"
count=$(wc -l < "$STACK" | tr -d ' ')
/opt/homebrew/bin/clipnotify push "$count" &
