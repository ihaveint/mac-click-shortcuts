#!/bin/bash
set -e

echo "==> Installing skhd..."
brew install koekeishiya/formulae/skhd

echo "==> Compiling cleanclick..."
swiftc "$(dirname "$0")/cleanclick.swift" -o /opt/homebrew/bin/cleanclick

echo "==> Compiling clipnotify..."
swiftc "$(dirname "$0")/clipnotify.swift" -o /opt/homebrew/bin/clipnotify

echo "==> Compiling clipconfirm..."
swiftc "$(dirname "$0")/clipconfirm.swift" -o /opt/homebrew/bin/clipconfirm

echo "==> Compiling dragdaemon..."
swiftc "$(dirname "$0")/dragdaemon.swift" -o /opt/homebrew/bin/dragdaemon_bin

# Codesign dragdaemon_bin so TCC permission survives recompiles
SIGN_ID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Apple Development" | head -1 | sed 's/.*"\(.*\)"/\1/')
if [ -n "$SIGN_ID" ]; then
    echo "==> Codesigning dragdaemon_bin with: $SIGN_ID"
    codesign --force --sign "$SIGN_ID" /opt/homebrew/bin/dragdaemon_bin
else
    echo "==> Warning: no Apple Development cert found — skipping codesign"
    echo "    Accessibility permission will reset on recompile without codesigning"
fi

echo "==> Installing dragdaemon LaunchAgent..."
cp "$(dirname "$0")/com.cleanclick.dragdaemon.plist" ~/Library/LaunchAgents/ 2>/dev/null || true

echo "==> Writing ~/.skhdrc..."
cp "$(dirname "$0")/skhdrc" ~/.skhdrc

echo "==> Starting skhd service..."
skhd --start-service

echo ""
echo "==> Done. Manual steps required:"
echo ""
echo "1. STOP the daemon before granting Accessibility (prevents crash-loop):"
echo "   launchctl unload ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist"
echo ""
echo "2. System Settings → Privacy & Security → Accessibility"
echo "   - Add /opt/homebrew/bin/dragdaemon_bin → toggle ON"
echo "   - Add /opt/homebrew/Cellar/skhd/$(skhd --version 2>/dev/null | grep -o '[0-9.]*' | head -1)/bin/skhd → toggle ON"
echo ""
echo "3. Restart:"
echo "   skhd --stop-service && skhd --start-service"
echo "   launchctl load ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist"
echo ""
echo "Shortcuts:"
echo "  cmd+shift+d  →  left click"
echo "  cmd+shift+e  →  right click"
echo "  cmd+shift+s  →  start drag"
echo "  cmd+shift+a  →  end drag"
echo "  cmd+shift+c  →  push clipboard to stack"
echo "  cmd+option+v →  pop stack and paste"
echo "  cmd+shift+u  →  drop top stack item"
echo "  cmd+shift+x  →  clear clipboard stack (with confirmation)"
echo ""
echo "Note: if cmd+shift+d conflicts in Safari, go to:"
echo "  System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts"
echo "  Add Safari shortcut: 'Add to Reading List' → remap to anything unused"
