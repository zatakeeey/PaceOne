import SwiftUI

struct ProfileHeaderView: View {
    var viewModel: ProfileViewModel

    @State private var isEditingNickname = false
    @State private var nicknameDraft = ""
    @FocusState private var isNicknameFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            avatar

            nicknameView
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    // MARK: - Аватар
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.73, green: 0.67, blue: 0.97),
                            Color(red: 0.57, green: 0.75, blue: 0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(viewModel.avatarLetter)
                .font(.system(size: 50, weight: .semibold))
                .foregroundStyle(.white)
                .offset(y: -1)
        }
        .frame(width: 110, height: 110)
    }

    // MARK: - Никнейм
    private var nicknameView: some View {
        Group {
            if isEditingNickname {
                HStack(spacing: 10) {
                    TextField("Никнейм", text: $nicknameDraft)
                        .focused($isNicknameFocused)
                        .submitLabel(.done)
                        .onSubmit(saveNickname)
                        .onAppear {
                            isNicknameFocused = true
                        }

                    Button(action: saveNickname) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .frame(maxWidth: 280)
                .frame(height: 44)
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            } else {
                Button {
                    nicknameDraft = viewModel.nickname
                    isEditingNickname = true
                } label: {
                    HStack(spacing: 7) {
                        Text(viewModel.nickname)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Image(systemName: "pencil")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.title3.weight(.semibold))
    }

    private func saveNickname() {
        viewModel.saveNickname(nicknameDraft)
        isNicknameFocused = false
        isEditingNickname = false
    }
}

#Preview {
    ProfileHeaderView(viewModel: ProfileViewModel())
}
