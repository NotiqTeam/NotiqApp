import Cocoa
import SwiftUI

class AttributionsWindow: NSWindowController {
    
    convenience init() {
        // Read dark mode preference before init
        let isDarkMode = UserDefaults.standard.bool(forKey: "settings.general.darkMode")
        
        let window = Self.makeWindow()
        window.backgroundColor = NSColor.controlBackgroundColor
        window.appearance = NSAppearance(named: isDarkMode ? .darkAqua : .aqua)
        
        self.init(window: window)
        
        let contentView = AttributionsView()
            .frame(minWidth: 500, minHeight: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .preferredColorScheme(isDarkMode ? .dark : .light) // apply SwiftUI dark mode
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        window.title = "Attributions"
        window.contentView = NSHostingView(rootView: contentView)
        window.alwaysOnTop = true
    }
    
    private static func makeWindow() -> NSWindow {
        let contentRect = NSRect(x: 0, y: 0, width: 500, height: 300)
        let styleMask: NSWindow.StyleMask = [
            .titled,
            .miniaturizable,
            .resizable,
            .closable,
            .fullSizeContentView
        ]
        return NSWindow(contentRect: contentRect,
                        styleMask: styleMask,
                        backing: .buffered,
                        defer: false)
    }
    
    static func show() {
        AttributionsWindow().window?.makeKeyAndOrderFront(nil)
    }
}
