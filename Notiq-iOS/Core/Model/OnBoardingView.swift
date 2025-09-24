import OnboardingKit
import SwiftUI

extension OnboardingConfiguration {
    static let production = OnboardingConfiguration(
        accentColor: .yellow,
        appDisplayName: "Notiq",
        features: [
            FeatureInfo(
                image: Image(systemName: "note.text"),
                title: "Take Notes",
                content: "Quickly jot down ideas, class notes, or meeting summaries."
            ),
            FeatureInfo(
                image: Image(systemName: "calendar"),
                title: "Calendar & Reminders",
                content: "Plan your schedule, set reminders, and never miss an important date."
            ),
            FeatureInfo(
                image: Image(systemName: "brain.head.profile"),
                title: "Mind Maps",
                content: "Organize your thoughts visually and create mind maps effortlessly."
            ),
            FeatureInfo(
                image: Image(systemName: "pencil.and.outline"),
                title: "Draw & Sketch",
                content: "Create sketches, annotate notes, or draw freely within your notes."
            ),
            FeatureInfo(
                image: Image(systemName: "square.and.arrow.up"),
                title: "Share & Collaborate",
                content: "Easily share notes with friends, classmates, or colleagues."
            )
        ],
        titleSectionAlignment: .center
    )
}
