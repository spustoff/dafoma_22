import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserSettingsViewModel

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var role: UserRole = .owner
    @State private var notificationsEnabled: Bool = true
    @State private var preferredWorkflow: WorkflowStyle = .kanban
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: UIConstants.standardPadding) {
                        avatarView
                        
                        VStack(spacing: 4) {
                            Text(viewModel.currentUser.fullName)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(AppColors.accentWhite)
                            
                            Text(viewModel.currentUser.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(viewModel.currentUser.role.displayName)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppColors.buttonPrimary)
                                .foregroundStyle(AppColors.accentWhite)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, UIConstants.standardPadding)
            }
            .listRowBackground(Color.clear)

            Section("Profile Information") {
                TextField("Full Name", text: $fullName)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Picker("Role", selection: $role) {
                    ForEach(UserRole.allCases) { 
                        Text($0.displayName).tag($0) 
                    }
                }
            }

            Section("Preferences") {
                HStack {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            viewModel.toggleNotifications(newValue)
                        }
                    
                    if !viewModel.hasNotificationPermission && notificationsEnabled {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }
                
                Picker("Workflow Style", selection: $preferredWorkflow) {
                    ForEach(WorkflowStyle.allCases) { 
                        Text($0.displayName).tag($0) 
                    }
                }
                .onChange(of: preferredWorkflow) { _, newValue in
                    viewModel.updateWorkflowStyle(newValue)
                }
            }
            
            Section("App Statistics") {
                StatRow(label: "Onboarding Completed", 
                       value: viewModel.settings.onboardingCompleted ? "Yes" : "No")
                StatRow(label: "Notifications Permission", 
                       value: viewModel.hasNotificationPermission ? "Granted" : "Not Granted")
            }
            
            Section("Actions") {
                Button("Reset Onboarding") {
                    showingResetAlert = true
                }
                .foregroundStyle(AppColors.buttonPrimary)
                
                if !viewModel.hasNotificationPermission && viewModel.settings.notificationsEnabled {
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProfile()
                }
                .bold()
            }
        }
        .alert("Reset Onboarding", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetOnboarding()
            }
        } message: {
            Text("This will show the onboarding flow again when you restart the app. Are you sure?")
        }
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(AppColors.buttonPrimary)
                .frame(width: 80, height: 80)
            
            if let avatarURL = viewModel.currentUser.avatarURL {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    initialsView
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
    }
    
    private var initialsView: some View {
        Text(viewModel.currentUser.initials)
            .font(.title)
            .bold()
            .foregroundStyle(AppColors.accentWhite)
    }
    
    private func loadCurrentValues() {
        fullName = viewModel.currentUser.fullName
        email = viewModel.currentUser.email
        role = viewModel.currentUser.role
        notificationsEnabled = viewModel.settings.notificationsEnabled
        preferredWorkflow = viewModel.settings.preferredWorkflow
    }
    
    private func saveProfile() {
        var updatedProfile = viewModel.currentUser
        updatedProfile.fullName = fullName
        updatedProfile.email = email
        updatedProfile.role = role
        viewModel.saveProfile(updatedProfile)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColors.accentWhite)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
