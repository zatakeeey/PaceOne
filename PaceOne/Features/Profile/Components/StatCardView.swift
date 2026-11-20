import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(height: 24)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

#Preview {
    StatCardView(title: "Привычки", value: "3", icon: "target", color: .purple)
        .padding()
}
