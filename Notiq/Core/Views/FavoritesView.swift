import SwiftUI

// MARK: - FavoritesView
struct FavoritesView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Binding var searchText: String
    @Binding var selectedNote: NoteEntity?
    
    private var filteredNotes: [NoteEntity] {
        vm.notes.filter {
            $0.isFavorite && (searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false))
        }
    }
    
    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
