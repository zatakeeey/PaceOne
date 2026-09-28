import SwiftUI

struct HabitCardView: View {
    let habit: Habit

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
            ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    // neon
                    .foregroundStyle(.white)
                    .shadow(color: habit.color.color.opacity(0.9), radius: 2)
                    .shadow(color: habit.color.color.opacity(0.7), radius: 5)
                    .shadow(color: habit.color.color.opacity(0.5), radius: 10)
            }
        }
    }
}

#Preview {
    HabitCardView(habit: Habit(emoji: "🎯", title: "Учить Swift", color: .blue))
        .padding()
}
