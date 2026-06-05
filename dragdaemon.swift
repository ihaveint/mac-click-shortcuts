import CoreGraphics
import AppKit
import Foundation

var isDragging = false
let downFile = "/tmp/cleanclick_dragdown"
let upFile   = "/tmp/cleanclick_dragup"
let fm = FileManager.default

func cgPos() -> CGPoint {
    let p = NSEvent.mouseLocation
    let h = NSScreen.screens.first?.frame.height ?? 0
    return CGPoint(x: p.x, y: h - p.y)
}

let syntheticSource = CGEventSource(stateID: .combinedSessionState)

func post(_ type: CGEventType, _ button: CGMouseButton, _ pos: CGPoint) {
    guard let e = CGEvent(mouseEventSource: syntheticSource, mouseType: type,
                          mouseCursorPosition: pos, mouseButton: button) else { return }
    e.flags = []
    e.post(tap: .cgSessionEventTap)
}

// Event tap: convert mouseMoved → leftMouseDragged while drag is active
//            stop drag on physical leftMouseDown
let mask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue)
                      | (1 << CGEventType.leftMouseDown.rawValue)

guard let tap = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: mask,
    callback: { _, type, event, _ -> Unmanaged<CGEvent>? in
        // ignore events we posted ourselves
        if event.getIntegerValueField(.eventSourceUnixProcessID) == Int64(ProcessInfo.processInfo.processIdentifier) {
            return Unmanaged.passRetained(event)
        }
        if type == .leftMouseDown && isDragging {
            isDragging = false
            // let the click pass through naturally — no mouseUp needed,
            // the physical click itself serves as the up
        }
        if type == .mouseMoved && isDragging {
            guard let drag = CGEvent(mouseEventSource: nil,
                                     mouseType: .leftMouseDragged,
                                     mouseCursorPosition: event.location,
                                     mouseButton: .left) else {
                return Unmanaged.passRetained(event)
            }
            drag.flags = []
            return Unmanaged.passRetained(drag)
        }
        return Unmanaged.passRetained(event)
    },
    userInfo: nil
) else {
    fputs("dragdaemon: failed to create event tap (no Accessibility permission?)\n", stderr)
    exit(1)
}

let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

// Poll trigger files every 30ms; also watchdog the event tap
Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
    // If macOS disabled our tap (e.g. permission revoked), exit so launchd restarts us
    if !CGEvent.tapIsEnabled(tap: tap) {
        fputs("dragdaemon: event tap disabled — exiting for restart\n", stderr)
        exit(2)
    }
    if fm.fileExists(atPath: downFile) {
        try? fm.removeItem(atPath: downFile)
        guard !isDragging else { return }
        isDragging = true
        post(.leftMouseDown, .left, cgPos())
    }
    if fm.fileExists(atPath: upFile) {
        try? fm.removeItem(atPath: upFile)
        guard isDragging else { return }
        isDragging = false
        post(.leftMouseUp, .left, cgPos())
    }
}

RunLoop.current.run()
