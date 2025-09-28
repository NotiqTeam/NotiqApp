import SwiftUI
import Combine
import OnboardingKit
import WhatsNewKit

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var vm: NotesViewModel
    @EnvironmentObject var faceIDManager: FaceIDManager

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenWhatsNewVersion: String = ""
    
    @State private var showOnboarding = false
    @State private var searchText: String = ""
    @Environment(\.scenePhase) var scenePhase
    

    // current app version (from Info.plist)
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    var body: some View {
        ZStack {
            NativeTabView()
                .environmentObject(vm)
                .environmentObject(faceIDManager)
                .onAppear {
                    // FaceID check
                    faceIDManager.checkForeground()
                }
            
                .whatsNewSheet()

            
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active: faceIDManager.checkForeground()
                    case .background: faceIDManager.markBackground()
                    default: break
                    }
                }
            
            if faceIDManager.isLocked {
                LockScreenView(faceIDManager: faceIDManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
    
    // MARK: - TabView with Floating Button above Tab Bar
    @ViewBuilder
    func NativeTabView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                Tab("Notes", systemImage: "note.text") { NotesView() }
                Tab("Calendar", systemImage: "calendar") { CalendarView() }
                Tab("Notiq AI", systemImage: "apple.intelligence") { NotiqAIView() }
                Tab("Reminders", systemImage: "checkmark.circle") { RemindersView() }
                Tab("Settings", systemImage: "gearshape.fill") {
                    SettingsView()
                        .environmentObject(vm)
                        .environmentObject(faceIDManager)
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            
        }
    }

    /// Helper to get bottom safe area inset
    private func safeAreaBottom() -> CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }




    private var filteredNotes: [NoteEntity] {
        vm.notes.filter { searchText.isEmpty || $0.title?.localizedCaseInsensitiveContains(searchText) == true }
    }
}

// MARK: - Lock Screen
struct LockScreenView: View {
    @ObservedObject var faceIDManager: FaceIDManager

    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "faceid")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                Text("Unlock with Face ID")
                    .foregroundColor(.white)
                    .font(.title2)
                Button("Try Again") { faceIDManager.authenticate() }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
            }
        }
        .onAppear { faceIDManager.authenticate() }
    }
}


// MARK: - Notes View
struct NotesView: View {
    @EnvironmentObject var vm: NotesViewModel
    @EnvironmentObject var faceIDManager: FaceIDManager
    @State private var selectedNotePath: [NoteEntity] = []
    @AppStorage("showAsGallery") private var showAsGallery: Bool = false
    @State private var isRefreshing = false
    @State private var searchText: String = ""


