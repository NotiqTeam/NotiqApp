import SwiftUI
import CoreData
import SwiftNEW

struct SettingsView: View {
    
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("appLockTimeout") private var appLockTimeout: Int = 0
    @State private var showFirstWarning = false
    @State private var showSecondWarning = false
    @EnvironmentObject var faceIDManager: FaceIDManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notesVM: NotesViewModel
    
    @State private var accentColor: Color = .blue
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Appearance
                Section(header: Text("Appearance").fontWeight(.bold)) {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    ColorPicker("Accent Color", selection: $accentColor)
                        .onChange(of: accentColor) { newValue in
                            saveAccentColor(newValue)
                        }
                }
                
                // MARK: Security
                Section(header: Text("Security").fontWeight(.bold)) {
                    Toggle(isOn: $faceIDManager.faceIDEnabled) {
                        Label("Enable Face ID", systemImage: "faceid")
                    }
                    Picker("App Lock Timeout", selection: $appLockTimeout) {
                        Text("Immediately").tag(0)
                        Text("1 Minute").tag(1)
                        Text("5 Minutes").tag(5)
                        Text("10 Minutes").tag(10)
                    }
                }
                
                // MARK: Data Management
                Section(header: Text("Data").fontWeight(.bold)) {
                    Button(role: .destructive) { showFirstWarning = true } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .alert("Are you sure?", isPresented: $showFirstWarning) {
                        Button("Cancel", role: .cancel) { }
                        Button("Continue", role: .destructive) { showSecondWarning = true }
                    } message: {
                        Text("This action cannot be undone. All saved settings and data will be deleted.")
                    }
                    .alert("Final Warning", isPresented: $showSecondWarning) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) { resetAppData() }
                    } message: {
                        Text("Are you absolutely sure you want to reset all app data?")
                    }
                    
                    Button {
                        // TODO: Implement Export Notes
                    } label: {
                        Label("Export Notes", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // TODO: Implement Restore Notes
                    } label: {
                        Label("Restore Notes", systemImage: "square.and.arrow.down")
                    }
                }
                
                // MARK: Feedback / Support
                Section(header: Text("Feedback & Support").fontWeight(.bold)) {
                    Link(destination: URL(string: "mailto:support@yourapp.com")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://yourapp.website")!) {
                        Label("Visit Website", systemImage: "globe")
                    }
                    Button {
                        // TODO: Trigger StoreKit rating
                    } label: {
                        Label("Rate the App", systemImage: "star.fill")
                    }
                }
                
                // MARK: About
                Section(header: Text("About").fontWeight(.bold)) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    Link("Privacy Policy", destination: URL(string: "https://yourapp.website/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://yourapp.website/terms")!)
                }
            }
            .navigationTitle("Settings")
            .onAppear { loadAccentColor() }
        }
    }
    
    // MARK: - Helpers
    
    private func resetAppData() {
        // Reset general settings
        darkModeEnabled = false
        appLockTimeout = 0

        // Clear UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        // Reset Notes in CoreData
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NoteEntity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDelete)
            try context.save()
        } catch {
            print("Error deleting all notes: \(error.localizedDescription)")
        }

        // Reset SwiftNEW version tracking
        SwiftNEW(
            show: .constant(false),
            color: .constant(.blue),
            size: .constant("normal"),
            label: .constant("What's New"),
            labelImage: .constant("sparkles"),
            history: .constant(true),
            mesh: .constant(true),
            glass: .constant(true)
        ).resetVersionTracking()

        // Refresh Notes and dismiss
        notesVM.refreshNotes()
        notesVM.selectedNote = nil
        dismiss()
    }

    
    // Save Color as Hex String
    private func saveAccentColor(_ color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let hexString = String(format: "%02X%02X%02X",
                               Int(red * 255),
                               Int(green * 255),
                               Int(blue * 255))
        UserDefaults.standard.set(hexString, forKey: "accentColorHex")
    }
    
    // Load Color from Hex String
    private func loadAccentColor() {
        let hexString = UserDefaults.standard.string(forKey: "accentColorHex") ?? "0000FF"
        let r = Double(Int(hexString.prefix(2), radix: 16) ?? 0)
        let g = Double(Int(hexString.dropFirst(2).prefix(2), radix: 16) ?? 0)
        let b = Double(Int(hexString.dropFirst(4).prefix(2), radix: 16) ?? 0)
        accentColor = Color(red: r/255, green: g/255, blue: b/255)
    }
}
