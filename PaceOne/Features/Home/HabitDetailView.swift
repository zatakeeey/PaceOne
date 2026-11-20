import SwiftUI

struct HabitDetailView: View {
    var viewModel: HomeViewModel
    let habitID: UUID
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var notificationsAllowed: Bool?
    
    @State private var selectedMonth: Date? = Self.startOfMonth(for: Date())
    @State private var isEditingDays = false
    @State private var showEditHabit = false
    @State private var showDeleteConfirmation = false
    @State private var completionFeedbackTrigger = false
    @State private var undoFeedbackTrigger = false
    @State private var historyFeedbackTrigger = false
    @State private var finishEditingFeedbackTrigger = false
    
    private var habit: Habit? {
        viewModel.habits.first(where: { $0.id == habitID })
    }
    
    // MARK: - Календарь: настройки и вычисления
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        cal.locale = Locale(identifier: "ru_RU")
        return cal
    }
    
    private static func startOfMonth(for date: Date) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        cal.firstWeekday = 2
        let components = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: components) ?? date
    }
    
    private var months: [Date] {
        let start = Self.startOfMonth(for: Date())
        return (-24...0).compactMap { calendar.date(byAdding: .month, value: $0, to: start) }
    }
    
    private func daysInMonth(for date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }
    
    private func firstWeekdayOffset(for date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 5) % 7
    }
    
    private func calendarDays(for date: Date) -> [Int?] {
        let blanks: [Int?] = Array(repeating: nil, count: firstWeekdayOffset(for: date))
        let days: [Int?] = (1...daysInMonth(for: date)).map { $0 }
        var all = blanks + days
        
        let totalCells = 42
        if all.count < totalCells {
            all += Array(repeating: nil, count: totalCells - all.count)
        }
        return all
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
    
    private var monthTitleText: String {
        guard let selectedMonth else { return "" }
        return monthTitle(for: selectedMonth)
    }
    
    private func date(forDay day: Int, in month: Date) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let year = components.year, let monthNum = components.month else { return nil }
        
        var dayComponents = DateComponents()
        dayComponents.year = year
        dayComponents.month = monthNum
        dayComponents.day = day
        
        return calendar.date(from: dayComponents)
    }
    
    private func isCompleted(day: Int, in month: Date) -> Bool {
        guard let habit, let date = date(forDay: day, in: month) else { return false }
        return habit.completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        if let habit {
            VStack(spacing: 0) {
                topBar(habit: habit)
                    .frame(height: 44)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(spacing: 24) {
                        Text(habit.emoji)
                            .font(.system(size: 60))

                        Text(habit.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        statsRow

                        calendarGrid
                            .padding(.top, 20)

                        if habit.remindersEnabled, let reminderTime = habit.reminderTime,
                           let notificationsAllowed {
                            Text(notificationsAllowed
                                 ? "Напоминания настроены каждый день на \(formattedTime(reminderTime))"
                                 : "Уведомления выключены — разрешите их в настройках")
                                .font(.footnote)
                                .foregroundStyle(notificationsAllowed ? Color.secondary : Color.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: historyFeedbackTrigger)
            .task(id: scenePhase) {
                await refreshNotificationPermission()
            }
            .onChange(of: showEditHabit) { _, isPresented in
                if !isPresented {
                    Task { await refreshNotificationPermission() }
                }
            }
        }
    }

    private func refreshNotificationPermission() async {
        guard scenePhase == .active else { return }
        notificationsAllowed = nil
        let allowed = await NotificationManager.shared.notificationsAllowed()
        guard !Task.isCancelled, scenePhase == .active else { return }
        notificationsAllowed = allowed

        // Берём актуальную привычку после проверки: её могли изменить или удалить.
        guard let habit else { return }
        if allowed && habit.remindersEnabled {
            NotificationManager.shared.scheduleReminder(for: habit)
        }
    }
    
    // MARK: - Верхняя панель с кнопками
    private func topBar(habit: Habit) -> some View {
        HStack {
            Menu {
                Button {
                    showEditHabit = true
                } label: {
                    Label("Редактировать привычку", systemImage: "pencil")
                }
                
                Button {
                    if isEditingDays {
                        finishEditingFeedbackTrigger.toggle()
                    }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditingDays.toggle()
                    }
                } label: {
                    Label(
                        isEditingDays ? "Готово" : "Отметить прошлые дни",
                        systemImage: isEditingDays ? "checkmark" : "calendar.badge.clock"
                    )
                }
                
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Действия с привычкой")
            
            Spacer()
            
            Button {
                if isEditingDays {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditingDays = false
                    }
                    finishEditingFeedbackTrigger.toggle()
                } else {
                    let wasCompleted = viewModel.isCompletedToday(habit)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleCompletion(for: habit.id)
                    }
                    if wasCompleted {
                        undoFeedbackTrigger.toggle()
                    } else {
                        completionFeedbackTrigger.toggle()
                    }
                }
            } label: {
                if isEditingDays {
                    Text("Готово")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(viewModel.isCompletedToday(habit) ? Color.white : Color.primary.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(
                            viewModel.isCompletedToday(habit)
                                ? Color.accentColor
                                : Color(.secondarySystemBackground),
                            in: Circle()
                        )
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .heavy), trigger: completionFeedbackTrigger)
            .sensoryFeedback(.impact(weight: .light), trigger: undoFeedbackTrigger)
            .accessibilityLabel(isEditingDays ? "Готово" : (viewModel.isCompletedToday(habit) ? "Отменить выполнение за сегодня" : "Выполнить сегодня"))
            .accessibilityValue(isEditingDays ? "Завершить редактирование дней" : (viewModel.isCompletedToday(habit) ? "Выполнено" : "Не выполнено"))
        }
        .sensoryFeedback(.impact(weight: .light), trigger: finishEditingFeedbackTrigger)
        .padding(.horizontal)
        .confirmationDialog(
            "Удалить привычку?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                viewModel.deleteHabit(habit.id)
                dismiss()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Это действие нельзя отменить. Вся история выполнения будет удалена.")
        }
        .sheet(isPresented: $showEditHabit) {
            AddHabitView(mode: .edit(habit)) { emoji, title, color, remindersEnabled, reminderTime in
                viewModel.updateHabit(
                    habitID: habit.id,
                    emoji: emoji,
                    title: title,
                    color: color,
                    remindersEnabled: remindersEnabled,
                    reminderTime: reminderTime
                )
            }
        }
    }
    
    // MARK: - Блоки статистики (стрик / всего дней)
    private var statsRow: some View {
        HStack(spacing: 12) {
            if let habit {
                statBlock(
                    value: "\(viewModel.currentStreak(habit))",
                    label: "Подряд",
                    icon: "flame.fill",
                    iconColor: viewModel.isCompletedToday(habit) ? .orange : .secondary
                )
                statBlock(value: "\(viewModel.totalCompletedDays(habit))", label: "Дней всего", icon: "calendar", iconColor: .blue)
            }
        }
        .padding(.horizontal)
    }
    
    private func statBlock(value: String, label: String, icon: String, iconColor: Color = .secondary) -> some View {
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
                .foregroundStyle(iconColor)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Календарь (заголовок, дни недели, свайп по месяцам)
    private var calendarGrid: some View {
        GeometryReader { geo in
            let sidePadding: CGFloat = 36
            let pageWidth = geo.size.width - sidePadding * 2
            
            VStack(spacing: 12) {
                Text(monthTitleText)
                    .font(.headline)
                
                HStack {
                    ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, sidePadding)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(months, id: \.self) { month in
                            monthGrid(for: month)
                                .frame(width: pageWidth)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .defaultScrollAnchor(.center)
                .scrollPosition(id: $selectedMonth)
                .contentMargins(.horizontal, sidePadding, for: .scrollContent)
            }
        }
        .frame(height: 340)
    }
    
    private func monthGrid(for month: Date) -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(calendarDays(for: month).enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day: day, month: month)
                } else {
                    Color.clear
                        .frame(width: 36, height: 36)
                }
            }
        }
    }
    
    private func isToday(day: Int, in month: Date) -> Bool {
        guard let date = date(forDay: day, in: month) else { return false }
        return calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func dayCell(day: Int, month: Date) -> some View {
        Text("\(day)")
            .font(.subheadline)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(isCompleted(day: day, in: month) ? Color.accentColor.opacity(0.3) : Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1)
                    .opacity(isEditingDays ? 1 : 0)
            )
            .overlay(alignment: .bottom) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: 4)
                    .offset(y: -4)
                    .opacity(isToday(day: day, in: month) ? 1 : 0)
            }
            .contentShape(Rectangle().inset(by: -4))
            .onTapGesture {
                guard isEditingDays,
                      let habit,
                      let date = date(forDay: day, in: month),
                      date <= Date()
                else { return }
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.toggleCompletion(for: habit.id, on: date)
                }
                historyFeedbackTrigger.toggle()
            }
    }
}

#Preview {
    let vm = HomeViewModel()
    let habit = Habit(emoji: "🎯", title: "Учить Swift", color: .blue)
    vm.habits = [habit]
    return HabitDetailView(viewModel: vm, habitID: habit.id)
}
