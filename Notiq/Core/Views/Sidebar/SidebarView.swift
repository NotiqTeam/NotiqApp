import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        List(SidebarItem.allCases, id: \.self, selection: $selection) { item in
            Label(item.rawValue, systemImage: systemImage(for: item))
                .padding(.vertical, 4)
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 180, idealWidth: 180, maxWidth: 300)
        .safeAreaInset(edge: .bottom) {
            SidebarFooter()
        }
        .navigationTitle("Notiq")
    }

    private func systemImage(for item: SidebarItem) -> String {
        switch item {
        case .allNotes: return "note.text"
        case .favorites: return "star"
        case .trash: return "trash"
        }
    }
}

struct SidebarFooter: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        return "Notiq v\(version)"
    }

    var body: some View {
        HStack {
            Spacer()
            Text(appVersion)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
