import SwiftUI
import GhosttyKit

/// View model for the settings UI. Reads current values from the Ghostty config
/// and writes changes to the config file, triggering a reload.
///
/// All settings use string representations matching the config file format.
/// Changes are written immediately (matching macOS System Settings behavior),
/// with debouncing for continuously-variable controls like sliders.
class SettingsViewModel: ObservableObject {
    /// A single setting backed by the config file.
    /// Handles reading from config, writing changes, and triggering reload.
    class Setting: ObservableObject {
        let key: String
        @Published var value: String

        private let save: (String, String) -> Void
        private var isLoading = true

        init(key: String, initial: String, save: @escaping (String, String) -> Void) {
            self.key = key
            self.value = initial
            self.save = save
            self.isLoading = false
        }

        func update(_ newValue: String) {
            guard !isLoading, value != newValue else { return }
            value = newValue
            save(key, newValue)
        }

        /// A Binding that writes through to the config file on change.
        var binding: Binding<String> {
            Binding(
                get: { self.value },
                set: { self.update($0) }
            )
        }

        /// Boolean binding for toggle controls.
        var boolBinding: Binding<Bool> {
            Binding(
                get: { self.value == "true" },
                set: { self.update($0 ? "true" : "false") }
            )
        }

        /// Double binding for numeric controls.
        var doubleBinding: Binding<Double> {
            Binding(
                get: { Double(self.value) ?? 0 },
                set: { self.update(String($0)) }
            )
        }
    }

    // MARK: - Settings

    // General
    private(set) lazy var fontFamily = makeSetting("font-family")
    private(set) lazy var fontSize = makeSetting("font-size")
    private(set) lazy var fontThicken = makeSetting("font-thicken")
    private(set) lazy var cursorStyle = makeSetting("cursor-style")
    private(set) lazy var cursorStyleBlink = makeSetting("cursor-style-blink")
    private(set) lazy var mouseHideWhileTyping = makeSetting("mouse-hide-while-typing")
    private(set) lazy var copyOnSelect = makeSetting("copy-on-select")
    private(set) lazy var shellIntegration = makeSetting("shell-integration")
    private(set) lazy var quitAfterLastWindowClosed = makeSetting("quit-after-last-window-closed")
    private(set) lazy var confirmCloseSurface = makeSetting("confirm-close-surface")
    private(set) lazy var focusFollowsMouse = makeSetting("focus-follows-mouse")

    // Appearance
    private(set) lazy var windowTheme = makeSetting("window-theme")
    private(set) lazy var windowDecoration = makeSetting("window-decoration")
    private(set) lazy var backgroundOpacity = makeSetting("background-opacity")
    private(set) lazy var minimumContrast = makeSetting("minimum-contrast")
    private(set) lazy var unfocusedSplitOpacity = makeSetting("unfocused-split-opacity")
    private(set) lazy var resizeOverlay = makeSetting("resize-overlay")

    // macOS
    private(set) lazy var macosTitlebarStyle = makeSetting("macos-titlebar-style")
    private(set) lazy var macosOptionAsAlt = makeSetting("macos-option-as-alt")
    private(set) lazy var macosNonNativeFullscreen = makeSetting("macos-non-native-fullscreen")
    private(set) lazy var macosWindowButtons = makeSetting("macos-window-buttons")
    private(set) lazy var macosTitlebarProxyIcon = makeSetting("macos-titlebar-proxy-icon")
    private(set) lazy var macosIcon = makeSetting("macos-icon")
    private(set) lazy var macosAutoSecureInput = makeSetting("macos-auto-secure-input")
    private(set) lazy var macosWindowShadow = makeSetting("macos-window-shadow")
    private(set) lazy var quickTerminalPosition = makeSetting("quick-terminal-position")
    private(set) lazy var quickTerminalAnimationDuration = makeSetting("quick-terminal-animation-duration")
    private(set) lazy var quickTerminalAutoHide = makeSetting("quick-terminal-autohide")

