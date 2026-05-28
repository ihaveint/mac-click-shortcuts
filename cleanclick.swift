import CoreGraphics
import AppKit

let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "left"

let pos = NSEvent.mouseLocation
let screenHeight = NSScreen.main?.frame.height ?? 0
let cgPos = CGPoint(x: pos.x, y: screenHeight - pos.y)

func postMouse(_ type: CGEventType, _ button: CGMouseButton) {
    let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: cgPos, mouseButton: button)!
    event.flags = []
    event.post(tap: .cghidEventTap)
}

func postKeystroke(keycode: CGKeyCode, flags: CGEventFlags = []) {
    let src = CGEventSource(stateID: .hidSystemState)
    let down = CGEvent(keyboardEventSource: src, virtualKey: keycode, keyDown: true)!
    let up   = CGEvent(keyboardEventSource: src, virtualKey: keycode, keyDown: false)!
    down.flags = flags
    up.flags   = flags
    down.post(tap: .cghidEventTap)
    Thread.sleep(forTimeInterval: 0.01)
    up.post(tap: .cghidEventTap)
}

switch mode {
case "right":
    postMouse(.rightMouseDown, .right)
    Thread.sleep(forTimeInterval: 0.01)
    postMouse(.rightMouseUp, .right)
case "dragdown":
    postMouse(.leftMouseDown, .left)
case "dragup":
    postMouse(.leftMouseUp, .left)
case "paste":
    // cmd+v  (keycode 9 = v)
    postKeystroke(keycode: 9, flags: .maskCommand)
default: // "left"
    postMouse(.leftMouseDown, .left)
    Thread.sleep(forTimeInterval: 0.01)
    postMouse(.leftMouseUp, .left)
}
