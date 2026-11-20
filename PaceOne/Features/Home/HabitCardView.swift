import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    var currentDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(habit.emoji)
                .font(.system(size: 36))
                .offset(y: -6)

            Text(habit.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            weekdayRow
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    habit.color.color.opacity(0.85),
                    habit.color.color.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var weekdayRow: some View {
        HStack(spacing: 10) {
            ForEach(habit.currentWeek(on: currentDate)) { day in
                Text(day.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(day.isCompleted ? 1 : 0.4))
                    .shadow(color: habit.color.color.opacity(day.isCompleted ? 0.9 : 0), radius: 2)
                    .shadow(color: habit.color.color.opacity(day.isCompleted ? 0.7 : 0), radius: 5)
                    .shadow(color: habit.color.color.opacity(day.isCompleted ? 0.5 : 0), radius: 10)
                    .accessibilityLabel("\(day.title): \(day.isCompleted ? "выполнено" : "не выполнено")")
            }
        }
    }
}

#Preview {
    HabitCardView(habit: Habit(emoji: "🎯", title: "Учить Swift", color: .blue))
        .padding()
}
