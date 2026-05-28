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

if mode == "drag" {
    let lockFile = "/tmp/cleanclick_drag.lock"
    if FileManager.default.fileExists(atPath: lockFile) {
        // second press — release
        postEvent(.leftMouseUp, .left)
        try? FileManager.default.removeItem(atPath: lockFile)
    } else {
        // first press — hold down
        postEvent(.leftMouseDown, .left)
        FileManager.default.createFile(atPath: lockFile, contents: nil, attributes: nil)
    }
} else {
    let rightClick = mode == "right"
    let downType: CGEventType = rightClick ? .rightMouseDown : .leftMouseDown
    let upType: CGEventType   = rightClick ? .rightMouseUp   : .leftMouseUp
    let button: CGMouseButton = rightClick ? .right          : .left

    postEvent(downType, button)
    Thread.sleep(forTimeInterval: 0.01)
    postEvent(upType, button)
}
