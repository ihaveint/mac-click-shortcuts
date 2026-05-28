#!/bin/bash
STACK=~/.clipboard_stack
if [ ! -s "$STACK" ]; then exit 0; fi
> "$STACK"
/opt/homebrew/bin/clipnotify drop "0" &
