//
//  ForgotPasswordView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-07.
//


// MARK: - Models
struct Plan: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var imageName: String
    var dateCreated: Date
}

// MARK: - View Models
class PlanListViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    
    init() {
        loadPlans()
    }
    
    func loadPlans() {
        if let data = UserDefaults.standard.data(forKey: "savedPlans"),
           let decoded = try? JSONDecoder().decode([Plan].self, from: data) {
            self.plans = decoded
        }
    }
    
    func savePlan(_ plan: Plan) {
        plans.append(plan)
        savePlans()
    }
    
    func deletePlan(at indexSet: IndexSet) {
        plans.remove(atOffsets: indexSet)
        savePlans()
    }
    
    func deletePlan(plan: Plan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans.remove(at: index)
            savePlans()
        }
    }
    
    private func savePlans() {
        if let encoded = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(encoded, forKey: "savedPlans")
        }
    }
}

// MARK: - Views
import SwiftUI

struct SaveToPlanView: View {
    @StateObject private var viewModel = PlanListViewModel()
    @State private var showingCreatePlan = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.plans) { plan in
                            PlanRowView(plan: plan, viewModel: viewModel)
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        showingCreatePlan = true
                    }) {
                        Text("Create New Plan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Save To My Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingCreatePlan) {
            CreatePlanView(viewModel: viewModel)
        }
    }
}

struct PlanRowView: View {
    let plan: Plan
    @ObservedObject var viewModel: PlanListViewModel
    @State private var showingPreferences = false
    @State private var showDeleteAlert = false
    @State private var showGroupChat = false
    
    var body: some View {
            Button(action: {
                showingPreferences = true
            }) {
                HStack(spacing: 12) {
                    // Image on the left
                    Image(plan.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Plan name
                    Text(plan.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Action buttons on the right
                    HStack(spacing: 16) {
                        // Group chat button
                        Button(action: {
                            showGroupChat = true  // Step 3: Set state to true to trigger navigation
                        }) {
                            Image(systemName: "rectangle.3.group.bubble")
                                .foregroundColor(.green)
                                .font(.system(size: 22))
                        }
                        .background(
                            NavigationLink("", destination: GroupSettingsView(), isActive: $showGroupChat) // Step 4: Use NavigationLink for navigation
                                .hidden()
                        )
                        
                        // Delete button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .sheet(isPresented: $showingPreferences) {
                TripPlannerView()
            }
            .alert("Delete Plan", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deletePlan(plan: plan)
                }
            } message: {
                Text("Are you sure you want to delete this plan?")
            }
        }
    }

struct CreatePlanView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PlanListViewModel
    @State private var planName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Plan Name", text: $planName)
            }
            .navigationTitle("Create New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newPlan = Plan(name: planName, imageName: "default_image", dateCreated: Date())
                        viewModel.savePlan(newPlan)
                        dismiss()
                    }
                    .disabled(planName.isEmpty)
                }
            }
        }
    }
}

struct CampingPreferenceViews: View {
    @Environment(\.dismiss) var dismiss
    var planName: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic Information")) {
                    NavigationLink(destination: DurationView()) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Camping Duration")
                        }
                    }
                    
                    NavigationLink(destination: PeopleCountView()) {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.green)
                            Text("Number of People")
                        }
                    }
                    
                    NavigationLink(destination: LocationPreferenceView()) {
                        HStack {
                            Image(systemName: "map")
                                .foregroundColor(.green)
                            Text("Preferred Location")
                        }
                    }
                }
                
                Section(header: Text("Amenities")) {
                    NavigationLink(destination: FacilitiesView()) {
                        HStack {
                            Image(systemName: "house")
                                .foregroundColor(.green)
                            Text("Required Facilities")
                        }
                    }
                    
                    NavigationLink(destination: EquipmentView()) {
                        HStack {
                            Image(systemName: "tent")
                                .foregroundColor(.green)
                            Text("Equipment Needed")
                        }
                    }
                }
                
                Section(header: Text("Activities")) {
                    NavigationLink(destination: ActivitiesView()) {
                        HStack {
                            Image(systemName: "figure.hiking")
                                .foregroundColor(.green)
                            Text("Planned Activities")
                        }
                    }
                    
                    NavigationLink(destination: RequirementsView()) {
                        HStack {
                            Image(systemName: "list.clipboard")
                                .foregroundColor(.green)
                            Text("Special Requirements")
                        }
                    }
                }
            }
            .navigationTitle(planName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Add save functionality
                        dismiss()
                    }
                }
            }
        }
    }
}

