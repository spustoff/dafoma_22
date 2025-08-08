import Foundation
import Combine

final class UserService: ObservableObject {
    @Published private(set) var users: [UserProfile]
    @Published var currentUserId: UUID?
    @Published var settings: AppSettings

    private let fileService: FileService
    private var cancellables: Set<AnyCancellable> = []

    init(fileService: FileService = FileService()) {
        self.fileService = fileService
        self.users = fileService.loadIfPresent([UserProfile].self, from: FileNames.users, fallback: [])
        self.settings = fileService.loadIfPresent(AppSettings.self, from: FileNames.settings, fallback: .default)
        self.currentUserId = users.first?.id

        Publishers.CombineLatest($users, $settings)
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] users, settings in
                guard let self else { return }
                try? self.fileService.save(users, to: FileNames.users)
                try? self.fileService.save(settings, to: FileNames.settings)
            }
            .store(in: &cancellables)

        // Create default user if none exists
        if users.isEmpty {
            let defaultUser = UserProfile(fullName: "You", email: "you@example.com")
            users = [defaultUser]
            currentUserId = defaultUser.id
        }
    }

    var currentUser: UserProfile? {
        get { 
            users.first(where: { $0.id == currentUserId }) 
        }
        set {
            guard let newValue else { return }
            if let idx = users.firstIndex(where: { $0.id == newValue.id }) { 
                users[idx] = newValue 
            }
        }
    }

    func addUser(_ user: UserProfile) { 
        users.append(user) 
    }
    
    func removeUsers(at offsets: IndexSet) { 
        users.remove(atOffsets: offsets) 
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
    }
}
