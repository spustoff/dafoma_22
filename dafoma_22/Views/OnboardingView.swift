import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage: Int = 0
    @State private var sampleName = ""
    @State private var sampleEmail = ""
    @State private var selectedWorkflow: WorkflowStyle = .kanban
    @State private var enableNotifications = true
    
    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                featuresPage.tag(1)
                personalizationPage.tag(2)
                sampleProjectPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

            navigationButtons
                .padding(.horizontal, UIConstants.standardPadding)
                .padding(.bottom, UIConstants.standardPadding)
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            sampleName = "Your Name"
            sampleEmail = "you@example.com"
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: UIConstants.largePadding) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.buttonPrimary)
            
            VStack(spacing: UIConstants.standardPadding) {
                Text("Welcome to \(AppStrings.appName)")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.accentWhite)
                
                Text("The ultimate task management and project collaboration platform designed for teams that ship.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, UIConstants.standardPadding)
            
            Spacer()
        }
    }
    
    private var featuresPage: some View {
        VStack(spacing: UIConstants.largePadding) {
            Spacer()
            
            Text("Powerful Features")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(AppColors.accentWhite)
            
            VStack(spacing: UIConstants.standardPadding) {
                FeatureRow(
                    icon: "checklist",
                    title: "Smart Task Management",
                    description: "Create, prioritize, and track tasks with intelligent filtering and tagging."
                )
                
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Visual Project Dashboards",
                    description: "Gantt-like timelines and progress tracking for complete project visibility."
                )
                
                FeatureRow(
                    icon: "person.2.fill",
                    title: "Team Collaboration",
                    description: "Real-time chat, file sharing, and controlled access levels for seamless teamwork."
                )
                
                FeatureRow(
                    icon: "gearshape.2.fill",
                    title: "Developer Tools Integration",
                    description: "API integrations and automation for CI/CD workflows and third-party services."
                )
            }
            .padding(.horizontal, UIConstants.standardPadding)
            
            Spacer()
        }
    }
    
    private var personalizationPage: some View {
        VStack(spacing: UIConstants.largePadding) {
            Spacer()
            
            Text("Personalize Your Experience")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(AppColors.accentWhite)
                .multilineTextAlignment(.center)
            
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $sampleName)
                    TextField("Email", text: $sampleEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Preferences") {
                    Picker("Workflow Style", selection: $selectedWorkflow) {
                        ForEach(WorkflowStyle.allCases) {
                            Text($0.displayName).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            
            Spacer()
        }
    }
    
    private var sampleProjectPage: some View {
        VStack(spacing: UIConstants.largePadding) {
            Spacer()
            
            VStack(spacing: UIConstants.standardPadding) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.accentYellow)
                
                Text("Sample Project Setup")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(AppColors.accentWhite)
                    .multilineTextAlignment(.center)
                
                Text("We'll create a sample project with tasks to help you get familiar with \(AppStrings.appName)'s capabilities.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, UIConstants.standardPadding)
            }
            
            VStack(alignment: .leading, spacing: UIConstants.smallPadding) {
                Text("What we'll create:")
                    .font(.headline)
                    .foregroundStyle(AppColors.accentWhite)
                
                SampleItemRow(icon: "folder", text: "\"Getting Started\" project")
                SampleItemRow(icon: "checkmark.circle", text: "Sample tasks with different priorities")
                SampleItemRow(icon: "tag", text: "Example tags and categories")
                SampleItemRow(icon: "calendar", text: "Timeline with due dates")
            }
            .padding(.horizontal, UIConstants.standardPadding)
            
            Spacer()
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentPage > 0 {
                Button("Back") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
                .foregroundStyle(AppColors.accentWhite)
            }
            
            Spacer()
            
            Button(action: {
                if currentPage < totalPages - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
            }) {
                Text(currentPage < totalPages - 1 ? "Continue" : "Get Started")
                    .bold()
                    .frame(minWidth: 120)
                    .frame(height: UIConstants.controlHeight)
                    .background(AppColors.buttonPrimary)
                    .foregroundStyle(AppColors.accentWhite)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: UIConstants.standardPadding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppColors.buttonPrimary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.accentWhite)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

struct SampleItemRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: UIConstants.smallPadding) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accentYellow)
                .frame(width: 20)
            
            Text(text)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
}
