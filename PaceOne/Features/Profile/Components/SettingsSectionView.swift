import SwiftUI

struct SettingsSectionView: View {
    @AppStorage("appTheme")
    private var appTheme: AppTheme = .system

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Настройки")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Image(systemName: "circle.lefthalf.filled")
                    .frame(width: 26)
                Text("Тема оформления")

                Spacer()

                Picker("Тема", selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title)
                            .tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
            .padding(16)
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 18)
            )

            NavigationLink {
                AboutAppView()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .frame(width: 26)

                    Text("О приложении")

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(16)
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 18)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsSectionView()
            .padding()
    }
}
