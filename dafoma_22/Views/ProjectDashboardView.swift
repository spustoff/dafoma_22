import SwiftUI

struct ProjectDashboardView: View {
    @ObservedObject var viewModel: ProjectListViewModel
    @State private var isPresentingNewProject = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.ganttItems.isNotEmpty {
                ganttChart
                    .padding(.horizontal)
                    .padding(.top, UIConstants.standardPadding)
            }

            List {
                ForEach(viewModel.projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project, viewModel: viewModel)) {
                        ProjectRowView(project: project, progress: progressForProject(project))
                    }
                    .listRowBackground(AppColors.background)
                }
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(.insetGrouped)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { 
                    isPresentingNewProject = true 
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppColors.accentWhite)
                }
                .accessibilityLabel("Add Project")
            }
        }
        .sheet(isPresented: $isPresentingNewProject) {
            NavigationStack {
                ProjectEditView(onSave: { name, summary, start, end in
                    viewModel.addProject(name: name, summary: summary, startDate: start, endDate: end)
                })
            }
        }
    }

    private var ganttChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .foregroundStyle(AppColors.accentWhite)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                let items = viewModel.ganttItems
                if items.isNotEmpty {
                    let dates = dateRange(items: items)
                    LazyHStack(alignment: .top, spacing: 16) {
                        ForEach(items) { item in
                            GanttBarView(item: item, globalStart: dates.start, globalEnd: dates.end)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                } else {
                    Text("No projects to display")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .background(AppColors.buttonSecondary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
    }

    private func dateRange(items: [GanttItem]) -> (start: Date, end: Date) {
        guard items.isNotEmpty else { return (Date(), Date()) }
        let starts = items.map { $0.startDate }
        let ends = items.map { $0.endDate }
        let start = starts.min() ?? Date()
        let end = ends.max() ?? Date()
        return (start, end)
    }
    
    private func progressForProject(_ project: Project) -> Double {
        viewModel.ganttItems.first(where: { $0.id == project.id })?.progress ?? 0.0
    }
}

struct ProjectRowView: View {
    let project: Project
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .foregroundStyle(AppColors.accentWhite)
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !project.summary.isEmpty {
                Text(project.summary)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            
            HStack {
                Label("\(project.durationDays) days", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("\(project.memberIds.count) members", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(AppColors.buttonPrimary)
        }
        .padding(.vertical, 4)
    }
}

struct GanttBarView: View {
    let item: GanttItem
    let globalStart: Date
    let globalEnd: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.name)
                .font(.caption)
                .foregroundStyle(AppColors.accentWhite)
                .lineLimit(1)
            
            GeometryReader { geometry in
                let totalDays = max(globalStart.days(until: globalEnd), 1)
                let itemStartOffset = max(globalStart.days(until: item.startDate), 0)
                let itemLength = max(item.startDate.days(until: item.endDate), 1)

                let unit = geometry.size.width / CGFloat(totalDays)
                let x = CGFloat(itemStartOffset) * unit
                let width = CGFloat(itemLength) * unit

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.buttonSecondary.opacity(0.4))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: item.colorHex))
                        .frame(width: width)
                        .offset(x: x)
                    
                    // Progress overlay
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: item.colorHex).opacity(0.7))
                        .frame(width: width * item.progress)
                        .offset(x: x)
                }
            }
            .frame(height: 20)
            
            HStack {
                Text(item.startDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.endDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 200)
        .padding(.vertical, 4)
    }
}

struct ProjectEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var summary: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    var onSave: (String, String, Date, Date) -> Void

    var body: some View {
        Form {
            Section("Overview") {
                TextField("Project Name", text: $name)
                TextField("Summary", text: $summary, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Schedule") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
            }
        }
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { 
                Button("Cancel") { dismiss() } 
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(name, summary, startDate, endDate)
                    dismiss()
                }
                .bold()
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    @ObservedObject var viewModel: ProjectListViewModel
    @State private var showingTaskCreation = false
    @State private var newMessage = ""
    
    var projectTasks: [TaskItem] {
        viewModel.tasksForProject(project)
    }

    var body: some View {
        List {
            Section("Overview") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(AppColors.accentWhite)
                    
                    if !project.summary.isEmpty {
                        Text(project.summary)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Start: \(project.startDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "calendar")
                        Spacer()
                        Label("End: \(project.endDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(AppColors.background)
            
            Section("Tasks (\(projectTasks.count))") {
                if projectTasks.isEmpty {
                    Text("No tasks yet")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(projectTasks) { task in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .foregroundStyle(AppColors.accentWhite)
                            Text(task.status.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(statusColor(task.status))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                Button("Add Task") {
                    showingTaskCreation = true
                }
                .foregroundStyle(AppColors.buttonPrimary)
            }
            .listRowBackground(AppColors.background)
            
            Section("Team Chat") {
                ForEach(project.messages) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.body)
                            .foregroundStyle(AppColors.accentWhite)
                        Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                HStack {
                    TextField("Type a message...", text: $newMessage)
                    Button("Send") {
                        if !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            // This would need the current user ID
                            let userId = UUID() // Placeholder
                            viewModel.addMessage(newMessage, to: project, from: userId)
                            newMessage = ""
                        }
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .listRowBackground(AppColors.background)
        }
        .listStyle(.insetGrouped)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTaskCreation) {
            NavigationStack {
                TaskEditView(task: TaskItem(projectId: project.id, title: "", details: "")) { newTask in
                    // This would need to be connected to TaskViewModel
                    // For now, just dismiss the sheet
                }
            }
        }
    }
    
    private func statusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .backlog: return AppColors.buttonSecondary
        case .inProgress: return .blue
        case .blocked: return .orange
        case .done: return .green
        }
    }
}
