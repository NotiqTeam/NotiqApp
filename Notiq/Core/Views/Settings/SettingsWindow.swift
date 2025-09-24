import SwiftUI

struct SettingsWindow: View {
    
    private enum Tabs: Hashable {
        case general
        case data
    }
    
    // Read dark mode from UserDefaults
    @AppStorage("settings.general.darkMode") private var darkMode: Bool = false
    
    var body: some View {
        TabView {
            
            // General Tab
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            // Data Tab
            ResetDataSettingsTab()
                .tabItem {
                    Label("Reset Data", systemImage: "internaldrive")
                }
                .tag(Tabs.data)
        }
        .padding(20)
        .frame(width: 450, height: 450)
        .preferredColorScheme(darkMode ? .dark : .light) // apply dark mode
    }
    
    /// Show settings programmatically
    static func show() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
}

struct SettingsWindow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWindow()
    }
}
