//
//  TripPlannerDetailsView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import SwiftUI

// Date Range struct for date selection
struct DateRange {
    var startDate: Date
    var endDate: Date
}

struct Member: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
}

struct TripPlannerDetailsView: View {
    @State private var selectedCity: String = ""
    @State private var selectedDates: DateRange?
    @State private var minBudget: String = ""
    @State private var maxBudget: String = ""
    @State private var selectedTransportMethods: Set<TransportMethod> = []
    @State private var selectedPackingItems: Set<PackingItem> = []
    @State private var selectedActivities: Set<Activity> = []
    @State private var numberOfPeople: Int = 1
    @State private var showingDatePicker = false
    @State private var notes: String = ""
    @State private var members: [Member] = [
        Member(name: "Member01", imageUrl: "person.circle.fill"),
        Member(name: "Member02", imageUrl: "person.circle.fill")
    ]
    
    // Enums for selection options
    enum TransportMethod: String, CaseIterable {
        case bus = "Bus"
        case train = "Train"
        case car = "Car"
        case other = "other"
    }
    
    enum PackingItem: String, CaseIterable {
        case backpack = "Backpack"
        case tent = "Tent"
        case waterBottle = "Water Bottle"
        case sleepingBag = "Sleeping Bag"
    }
    
    enum Activity: String, CaseIterable {
        case hiking = "Hiking"
        case swimming = "Swimming"
        case bbqDinner = "BBQ Dinner"
        case cycling = "cycling"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Plan your next\nadventure")
                        .font(.largeTitle)
                        .bold()
                    
                    // Destination Section
                    destinationSection
                    
                    // Budget Section
                    budgetSection
                    
                    // Transport Section
                    transportSection
                    
                    // Packing List Section
                    packingListSection
                    
                    // People Count Section
                    peopleCountSection
                    
                    // Activities Section
                    activitiesSection
                    
                    // Members Section
                    membersSection
                    
                    // Notes Section
                    notesSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationBarItems(leading: Button(action: {
                // Back button action
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            })
            .navigationBarTitle("Your Tour", displayMode: .inline)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDates: $selectedDates, isPresented: $showingDatePicker)
        }
    }
    
    // MARK: - View Components
    
    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where do you want to go?")
                .font(.headline)
            
            HStack {
                TextField("Select a City", text: $selectedCity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    showingDatePicker.toggle()
                }) {
                    Text("Select dates")
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add destination")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
    }
    
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your Budget")
                .font(.headline)
            
            HStack {
                TextField("Min", text: $minBudget)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("-")
                TextField("Max", text: $maxBudget)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("$")
            }
        }
    }
    
    private var transportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What is your travel method?")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(TransportMethod.allCases, id: \.self) { method in
                    Toggle(method.rawValue, isOn: Binding(
                        get: { selectedTransportMethods.contains(method) },
                        set: { isSelected in
                            if isSelected {
                                selectedTransportMethods.insert(method)
                            } else {
                                selectedTransportMethods.remove(method)
                            }
                        }
                    ))
                    .toggleStyle(CheckboxToggleStyle())
                }
            }
        }
    }
    
    private var packingListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Packing List")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(PackingItem.allCases, id: \.self) { item in
                    Toggle(item.rawValue, isOn: Binding(
                        get: { selectedPackingItems.contains(item) },
                        set: { isSelected in
                            if isSelected {
                                selectedPackingItems.insert(item)
                            } else {
                                selectedPackingItems.remove(item)
                            }
                        }
                    ))
                    .toggleStyle(CheckboxToggleStyle())
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
            }
        }
    }
    
    private var peopleCountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How many people are going?")
                .font(.headline)
            
            HStack {
                Text("Person")
                Spacer()
                Button(action: {
                    if numberOfPeople > 1 {
                        numberOfPeople -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("\(numberOfPeople)")
                    .frame(width: 40)
                    .multilineTextAlignment(.center)
                
                Button(action: { numberOfPeople += 1 }) {
                    Image(systemName: "plus")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Things to Do")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(Activity.allCases, id: \.self) { activity in
                    Toggle(activity.rawValue, isOn: Binding(
                        get: { selectedActivities.contains(activity) },
                        set: { isSelected in
                            if isSelected {
                                selectedActivities.insert(activity)
                            } else {
                                selectedActivities.remove(activity)
                            }
                        }
                    ))
                    .toggleStyle(CheckboxToggleStyle())
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Activity")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
            }
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Add Members")
                    .font(.headline)
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
            }
            
            ForEach(members) { member in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    Text(member.name)
                        .font(.body)
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Text("Share")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {}) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.top, 16)
    }
}

struct DatePickerView: View {
    @Binding var selectedDates: DateRange?
    @Binding var isPresented: Bool
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    selectedDates = DateRange(startDate: startDate, endDate: endDate)
                    isPresented = false
                }
            )
            .navigationBarTitle("Select Dates", displayMode: .inline)
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

struct TripPlannerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlannerDetailsView()
    }
}
