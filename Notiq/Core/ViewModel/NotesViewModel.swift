import SwiftUI
internal import CoreData
internal import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteEntity] = []
    
    let manager: CoreDataManager
    
    init(manager: CoreDataManager = .shared) {
        self.manager = manager
        fetchNotes()
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
        fetchNotes()
        return note
    }
    
    func updateNote(_ note: NoteEntity, title: String, content: String) {
        note.title = title
        note.content = content
        note.timestamp = Date()
        saveContext()
        fetchNotes()
    }
    
    func deleteNote(_ note: NoteEntity) {
        manager.container.viewContext.delete(note)
        saveContext()
        fetchNotes()
    }
    
    func togglePin(_ note: NoteEntity) {
        note.isPinned.toggle()
        saveContext()
        fetchNotes()
    }
    
    func toggleFavorite(_ note: NoteEntity) {
        note.isFavorite.toggle()
        saveContext()
        fetchNotes()
    }
    
    // MARK: - Helpers
    private func saveContext() {
        manager.saveContext()
    }
    
    func fetchNotes() {
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
