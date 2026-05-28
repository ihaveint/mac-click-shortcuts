#!/bin/bash
# Push current clipboard onto stack
pbpaste | base64 >> ~/.clipboard_stack
