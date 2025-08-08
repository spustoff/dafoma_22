import Foundation

enum WorkflowStyle: String, Codable, CaseIterable, Identifiable {
    case kanban, scrum, simple
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .kanban: return "Kanban"
        case .scrum: return "Scrum"
        case .simple: return "Simple"
        }
    }
}

struct AppSettings: Codable, Hashable {
    var notificationsEnabled: Bool
    var preferredWorkflow: WorkflowStyle
    var onboardingCompleted: Bool

    static let `default` = AppSettings(
        notificationsEnabled: true,
        preferredWorkflow: .kanban,
        onboardingCompleted: false
    )
}
