import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var isPresentingNewTask = false
    @State private var showingFilters = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.allTags.isNotEmpty || viewModel.selectedTags.isNotEmpty {
                filterSection
                    .padding(.horizontal)
                    .padding(.top, UIConstants.standardPadding)
            }

            List {
                ForEach(viewModel.filteredTasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task, onSave: { updated in
                        viewModel.update(updated)
                    })) {
                        TaskRowView(task: task) {
                            viewModel.toggleTaskStatus(task)
                        }
                    }
                    .listRowBackground(AppColors.background)
                }
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(.insetGrouped)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingFilters.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(AppColors.accentWhite)
                }
                
                Button {
                    isPresentingNewTask = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppColors.accentWhite)
                }
                .accessibilityLabel("Add Task")
            }
        }
        .sheet(isPresented: $isPresentingNewTask) {
            NavigationStack {
                TaskEditView(task: TaskItem(title: "", details: "")) { newTask in
                    if newTask.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
                    viewModel.create(newTask)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            TaskFiltersView(viewModel: viewModel)
        }
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.selectedTags.isNotEmpty {
                Text("Active Filters:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag)
                                    .font(.caption)
                                Button {
                                    viewModel.selectedTags.remove(tag)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(AppColors.buttonPrimary)
                            .foregroundStyle(AppColors.accentWhite)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: TaskItem
    let onStatusToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onStatusToggle) {
                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.status == .done ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .foregroundStyle(AppColors.accentWhite)
                    .font(.headline)
                    .strikethrough(task.status == .done)
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    priorityIndicator(task.priority)
                    
                    if let dueDate = task.dueDate {
                        dueDateIndicator(dueDate)
                    }
                }
                
                if task.tags.isNotEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(task.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 6)
                                    .background(AppColors.buttonSecondary.opacity(0.6))
                                    .foregroundStyle(AppColors.accentWhite)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            statusIndicator(task.status)
        }
        .padding(.vertical, 4)
    }
    
    private func priorityIndicator(_ priority: TaskPriority) -> some View {
        Text(priority.displayName)
            .font(.caption2)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(priorityColor(priority))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    
    private func dueDateIndicator(_ dueDate: Date) -> some View {
        let isOverdue = dueDate < Date()
        return Text(dueDate.formatted(date: .abbreviated, time: .omitted))
            .font(.caption2)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(isOverdue ? .red : .blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    
    private func statusIndicator(_ status: TaskStatus) -> some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(statusColor(status))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
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

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var task: TaskItem
    var onSave: (TaskItem) -> Void

    var body: some View {
        TaskEditView(task: task, onSave: onSave)
            .navigationTitle("Task Details")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
    }
}

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var task: TaskItem
    var onSave: (TaskItem) -> Void

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var status: TaskStatus = .backlog
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var tagsText: String = ""

    var body: some View {
        Form {
            Section("Overview") {
                TextField("Title", text: $title)
                TextField("Details", text: $details, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section("Status & Priority") {
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { 
                        Text($0.displayName).tag($0) 
                    }
                }
                
                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { 
                        Text($0.displayName).tag($0) 
                    }
                }
            }
            
            Section("Schedule") {
                Toggle("Has Due Date", isOn: $hasDueDate)
                
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            Section("Organization") {
                TextField("Tags (comma separated)", text: $tagsText)
                    .autocapitalization(.none)
            }
        }
        .onAppear {
            title = task.title
            details = task.details
            priority = task.priority
            status = task.status
            hasDueDate = task.dueDate != nil
            if let dueDate = task.dueDate {
                self.dueDate = dueDate
            }
            tagsText = task.tags.joined(separator: ", ")
        }
        .navigationTitle(task.title.isEmpty ? "New Task" : "Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    var updated = task
                    updated.title = title
                    updated.details = details
                    updated.priority = priority
                    updated.status = status
                    updated.dueDate = hasDueDate ? dueDate : nil
                    updated.tags = tagsText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    updated.updatedAt = Date()
                    onSave(updated)
                    dismiss()
                }
                .bold()
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct TaskFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Filter by Status") {
                    Picker("Status", selection: Binding(
                        get: { viewModel.selectedStatus },
                        set: { viewModel.selectedStatus = $0 }
                    )) {
                        Text("All").tag(nil as TaskStatus?)
                        ForEach(TaskStatus.allCases) {
                            Text($0.displayName).tag($0 as TaskStatus?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Filter by Tags") {
                    ForEach(Array(viewModel.allTags).sorted(), id: \.self) { tag in
                        let isSelected = viewModel.selectedTags.contains(tag)
                        Button {
                            if isSelected {
                                viewModel.selectedTags.remove(tag)
                            } else {
                                viewModel.selectedTags.insert(tag)
                            }
                        } label: {
                            HStack {
                                Text(tag)
                                    .foregroundStyle(AppColors.accentWhite)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.buttonPrimary)
                                }
                            }
                        }
                    }
                }
                
                if viewModel.selectedTags.isNotEmpty || viewModel.selectedStatus != nil {
                    Section {
                        Button("Clear All Filters") {
                            viewModel.selectedTags.removeAll()
                            viewModel.selectedStatus = nil
                        }
                        .foregroundStyle(AppColors.buttonPrimary)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
