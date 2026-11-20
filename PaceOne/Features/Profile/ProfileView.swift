import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(
        habitStore: HabitStore = HabitStore(),
        usageStore: AppUsageStore = AppUsageStore(),
        dateProvider: CurrentDateProvider = CurrentDateProvider()
    ) {
        _viewModel = State(initialValue: ProfileViewModel(
            habitStore: habitStore,
            usageStore: usageStore,
            dateProvider: dateProvider
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    ProfileHeaderView(viewModel: viewModel)

                    statsRow

                    SettingsSectionView()

                    Text("by Georgiy P.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCardView(title: "Привычки", value: "\(viewModel.goalCount)", icon: "target", color: .purple)
            StatCardView(title: "Дней вместе", value: "\(viewModel.daysTogether)", icon: "calendar", color: .orange)
            StatCardView(title: "Выполнений", value: "\(viewModel.totalCompletions)", icon: "checkmark.circle", color: .green)
        }
    }
}

#Preview {
    ProfileView()
}
