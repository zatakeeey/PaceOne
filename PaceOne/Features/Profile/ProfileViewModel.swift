import Foundation
import Observation

@Observable
class ProfileViewModel {
    private static let nicknameKey = "profileNickname"
    private let habitStore: HabitStore
    private let usageStore: AppUsageStore
    private let dateProvider: CurrentDateProvider

    var goalCount: Int { habitStore.habits.count }
    var daysTogether: Int { usageStore.elapsedDays(on: dateProvider.date) }

    var totalCompletions: Int {
        habitStore.habits.reduce(0) { total, habit in
            total + habit.completedDates.count
        }
    }

    var nickname: String = "Пользователь" {
        didSet { UserDefaults.standard.set(nickname, forKey: Self.nicknameKey) }
    }

    init(
        habitStore: HabitStore = HabitStore(),
        usageStore: AppUsageStore = AppUsageStore(),
        dateProvider: CurrentDateProvider = CurrentDateProvider()
    ) {
        self.habitStore = habitStore
        self.usageStore = usageStore
        self.dateProvider = dateProvider
        if let saved = UserDefaults.standard.string(forKey: Self.nicknameKey) {
            nickname = saved
        }
    }

    var avatarLetter: String {
        String(nickname.first ?? "?")
    }

    func saveNickname(_ draft: String) {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        nickname = trimmed
    }
}
