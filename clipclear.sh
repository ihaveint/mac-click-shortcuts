#!/bin/bash
STACK=~/.clipboard_stack
if [ ! -s "$STACK" ]; then exit 0; fi
/opt/homebrew/bin/clipconfirm "Clear clipboard stack?" || exit 0
> "$STACK"
/opt/homebrew/bin/clipnotify drop "0" &
