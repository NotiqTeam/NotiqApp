import SwiftUI

struct TrashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
            
            Text("Trash")
                .font(.largeTitle)
                .bold()
            
            Text("This feature is coming soon!\nWork in progress...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
