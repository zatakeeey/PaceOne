import SwiftUI

struct AboutAppView: View {
    private let privacyPolicyURL = "https://zatakeeey.github.io/PaceOne/privacy-policy.html"

    var body: some View {
        VStack(spacing: 12) {
            Text("PaceOne")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Трекер ежедневных привычек")
                .foregroundStyle(.secondary)

            Text("Версия 1.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Group {
                if let url = URL(string: privacyPolicyURL),
                   url.scheme == "https", url.host != nil {
                    Link("Политика конфиденциальности", destination: url)
                } else {
                    Button("Политика конфиденциальности") { }
                        .disabled(true)
                }
            }
            .frame(minHeight: 44)
            .padding(.top, 12)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutAppView()
    }
}
