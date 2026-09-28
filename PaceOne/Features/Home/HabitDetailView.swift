import SwiftUI

struct HabitDetailView: View {
    var viewModel: HomeViewModel
    let habitID: UUID

    private var habit: Habit? {
        viewModel.habits.first(where: { $0.id == habitID })
    }

    var body: some View {
        if let habit {
            VStack(spacing: 24) {
                topBar(habit: habit)

                Text(habit.emoji)
                    .font(.system(size: 60))

                Text(habit.title)
                    .font(.title)
                    .fontWeight(.bold)

                statsRow

                calendarGrid
                    .padding(.top, 12)

                Spacer()
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Верхняя панель с кнопками
    private func topBar(habit: Habit) -> some View {
        HStack {
            Button {
                // меню редактировать/удалить — следующий подшаг
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleCompletion(for: habit.id)
                }
            } label: {
                Image(systemName: viewModel.isCompletedToday(habit)
                      ? "arrow.uturn.backward"
                      : "checkmark")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Блоки статистики (стрик / всего дней)
    private var statsRow: some View {
        HStack(spacing: 12) {
            statBlock(value: "5", label: "Подряд", icon: "flame.fill")
            statBlock(value: "23", label: "Дней всего", icon: "calendar")
        }
        .padding(.horizontal)
    }

    private func statBlock(value: String, label: String, icon: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Календарь
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            Text("Сентябрь")
                .font(.headline)

            HStack {
                ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...30, id: \.self) { day in
                    let isCompleted = [6, 7, 9, 11, 12, 14, 16, 19, 21].contains(day)

                    Text("\(day)")
                        .font(.subheadline)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isCompleted ? Color.accentColor.opacity(0.3) : Color.clear)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let vm = HomeViewModel()
    let habit = Habit(emoji: "🎯", title: "Учить Swift", color: .blue)
    vm.habits = [habit]
    return HabitDetailView(viewModel: vm, habitID: habit.id)
}
