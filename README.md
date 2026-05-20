# mac-click-shortcuts

Keyboard shortcuts for mouse clicks on macOS. Runs silently in the background, auto-starts on login.

| Shortcut | Action |
|---|---|
| `cmd+shift+d` | Left click at cursor |
| `cmd+shift+e` | Right click at cursor |

## How it works

- **skhd** — global hotkey daemon, runs as a launchd agent
- **cleanclick** — small compiled Swift binary that posts a `CGEvent` mouse click with modifier flags explicitly cleared (prevents `cmd+shift` bleeding into the click)

## Install

```bash
git clone https://github.com/YOUR_USERNAME/mac-click-shortcuts
cd mac-click-shortcuts
chmod +x install.sh
./install.sh
```

Then grant Accessibility permission (script will tell you exactly where).

## Accessibility permission

macOS requires Accessibility access for both global hotkey interception and synthetic mouse events. One-time setup:

1. System Settings → Privacy & Security → Accessibility
2. Add `/opt/homebrew/Cellar/skhd/<version>/bin/skhd` (use the real path, not the symlink)
3. Toggle ON
4. Run `skhd --stop-service && skhd --start-service`

## Safari conflict

`cmd+shift+d` conflicts with Safari's "Add to Reading List". Fix:

1. System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts
2. Click `+` → App: Safari
3. Menu Title: `Add to Reading List` (exact)
4. New shortcut: anything unused (e.g. `cmd+ctrl+shift+\`)

## Changing shortcuts

Edit `~/.skhdrc` and run `skhd --reload`.

## Commands

```bash
skhd --start-service   # start + register as login item
skhd --stop-service    # stop
skhd --reload          # reload config without restart
pgrep skhd             # verify running
```
