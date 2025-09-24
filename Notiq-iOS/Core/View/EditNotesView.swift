import SwiftUI

struct EditNotesView: View {
    @ObservedObject var note: NoteEntity  // ✅ ObservedObject
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var contentEditorInFocus: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                TextField("Title", text: Binding(
                    get: { note.title ?? "" },
                    set: { newValue in
                        note.title = newValue
                        vm.updateNote(note, title: note.title ?? "", content: note.content ?? "")
                    })
                )
                .font(.title.bold())
                .submitLabel(.next)
                .onSubmit { contentEditorInFocus = true }
                
                // Content
                TextEditor(text: Binding(
                    get: { note.content ?? "" },
                    set: { newValue in
                        note.content = newValue
                        vm.updateNote(note, title: note.title ?? "", content: note.content ?? "")
                    })
                )
                .frame(minHeight: 200)
                .font(.title3)
                .focused($contentEditorInFocus)
            }
            .padding(10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack { Spacer() ; Button("Done") { contentEditorInFocus = false } }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    vm.updateNote(note, title: note.title ?? "", content: note.content ?? "")
                    dismiss()
                }
            }
        }
    }
}
