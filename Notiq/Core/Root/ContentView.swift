import SwiftUI
internal import CoreData
import WhatsNewKit

// MARK: - ContentView
struct ContentView: View {
    @State private var selection: SidebarItem? = .allNotes
    @State private var selectedNote: NoteEntity? = nil
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("isCardMode") private var isCardMode: Bool = true
    
    @State private var sidebarWidth: CGFloat = UserDefaults.standard.double(forKey: "sidebarWidth") > 0
        ? CGFloat(UserDefaults.standard.double(forKey: "sidebarWidth"))
        : 220
    @State private var searchText = ""
    
    @EnvironmentObject var vm: NotesViewModel
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 180, ideal: sidebarWidth, max: 300)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.size.width) { newWidth in
                                sidebarWidth = newWidth
                                UserDefaults.standard.set(newWidth, forKey: "sidebarWidth")
                            }
                    }
                )
        } detail: {
            detailView
                .searchable(text: $searchText, prompt: "Search notes...")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("", selection: $isCardMode) {
                    Image(systemName: "list.bullet").tag(false)
                    Image(systemName: "rectangle.grid.2x2").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
                .help("Toggle View Mode")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNewNote) {
                    Image(systemName: "plus")
                }
                .help("New Note")
            }
        }
        .whatsNewSheet()
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .allNotes, .none:
            if isCardMode {
                if let note = selectedNote {
                    GridEditNotesView(note: note, selection: $selection, selectedNote: $selectedNote)
                } else {
                    AllNotesView(isGridView: $isCardMode, searchText: $searchText, selectedNote: $selectedNote)
                }
            } else {
                HStack(spacing: 0) {
                    AllNotesView(isGridView: $isCardMode, searchText: $searchText, selectedNote: $selectedNote)
                        .frame(minWidth: 280, maxWidth: 360)
                        .background(Color(NSColor.controlBackgroundColor))
                    Divider()
                    if let note = selectedNote {
                        ListEditNotesView(note: note, selection: $selection, selectedNote: $selectedNote)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("Select a note")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case .favorites:
            FavoritesView(searchText: $searchText, selectedNote: $selectedNote)
        case .trash:
            TrashView()
        }
    }

    
    private func createNewNote() {
        let newNote = vm.createNote()
        selectedNote = newNote
        selection = .allNotes
    }
}
