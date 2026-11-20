import SwiftUI

struct AddHabitView: View {
    enum Mode {
        case create
        case edit(Habit)
    }

    @Environment(\.dismiss) private var dismiss

    var mode: Mode
    var onSave: (String, String, HabitColor, Bool, Date?) -> Void

    @State private var selectedEmoji: String
    @State private var title: String
    @State private var selectedColor: HabitColor
    @State private var remindersEnabled: Bool
    @State private var reminderTime: Date

    private let emojiOptions = [
        "🎯", "💧", "💪", "📚", "🏃", "😴", "🚶", "🧘", "🥗", "✍️",
        "🧑‍💻", "🧠", "📵", "🚭", "💰", "🦷", "☀️", "⏰", "🏋️", "🚴",
        "🏊", "🛏️", "🌙", "🧹", "🧴", "🍎", "🥦", "📖", "✏️", "☕️",
        "🎸", "🎨", "🎧", "🌱", "🙏", "❤️", "📈", "📅", "✅", "🔥",
        "⭐️", "🍊", "🍋", "🎹", "📷", "🧵", "🧩", "🎮", "🌊", "🧊"
    ]

    private let gridRows = [
        GridItem(.fixed(46), spacing: 12),
        GridItem(.fixed(46), spacing: 12)
    ]

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    init(mode: Mode = .create, onSave: @escaping (String, String, HabitColor, Bool, Date?) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            self._selectedEmoji = State(initialValue: emojiOptions[0])
            self._title = State(initialValue: "")
            self._selectedColor = State(initialValue: .blue)
            self._remindersEnabled = State(initialValue: false)

            var defaultTimeComponents = DateComponents()
            defaultTimeComponents.hour = 9
            defaultTimeComponents.minute = 0
            let defaultTime = Calendar.current.date(from: defaultTimeComponents) ?? Date()
            self._reminderTime = State(initialValue: defaultTime)

        case .edit(let habit):
            self._selectedEmoji = State(initialValue: habit.emoji)
            self._title = State(initialValue: habit.title)
            self._selectedColor = State(initialValue: habit.color)
            self._remindersEnabled = State(initialValue: habit.remindersEnabled)
            self._reminderTime = State(initialValue: habit.reminderTime ?? Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Text(selectedEmoji)
                            .font(.system(size: 60))

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: gridRows, spacing: 12) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.title)
                                            .frame(width: 48, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(emoji == selectedEmoji ? Color.accentColor : .clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black, location: 0.03),
                                    .init(color: .black, location: 0.985),
                                    .init(color: .clear, location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                Section("Название") {
                    TextField("Например, Учить Swift", text: $title)
                }

                Section("Цвет") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HabitColor.allCases) { habitColor in
                                Button {
                                    selectedColor = habitColor
                                } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(habitColor.color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                                .opacity(habitColor == selectedColor ? 1 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Напоминания") {
                    Toggle("Напоминать каждый день", isOn: $remindersEnabled.animation(.easeInOut(duration: 0.25)))
                }
                .listSectionSpacing(8)

                if remindersEnabled {
                    Section {
                        DatePicker("Время", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle(isEditMode ? "Редактировать привычку" : "Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditMode ? "Сохранить" : "Готово") {
                        onSave(
                            selectedEmoji,
                            title,
                            selectedColor,
                            remindersEnabled,
                            remindersEnabled ? reminderTime : nil
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedEmoji)
        .sensoryFeedback(.selection, trigger: selectedColor)
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    AddHabitView(onSave: { _, _, _, _, _ in })
}
