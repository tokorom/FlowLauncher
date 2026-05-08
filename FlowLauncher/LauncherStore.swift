//
//  LauncherStore.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class LauncherStore {
    private(set) var items: [LauncherItem] = []
    var lastErrorMessage: String?

    private let fileURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directoryURL = appSupportURL.appending(path: "FlowLauncher", directoryHint: .isDirectory)
        fileURL = directoryURL.appending(path: "launcher-items.json")

        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try load()
        } catch {
            lastErrorMessage = "登録情報を読み込めませんでした: \(error.localizedDescription)"
        }
    }

    func hasKey(_ key: String) -> Bool {
        items.contains { $0.key == key }
    }

    func add(appURL: URL, key rawKey: String) throws {
        guard let key = LauncherKey.normalize(rawKey) else {
            throw LauncherStoreError.invalidKey
        }

        guard !hasKey(key) else {
            throw LauncherStoreError.duplicatedKey
        }

        let bookmarkData = try appURL.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        let bundle = Bundle(url: appURL)
        let item = LauncherItem(
            name: Self.displayName(for: appURL, bundle: bundle),
            key: key,
            bundleIdentifier: bundle?.bundleIdentifier,
            bookmarkData: bookmarkData
        )

        items.append(item)
        items.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        try save()
    }

    func remove(_ item: LauncherItem) {
        items.removeAll { $0.id == item.id }

        do {
            try save()
        } catch {
            lastErrorMessage = "削除結果を保存できませんでした: \(error.localizedDescription)"
        }
    }

    func launch(matching event: NSEvent) -> Bool {
        guard let key = LauncherKey.normalize(event) else {
            return false
        }

        guard let item = items.first(where: { $0.key == key }) else {
            return false
        }

        launch(item)
        return true
    }

    private func launch(_ item: LauncherItem) {
        if let bundleIdentifier = item.bundleIdentifier,
            let runningApplication =
                NSRunningApplication
                .runningApplications(withBundleIdentifier: bundleIdentifier)
                .first
        {
            runningApplication.activate(options: [.activateAllWindows])
            return
        }

        guard let appURL = item.resolvedURL else {
            lastErrorMessage = "\(item.name) の場所を見つけられませんでした。登録し直してください。"
            return
        }

        let isAccessing = appURL.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                appURL.stopAccessingSecurityScopedResource()
            }
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)
    }

    private func load() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        let data = try Data(contentsOf: fileURL)
        items = try JSONDecoder().decode([LauncherItem].self, from: data)
    }

    private func save() throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func displayName(for appURL: URL, bundle: Bundle?) -> String {
        if let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }

        if let bundleName = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }

        return appURL.deletingPathExtension().lastPathComponent
    }
}

enum LauncherStoreError: LocalizedError {
    case duplicatedKey
    case invalidKey

    var errorDescription: String? {
        switch self {
        case .duplicatedKey:
            "そのキーはすでに登録されています。"
        case .invalidKey:
            "キーは1文字で入力してください。"
        }
    }
}
