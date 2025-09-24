//
//  ListCellView.swift
//  Notiq
//
//  Created by Kilian Balaguer on 24/09/2025.
//


import SwiftUI

struct ListCellView: View {
    var note: NoteEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title ?? "New Note")
                .font(.headline)
                .lineLimit(1)
            
            Text(note.content ?? "No content")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4) // subtle breathing space
    }
}
