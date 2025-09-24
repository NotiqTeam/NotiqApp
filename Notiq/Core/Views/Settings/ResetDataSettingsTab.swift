//
//  DataSettingsTab.swift
//  Notiq
//
//  Created by Kilian Balaguer on 05/09/2025.
//


import SwiftUI

struct ResetDataSettingsTab: View {
    @State private var showFirstWarning = false
    @State private var showSecondWarning = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Header
            VStack(spacing: 8) {
                Image(systemName: "externaldrive.badge.timemachine")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                Text("Reset Data")
                    .font(.headline)
            }
            
            // Info section
            Text("Here you can reset everything back to default settings. Be careful: resetting will delete all preferences and requires a restart.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            // Reset All Data Button
            Button(role: .destructive) {
                showFirstWarning = true
            } label: {
                Label("Reset All Data", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .frame(maxWidth: 200)
            .alert("Are you sure?", isPresented: $showFirstWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showSecondWarning = true
                }
            } message: {
                Text("This action cannot be undone. All saved settings and data will be deleted.")
            }
            .alert("Final Warning", isPresented: $showSecondWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Delete & Restart", role: .destructive) {
                    resetAppData()
                }
            } message: {
                Text("Are you absolutely sure you want to reset all data and restart the app?")
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func resetAppData() {
        // Clear all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // Restart app
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-n", Bundle.main.bundlePath]
        try? task.run()
        NSApp.terminate(nil)
    }
}
