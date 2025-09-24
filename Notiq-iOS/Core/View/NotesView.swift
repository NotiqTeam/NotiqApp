import SwiftUI
import Combine
import OnboardingKit
import WhatsNewKit

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var vm: NotesViewModel
    @EnvironmentObject var faceIDManager: FaceIDManager

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    @State private var searchText: String = ""
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            NativeTabView()
                .environmentObject(vm)
                .environmentObject(faceIDManager)
                .onAppear {
                    if !hasSeenOnboarding { showOnboarding = true }
                    faceIDManager.checkForeground()
                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active: faceIDManager.checkForeground()
                    case .background: faceIDManager.markBackground()
                    default: break
                    }
                }
                .whatsNewSheet()

            if faceIDManager.isLocked {
                LockScreenView(faceIDManager: faceIDManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    // MARK: - TabView
    @ViewBuilder
    func NativeTabView() -> some View {
        TabView {
            Tab("Notes", systemImage: "note.text") { NotesView() }
            Tab("Calendar", systemImage: "calendar") { CalendarView() }
            Tab("Reminders", systemImage: "checkmark.circle") { RemindersView() }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
                    .environmentObject(vm)
                    .environmentObject(faceIDManager)
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    if filteredNotes.isEmpty {
                        ContentUnavailableView.search
                            .navigationTitle("Search")
                    } else {
                        List(filteredNotes) { note in
                            NavigationLink(value: note) {
                                ListCellView(note: note)
                            }
                        }
                        .navigationTitle("Search")
                    }
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "Search notes...")
                .navigationDestination(for: NoteEntity.self) { note in
                    EditNotesView(note: note).id(note)
                }
            }
        }
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
                Image(systemName: "faceid").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(.yellow)
                Text("Unlock with Face ID").foregroundColor(.white).font(.title2)
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

    var groupedByDate: [Date: [NoteEntity]] {
        let calendar = Calendar.current
        return Dictionary(grouping: vm.notes) { note in
            let date = note.timestamp ?? Date()
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: comps) ?? Date()
        }
    }
    var headers: [Date] { groupedByDate.keys.sorted(by: >) }

    var body: some View {
        NavigationStack(path: $selectedNotePath) {
            Group {
                if showAsGallery {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(vm.notes) { note in
                                NavigationLink(value: note) {
                                    NoteCardRow(note: note, onDelete: {
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
                    List {
                        ForEach(headers, id: \.self) { header in
                            Section(header: Text(header, style: .date)) {
                                ForEach(groupedByDate[header] ?? []) { note in
                                    NavigationLink(value: note) {
                                        NoteRow(note: note)
                                    }
                                    .contextMenu { noteContextMenu(note) }
                                }
                                .onDelete { offsets in deleteNote(in: header, at: offsets) }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .refreshable { await refreshData() }
                }
            }
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

    struct NoteCardRow: View {
        @ObservedObject var note: NoteEntity
        var onDelete: (() -> Void)? = nil
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(note.title ?? "Untitled").font(.headline).lineLimit(1)
                Text(note.content ?? "").font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                Spacer()
                Text(note.timestamp ?? Date(), style: .date).font(.caption2).foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemGroupedBackground)))
            .contextMenu { Button(role: .destructive) { onDelete?() } label: { Label("Delete", systemImage: "trash") } }
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
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { Task { await refreshData() } }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing)

                Menu {
                    Button(action: { showAsGallery.toggle() }) {
                        Label(showAsGallery ? "View as List" : "View as Gallery",
                              systemImage: showAsGallery ? "list.bullet" : "square.grid.2x2")
                    }

                    Button(action: { Task { await refreshData() } }) {
                        Label("Refresh Notes", systemImage: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                }
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

// MARK: - Calendar & Reminders placeholders
struct CalendarView: View {
    var body: some View {
        Text("Calendar coming soon").foregroundStyle(.secondary).navigationTitle("Calendar")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }
}

struct RemindersView: View {
    var body: some View {
        Text("Reminders coming soon").foregroundStyle(.secondary).navigationTitle("Reminders")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }
}
