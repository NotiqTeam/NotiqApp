//
//  Untitled.swift
//  Notiq
//
//  Created by Kilian Balaguer on 22/09/2025.
//

import SwiftUI
internal import CoreData

// Helper to safely bind optional Strings
extension Binding where Value == String? {
    var bound: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}
