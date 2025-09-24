//
//  NoteEntity+CoreDataProperties.swift
//  Notiq
//
//  Created by Kilian Balaguer on 21/09/2025.
//
//

public import Foundation
public import CoreData


public typealias NoteEntityCoreDataPropertiesSet = NSSet

extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var isTrashed: Bool
    @NSManaged public var isFavorite: Bool

}

extension NoteEntity : Identifiable {

}
