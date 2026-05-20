#!/bin/bash
set -e

echo "==> Installing skhd..."
brew install koekeishiya/formulae/skhd

echo "==> Compiling cleanclick..."
swiftc "$(dirname "$0")/cleanclick.swift" -o /opt/homebrew/bin/cleanclick

echo "==> Writing ~/.skhdrc..."
cp "$(dirname "$0")/skhdrc" ~/.skhdrc

echo "==> Starting skhd service..."
skhd --start-service

echo ""
echo "==> Done. One manual step required:"
echo ""
echo "    System Settings → Privacy & Security → Accessibility"
echo "    Add /opt/homebrew/Cellar/skhd/$(skhd --version 2>/dev/null | grep -o '[0-9.]*' | head -1)/bin/skhd and toggle ON"
echo "    Then run: skhd --stop-service && skhd --start-service"
echo ""
echo "Shortcuts:"
echo "  cmd+shift+d  →  left click"
echo "  cmd+shift+e  →  right click"
echo ""
echo "Note: if cmd+shift+d conflicts in Safari, go to:"
echo "  System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts"
echo "  Add Safari shortcut: 'Add to Reading List' → remap to anything unused"
