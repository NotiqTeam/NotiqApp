internal import CoreData
import AppKit
internal import Combine

final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let container: NSPersistentCloudKitContainer
    
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "NotesContainer") // your .xcdatamodeld name
        
        if let description = container.persistentStoreDescriptions.first {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.NotiqTeam.notiq"
            )
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processRemoteStoreChange),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do { try context.save() }
            catch { context.rollback(); print("Error saving Core Data: \(error)") }
        }
    }
    
    @objc private func processRemoteStoreChange(_ notification: Notification) {
        container.viewContext.perform {
            self.container.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
