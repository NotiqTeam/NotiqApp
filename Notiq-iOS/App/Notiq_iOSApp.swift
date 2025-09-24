import SwiftUI
import CoreData
import OnboardingKit
import WhatsNewKit

@main
struct NotiqApp: App {

    // MARK: - Core Data Manager (local-only)
    let coreDataManager = CoreDataManager.shared

    // MARK: - Managers
    @StateObject private var notesVM = NotesViewModel(manager: CoreDataManager.shared)
    @StateObject private var faceIDManager = FaceIDManager()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
                .environmentObject(notesVM)
                .environmentObject(faceIDManager)
                .environment(
                    \.whatsNew,
                    WhatsNewEnvironment(
                        versionStore: UserDefaultsWhatsNewVersionStore(),
                        whatsNewCollection: self
                    )
                )
                .showOnboardingIfNeeded(
                    config: .production,
                    appIcon: Image("Icon"),
                    dataPrivacyContent: {
                        AnyView(PrivacyPolicyView())
                    }
                )
                .whatsNewSheet()
        }
    }
}

// MARK: - WhatsNewCollectionProvider
extension NotiqApp: WhatsNewCollectionProvider {
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "1.0.0-nightly.1",
            title: "Welcome to Notiq Nightly!",
            features: [
                .init(
                    image: .init(systemName: "sparkles"),
                    title: "First Nightly Release",
                    subtitle: "You’re among the first to try Notiq on iOS. Exciting times ahead!"
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
                hapticFeedback: { .notification(.success) }()
            ),
            secondaryAction: .init(
                title: "Learn more",
                action: .openURL(URL(string: "https://github.com/SvenTiigi/WhatsNewKit")!)
            )
        )
    }
}
