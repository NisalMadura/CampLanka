//
//  PlanListView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-02.
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
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "savedPlans"),
           let decoded = try? JSONDecoder().decode([Plan].self, from: data) {
            self.plans = decoded
        }
    }
    
    func savePlan(_ plan: Plan) {
        plans.append(plan)
        savePlans()
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
                            PlanRowView(plan: plan)
                                .onTapGesture {
                                    // Handle plan selection
                                    dismiss()
                                }
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
                
                // Tab Bar
                //CustomTabBar()
            }
            .navigationTitle("Save To My Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            //Image(systemName: "chevron.left")
                            //Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePlan) {
            CreatePlanView(viewModel: viewModel)
        }
    }
}

struct PlanRowView: View {
    let plan: Plan
    
    var body: some View {
        HStack {
            Image(plan.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            Text(plan.name)
                .font(.system(size: 16))
                .padding(.leading, 8)
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
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



struct TabBarButton: View {
    let image: String
    let text: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: image)
                .font(.system(size: 20))
            Text(text)
                .font(.system(size: 12))
        }
        .foregroundColor(text == "Add Plan" ? .green : .gray)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview Provider
struct SaveToPlanView_Previews: PreviewProvider {
    static var previews: some View {
        SaveToPlanView()
    }
}
