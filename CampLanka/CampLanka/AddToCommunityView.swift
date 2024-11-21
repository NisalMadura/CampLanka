//
//  AddToCommunityView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import SwiftUI

struct AddToCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showWriteReview = false
    @State private var showAddLocation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                Text("Add to the Community")
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                Button(action: {
                    showWriteReview = true
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                        Text("Write a Review")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0/255, green: 86/255, blue: 63/255))
                    .cornerRadius(12)
                }
                
                
                Button(action: {
                    showAddLocation = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                        Text("Add a Location")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0/255, green: 86/255, blue: 63/255))
                    .cornerRadius(12)
                }
                
                
                Text("The CampLanka has the most reviews\nbecause of campers like you.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 40, height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.bottom)
            }
            .padding()
            .sheet(isPresented: $showWriteReview) {
                WriteReviewView()
            }
            .sheet(isPresented: $showAddLocation) {
                AddLocationView()
            }
        }
    }
}


struct WriteReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reviewText = ""
    @State private var rating: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title2)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
                
                
                TextEditor(text: $reviewText)
                    .frame(height: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        
                        dismiss()
                    }
                    .disabled(reviewText.isEmpty || rating == 0)
                }
            }
        }
    }
}


struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var locationName = ""
    @State private var description = ""
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location Details")) {
                    TextField("Location Name", text: $locationName)
                    TextField("Address", text: $address)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photos")
                        }
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        
                        dismiss()
                    }
                    .disabled(locationName.isEmpty || address.isEmpty)
                }
            }
        }
    }
}


struct HomeViewUpdate: View {
    @State private var showAddCommunity = false
    
    var body: some View {
        // Your existing HomeView content
        Button(action: {
            showAddCommunity = true
        }) {
            Text("Add to Community")
        }
        .sheet(isPresented: $showAddCommunity) {
            AddToCommunityView()
                .presentationDetents([.medium])
        }
    }
}

struct AddToCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        AddToCommunityView()
    }
}
