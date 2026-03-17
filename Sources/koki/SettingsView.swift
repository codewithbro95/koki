import SwiftUI

struct SettingsView: View {
    @StateObject private var model: SettingsViewModel

    init(state: AppState) {
        _model = StateObject(wrappedValue: SettingsViewModel(appState: state))
    }

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $model.selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
        } detail: {
            SettingsDetailView(model: model, section: model.selection)
        }
        .frame(width: 760, height: 520)
        .onDisappear {
            model.recorder.stop()
        }
    }
}

private struct SettingsDetailView: View {
    @ObservedObject var model: SettingsViewModel
    let section: SettingsSection

    var body: some View {
        switch section {
        case .general:
            GeneralSettingsView(model: model)
        case .voice:
            VoiceSettingsView(model: model)
        case .about:
            AboutSettingsView(model: model)
        }
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var recorder: HotKeyRecorder

    init(model: SettingsViewModel) {
        self.model = model
        self.recorder = model.recorder
    }

    var body: some View {
        Form {
            Section("Shortcut") {
                LabeledContent("Current Shortcut") {
                    ShortcutBadge(text: model.settings.hotKey.displayValue)
                }

                HStack(spacing: 10) {
                    Button {
                        recorder.start()
                    } label: {
                        Label(
                            recorder.isRecording ? "Listening for Keys…" : "Set Shortcut",
                            systemImage: recorder.isRecording ? "record.circle" : "keyboard"
                        )
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        recorder.start()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .help("Update shortcut")
                }

                let isWarning = recorder.hint.hasPrefix("Use exactly")
                Text(recorder.hint)
                    .font(.subheadline)
                    .foregroundStyle(isWarning ? Color.orange : Color.secondary)
            }

            if model.hasAccessibilityPermission == false {
                Section("Permissions") {
                    Text("Koki needs Accessibility permission to read selected text from other apps.")
                        .foregroundStyle(.secondary)

                    Button("Request Accessibility Permission") {
                        model.requestAccessibilityPermission()
                        model.refreshAccessibilityPermission()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(SettingsSection.general.title)
        .onAppear {
            model.refreshAccessibilityPermission()
        }
    }
}

private struct VoiceSettingsView: View {
    @ObservedObject var model: SettingsViewModel

    var body: some View {
        Form {
            Section {
                if model.hasSystemVoices {
                    LabeledContent("System Voice") {
                        HStack(spacing: 8) {
                            Picker("System Voice", selection: voiceIdentifierBinding) {
                                ForEach(voiceGroups, id: \.0) { group in
                                    Section(group.0) {
                                        ForEach(group.1) { voice in
                                            Text(voice.name)
                                                .tag(voice.id)
                                        }
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()

                            Button {
                                model.previewVoice()
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .buttonStyle(.borderless)
                            .help("Play a sample of the selected voice")
                        }
                    }
                } else {
                    Text("No system voices found. Install one in System Settings > Accessibility > Spoken Content > System Voice.")
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Speaking Rate") {
                    HStack {
                        Slider(value: speechRateBinding, in: 120...320)
                        Text("\(Int(model.settings.speechRate))")
                            .monospacedDigit()
                            .frame(width: 44)
                    }
                }

                HStack {
                    Button("Play Sample") {
                        model.previewVoice()
                    }
                    .disabled(model.hasSystemVoices == false)

                    Button("Stop") {
                        model.stopReading()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(SettingsSection.voice.title)
        .onAppear {
            model.syncSelectedVoice()
        }
    }

    private var voiceIdentifierBinding: Binding<String> {
        Binding {
            model.selectedVoiceID
        } set: { value in
            model.updateSelectedVoice(value)
        }
    }

    private var speechRateBinding: Binding<Double> {
        Binding {
            model.settings.speechRate
        } set: { value in
            model.settings.speechRate = value
        }
    }

    private var voiceGroups: [(String, [SystemVoice])] {
        let grouped = Dictionary(grouping: model.availableVoices) { voice in
            voice.locale.isEmpty ? "Other" : voice.locale
        }

        return grouped.keys.sorted { lhs, rhs in
            lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }.map { key in
            let voices = grouped[key, default: []].sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return (key, voices)
        }
    }
}

private struct AboutSettingsView: View {
    @ObservedObject var model: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("🌮")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Give your eyes a break")
                        .font(.title2)
                    Text("A tiny macOS utility that lets you select any text, hit a hotkey, and hear it read out loud. Great for long emails, docs, or web articles when your eyes need a break.")
                        .foregroundStyle(.secondary)
                }
            }

            Text("Status: \(model.appState.lastStatus)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Button("Check for Updates") {
                    model.checkForUpdates()
                }
                Button("Open About Panel") {
                    model.showAbout()
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(SettingsSection.about.title)
    }
}

private struct ShortcutBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.headline)
            .monospaced()
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
    }
}
