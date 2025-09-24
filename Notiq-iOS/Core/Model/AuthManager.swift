import SwiftUI
import LocalAuthentication
import Combine

class FaceIDManager: ObservableObject {
    @AppStorage("faceIDEnabled") var faceIDEnabled: Bool = false
    @AppStorage("faceIDLocked") private var faceIDLocked: Bool = true // persists across launches
    
    @Published var isUnlocked: Bool = false
    @Published var isLocked: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        isLocked = faceIDEnabled && faceIDLocked
        isUnlocked = !isLocked
    }
    
    func authenticate() {
        guard faceIDEnabled else { return }
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your notes") { success, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                    self.isLocked = !success
                    self.faceIDLocked = !success
                }
            }
        }
    }
    
    func markBackground() {
        guard faceIDEnabled else { return }
        isUnlocked = false
        isLocked = true
        faceIDLocked = true
    }
    
    func checkForeground() {
        guard faceIDEnabled else { return }
        if faceIDLocked {
            authenticate()
        }
    }
    
    func resetLock() {
        isUnlocked = false
        isLocked = true
        faceIDLocked = true
    }
}
