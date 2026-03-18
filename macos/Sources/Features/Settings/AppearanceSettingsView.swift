import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Window Theme", selection: viewModel.windowTheme.binding) {
                    Text("Auto").tag("auto")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("Ghostty").tag("ghostty")
                }
            }

            Section("Window") {
                Picker("Window Decorations", selection: viewModel.windowDecoration.binding) {
                    Text("Auto").tag("auto")
                    Text("None").tag("none")
                    Text("Client").tag("client")
                    Text("Server").tag("server")
                }

                Picker("Resize Overlay", selection: viewModel.resizeOverlay.binding) {
                    Text("Always").tag("always")
                    Text("Never").tag("never")
                    Text("After First").tag("after-first")
                }
            }

            Section("Transparency") {
                SliderSetting(
                    "Background Opacity",
                    setting: viewModel.backgroundOpacity,
                    range: 0...1
                ) { String(format: "%.0f%%", $0 * 100) }

                SliderSetting(
                    "Unfocused Split Opacity",
                    setting: viewModel.unfocusedSplitOpacity,
                    range: 0.15...1
                ) { String(format: "%.0f%%", $0 * 100) }
            }

            Section("Contrast") {
                SliderSetting(
                    "Minimum Contrast",
                    setting: viewModel.minimumContrast,
                    range: 1...21
                ) { String(format: "%.1f", $0) }
            }
        }
        .formStyle(.grouped)
    }
}
