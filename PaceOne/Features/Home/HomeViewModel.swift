import Foundation
import Observation

@Observable
class HomeViewModel {
    private let habitStore: HabitStore

    var loadFailed: Bool { habitStore.loadFailed }

    var habits: [Habit] {
        get { habitStore.habits }
        set {
            guard !loadFailed else { return }
            habitStore.habits = newValue
        }
    }
    var showLimitAlert = false
    var showAddHabit = false
    var selectedHabit: Habit?

    let maxHabits = 3
    init(habitStore: HabitStore = HabitStore()) {
        self.habitStore = habitStore
    }

    // MARK: - Действия

    func addButtonTapped() {
        guard !loadFailed else { return }
        if habits.count >= maxHabits {
            showLimitAlert = true
        } else {
            showAddHabit = true
        }
    }

    func addHabit(emoji: String, title: String, color: HabitColor, remindersEnabled: Bool, reminderTime: Date?) {
        guard !loadFailed else { return }
        let newHabit = Habit(emoji: emoji, title: title, color: color, remindersEnabled: remindersEnabled, reminderTime: reminderTime)
        habits.append(newHabit)

        if remindersEnabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    NotificationManager.shared.scheduleReminder(for: newHabit)
                }
            }
        }
    }

    func updateHabit(
        habitID: UUID,
        emoji: String,
        title: String,
        color: HabitColor,
        remindersEnabled: Bool,
        reminderTime: Date?
    ) {
        guard !loadFailed else { return }
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].emoji = emoji
        habits[index].title = title
        habits[index].color = color
        habits[index].remindersEnabled = remindersEnabled
        habits[index].reminderTime = reminderTime

        let updatedHabit = habits[index]
        NotificationManager.shared.cancelReminder(for: habitID)

        if remindersEnabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    NotificationManager.shared.scheduleReminder(for: updatedHabit)
                }
            }
        }
    }

    func deleteHabit(_ habitID: UUID) {
        guard !loadFailed else { return }
        habits.removeAll { $0.id == habitID }
        NotificationManager.shared.cancelReminder(for: habitID)
    }

    func isCompletedToday(_ habit: Habit) -> Bool {
        habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: Date()) }
    }

    func toggleCompletion(for habitID: UUID, on date: Date = Date()) {
        guard !loadFailed else { return }
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }

        let calendar = Calendar.current
        if let existingIndex = habits[index].completedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            habits[index].completedDates.remove(at: existingIndex)
        } else {
            habits[index].completedDates.append(date)
        }
    }

    func totalCompletedDays(_ habit: Habit) -> Int {
        habit.completedDates.count
    }

    func currentStreak(_ habit: Habit) -> Int {
        let calendar = Calendar.current
        let completedDays = Set(
            habit.completedDates.map {
                calendar.startOfDay(for: $0)
            }
        )
        var cursor = calendar.startOfDay(for: Date())

        // Если сегодня ещё не выполнено,
        // проверяем вчерашний день
        if !completedDays.contains(cursor) {
            guard let yesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: cursor
            ), completedDays.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }
        var streak = 0

        // Считаем выполненные дни подряд
        while completedDays.contains(cursor) {
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: cursor
            ) else {
                break
            }
            cursor = previousDay
        }
        return streak
    }
}
