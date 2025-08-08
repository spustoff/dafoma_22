import SwiftUI

enum AppStrings {
    static let appName = "TaskPilot"
}

enum AppColors {
    static let background = Color(hex: "#02102b")
    static let buttonPrimary = Color(hex: "#bd0e1b")
    static let buttonSecondary = Color(hex: "#0a1a3b")
    static let accentWhite = Color(hex: "#ffffff")
    static let accentYellow = Color(hex: "#ffbe00")
}

enum UIConstants {
    static let cornerRadius: CGFloat = 12
    static let smallPadding: CGFloat = 8
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let controlHeight: CGFloat = 44
}

enum FileNames {
    static let tasks = "tasks.json"
    static let projects = "projects.json"
    static let users = "users.json"
    static let settings = "settings.json"
    static let attachments = "attachments"
}
