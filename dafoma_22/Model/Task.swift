import Foundation

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low, medium, high, critical
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case backlog, inProgress, blocked, done
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .backlog: return "Backlog"
        case .inProgress: return "In Progress"
        case .blocked: return "Blocked"
        case .done: return "Done"
        }
    }
}

struct Attachment: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var fileURL: URL
    
    init(id: UUID = UUID(), name: String, fileURL: URL) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
    }
}

struct TaskItem: Codable, Identifiable, Hashable {
    let id: UUID
    var projectId: UUID?
    var title: String
    var details: String
    var priority: TaskPriority
    var status: TaskStatus
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var tags: [String]
    var assigneeUserIds: [UUID]
    var attachments: [Attachment]

    init(id: UUID = UUID(), projectId: UUID? = nil, title: String, details: String = "", priority: TaskPriority = .medium, status: TaskStatus = .backlog, createdAt: Date = Date(), updatedAt: Date = Date(), dueDate: Date? = nil, tags: [String] = [], assigneeUserIds: [UUID] = [], attachments: [Attachment] = []) {
        self.id = id
        self.projectId = projectId
        self.title = title
        self.details = details
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.dueDate = dueDate
        self.tags = tags
        self.assigneeUserIds = assigneeUserIds
        self.attachments = attachments
    }
}
