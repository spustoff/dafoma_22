import Foundation
import Combine

final class ProjectService: ObservableObject {
    @Published private(set) var projects: [Project]

    private let fileService: FileService
    private var cancellables: Set<AnyCancellable> = []

    init(fileService: FileService = FileService()) {
        self.fileService = fileService
        self.projects = fileService.loadIfPresent([Project].self, from: FileNames.projects, fallback: [])

        $projects
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] projects in
                guard let self else { return }
                try? self.fileService.save(projects, to: FileNames.projects)
            }
            .store(in: &cancellables)
    }

    func createProject(_ project: Project) { 
        projects.append(project) 
    }
    
    func updateProject(_ project: Project) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[idx] = project
    }
    
    func deleteProjects(at offsets: IndexSet) { 
        projects.remove(atOffsets: offsets) 
    }
    
    func addMessage(_ message: ChatMessage, to projectId: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[idx].messages.append(message)
    }
    
    func activeProjects() -> [Project] {
        let now = Date()
        return projects.filter { $0.startDate <= now && $0.endDate >= now }
    }
}
