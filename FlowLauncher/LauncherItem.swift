//
//  LauncherItem.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

struct LauncherItem: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var key: String
    var bundleIdentifier: String?
    private var bookmarkData: Data

    init(
        id: UUID = UUID(),
        name: String,
        key: String,
        bundleIdentifier: String?,
        bookmarkData: Data
    ) {
        self.id = id
        self.name = name
        self.key = key
        self.bundleIdentifier = bundleIdentifier
        self.bookmarkData = bookmarkData
    }

    var displayKey: String {
        key.uppercased()
    }

    var icon: NSImage {
        guard let url = resolvedURL else {
            return NSWorkspace.shared.icon(for: .application)
        }

        return NSWorkspace.shared.icon(forFile: url.path)
    }

    var resolvedURL: URL? {
        var isStale = false

        return try? URL(
            resolvingBookmarkData: bookmarkData,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
}
