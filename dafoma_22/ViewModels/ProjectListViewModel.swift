import Foundation
import Combine

struct GanttItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let startDate: Date
    let endDate: Date
    let colorHex: String
    let progress: Double
}

final class ProjectListViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var ganttItems: [GanttItem] = []
    @Published var selectedProject: Project?

    private let projectService: ProjectService
    private let taskService: TaskService
    private var cancellables: Set<AnyCancellable> = []

    init(projectService: ProjectService, taskService: TaskService) {
        self.projectService = projectService
        self.taskService = taskService

        projectService.$projects
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)

        Publishers.CombineLatest(projectService.$projects, taskService.$tasks)
            .map { [weak self] projects, tasks in
                projects.map { project in
                    let projectTasks = tasks.filter { $0.projectId == project.id }
                    let completedTasks = projectTasks.filter { $0.status == .done }
                    let progress = projectTasks.isEmpty ? 0.0 : Double(completedTasks.count) / Double(projectTasks.count)
                    
                    return GanttItem(
                        id: project.id,
                        name: project.name,
                        startDate: project.startDate,
                        endDate: project.endDate,
                        colorHex: self?.colorForProject(project) ?? "#0a1a3b",
                        progress: progress
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$ganttItems)
    }

    func addProject(name: String, summary: String, startDate: Date, endDate: Date) {
        let project = Project(name: name, summary: summary, startDate: startDate, endDate: endDate)
        projectService.createProject(project)
    }

    func update(_ project: Project) {
        projectService.updateProject(project)
    }

    func delete(at offsets: IndexSet) { 
        projectService.deleteProjects(at: offsets) 
    }
    
    func deleteProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            delete(at: IndexSet(integer: index))
        }
    }
    
    func tasksForProject(_ project: Project) -> [TaskItem] {
        taskService.tasks(for: project.id)
    }
    
    func addMessage(_ message: String, to project: Project, from userId: UUID) {
        let chatMessage = ChatMessage(projectId: project.id, authorId: userId, body: message)
        projectService.addMessage(chatMessage, to: project.id)
    }
    
    var activeProjects: [Project] {
        projectService.activeProjects()
    }
    
    private func colorForProject(_ project: Project) -> String {
        let colors = ["#bd0e1b", "#0a1a3b", "#ffbe00"]
        let index = abs(project.name.hashValue) % colors.count
        return colors[index]
    }
}
