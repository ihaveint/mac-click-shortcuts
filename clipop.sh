#!/bin/bash
STACK=~/.clipboard_stack
if [ ! -s "$STACK" ]; then
    exit 0
fi
tail -1 "$STACK" | base64 --decode | pbcopy
sed -i '' '$d' "$STACK"
/opt/homebrew/bin/cleanclick paste
