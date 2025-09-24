//
//  ListCellViewMac.swift
//  Notiq
//
//  Created by Kilian Balaguer on 21/09/2025.
//


import SwiftUI

struct ListCellViewMac: View {
    let note: NoteEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title ?? "Untitled")
                    .font(.headline)
                    .lineLimit(1)
                Text(note.content ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(note.timestamp ?? Date(), style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(4)
    }
}
