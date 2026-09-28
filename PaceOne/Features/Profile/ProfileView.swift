import SwiftUI

struct ProfileView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
            .navigationTitle("PaceOne")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Тема", selection: $appTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Label(theme.title, systemImage: theme.icon)
                                    .tag(theme)
                            }
                        }
                    } label: {
                        Image(systemName: appTheme.icon)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //действие
                        print("settings tapped")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
