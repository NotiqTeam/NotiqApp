//
//  NoteCardViewMac.swift
//  Notiq
//
//  Created by Kilian Balaguer on 21/09/2025.
//


import SwiftUI

struct NoteCardViewMac: View {
    let note: NoteEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title ?? "Untitled")
                .font(.headline)
                .lineLimit(1)
            
            Text(note.content ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(6)
            
            Spacer()
            
            Text(note.timestamp ?? Date(), style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 1, y: 1)
        )
    }
}
