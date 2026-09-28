import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedEmoji: String
    @State private var title = ""
    @State private var selectedColor: HabitColor = .blue
    @State private var remindersEnabled = false
    @State private var reminderTime: Date

    var onSave: (String, String, HabitColor, Bool, Date?) -> Void

    private let emojiOptions = [
        "🎯", "📚", "💪", "🏃", "🧘", "💧", "🥗", "😴", "✍️", "🎸",
        "🧑‍💻", "🎨", "🧹", "🚭", "🌱", "🙏", "🚴", "🧠", "💰", "📵",
        "☀️", "🌙", "🎧", "☕️", "📖", "✏️", "🏋️", "🏊", "🚶", "🦷",
        "🧴", "⏰", "📅", "✅", "⭐️", "🔥", "❤️", "🍎", "🍊", "🥦",
        "🍋", "🧊", "🌊", "🎹", "📷", "🧵", "🧩", "🎮", "📈", "🛏️"
    ]

    private let gridRows = [
        GridItem(.fixed(46), spacing: 12),
        GridItem(.fixed(46), spacing: 12)
    ]

    init(onSave: @escaping (String, String, HabitColor, Bool, Date?) -> Void) {
        self.onSave = onSave
        self._selectedEmoji = State(initialValue: emojiOptions[0])

        var defaultTimeComponents = DateComponents()
        defaultTimeComponents.hour = 9
        defaultTimeComponents.minute = 0
        let defaultTime = Calendar.current.date(from: defaultTimeComponents) ?? Date()
        self._reminderTime = State(initialValue: defaultTime)
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
                                    .init(color: .black, location: 0.97),
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
            .navigationTitle("Новая цель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
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
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    AddHabitView(onSave: { _, _, _, _, _ in })
}
