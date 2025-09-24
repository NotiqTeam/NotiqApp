import AppKit
import SwiftUI

class AboutWindow: NSWindowController {

    convenience init() {
        // Read Dark Mode BEFORE calling self.init
        let isDarkMode = UserDefaults.standard.bool(forKey: "settings.general.darkMode")
        
        let window = Self.makeWindow()
        window.backgroundColor = NSColor.controlBackgroundColor
        window.appearance = NSAppearance(named: isDarkMode ? .darkAqua : .aqua)
        
        self.init(window: window) // ✅ call self.init after preparing everything

        let contentView = makeAboutView(isDarkMode: isDarkMode)
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        window.title = "About Notiq"
        window.contentView = NSHostingView(rootView: contentView)
        window.alwaysOnTop = true
    }

    private static func makeWindow() -> NSWindow {
        let contentRect = NSRect(x: 0, y: 0, width: 500, height: 260)
        let styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .fullSizeContentView
        ]
        return NSWindow(contentRect: contentRect,
                        styleMask: styleMask,
                        backing: .buffered,
                        defer: false)
    }

    private func makeAboutView(isDarkMode: Bool) -> some View {
        AboutView(
            icon: NSApp.applicationIconImage ?? NSImage(),
            name: Bundle.main.name,
            version: Bundle.main.version,
            build: Bundle.main.buildVersion,
            copyright: Bundle.main.copyright,
            developerName: "Kilian Balaguer")
            .frame(width: 500, height: 260)
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    static func show() {
        AboutWindow().window?.makeKeyAndOrderFront(nil)
    }
}
