import Foundation

struct HabitWeekDay: Identifiable {
    let date: Date
    let title: String
    let isCompleted: Bool

    var id: Date { date }
}

extension Habit {
    func currentWeek(on date: Date, calendar: Calendar = .current) -> [HabitWeekDay] {
        let today = calendar.startOfDay(for: date)
        let offset = (calendar.component(.weekday, from: today) + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -offset, to: today) else {
            return []
        }

        let titles = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        return titles.enumerated().compactMap { index, title in
            guard let day = calendar.date(byAdding: .day, value: index, to: monday) else {
                return nil
            }
            return HabitWeekDay(
                date: day,
                title: title,
                isCompleted: completedDates.contains { calendar.isDate($0, inSameDayAs: day) }
            )
        }
    }
}
