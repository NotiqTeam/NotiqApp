//
//  Extensions.swift
//  Notiq
//
//  Created by Kilian Balaguer on 19/09/2025.
//

import Foundation
import SwiftUI

// MARK: View

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
