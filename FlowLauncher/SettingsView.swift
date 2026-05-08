//
//  SettingsView.swift
//  FlowLauncher
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Flow")
                            .font(.headline)
                        Text(settings.appVersion)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text("キーを押したら対応したアプリを開くシンプルなランチャー")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("起動設定") {
                Picker("起動ホットキー", selection: $settings.hotkeyModifier) {
                    ForEach(ModifierKey.allCases) { key in
                        Text("\(key.displayString) の2連打").tag(key)
                    }
                }
                .help("指定したキーを2回連続で押すとランチャーが開きます。")

                Toggle("ログイン時に自動起動", isOn: $settings.launchAtLogin)
                    .help("Macの起動時に自動的にFlowを開始します。")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
    }
}

#Preview {
    SettingsView()
}
