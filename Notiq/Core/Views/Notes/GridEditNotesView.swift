import SwiftUI
internal import CoreData

struct GridEditNotesView: View {
    @ObservedObject var note: NoteEntity
    @Binding var selection: SidebarItem?
    @Binding var selectedNote: NoteEntity?
    
    @EnvironmentObject var vm: NotesViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Toolbar
            HStack {
                Button(action: { selectedNote = nil }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(6)
                }
                .clipShape(Circle())
                
                Spacer()
                
                Button(role: .destructive) {
                    vm.deleteNote(note)
                    selectedNote = nil
                    selection = .allNotes
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .padding(6)
                }
                .clipShape(Circle())
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            Spacer()
            
            // MARK: - Title + Content Container
            VStack(spacing: 0) {
                TextField("Title", text: $note.title.bound)
                    .font(.title)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedCorners(tl: 12, tr: 12, bl: 0, br: 0))
                
                Divider()
                
                TextEditor(text: $note.content.bound)
                    .padding()
                    .background(Color(NSColor.textBackgroundColor))
                    .clipShape(RoundedCorners(tl: 0, tr: 0, bl: 12, br: 12))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor).ignoresSafeArea())
        .onDisappear {
            vm.updateNote(note, title: note.title ?? "", content: note.content ?? "")
        }
    }
}
