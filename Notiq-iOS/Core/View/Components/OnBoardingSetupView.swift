import SwiftUI
import LocalAuthentication

struct OnBoardingSetupFlowView: View {

    @EnvironmentObject var faceIDManager: FaceIDManager
    var appIcon = Image("Icon")
    private let accentColor: Color = .yellow
    private let appDisplayName: String = "Notiq"
    var onFinish: () -> Void = {}

    @State private var step: Int = 0
    @State private var showPrivacySheet = false
    @State private var faceIDError: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Title Section
            VStack(spacing: 2) {
                appIcon
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .padding(.bottom, 6)

                Text(titleText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

            }
            .padding(.horizontal, 64)

            Spacer()

            // MARK: - Bottom Section
            VStack(spacing: 0) {

                if step == 1 {
                    Image(systemName: "faceid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(accentColor)
                        .padding(.bottom, 6)

                    Text("Do you want to enable Face ID for secure access?")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)

                    if let error = faceIDError {
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.bottom, 6)
                    }

                } else if step == 2 {
                    Image("DataPrivacy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(accentColor)
                        .padding(.bottom, 6)

                    Text("You have finished setup!\nWelcome to the app.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                }

                Button(action: { buttonAction() }) {
                    Text(buttonText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .tint(accentColor)

            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.bottom, 0)
            .sheet(isPresented: $showPrivacySheet) {
                NavigationStack {
                    PrivacyPolicyView()
                        .navigationTitle("Data Management")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showPrivacySheet = false }
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    // MARK: - Computed
    private var titleText: String {
        switch step {
        case 0: return "Let's start configuring the app to your liking"
        case 1: return "FaceID Setup"
        case 2: return "Setup Complete"
        default: return ""
        }
    }

    private var buttonText: String {
        switch step {
        case 2: return "Finish"
        default: return "Next"
        }
    }

    // MARK: - Actions
    private func buttonAction() {
        switch step {
        case 0:
            step += 1
        case 1:
            step += 1

        case 2:
            onFinish() // <- triggers whatever you pass in package flowContent
        default:
            break
        }
    }

    private func requestFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Enable Face ID for secure access") { success, evaluationError in
                DispatchQueue.main.async {
                    if success {
                        faceIDManager.faceIDEnabled = true
                        step += 1
                    } else {
                        faceIDError = evaluationError?.localizedDescription ?? "Face ID failed"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                faceIDError = "Face ID not available on this device"
            }
        }
    }
}

struct OnBoardingSetupFlowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnBoardingSetupFlowView()
                .environmentObject(FaceIDManager())
        }
    }
}
