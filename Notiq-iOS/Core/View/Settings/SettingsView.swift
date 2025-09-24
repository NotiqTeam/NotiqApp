import SwiftUI
import CoreData

struct SettingsView: View {
    
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showFirstWarning = false
    @State private var showSecondWarning = false
    @EnvironmentObject var faceIDManager: FaceIDManager
    
    
    @Environment(\.dismiss) private var dismiss
    
    // Inject NotesViewModel to refresh notes after reset
    @EnvironmentObject var notesVM: NotesViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance").fontWeight(.bold)) {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                // Inside SettingsView
                Section(header: Text("Security").fontWeight(.bold)) {
                    Toggle(isOn: $faceIDManager.faceIDEnabled) {
                        Label("Enable Face ID", systemImage: "faceid")
                    }
                }
                
                
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
                        Button("Delete", role: .destructive) {
                            resetAppData()
                        }
                    } message: {
                        Text("Are you absolutely sure you want to reset all app data?")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func resetAppData() {
        // 1️⃣ Reset UserDefaults
        darkModeEnabled = false
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // 2️⃣ Delete all notes safely with batch delete
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NoteEntity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDelete)
            try context.save()
        } catch {
            print("Error deleting all notes: \(error.localizedDescription)")
        }
        
        // 3️⃣ Refresh NotesView
        notesVM.refreshNotes()
        notesVM.selectedNote = nil
        
        // 4️⃣ Close settings sheet
        dismiss()
    }
}
