import SwiftUI
internal import CoreData
#if os(macOS)
import Sparkle
#endif
import OnboardingKit
import WhatsNewKit

@main
struct NotiqApp: App {
    // MARK: - Persistence
    let coreDataManager = CoreDataManager.shared
    @StateObject private var notesVM = NotesViewModel(manager: CoreDataManager.shared)

    // MARK: - Dark mode
    @AppStorage("settings.general.darkMode") private var darkMode: Bool = false

    // MARK: - macOS Updater
    #if os(macOS)
    private let updaterController: SPUStandardUpdaterController
    #endif

    init() {
        // ✅ Initialize StateObject without capturing self
        let vm = NotesViewModel(manager: coreDataManager)
        _notesVM = StateObject(wrappedValue: vm)

        #if os(macOS)
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        #endif
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesVM)
                .preferredColorScheme(darkMode ? .dark : .light)
                .whatsNewSheet()
                .showOnboardingIfNeeded(
                    config: .production,
                    appIcon: Image("Icon"),
                    dataPrivacyContent: { PrivacyPolicyView() }
                )
        }

        // MARK: - Commands
        .commands {
            SidebarCommands()
            
            #if os(macOS)
            // Replace default App menu items (including About)
            CommandGroup(replacing: .appInfo) {
                Button("About Notiq") {
                    AboutWindow.show()
                }
                
                Divider()
                
                CheckForUpdatesView(updater: updaterController.updater)
            }

            // Notes menu
            CommandMenu("Notes") {
                Button("Refresh Notes") { notesVM.fetchNotes() }
                    .keyboardShortcut("r", modifiers: [.command])
            }
            #endif
        }
        // MARK: - Settings Window
        Settings {
            SettingsWindow()
        }
    }
}

// MARK: - WhatsNewCollectionProvider
extension NotiqApp: WhatsNewCollectionProvider {
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "2025.09.22-nightly.1",
            title: "Welcome to Notiq Nightly!",
            features: [
                .init(
                    image: .init(systemName: "sparkles"),
                    title: "First Nightly Release",
                    subtitle: "You’re among the first to try Notiq. Exciting times ahead!"
                ),
                .init(
                    image: .init(systemName: "note.text"),
                    title: "Create Notes Easily",
                    subtitle: "Quickly jot down your ideas and thoughts in a clean, simple editor."
                ),
                .init(
                    image: .init(systemName: "star.fill"),
                    title: "Favorites",
                    subtitle: "Mark important notes to access them instantly anytime."
                ),
                .init(
                    image: .init(systemName: "rectangle.grid.2x2"),
                    title: "Grid & List Views",
                    subtitle: "Switch between a neat list or a stylish grid layout for your notes."
                ),
                .init(
                    image: .init(systemName: "gearshape"),
                    title: "Customize Your Experience",
                    subtitle: "Adjust settings and layouts to fit your workflow perfectly."
                )
            ],
            primaryAction: .init(
                hapticFeedback: {
                    #if os(iOS)
                    .notification(.success)
                    #else
                    nil
                    #endif
                }()
            ),
            secondaryAction: .init(
                title: "Learn more",
                action: .openURL(.init(string: "https://github.com/SvenTiigi/WhatsNewKit"))
            )
        )
    }
}
