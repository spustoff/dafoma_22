import Foundation
import Combine

final class TaskViewModel: ObservableObject {
    @Published var allTasks: [TaskItem] = []
    @Published var selectedTags: Set<String> = []
    @Published var filteredTasks: [TaskItem] = []
    @Published var selectedStatus: TaskStatus?

    private let taskService: TaskService
    private var cancellables: Set<AnyCancellable> = []

    init(taskService: TaskService) {
        self.taskService = taskService

        taskService.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.allTasks = $0 }
            .store(in: &cancellables)

        Publishers.CombineLatest3($allTasks, $selectedTags, $selectedStatus)
            .map { tasks, tags, status in
                var filtered = tasks
                
                // Filter by tags
                if tags.isNotEmpty {
                    filtered = filtered.filter { !$0.tags.isEmpty && !Set($0.tags).isDisjoint(with: tags) }
                }
                
                // Filter by status
                if let status = status {
                    filtered = filtered.filter { $0.status == status }
                }
                
                return filtered
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$filteredTasks)
    }

    func addTask(title: String, details: String, priority: TaskPriority, dueDate: Date?, tags: [String], projectId: UUID? = nil) {
        var task = TaskItem(projectId: projectId, title: title, details: details, priority: priority)
        task.dueDate = dueDate
        task.tags = tags
        taskService.createTask(task)
    }

    func create(_ task: TaskItem) { 
        taskService.createTask(task) 
    }
    
    func update(_ task: TaskItem) { 
        taskService.updateTask(task) 
    }
    
    func delete(at offsets: IndexSet) { 
        taskService.deleteTasks(at: offsets) 
    }
    
    func toggleTaskStatus(_ task: TaskItem) {
        var updatedTask = task
        switch task.status {
        case .backlog:
            updatedTask.status = .inProgress
        case .inProgress:
            updatedTask.status = .done
        case .blocked:
            updatedTask.status = .inProgress
        case .done:
            updatedTask.status = .backlog
        }
        update(updatedTask)
    }
    
    var allTags: Set<String> {
        Set(allTasks.flatMap { $0.tags })
    }
    
    var overdueTasks: [TaskItem] {
        taskService.overdueTasks()
    }
    
    var tasksGroupedByStatus: [TaskStatus: [TaskItem]] {
        taskService.tasksGroupedByStatus()
    }
}
