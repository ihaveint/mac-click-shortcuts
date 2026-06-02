# mac-click-shortcuts

Keyboard shortcuts for mouse clicks, drag, and clipboard stack on macOS. Runs silently in the background, auto-starts on login.

| Shortcut | Action |
|---|---|
| `cmd+shift+d` | Left click at cursor |
| `cmd+shift+e` | Right click at cursor |
| `cmd+shift+s` | Start drag (hold mouseDown) |
| `cmd+shift+a` | End drag (release mouseUp) |
| `cmd+shift+c` | Push current clipboard to stack |
| `cmd+option+v` | Pop stack → paste |
| `cmd+shift+u` | Drop top stack item (no paste) |

## How it works

- **skhd** — global hotkey daemon, runs as a launchd agent
- **cleanclick** — compiled Swift binary that posts `CGEvent` mouse clicks with modifier flags explicitly cleared (prevents `cmd+shift` bleeding into the click). Also handles `paste` mode (synthetic cmd+v) to avoid Accessibility chain break through bash.
- **dragdaemon** — persistent Swift daemon that:
  - Intercepts all `mouseMoved` events via `CGEventTap`
  - Converts them to `leftMouseDragged` while drag is active
  - Triggered by skhd via `/tmp` flag files (`/tmp/cleanclick_dragdown`, `/tmp/cleanclick_dragup`)
  - Runs as a LaunchAgent, auto-starts on login, restarts on crash
- **clipboard stack** — LIFO stack stored in `~/.clipboard_stack` (base64-encoded entries, one per line)
- **clipnotify** — compiled Swift binary that shows a borderless animated overlay in the bottom-left corner on each push (blue), pop (green), or drop (red), displaying item count

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

1. **Stop the daemon first** (prevents crash-loop interfering with permission grant):
```bash
launchctl unload ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
```

2. System Settings → Privacy & Security → Accessibility
3. Remove any existing `dragdaemon` or `dragdaemon_bin` entries
4. Click `+`, navigate to `/opt/homebrew/bin/dragdaemon_bin`, Open, toggle **ON**
5. Also add `/opt/homebrew/Cellar/skhd/<version>/bin/skhd` if not present
6. Restart everything:
```bash
skhd --stop-service && skhd --start-service
launchctl load ~/Library/LaunchAgents/com.cleanclick.dragdaemon.plist
```

### Surviving recompiles (codesigning)

The LaunchAgent runs `dragdaemon_bin` directly. When signed with a stable Apple Developer certificate, TCC tracks by team identity instead of binary hash — permission survives recompiles.

Sign after install or recompile:
```bash
codesign --force --sign "Apple Development: <your-apple-id> (<team-id>)" /opt/homebrew/bin/dragdaemon_bin
```

To find your signing identity:
```bash
security find-identity -v -p codesigning
```

After signing, re-grant Accessibility once (steps above). Subsequent recompiles only need the `codesign` command — no re-granting.

## Clipboard stack

Push/pop workflow:
1. Select text → `cmd+c` (normal copy)
2. `cmd+shift+c` → pushes current clipboard onto stack (blue overlay shows count)
3. Repeat to stack more items
4. `cmd+option+v` → pops top item, pastes it (green overlay shows remaining count)

Stack is LIFO — last pushed is first popped.

`cmd+shift+u` drops the top item silently (red overlay) without touching the clipboard or pasting — useful for discarding a bad push.

```bash
cat ~/.clipboard_stack    # inspect stack (base64 encoded)
> ~/.clipboard_stack      # clear stack
```

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

# clipboard stack
cat ~/.clipboard_stack      # inspect stack
> ~/.clipboard_stack        # clear stack
```
