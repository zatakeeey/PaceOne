import SwiftUI

enum HabitColor: String, CaseIterable, Identifiable, Codable {
    case blue, teal, green, yellow, orange, red, purple, pink

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue:   Color(red: 0.42, green: 0.56, blue: 0.75)
        case .teal:   Color(red: 0.37, green: 0.66, blue: 0.63)
        case .green:  Color(red: 0.49, green: 0.72, blue: 0.56)
        case .yellow: Color(red: 0.89, green: 0.70, blue: 0.24)
        case .orange: Color(red: 0.88, green: 0.56, blue: 0.27)
        case .red:    Color(red: 0.82, green: 0.41, blue: 0.42)
        case .purple: Color(red: 0.61, green: 0.52, blue: 0.77)
        case .pink:   Color(red: 0.85, green: 0.55, blue: 0.70)
        }
    }
}
