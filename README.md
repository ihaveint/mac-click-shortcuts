# mac-click-shortcuts

Keyboard shortcuts for mouse clicks and drag on macOS. Runs silently in the background, auto-starts on login.

| Shortcut | Action |
|---|---|
| `cmd+shift+d` | Left click at cursor |
| `cmd+shift+e` | Right click at cursor |
| `cmd+shift+s` | Start drag (hold mouseDown) |
| `cmd+shift+a` | End drag (release mouseUp) |

## How it works

- **skhd** — global hotkey daemon, runs as a launchd agent
- **cleanclick** — compiled Swift binary that posts `CGEvent` mouse clicks with modifier flags explicitly cleared (prevents `cmd+shift` bleeding into the click)
- **dragdaemon** — persistent Swift daemon that:
  - Intercepts all `mouseMoved` events via `CGEventTap`
  - Converts them to `leftMouseDragged` while drag is active
  - Triggered by skhd via `/tmp` flag files (`/tmp/cleanclick_dragdown`, `/tmp/cleanclick_dragup`)
  - Runs as a LaunchAgent, auto-starts on login, restarts on crash

## Install

```bash
git clone https://github.com/ihaveint/mac-click-shortcuts
cd mac-click-shortcuts
chmod +x install.sh
./install.sh
```

Then grant Accessibility permission (script will tell you exactly where).

## Accessibility permission

macOS requires Accessibility access for global hotkey interception, synthetic mouse events, and event tap. One-time setup for each binary:

1. System Settings → Privacy & Security → Accessibility
2. Add each of these (use `+` → Cmd+Shift+G to paste path):
   - `/opt/homebrew/Cellar/skhd/<version>/bin/skhd`
   - `/opt/homebrew/bin/dragdaemon`
3. Toggle both ON
4. Run:
```bash
skhd --stop-service && skhd --start-service
launchctl unload ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
launchctl load ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
```

> **Note:** if you recompile either binary, its hash changes and Accessibility permission resets — re-grant and restart.

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
# skhd
skhd --start-service        # start + register as login item
skhd --stop-service         # stop
skhd --reload               # reload config without restart
pgrep skhd                  # verify running

# dragdaemon
pgrep dragdaemon            # verify running
cat /tmp/dragdaemon.err.log # check errors
launchctl unload ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
launchctl load ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
```
