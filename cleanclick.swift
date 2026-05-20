import CoreGraphics
import AppKit

let args = CommandLine.arguments
let rightClick = args.count > 1 && args[1] == "right"

let pos = NSEvent.mouseLocation
let screenHeight = NSScreen.main?.frame.height ?? 0
let cgPos = CGPoint(x: pos.x, y: screenHeight - pos.y)

let downType: CGEventType = rightClick ? .rightMouseDown : .leftMouseDown
let upType: CGEventType = rightClick ? .rightMouseUp : .leftMouseUp
let button: CGMouseButton = rightClick ? .right : .left

let mouseDown = CGEvent(mouseEventSource: nil, mouseType: downType, mouseCursorPosition: cgPos, mouseButton: button)!
let mouseUp   = CGEvent(mouseEventSource: nil, mouseType: upType,   mouseCursorPosition: cgPos, mouseButton: button)!

mouseDown.flags = []
mouseUp.flags   = []

mouseDown.post(tap: .cghidEventTap)
Thread.sleep(forTimeInterval: 0.01)
mouseUp.post(tap: .cghidEventTap)
