import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case owner, admin, contributor, viewer
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .admin: return "Admin"
        case .contributor: return "Contributor"
        case .viewer: return "Viewer"
        }
    }
}

struct UserProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var fullName: String
    var email: String
    var role: UserRole
    var avatarURL: URL?

    init(id: UUID = UUID(), fullName: String, email: String, role: UserRole = .owner, avatarURL: URL? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.role = role
        self.avatarURL = avatarURL
    }
    
    var initials: String {
        let components = fullName.split(separator: " ")
        return components.compactMap { $0.first }.map(String.init).prefix(2).joined()
    }
}
