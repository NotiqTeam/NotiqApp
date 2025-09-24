import Foundation

enum SidebarItem: String, CaseIterable, Identifiable {
    case allNotes = "All Notes"
    case favorites = "Favorites"
    case trash = "Trash"

    var id: String { rawValue }
}
