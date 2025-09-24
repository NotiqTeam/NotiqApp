import SwiftUI
import CoreData
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteEntity] = []
    @Published var selectedNote: NoteEntity?

    let manager: CoreDataManager

    init(manager: CoreDataManager = .shared) {
        self.manager = manager
        refreshNotes()
    }

    // MARK: - CRUD
    func createNote(title: String = "Untitled", content: String = "") -> NoteEntity {
        let note = NoteEntity(context: manager.container.viewContext)
        note.id = UUID()
        note.timestamp = Date()
        note.title = title
        note.content = content
        note.isPinned = false
        note.isFavorite = false
        
        saveContext()
        refreshNotes()
        return note
    }

    func updateNote(_ note: NoteEntity, title: String, content: String) {
        note.title = title
        note.content = content
        note.timestamp = Date()
        saveContext()
        refreshNotes()
    }

    func deleteNote(_ note: NoteEntity) {
        manager.container.viewContext.delete(note)
        saveContext()
        refreshNotes()
    }

    func togglePin(_ note: NoteEntity) {
        note.isPinned.toggle()
        saveContext()
        refreshNotes()
    }

    func toggleFavorite(_ note: NoteEntity) {
        note.isFavorite.toggle()
        saveContext()
        refreshNotes()
    }

    // MARK: - Save
    private func saveContext() {
        manager.saveContext()
    }

    // MARK: - Refresh
    func refreshNotes() {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        do {
            notes = try manager.container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch notes: \(error)")
            notes = []
        }
    }
}
