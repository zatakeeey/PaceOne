import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.habits.isEmpty {
                    Text("Пока ничего нет — добавьте цель через \"+\" в углу!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.habits) { habit in
                                HabitCardView(habit: habit)
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
                }
            }
            .alert("У вас уже 3 цели", isPresented: $viewModel.showLimitAlert) {
                Button("Понятно", role: .cancel) { }
            } message: {
                Text("Удалите одну из существующих целей, чтобы добавить новую.")
            }
            .sheet(isPresented: $viewModel.showAddHAbit) {
                AddHabitView { emoji, title, color, remindersEnabled, reminderTime in
                    viewModel.addHabit(emoji: emoji, title: title, color: color, remindersEnabled: remindersEnabled, reminderTime: reminderTime)
                }
            }
            .sheet(item: $viewModel.selectedHabit) { habit in
                HabitDetailView(viewModel: viewModel, habitID: habit.id)
            }
        }
    }
}

#Preview {
    HomeView()
}
