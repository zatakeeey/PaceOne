import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let dateProvider: CurrentDateProvider

    init(habitStore: HabitStore = HabitStore(), dateProvider: CurrentDateProvider = CurrentDateProvider()) {
        self.dateProvider = dateProvider
        _viewModel = State(initialValue: HomeViewModel(habitStore: habitStore))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.loadFailed {
                    VStack(spacing: 12) {
                        Text("Не удалось загрузить привычки")
                            .font(.headline)
                        Text("Сохранённые данные не изменены.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                } else if viewModel.habits.isEmpty {
                    VStack(spacing: 20) {
                        Text("Пока ничего нет — добавьте привычку через \"+\" в углу или с помощью кнопки ниже!")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            viewModel.addButtonTapped()
                        } label: {
                            Text("Добавить привычку")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .frame(minHeight: 48)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.habits) { habit in
                                HabitCardView(habit: habit, currentDate: dateProvider.date)
                                    .onTapGesture {
                                        viewModel.selectedHabit = habit
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Text("Stay in motion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            .navigationTitle("Главная")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Привет!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addButtonTapped()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.loadFailed)
                }
            }
            .alert("Достигнут лимит привычек: \(viewModel.maxHabits)", isPresented: $viewModel.showLimitAlert) {
                Button("Понятно", role: .cancel) { }
            } message: {
                Text("Удалите одну из существующих привычек, чтобы добавить новую.")
            }
            .sheet(isPresented: $viewModel.showAddHabit) {
                AddHabitView { emoji, title, color, remindersEnabled, reminderTime in
                    viewModel.addHabit(emoji: emoji, title: title, color: color, remindersEnabled: remindersEnabled, reminderTime: reminderTime)
                }
            }
            .sheet(item: $viewModel.selectedHabit) { habit in
                HabitDetailView(viewModel: viewModel, habitID: habit.id)
                    .dynamicTypeSize(.large)
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView()
}
