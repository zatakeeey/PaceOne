import Foundation
import Observation

@Observable
final class HabitStore {
    private(set) var loadFailed = false

    var habits: [Habit] = [] {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let storageKey = "savedHabits"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let storedValue = defaults.object(forKey: storageKey) else { return }
        guard let data = storedValue as? Data else {
            loadFailed = true
            return
        }
        do {
            habits = try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            loadFailed = true
        }
    }

    private func save() {
        // Не заменяем исходную запись, если её не удалось прочитать.
        guard !loadFailed else { return }
        if let data = try? JSONEncoder().encode(habits) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
