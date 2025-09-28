import SwiftUI

struct NotiqAIView: View {
    @State private var animate = false
    @State private var showPreview = false
    @State private var userInput = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if showPreview {
                        // Preview layout (unchanged)
                        VStack(spacing: 16) {
                            // Back button
                            HStack {
                                GlowingBackButton {
                                    showPreview = false
                                    animate = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        animate = true
                                    }
                                }
                                Spacer()
                            }
                            
                            // Title + subtitle
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notiq AI Preview")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("This is how your Notiq AI would look.")
                                    .multilineTextAlignment(.leading)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            
                            // Middle content
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 500)
                                .padding(.top, 20)
                            
                            Spacer()
                            
                            // TextField at bottom
                            TextField("Type your query...", text: $userInput)
                                .padding()
                                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 20))
                                .foregroundColor(.primary)
                                .intelligence(spread: 8, blur: 12, shape: RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                    } else {
                        // Original content
                        VStack(spacing: 24) {
                            Spacer() // Push main content to top

                            Image(systemName: "apple.intelligence")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("Notiq AI")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Your AI assistant is coming—ready to help with Notes, Calendar, and more!")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                            
                            HStack(spacing: 8) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 12, height: 12)
                                        .scaleEffect(animate ? 1.0 : 0.3)
                                        .animation(
                                            Animation.easeInOut(duration: 0.6)
                                                .repeatForever()
                                                .delay(Double(index) * 0.2),
                                            value: animate
                                        )
                                }
                            }
                            
                            Button("Preview Notiq AI") { showPreview = true }
                                .padding()
                                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 25))
                                .intelligence(spread: 8, blur: 12, shape: RoundedRectangle(cornerRadius: 25))
                            
                            Spacer() // Push bottom privacy info to bottom

                            // Bottom privacy info
                            VStack(spacing: 6) {
                                Image("DataPrivacy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                
                                Text("NotiqAI collects your activity, which is not associated with your Apple ID.")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom, 12)
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                        .onAppear { animate = true }
                    }
                }
            }
        }
    }
}

// MARK: - Custom Back Button
struct GlowingBackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .glassEffect()
                    .overlay(
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .intelligence(spread: 8, blur: 12, shape: Circle())
                    )
            }
            .frame(width: 45, height: 45)
        }
        .clipShape(.circle)
        .intelligence(spread: 8, blur: 12, shape: Circle())
    }
}

// MARK: - Preview
#Preview {
    NotiqAIView()
}
