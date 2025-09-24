import SwiftUI

struct GeneralSettingsTab: View {
    
    @AppStorage("settings.general.name") private var name: String = ""
    @AppStorage("settings.general.darkMode") private var darkMode: Bool = false
    @AppStorage("settings.general.accentColor") private var accentColor: String = "Blue"
    @AppStorage("settings.general.showNotifications") private var showNotifications: Bool = true
    @AppStorage("settings.general.autosave") private var autosave: Bool = true
    @AppStorage("settings.general.autosaveInterval") private var autosaveInterval: Int = 5
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // User Section
                VStack(spacing: 10) {
                    Text("User").font(.headline)
                    TextField("Name:", text: $name)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                    Text("This is your display name in Notiq.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Appearance Section
                VStack(spacing: 10) {
                    Text("Appearance").font(.headline)
                    Toggle("Dark Mode", isOn: $darkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    Picker("Accent Color", selection: $accentColor) {
                        Text("Blue").tag("Blue")
                        Text("Red").tag("Red")
                        Text("Green").tag("Green")
                        Text("Orange").tag("Orange")
                        Text("Purple").tag("Purple")
                    }
                    .pickerStyle(.menu)
                }
                
                // Notifications Section
                VStack(spacing: 10) {
                    Text("Notifications").font(.headline)
                    Toggle("Show Notifications", isOn: $showNotifications)
                }
                
                // Autosave Section
                VStack(spacing: 10) {
                    Text("Autosave").font(.headline)
                    Toggle("Enable Autosave", isOn: $autosave)
                    Stepper(value: $autosaveInterval, in: 1...60, step: 1) {
                        Text("Autosave Interval: \(autosaveInterval) min")
                    }
                }
                
                // Apply Button
                Button("Apply Settings") {
                    print("Settings applied!")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(8)
                
            }
            .frame(maxWidth: 400) // limit width for centering
            .padding()
            .frame(maxWidth: .infinity) // center horizontally
        }
        .frame(minWidth: 500, minHeight: 450)
    }
}

struct GeneralSettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsTab()
    }
}
