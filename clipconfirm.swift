import AppKit

let args = CommandLine.arguments
let question = args.count > 1 ? args[1] : "Are you sure?"

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let screen = NSScreen.main!.visibleFrame
let width: CGFloat = 300
let height: CGFloat = 64
let margin: CGFloat = 90
let frame = NSRect(
    x: screen.minX + margin,
    y: screen.minY + margin,
    width: width,
    height: height
)

let window = NSWindow(
    contentRect: frame,
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)
window.isOpaque = false
window.backgroundColor = .clear
window.level = .screenSaver
window.collectionBehavior = [.canJoinAllSpaces, .stationary]
window.makeKeyAndOrderFront(nil)

let box = NSBox(frame: NSRect(x: 0, y: 0, width: width, height: height))
box.boxType = .custom
box.fillColor = NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 0.95)
box.borderWidth = 0
box.cornerRadius = 12

let questionLabel = NSTextField(frame: NSRect(x: 12, y: 34, width: width - 24, height: 18))
questionLabel.stringValue = question
questionLabel.alignment = .center
questionLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
questionLabel.textColor = .white
questionLabel.isBezeled = false; questionLabel.isEditable = false; questionLabel.drawsBackground = false

let hintLabel = NSTextField(frame: NSRect(x: 12, y: 10, width: width - 24, height: 16))
hintLabel.stringValue = "Y  confirm   ·   N / esc  cancel"
hintLabel.alignment = .center
hintLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
hintLabel.textColor = NSColor.white.withAlphaComponent(0.5)
hintLabel.isBezeled = false; hintLabel.isEditable = false; hintLabel.drawsBackground = false

box.addSubview(questionLabel)
box.addSubview(hintLabel)
window.contentView?.addSubview(box)
window.alphaValue = 0
window.orderFront(nil)

NSAnimationContext.runAnimationGroup { ctx in
    ctx.duration = 0.15
    window.animator().alphaValue = 1
}

func confirm() {
    NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = 0.1
        window.animator().alphaValue = 0
    }, completionHandler: {
        exit(0)
    })
}

func cancel() {
    NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = 0.1
        window.animator().alphaValue = 0
    }, completionHandler: {
        exit(1)
    })
}

// Auto-cancel after 8 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 8) { cancel() }

// Key monitor
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    switch event.keyCode {
    case 16: // y
        confirm()
    case 45: // n
        cancel()
    case 53: // escape
        cancel()
    case 36, 76: // enter/return — confirm
        confirm()
    default: break
    }
}

NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    switch event.keyCode {
    case 16: confirm()
    case 45: cancel()
    case 53: cancel()
    case 36, 76: confirm()
    default: break
    }
    return event
}

app.run()