    // Advanced
    private(set) lazy var autoUpdate = makeSetting("auto-update")
    private(set) lazy var autoUpdateChannel = makeSetting("auto-update-channel")
    private(set) lazy var windowSaveState = makeSetting("window-save-state")

    // MARK: - Internal

    private let config: Ghostty.Config
    private var configValues: [String: String] = [:]

    init(config: Ghostty.Config) {
        self.config = config
        self.configValues = Self.readAllValues(config: config)
    }

    // MARK: - Setting Factory

    private func makeSetting(_ key: String) -> Setting {
        let initial = configValues[key] ?? ""
        return Setting(key: key, initial: initial) { [weak self] key, value in
            self?.persistAndReload(key: key, value: value)
        }
    }

    private func persistAndReload(key: String, value: String) {
        guard ConfigFileEditor.applyChanges([key: value]) else { return }
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.reloadConfig(nil)
    }

    // MARK: - Config Value Reading

    /// Read all settings values we care about from the config.
    /// Uses the C API for typed reads, falling back to config file for unsupported types.
    private static func readAllValues(config: Ghostty.Config) -> [String: String] {
        guard let cfg = config.config else { return [:] }
        var values: [String: String] = [:]

        // Enums - read as string pointers
        let enumKeys = [
            "cursor-style", "cursor-style-blink", "copy-on-select",
            "shell-integration", "confirm-close-surface",
            "window-theme", "window-decoration", "resize-overlay",
            "macos-titlebar-style", "macos-option-as-alt",
            "macos-non-native-fullscreen", "macos-window-buttons",
            "macos-titlebar-proxy-icon", "macos-icon",
            "auto-update", "auto-update-channel", "window-save-state",
            "quick-terminal-position",
        ]
        for key in enumKeys {
            if let v = readString(cfg, key: key) { values[key] = v }
        }

        // Bools
        let boolKeys = [
            "mouse-hide-while-typing", "quit-after-last-window-closed",
            "focus-follows-mouse", "font-thicken",
            "macos-auto-secure-input", "macos-window-shadow",
            "quick-terminal-autohide",
        ]
        for key in boolKeys {
            if let v = readBool(cfg, key: key) { values[key] = v ? "true" : "false" }
        }

        // f64 values
        let f64Keys = [
            "background-opacity", "minimum-contrast", "unfocused-split-opacity",
            "quick-terminal-animation-duration",
        ]
        for key in f64Keys {
            if let v = readF64(cfg, key: key) { values[key] = String(v) }
        }

        // f32 values
        if let v = readF32(cfg, key: "font-size") { values["font-size"] = String(v) }

        // RepeatableString types - not accessible via C API, read from file
        if let v = readFromConfigFile(key: "font-family") { values["font-family"] = v }

        return values
    }

    // MARK: - C API Typed Readers

    private static func readString(_ cfg: ghostty_config_t, key: String) -> String? {
        var v: UnsafePointer<Int8>?
        guard ghostty_config_get(cfg, &v, key, UInt(key.utf8.count)),
              let ptr = v else { return nil }
        return String(cString: ptr)
    }

    private static func readBool(_ cfg: ghostty_config_t, key: String) -> Bool? {
        var v = false
        guard ghostty_config_get(cfg, &v, key, UInt(key.utf8.count)) else { return nil }
        return v
    }

    private static func readF64(_ cfg: ghostty_config_t, key: String) -> Double? {
        var v: Double = 0
        guard ghostty_config_get(cfg, &v, key, UInt(key.utf8.count)) else { return nil }
        return v
    }

    private static func readF32(_ cfg: ghostty_config_t, key: String) -> Float? {
        var v: Float = 0
        guard ghostty_config_get(cfg, &v, key, UInt(key.utf8.count)) else { return nil }
        return v
    }

    private static func readFromConfigFile(key: String) -> String? {
        guard let path = ConfigFileEditor.configFilePath(),
              let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        var result: String?
        for line in ConfigFileEditor.parse(contents: contents) {
            if case .setting(let k, let v, _) = line, k == key { result = v }
        }
        return result
    }
}
