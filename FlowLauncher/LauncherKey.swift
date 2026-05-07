//
//  LauncherKey.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import Foundation

enum LauncherKey {
    static func normalize(_ rawValue: String?) -> String? {
        guard let rawValue else {
            return nil
        }

        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let character = trimmedValue.first else {
            return nil
        }

        guard character.unicodeScalars.allSatisfy({ scalar in
            !CharacterSet.controlCharacters.contains(scalar)
        }) else {
            return nil
        }

        return String(character).lowercased()
    }

    static func normalize(_ event: NSEvent) -> String? {
        let ignoredModifiers: NSEvent.ModifierFlags = [.command, .control, .option]

        guard event.modifierFlags.intersection(ignoredModifiers).isEmpty else {
            return nil
        }

        return normalize(event.charactersIgnoringModifiers)
    }
}
