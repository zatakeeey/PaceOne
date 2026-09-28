import Foundation
import Observation

@Observable
class HomeViewModel {
    var habits: [Habit] = []
    var showLimitAlert = false
    var showAddHAbit = false
    var selectedHabit: Habit?
    
    private let maxHabits = 3
    
    func addButtonTapped() {
        if habits.count >= maxHabits {
            showLimitAlert = true
        } else {
            showAddHAbit = true
        }
    }
    
    func addHabit(emoji: String, title: String, color: HabitColor, remindersEnabled: Bool, reminderTime: Date?) {
        let newHabit = Habit(emoji: emoji, title: title, color: color, remindersEnabled: remindersEnabled, reminderTime: reminderTime)
        habits.append(newHabit)
    }
    
    func isCompletedToday(_ habit: Habit) -> Bool {
        habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: Date()) }
    }

    func toggleCompletion(for habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }

        let calendar = Calendar.current
        if let existingIndex = habits[index].completedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            habits[index].completedDates.remove(at: existingIndex)
        } else {
            habits[index].completedDates.append(Date())
        }
    }
}
