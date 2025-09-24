import SwiftUI

// MARK: - AllNotesView
struct AllNotesView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Binding var isGridView: Bool
    @Binding var searchText: String
    @Binding var selectedNote: NoteEntity?
    
    private var filteredNotes: [NoteEntity] {
        vm.notes.filter { searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }
    
    var body: some View {
        Group {
            if isGridView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
                        ForEach(filteredNotes) { note in
                            NoteCardViewMac(note: note)
                                .onTapGesture { selectedNote = note }
                                .contextMenu { macContextMenu(for: note) }
                        }
                    }
                    .padding()
                }
            } else {
                List(selection: $selectedNote) {
                    ForEach(filteredNotes) { note in
                        NoteRowWithActions(note: note)
                            .tag(note)
                            .onTapGesture { selectedNote = note }
                    }
                }
                .listStyle(.inset) // macOS Notes-like
                                .scrollContentBackground(.hidden) // 👈 hide transparent bg
                                .background(Color(NSColor.windowBackgroundColor)) // 👈 add visible bg
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func macContextMenu(for note: NoteEntity) -> some View {
        Button("Delete") { vm.deleteNote(note) }
        Button("Duplicate") { _ = vm.createNote() }
        Button("Pin") { vm.togglePin(note) }
    }
}

struct NoteRowWithActions: View {
    @EnvironmentObject var vm: NotesViewModel
    let note: NoteEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title ?? "Untitled")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // ✅ Pin icon
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.yellow)
                    }
                }

                Text(note.content ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if let date = note.timestamp {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .leading) {
                    // Pin
                    Button(action: { vm.togglePin(note) }) {
                        Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.fill" : "pin")
                    }
                    .tint(.yellow)
                    
                    // Favorite
                    Button(action: { vm.toggleFavorite(note) }) {
                        Label(note.isFavorite ? "Unfavorite" : "Favorite", systemImage: note.isFavorite ? "star.fill" : "star")
                    }
                    .tint(.orange)
                }
        .swipeActions(edge: .trailing) {
            // Delete
            Button(role: .destructive, action: { vm.deleteNote(note) }) {
                Label("Delete", systemImage: "trash")
            }

            // Share
            Button(action: { share(note) }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
    }

    // MARK: - Share function
    private func share(_ note: NoteEntity) {
        #if os(macOS)
        let picker = NSSharingServicePicker(items: [note.title ?? "Untitled", note.content ?? ""])
        if let window = NSApplication.shared.keyWindow {
            picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
        }
        #elseif os(iOS)
        let items: [Any] = [note.title ?? "Untitled", note.content ?? ""]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(vc, animated: true)
        }
        #endif
    }
}
