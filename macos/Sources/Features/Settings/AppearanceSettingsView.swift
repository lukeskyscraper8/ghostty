import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Window Theme", selection: $viewModel.windowTheme) {
                    Text("Auto").tag("auto")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("Ghostty").tag("ghostty")
                }
            }

            Section("Window") {
                Picker("Window Decorations", selection: $viewModel.windowDecoration) {
                    Text("Auto").tag("auto")
                    Text("None").tag("none")
                    Text("Client").tag("client")
                    Text("Server").tag("server")
                }

                Picker("Resize Overlay", selection: $viewModel.resizeOverlay) {
                    Text("Always").tag("always")
                    Text("Never").tag("never")
                    Text("After First").tag("after-first")
                }
            }

            Section("Transparency") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Background Opacity")
                        Spacer()
                        Text(String(format: "%.0f%%", viewModel.backgroundOpacity * 100))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $viewModel.backgroundOpacity, in: 0...1)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Unfocused Split Opacity")
                        Spacer()
                        Text(String(format: "%.0f%%", viewModel.unfocusedSplitOpacity * 100))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $viewModel.unfocusedSplitOpacity, in: 0.15...1)
                }
            }

            Section("Contrast") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Minimum Contrast")
                        Spacer()
                        Text(String(format: "%.1f", viewModel.minimumContrast))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $viewModel.minimumContrast, in: 1...21)
                }
            }
        }
        .formStyle(.grouped)
    }
}
