import Foundation
import GhosttyKit

/// Utility for reading, parsing, and writing the Ghostty config file.
/// Preserves comments, blank lines, and formatting when modifying settings.
class ConfigFileEditor {
    enum ConfigLine {
        case blank
        case comment(String)
        case setting(key: String, value: String, originalLine: String)
        case unknown(String)
    }

    /// Returns the path to the user's config file.
    static func configFilePath() -> String? {
        let allocated = Ghostty.AllocatedString(ghostty_config_open_path())
        let path = allocated.string
        return path.isEmpty ? nil : path
    }

    /// Parse config file contents into structured lines.
    static func parse(contents: String) -> [ConfigLine] {
        let rawLines = contents.components(separatedBy: "\n")
        return rawLines.map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                return .blank
            }

            if trimmed.hasPrefix("#") {
                return .comment(line)
            }

            // Try to parse as key = value
            if let eqIndex = trimmed.firstIndex(of: "=") {
                let key = String(trimmed[trimmed.startIndex..<eqIndex])
                    .trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: eqIndex)...])
                    .trimmingCharacters(in: .whitespaces)

                if !key.isEmpty, !key.contains(" ") {
                    return .setting(key: key, value: value, originalLine: line)
                }
            }

            return .unknown(line)
        }
    }

    /// Serialize structured lines back to a string.
    static func serialize(lines: [ConfigLine]) -> String {
        let result = lines.map { line -> String in
            switch line {
            case .blank:
                return ""
            case .comment(let text):
                return text
            case .setting(let key, let value, _):
                return "\(key) = \(value)"
            case .unknown(let text):
                return text
            }
        }
        return result.joined(separator: "\n")
    }

    /// Update a single key-value pair in the parsed lines.
    /// If the key exists, updates the last occurrence.
    /// If the key doesn't exist, appends it at the end.
    static func updateValue(key: String, value: String, in lines: inout [ConfigLine]) {
        // Find the last occurrence of this key
        var lastIndex: Int?
        for (i, line) in lines.enumerated() {
            if case .setting(let k, _, _) = line, k == key {
                lastIndex = i
            }
        }

        if let idx = lastIndex {
            lines[idx] = .setting(key: key, value: value, originalLine: "")
        } else {
            // Append at the end, adding a blank line separator if needed
            if let last = lines.last, case .blank = last {
                // Already ends with blank
            } else if !lines.isEmpty {
                lines.append(.blank)
            }
            lines.append(.setting(key: key, value: value, originalLine: ""))
        }
    }

    /// Remove a key from the config (resets to default).
    /// Removes all occurrences of the key.
    static func removeValue(key: String, in lines: inout [ConfigLine]) {
        lines.removeAll { line in
            if case .setting(let k, _, _) = line, k == key {
                return true
            }
            return false
        }
    }

    /// Read the config file, apply changes, and write it back atomically.
    /// - Parameter changes: Dictionary of key-value pairs to update.
    ///   A nil value means remove the key (reset to default).
    static func applyChanges(_ changes: [String: String?]) -> Bool {
        guard let path = configFilePath() else { return false }

        let fileURL = URL(fileURLWithPath: path)

        // Read existing contents or start fresh
        let contents: String
        do {
            contents = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            contents = ""
        }

        var lines = parse(contents: contents)

        for (key, value) in changes {
            if let value = value {
                updateValue(key: key, value: value, in: &lines)
            } else {
                removeValue(key: key, in: &lines)
            }
        }

        let newContents = serialize(lines: lines)

        // Write atomically
        do {
            try newContents.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
