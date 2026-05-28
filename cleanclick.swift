import CoreGraphics
import AppKit

let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "left"

let pos = NSEvent.mouseLocation
let screenHeight = NSScreen.main?.frame.height ?? 0
let cgPos = CGPoint(x: pos.x, y: screenHeight - pos.y)

func postEvent(_ type: CGEventType, _ button: CGMouseButton) {
    let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: cgPos, mouseButton: button)!
    event.flags = []
    event.post(tap: .cghidEventTap)
}

switch mode {
case "right":
    postEvent(.rightMouseDown, .right)
    Thread.sleep(forTimeInterval: 0.01)
    postEvent(.rightMouseUp, .right)
case "dragdown":
    postEvent(.leftMouseDown, .left)
case "dragup":
    postEvent(.leftMouseUp, .left)
default: // "left"
    postEvent(.leftMouseDown, .left)
    Thread.sleep(forTimeInterval: 0.01)
    postEvent(.leftMouseUp, .left)
}
