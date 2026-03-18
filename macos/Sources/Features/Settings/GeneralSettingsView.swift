import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Font") {
                HStack {
                    Text("Font Family")
                    Spacer()
                    TextField("e.g. JetBrains Mono", text: $viewModel.fontFamily)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }

                HStack {
                    Text("Font Size")
                    Spacer()
                    TextField("Size", value: $viewModel.fontSize, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Stepper("", value: $viewModel.fontSize, in: 1...200, step: 1)
                        .labelsHidden()
                }

                Toggle("Thicken Font Strokes", isOn: $viewModel.fontThicken)
            }

            Section("Cursor") {
                Picker("Cursor Style", selection: $viewModel.cursorStyle) {
                    Text("Block").tag("block")
                    Text("Bar").tag("bar")
                    Text("Underline").tag("underline")
                }
                .pickerStyle(.segmented)

                Picker("Cursor Blink", selection: $viewModel.cursorStyleBlink) {
                    Text("Default").tag("")
                    Text("On").tag("true")
                    Text("Off").tag("false")
                }
            }

            Section("Terminal") {
                Picker("Shell Integration", selection: $viewModel.shellIntegration) {
                    Text("Detect").tag("detect")
                    Text("None").tag("none")
                    Text("Fish").tag("fish")
                    Text("Zsh").tag("zsh")
                    Text("Bash").tag("bash")
                    Text("Elvish").tag("elvish")
                }

                Picker("Copy on Select", selection: $viewModel.copyOnSelect) {
                    Text("Off").tag("false")
                    Text("On").tag("true")
                    Text("Clipboard").tag("clipboard")
                }

                Toggle("Hide Mouse While Typing", isOn: $viewModel.mouseHideWhileTyping)
                Toggle("Focus Follows Mouse", isOn: $viewModel.focusFollowsMouse)
            }

            Section("Window") {
                Picker("Confirm Before Closing", selection: $viewModel.confirmCloseSurface) {
                    Text("Yes").tag("true")
                    Text("No").tag("false")
                    Text("Always").tag("always")
                }

                Toggle("Quit After Last Window Closed", isOn: $viewModel.quitAfterLastWindowClosed)
            }
        }
        .formStyle(.grouped)
    }
}
