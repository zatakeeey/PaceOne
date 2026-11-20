import SwiftUI

//MARK: - TAB-BAR
struct ContentView: View {
    @State private var habitStore = HabitStore()
    @State private var usageStore = AppUsageStore()
    @State private var dateProvider = CurrentDateProvider()

    var body: some View {
        TabView {
            HomeView(habitStore: habitStore, dateProvider: dateProvider)
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            ProfileView(habitStore: habitStore, usageStore: usageStore, dateProvider: dateProvider)
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
