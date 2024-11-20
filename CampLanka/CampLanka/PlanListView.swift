//
// PlanListView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-07.
//



import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation


struct Plan: Identifiable {
    var id: String
    var name: String
    var imageName: String
    var dateCreated: Date
    var userId: String
    
    init(id: String = UUID().uuidString,
         name: String,
         imageName: String = "default_image",
         dateCreated: Date = Date(),
         userId: String = Auth.auth().currentUser?.uid ?? "") {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.dateCreated = dateCreated
        self.userId = userId
    }
    
    
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> Plan? {
        let data = document.data()
        
        guard let name = data["name"] as? String else { return nil }
        
        let id = document.documentID
        let imageName = data["imageName"] as? String ?? "default_image"
        let timestamp = (data["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        let userId = data["userId"] as? String ?? ""
        
        return Plan(id: id,
                    name: name,
                    imageName: imageName,
                    dateCreated: timestamp,
                    userId: userId)
    }
    
    
    var firestoreData: [String: Any] {
        return [
            "name": name,
            "imageName": imageName,
            "dateCreated": Timestamp(date: dateCreated),
            "userId": userId
        ]
    }
}

class PlanListViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        loadPlans()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func loadPlans() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        listenerRegistration?.remove()
        listenerRegistration = db.collection("plans")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.plans = []
                    return
                }
                
                self.plans = documents.compactMap { Plan.fromFirestore($0) }
            }
    }
    
    func savePlan(_ name: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        let plan = Plan(name: name, userId: userId)
        
        db.collection("plans").document(plan.id).setData(plan.firestoreData) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deletePlan(plan: Plan) {
        isLoading = true
        
        db.collection("plans").document(plan.id).delete { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
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
                        viewModel.savePlan(planName)
                        dismiss()
                    }
                    .disabled(planName.isEmpty)
                }
            }
        }
    }
}

struct SaveToPlanView: View {
    @StateObject private var viewModel = PlanListViewModel()
    @State private var showingCreatePlan = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.plans) { plan in
                                PlanRowView(plan: plan, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
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
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .sheet(isPresented: $showingCreatePlan) {
            CreatePlanView(viewModel: viewModel)
        }
        .navigationBarBackButtonHidden(true)
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
                Image(plan.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(plan.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 16) {
                    NavigationLink(
                        destination: ChatView(
                            groupName: plan.name,
                            participants: [
                                User(name: "Michael Tran", avatar: "person.circle"),
                                User(name: "Chris", avatar: "person.circle"),
                                User(name: "Kristen Decastro", avatar: "person.circle")
                            ]
                        ),
                        isActive: $showGroupChat
                    ) {
                        Image(systemName: "rectangle.3.group.bubble")
                            .foregroundColor(.green)
                            .font(.system(size: 22))
                    }
                    
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
            TripPlannerDetailsView(planId: plan.id)
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


struct SaveToPlanView_Previews: PreviewProvider {
    static var previews: some View {
        SaveToPlanView()
    }
}
