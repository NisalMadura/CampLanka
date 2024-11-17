//
//  PersonalDetailsView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-17.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct PersonalDetails: Codable {
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date
    var address: String
    var gender: String
}

struct PersonalDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var personalDetails = PersonalDetails(
        email: "",
        phoneNumber: "",
        dateOfBirth: Date(),
        address: "",
        gender: "Prefer not to say"
    )
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingSaveSuccess = false
    
    private let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    if isEditing {
                        TextField("Email", text: $personalDetails.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        TextField("Phone Number", text: $personalDetails.phoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    } else {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(personalDetails.email)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Phone Number")
                            Spacer()
                            Text(personalDetails.phoneNumber)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Personal Information")) {
                    if isEditing {
                        DatePicker(
                            "Date of Birth",
                            selection: $personalDetails.dateOfBirth,
                            displayedComponents: .date
                        )
                        
                        Picker("Gender", selection: $personalDetails.gender) {
                            ForEach(genderOptions, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        
                        TextField("Address", text: $personalDetails.address)
                            .textContentType(.fullStreetAddress)
                    } else {
                        HStack {
                            Text("Date of Birth")
                            Spacer()
                            Text(formattedDate(personalDetails.dateOfBirth))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Gender")
                            Spacer()
                            Text(personalDetails.gender)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Address")
                            Spacer()
                            Text(personalDetails.address)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Personal Details")
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        savePersonalDetails()
                    } else {
                        isEditing = true
                    }
                }
                .disabled(isSaving)
            )
            .onAppear {
                fetchPersonalDetails()
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func fetchPersonalDetails() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError("Please sign in again to view your personal details.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                showError("We couldn't load your details at this moment. Please try again later.")
                print("Debug error: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if let email = Auth.auth().currentUser?.email {
                    personalDetails.email = email
                }
                
                personalDetails.phoneNumber = document.data()?["phoneNumber"] as? String ?? ""
                personalDetails.address = document.data()?["address"] as? String ?? ""
                personalDetails.gender = document.data()?["gender"] as? String ?? "Prefer not to say"
                
                if let timestamp = document.data()?["dateOfBirth"] as? Timestamp {
                    personalDetails.dateOfBirth = timestamp.dateValue()
                }
            }
        }
    }
    
    private func savePersonalDetails() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError("Please sign in again to save your changes.")
            return
        }
        
        isSaving = true
        
        let data: [String: Any] = [
            "phoneNumber": personalDetails.phoneNumber,
            "dateOfBirth": Timestamp(date: personalDetails.dateOfBirth),
            "address": personalDetails.address,
            "gender": personalDetails.gender
        ]
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(data, merge: true) { error in
            isSaving = false
            
            if let error = error {
                showError("Unable to save your changes. Please check your internet connection and try again.")
                print("Debug error: \(error.localizedDescription)")
            } else {
                isEditing = false
                showingSaveSuccess = true
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}
