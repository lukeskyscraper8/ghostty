import SwiftUI

/// A slider control that displays a label, formatted value, and range slider.
/// Debounces writes to avoid excessive config saves while dragging.
struct SliderSetting: View {
    let title: String
    let setting: SettingsViewModel.Setting
    let range: ClosedRange<Double>
    let format: (Double) -> String
    let step: Double?

    @State private var localValue: Double
    @State private var debounceTask: Task<Void, Never>?

    init(
        _ title: String,
        setting: SettingsViewModel.Setting,
        range: ClosedRange<Double>,
        step: Double? = nil,
        format: @escaping (Double) -> String
    ) {
        self.title = title
        self.setting = setting
        self.range = range
        self.step = step
        self.format = format
        self._localValue = State(initialValue: Double(setting.value) ?? range.lowerBound)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(format(localValue))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            if let step {
                Slider(value: $localValue, in: range, step: step)
                    .onChange(of: localValue) { debouncedSave() }
            } else {
                Slider(value: $localValue, in: range)
                    .onChange(of: localValue) { debouncedSave() }
            }
        }
    }

    private func debouncedSave() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            setting.update(String(localValue))
        }
    }
}

/// A stepper with a text field for numeric input.
struct NumericSetting: View {
    let title: String
    let setting: SettingsViewModel.Setting
    let range: ClosedRange<Double>
    let step: Double

    @State private var localValue: Double

    init(_ title: String, setting: SettingsViewModel.Setting, range: ClosedRange<Double>, step: Double = 1) {
        self.title = title
        self.setting = setting
        self.range = range
        self.step = step
        self._localValue = State(initialValue: Double(setting.value) ?? range.lowerBound)
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: $localValue, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .onSubmit { setting.update(String(localValue)) }
            Stepper("", value: $localValue, in: range, step: step)
                .labelsHidden()
                .onChange(of: localValue) { setting.update(String(localValue)) }
        }
    }
}
