//
//  RemindersView.swift
//  Notiq
//
//  Created by Kilian Balaguer on 26/09/2025.
//


import SwiftUI

struct RemindersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
            
            Text("Reminders")
                .font(.largeTitle)
                .bold()
            
            Text("This feature is coming soon!\nWork in progress...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Reminders")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}
