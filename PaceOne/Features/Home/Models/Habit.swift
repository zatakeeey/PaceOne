import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var emoji: String
    var title: String
    var color: HabitColor
    var remindersEnabled: Bool
    var reminderTime: Date?
    var createdAt: Date
    var completedDates: [Date]
    
    init(emoji: String, title: String, color: HabitColor, remindersEnabled: Bool = false, reminderTime: Date? = nil) {
        self.id = UUID()
        self.emoji = emoji
        self.title = title
        self.color = color
        self.remindersEnabled = remindersEnabled
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.completedDates = []
    }
}
