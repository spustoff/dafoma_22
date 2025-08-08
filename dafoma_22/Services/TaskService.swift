import Foundation
import Combine

final class TaskService: ObservableObject {
    @Published private(set) var tasks: [TaskItem]

    private let fileService: FileService
    private var cancellables: Set<AnyCancellable> = []

    init(fileService: FileService = FileService()) {
        self.fileService = fileService
        self.tasks = fileService.loadIfPresent([TaskItem].self, from: FileNames.tasks, fallback: [])

        $tasks
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] tasks in
                guard let self else { return }
                try? self.fileService.save(tasks, to: FileNames.tasks)
            }
            .store(in: &cancellables)
    }

    func createTask(_ task: TaskItem) { 
        tasks.append(task) 
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        var updatedTask = task
        updatedTask.updatedAt = Date()
        tasks[index] = updatedTask
    }

    func deleteTasks(at offsets: IndexSet) { 
        tasks.remove(atOffsets: offsets) 
    }

    func tasks(for projectId: UUID?) -> [TaskItem] {
        tasks.filter { $0.projectId == projectId }
    }

    func tasks(matchingTags tags: Set<String>) -> [TaskItem] {
        guard tags.isNotEmpty else { return tasks }
        return tasks.filter { !$0.tags.isEmpty && !Set($0.tags).isDisjoint(with: tags) }
    }

    func overdueTasks(referenceDate: Date = Date()) -> [TaskItem] {
        tasks.filter { task in
            if let due = task.dueDate { 
                return due < referenceDate && task.status != .done 
            }
            return false
        }
    }
    
    func tasksGroupedByStatus() -> [TaskStatus: [TaskItem]] {
        Dictionary(grouping: tasks, by: { $0.status })
    }
}
