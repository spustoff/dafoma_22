import Foundation
import UserNotifications

final class NotificationService: ObservableObject {
    @Published var hasPermission = false
    
    init() {
        checkPermission()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                completion(granted)
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleDueTaskNotification(taskTitle: String, dueDate: Date) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due"
        content.body = "\(taskTitle) is due."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleProjectDeadlineNotification(projectName: String, deadline: Date) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Project Deadline"
        content.body = "\(projectName) deadline is approaching."
        content.sound = .default
        
        // Schedule 1 day before deadline
        let notificationDate = Calendar.current.date(byAdding: .day, value: -1, to: deadline) ?? deadline
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