// Detailed Views
struct DurationView: View {
    @State private var selectedDays = 1
    @State private var selectedNights = 1
    
    var body: some View {
        Form {
            Section(header: Text("Trip Duration")) {
                Stepper("Days: \(selectedDays)", value: $selectedDays, in: 1...30)
                Stepper("Nights: \(selectedNights)", value: $selectedNights, in: 1...30)
            }
        }
        .navigationTitle("Duration Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PeopleCountView: View {
    @State private var adultCount = 1
    @State private var childCount = 0
    
    var body: some View {
        Form {
            Section(header: Text("Group Size")) {
                Stepper("Adults (18+): \(adultCount)", value: $adultCount, in: 1...20)
                Stepper("Children: \(childCount)", value: $childCount, in: 0...10)
            }
            
            Section(footer: Text("Total group size: \(adultCount + childCount)")) {
                // Additional settings if needed
            }
        }
        .navigationTitle("People Count")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationPreferenceView: View {
    @State private var selectedRegion = "Central Province"
    let regions = ["Central Province", "Eastern Province", "Northern Province", "Southern Province", "Western Province", "North Western Province", "North Central Province", "Uva Province", "Sabaragamuwa Province"]
    
    var body: some View {
        Form {
            Section(header: Text("Preferred Region")) {
                Picker("Region", selection: $selectedRegion) {
                    ForEach(regions, id: \.self) { region in
                        Text(region).tag(region)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .navigationTitle("Location Preference")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FacilitiesView: View {
    @State private var needsWater = true
    @State private var needsElectricity = true
    @State private var needsBathroom = true
    @State private var needsKitchen = false
    
    var body: some View {
        Form {
            Section(header: Text("Basic Facilities")) {
                Toggle("Water Supply", isOn: $needsWater)
                Toggle("Electricity", isOn: $needsElectricity)
                Toggle("Bathroom", isOn: $needsBathroom)
                Toggle("Kitchen Access", isOn: $needsKitchen)
            }
        }
        .navigationTitle("Required Facilities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EquipmentView: View {
    @State private var needsTent = true
    @State private var needsSleepingBag = true
    @State private var needsCookingGear = false
    @State private var needsFirstAid = true
    
    var body: some View {
        Form {
            Section(header: Text("Camping Equipment")) {
                Toggle("Tent", isOn: $needsTent)
                Toggle("Sleeping Bag", isOn: $needsSleepingBag)
                Toggle("Cooking Gear", isOn: $needsCookingGear)
                Toggle("First Aid Kit", isOn: $needsFirstAid)
            }
        }
        .navigationTitle("Equipment Needed")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ActivitiesView: View {
    @State private var selectedActivities = Set<String>()
    let activities = ["Hiking", "Swimming", "Fishing", "Bird Watching", "Photography", "Campfire", "Star Gazing"]
    
    var body: some View {
        Form {
            Section(header: Text("Select Activities")) {
                ForEach(activities, id: \.self) { activity in
                    Toggle(activity, isOn: Binding(
                        get: { selectedActivities.contains(activity) },
                        set: { isSelected in
                            if isSelected {
                                selectedActivities.insert(activity)
                            } else {
                                selectedActivities.remove(activity)
                            }
                        }
                    ))
                }
            }
        }
        .navigationTitle("Planned Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RequirementsView: View {
    @State private var specialDiet = false
    @State private var accessibilityNeeds = false
    @State private var medicalConditions = false
    @State private var notes = ""
    
    var body: some View {
        Form {
            Section(header: Text("Special Requirements")) {
                Toggle("Special Diet", isOn: $specialDiet)
                Toggle("Accessibility Needs", isOn: $accessibilityNeeds)
                Toggle("Medical Conditions", isOn: $medicalConditions)
            }
            
            Section(header: Text("Additional Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
        }
        .navigationTitle("Special Requirements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
struct SaveToPlanView_Previews: PreviewProvider {
    static var previews: some View {
        SaveToPlanView()
    }
}