    var groupedByDate: [Date: [NoteEntity]] {
        let calendar = Calendar.current
        return Dictionary(grouping: vm.notes) { note in
            let date = note.timestamp ?? Date()
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: comps) ?? Date()
        }
    }
    var headers: [Date] { groupedByDate.keys.sorted(by: >) }

    // 🔹 filtered notes using local searchText
    private var filteredNotes: [NoteEntity] {
        vm.notes.filter { searchText.isEmpty || $0.title?.localizedCaseInsensitiveContains(searchText) == true }
    }
    
    var body: some View {
        NavigationStack(path: $selectedNotePath) {
            Group {
                if showAsGallery {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(vm.notes) { note in
                                NavigationLink(value: note) {
                                    NoteCardView(note: note, onDelete: {
                                        vm.deleteNote(note)
                                        selectedNotePath.removeAll { $0 == note }
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .refreshable { await refreshData() }
                } else {
                    // MARK: Normal List
                    List {
                        ForEach(headers, id: \.self) { header in
                            Section(header: Text(header, style: .date)) {
                                ForEach(groupedByDate[header] ?? []) { note in
                                    NavigationLink(value: note) {
                                        ListCellView(note: note)
                                    }
                                    .contextMenu {
                                            ControlGroup {
                                                Button { } label: {
                                                    Text("Share")
                                                    Image(systemName: "square.and.arrow.up")
                                                }
                                                Button { } label: {
                                                    Text("Move")
                                                    Image(systemName: "folder")
                                                }
                                                Button(role: .destructive) {
                                                    vm.deleteNote(note)
                                                    if selectedNotePath.contains(note) {
                                                        selectedNotePath.removeAll(where: { $0 == note })
                                                    }
                                                } label:  {
                                                    Text("Delete")
                                                    Image(systemName: "trash")
                                                }
                                            }
                                            Button {
                                                print("Pin tapped")
                                            } label: {
                                                Label("Pin Note", systemImage: "pin")
                                            }
                                            Button {
                                                print("Lock tapped")
                                            } label: {
                                                Label("Lock Note", systemImage: "lock")
                                            }
                                            Button {
                                                print("Duplicated tapped")
                                            } label: {
                                                Label("Duplicate Note", systemImage: "document.on.document")
                                            }
                                        } preview: {
                                            ScrollView { // preview scrollable
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text(note.title ?? "Untitled")
                                                        .font(.title2)
                                                        .bold()
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    
                                                    Text(note.content ?? "")
                                                        .font(.body)
                                                        .foregroundStyle(.secondary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                            }
                                            .frame(minWidth: 400, maxWidth: 400, minHeight: 500)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .fill(Color(.systemBackground))
                                            )
                                        }
                                    
                                }
                                .onDelete { offsets in deleteNote(in: header, at: offsets) }
                                
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden) // hide the system list bg
                    .background(Color(.systemGroupedBackground)) // 👈 re-add proper bg
                    .refreshable { await refreshData() }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Notes")
            .toolbar { notesToolbar }
            .navigationDestination(for: NoteEntity.self) { note in
                EditNotesView(note: note).id(note)
            }
            .overlay { if isRefreshing { ProgressView().scaleEffect(1.2).tint(.primary) } }
        }
    }

    // MARK: - Row Views
    struct NoteRow: View {
        @ObservedObject var note: NoteEntity
        var body: some View {
            VStack(alignment: .leading) {
                Text(note.title ?? "Untitled").bold()
                Text(note.content ?? "").foregroundStyle(.secondary).lineLimit(2)
            }
        }
    }

    // MARK: - Grid Card View
    struct NoteCardView: View {
        let note: NoteEntity
        var onDelete: (() -> Void)? = nil
        var onFavorite: (() -> Void)? = nil

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(note.title ?? "Untitled")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(note.content ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                
                Spacer()
                
                Text(note.timestamp ?? Date(), style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .tint(.primary)
            // MARK: - Context menu with preview
            .contextMenu {
                ControlGroup {
                    Button { } label: {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button { } label: {
                        Text("Move")
                        Image(systemName: "folder")
                    }
                    Button(role: .destructive) { onDelete?()
                    } label:  {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                }
                Button {
                    print("Pin tapped")
                } label: {
                    Label("Pin Note", systemImage: "pin")
                }
                Button {
                    print("Lock tapped")
                } label: {
                    Label("Lock Note", systemImage: "lock")
                }
                Button {
                    print("Duplicated tapped")
                } label: {
                    Label("Duplicate Note", systemImage: "document.on.document")
                }
            } preview: {
                ScrollView { // enable scrolling
                    VStack(alignment: .leading, spacing: 12) {
                        Text(note.title ?? "Untitled")
                            .font(.title2)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(note.content ?? "")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // align content to top-left
                    .padding()
                }
                .frame(minWidth: 400, maxWidth: 400,minHeight: 500) // Width of the preview
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemBackground))
                )
            }
            
        }
    }


    // MARK: - Context Menu
    func noteContextMenu(_ note: NoteEntity) -> some View {
        Group {
            Button { print("Pin tapped") } label: { Label("Pin Note", systemImage: "pin") }
            Button { vm.deleteNote(note) } label: { Label("Delete", systemImage: "trash") }
        }
    }

    // MARK: - Toolbar
    var notesToolbar: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: { createNewNote() }) {
                    Label("New", systemImage: "square.and.pencil")
                }
                .tint(Color.accentColor)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Refresh button
                Button(action: { Task { await refreshData() } }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing)
                .tint(Color.accentColor) // Colors both label and icon

                // Menu with gallery toggle + refresh notes
                Menu {
                    Button(action: { showAsGallery.toggle() }) {
                        Label(showAsGallery ? "View as List" : "View as Gallery",
                              systemImage: showAsGallery ? "list.bullet" : "square.grid.2x2")
                    }
                    .tint(Color.yellow) // Colors icon inside menu item

                    Button(action: { Task { await refreshData() } }) {
                        Label("Refresh Notes", systemImage: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                    .tint(Color.yellow) // Colors icon inside menu item
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .tint(Color.accentColor) // Colors the ellipsis icon
                }
                .tint(Color.accentColor)
            }
        }
    }
    
    
    // MARK: - Actions
    private func createNewNote() {
        let newNote = vm.createNote()
        selectedNotePath = [newNote]
    }

    private func deleteNote(in header: Date, at offsets: IndexSet) {
        offsets.forEach { i in
            if let noteToDelete = groupedByDate[header]?[i] {
                vm.deleteNote(noteToDelete)
                selectedNotePath.removeAll { $0 == noteToDelete }
            }
        }
    }

    private func refreshData() async {
        await MainActor.run { isRefreshing = true }
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            vm.refreshNotes()
            isRefreshing = false
        }
    }
}

