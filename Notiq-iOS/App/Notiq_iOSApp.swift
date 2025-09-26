import SwiftUI
import CoreData
import OnboardingKit

@main
struct NotiqApp: App {

    // MARK: - Core Data Manager (local-only)
    let coreDataManager = CoreDataManager.shared

    // MARK: - Managers
    @StateObject private var notesVM = NotesViewModel(manager: CoreDataManager.shared)
    @StateObject private var faceIDManager = FaceIDManager()
    
    @AppStorage("OnBoardingViewState") private var onBoardingViewState: Bool = false

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
                .environmentObject(notesVM)
                .environmentObject(faceIDManager)
                .showOnboardingIfNeeded(
                    storage: _onBoardingViewState, // pass the property itself, not $binding
                    config: .production,
                    appIcon: Image("Icon"),
                    dataPrivacyContent: {
                        PrivacyPolicyView()
                    },
                    flowContent: {
                        OnBoardingSetupFlowView(onFinish: {
                            print("Onboarding Flow Finished")
                            onBoardingViewState = true

                        })
                        .environmentObject(faceIDManager)
                    }
                )
        }
    }
}
