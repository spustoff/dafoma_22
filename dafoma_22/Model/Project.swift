import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    let id: UUID
    let projectId: UUID
    var authorId: UUID
    var body: String
    var createdAt: Date

    init(id: UUID = UUID(), projectId: UUID, authorId: UUID, body: String, createdAt: Date = Date()) {
        self.id = id
        self.projectId = projectId
        self.authorId = authorId
        self.body = body
        self.createdAt = createdAt
    }
}

struct Project: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var summary: String
    var startDate: Date
    var endDate: Date
    var memberIds: [UUID]
    var taskIds: [UUID]
    var messages: [ChatMessage]

    init(id: UUID = UUID(), name: String, summary: String = "", startDate: Date = Date(), endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), memberIds: [UUID] = [], taskIds: [UUID] = [], messages: [ChatMessage] = []) {
        self.id = id
        self.name = name
        self.summary = summary
        self.startDate = startDate
        self.endDate = endDate
        self.memberIds = memberIds
        self.taskIds = taskIds
        self.messages = messages
    }

    var durationDays: Int {
        startDate.days(until: endDate)
    }
    
    var progress: Double {
        guard !taskIds.isEmpty else { return 0.0 }
        // This would need to be calculated with actual task data
        return 0.0
    }
}
