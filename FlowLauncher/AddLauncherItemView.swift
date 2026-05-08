//
//  AddLauncherItemView.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddLauncherItemView: View {
    @Environment(\.dismiss) private var dismiss
    var store: LauncherStore

    @State private var selectedAppURL: URL?
    @State private var keyInput = ""
    @State private var errorMessage: String?

    private var normalizedKey: String? {
        LauncherKey.normalize(keyInput)
    }

    private var isDuplicatedKey: Bool {
        guard let normalizedKey else {
            return false
        }

        return store.hasKey(normalizedKey)
    }

    private var canAdd: Bool {
        selectedAppURL != nil && normalizedKey != nil && !isDuplicatedKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Form {
                LabeledContent("アプリ") {
                    HStack {
                        Text(selectedAppURL?.deletingPathExtension().lastPathComponent ?? "未選択")
                            .foregroundStyle(selectedAppURL == nil ? .secondary : .primary)
                            .lineLimit(1)

                        Button("参照...") {
                            selectApp()
                        }
                    }
                }

                LabeledContent("キー") {
                    TextField("1文字", text: $keyInput)
                        .frame(width: 80)
                        .onChange(of: keyInput) {
                            sanitizeKeyInput()
                        }
                }
            }

            if isDuplicatedKey {
                Text("そのキーはすでに登録されています。")
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()

                Button("キャンセル", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("追加") {
                    addApp()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canAdd)
            }
        }
        .padding(24)
        .frame(width: 420)
    }

    private func selectApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.directoryURL = URL(filePath: "/Applications")
        panel.prompt = "選択"
        panel.treatsFilePackagesAsDirectories = false

        guard panel.runModal() == .OK,
            let url = panel.url
        else {
            return
        }

        selectedAppURL = url
        errorMessage = nil
    }

    private func sanitizeKeyInput() {
        guard let normalizedKey else {
            keyInput = ""
            return
        }

        if keyInput != normalizedKey {
            keyInput = normalizedKey
        }
    }

    private func addApp() {
        guard let selectedAppURL else {
            return
        }

        do {
            try store.add(appURL: selectedAppURL, key: keyInput)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
