//
//  ContentView.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import SwiftUI

struct ContentView: View {
    @State private var store = LauncherStore()
    @State private var isAddingApp = false

    var body: some View {
        @Bindable var store = store
        List {
            if store.items.isEmpty {
                ContentUnavailableView(
                    "アプリが未登録です",
                    systemImage: "app.dashed",
                    description: Text("下の追加ボタンから登録してください。")
                )
                .frame(maxWidth: .infinity, minHeight: 120)
            }

            ForEach(store.items) { item in
                LauncherItemRow(item: item)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button("削除", systemImage: "trash", role: .destructive) {
                            store.remove(item)
                        }
                    }
            }

            Button {
                isAddingApp = true
            } label: {
                Label("アプリを追加", systemImage: "plus")
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 320, minHeight: 200)
        .toolbar(.hidden, for: .windowToolbar)
        .background(
            KeyCaptureView(isEnabled: !isAddingApp) { event in
                if store.launch(matching: event) {
                    AppDelegate.instance?.hideApp()
                    return true
                }
                return false
            }
        )
        .sheet(isPresented: $isAddingApp) {
            AddLauncherItemView(store: store)
        }
        .alert(
            "エラー",
            isPresented: Binding(
                get: { store.lastErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.lastErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.lastErrorMessage ?? "")
        }
        .onExitCommand {
            AppDelegate.instance?.hideApp()
        }
    }
}

private struct LauncherItemRow: View {
    let item: LauncherItem

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(item: item)

            Text(item.name)
                .lineLimit(1)

            Spacer()

            Text(item.displayKey)
                .font(.body.monospaced())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityLabel("キー \(item.displayKey)")
        }
        .padding(.vertical, 6)
    }
}

private struct AppIconView: View {
    let item: LauncherItem

    var body: some View {
        Image(nsImage: item.icon)
            .resizable()
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)
    }
}
