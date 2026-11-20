import SwiftUI

struct AboutAppView: View {
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
        }
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
