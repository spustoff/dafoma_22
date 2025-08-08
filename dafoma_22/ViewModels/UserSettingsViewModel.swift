import Foundation
import Combine

final class UserSettingsViewModel: ObservableObject {
    @Published var currentUser: UserProfile
    @Published var settings: AppSettings
    @Published var hasNotificationPermission: Bool = false

    private let userService: UserService
    private let notificationService: NotificationService
    private var cancellables: Set<AnyCancellable> = []

    init(userService: UserService, notificationService: NotificationService) {
        self.userService = userService
        self.notificationService = notificationService

        self.currentUser = userService.currentUser ?? UserProfile(fullName: "You", email: "you@example.com")
        self.settings = userService.settings

        userService.$users
            .map { [weak userService] _ in 
                userService?.currentUser ?? UserProfile(fullName: "You", email: "you@example.com") 
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)

        userService.$settings
            .receive(on: DispatchQueue.main)
            .assign(to: &$settings)
            
        notificationService.$hasPermission
            .receive(on: DispatchQueue.main)
            .assign(to: &$hasNotificationPermission)
    }

    func saveProfile(_ profile: UserProfile) {
        userService.currentUser = profile
    }

    func toggleNotifications(_ enabled: Bool) {
        var newSettings = settings
        newSettings.notificationsEnabled = enabled
        userService.updateSettings(newSettings)
        
        if enabled && !hasNotificationPermission {
            notificationService.requestAuthorization { [weak self] granted in
                if !granted {
                    // Revert setting if permission denied
                    var revertedSettings = self?.settings ?? .default
                    revertedSettings.notificationsEnabled = false
                    self?.userService.updateSettings(revertedSettings)
                }
            }
        }
    }
    
    func updateWorkflowStyle(_ style: WorkflowStyle) {
        var newSettings = settings
        newSettings.preferredWorkflow = style
        userService.updateSettings(newSettings)
    }

    func completeOnboarding() {
        var newSettings = settings
        newSettings.onboardingCompleted = true
        userService.updateSettings(newSettings)
    }
    
    func resetOnboarding() {
        var newSettings = settings
        newSettings.onboardingCompleted = false
        userService.updateSettings(newSettings)
    }
}
