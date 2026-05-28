import AppKit

let args = CommandLine.arguments
let type = args.count > 1 ? args[1] : "push"
let extra = args.count > 2 ? args[2] : ""

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let label: String
let color: NSColor
switch type {
case "pop":
    label = extra.isEmpty ? "📋 Popped" : "📋 Popped  ·  \(extra) left"
    color = NSColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 0.92)
case "drop":
    label = extra.isEmpty ? "🗑 Dropped" : "🗑 Dropped  ·  \(extra) left"
    color = NSColor(red: 0.4, green: 0.15, blue: 0.1, alpha: 0.92)
default: // push
    label = extra.isEmpty ? "📋 Pushed" : "📋 Pushed  ·  \(extra) in stack"
    color = NSColor(red: 0.1, green: 0.2, blue: 0.45, alpha: 0.92)
}

let screen = NSScreen.main!.visibleFrame
let width: CGFloat = 240
let height: CGFloat = 48
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
window.ignoresMouseEvents = true
window.collectionBehavior = [.canJoinAllSpaces, .stationary]

let box = NSBox(frame: NSRect(x: 0, y: 0, width: width, height: height))
box.boxType = .custom
box.fillColor = color
box.borderWidth = 0
box.cornerRadius = 10

let textHeight: CGFloat = 20
let text = NSTextField(frame: NSRect(x: 8, y: (height - textHeight) / 2, width: width - 16, height: textHeight))
text.stringValue = label
text.alignment = .center
text.font = NSFont.systemFont(ofSize: 14, weight: .medium)
text.textColor = .white
text.isBezeled = false
text.isEditable = false
text.drawsBackground = false

box.addSubview(text)
window.contentView?.addSubview(box)
window.alphaValue = 0
window.orderFront(nil)

// Fade in
NSAnimationContext.runAnimationGroup({ ctx in
    ctx.duration = 0.2
    window.animator().alphaValue = 1
}, completionHandler: {
    // Hold, then fade out
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            window.animator().alphaValue = 0
        }, completionHandler: {
            app.terminate(nil)
        })
    }
})

app.run()
