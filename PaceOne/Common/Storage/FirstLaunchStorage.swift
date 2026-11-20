import Foundation

final class AppUsageStore {
    let firstLaunchDate: Date

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        let key = "firstLaunchDate"
        if let saved = defaults.object(forKey: key) as? Date {
            firstLaunchDate = saved
        } else {
            firstLaunchDate = now
            defaults.set(now, forKey: key)
        }
    }

    func elapsedDays(on date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: firstLaunchDate)
        let end = calendar.startOfDay(for: date)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }
}
