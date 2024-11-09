import SwiftUI
import EventKit
import FirebaseFirestore
import FirebaseAuth

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
    
    @State private var eventKitManager = EventKitManager()  // EventKitManager instance
    @State private var isPermissionGranted = false  // Flag to check permission
    
    private var db = Firestore.firestore()
    
    enum TransportMethod: String, CaseIterable {
        case bus = "Bus"
        case train = "Train"
        case car = "Car"
        case other = "Other"
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
        case cycling = "Cycling"
    }

    struct Member: Identifiable {
        var id = UUID()
        var name: String
        var imageUrl: String
    }
    
    struct DateRange {
        var startDate: Date
        var endDate: Date
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Plan your next\nadventure")
                        .font(.largeTitle)
                        .bold()
                    
                    destinationSection
                    
                    budgetSection
                    
                    transportSection
                    
                    packingListSection
                    
                    peopleCountSection
                    
                    activitiesSection
                    
                    membersSection
                    
                    notesSection
                    
                    actionButtons
                }
                .padding()
            }
            .navigationBarTitle("Plan Your Tour", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            //.nevigationBarBackButtonHidden(false)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDates: $selectedDates, isPresented: $showingDatePicker)
        }
        .onAppear {
            eventKitManager.requestCalendarPermission { granted in
                isPermissionGranted = granted
            }
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
                    Toggle(isOn: Binding(
                        get: { selectedTransportMethods.contains(method) },
                        set: { isSelected in
                            if isSelected {
                                selectedTransportMethods.insert(method)
                            } else {
                                selectedTransportMethods.remove(method)
                            }
                        }
                    )) {
                        Text(method.rawValue)
                    }
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
                    Toggle(isOn: Binding(
                        get: { selectedPackingItems.contains(item) },
                        set: { isSelected in
                            if isSelected {
                                selectedPackingItems.insert(item)
                            } else {
                                selectedPackingItems.remove(item)
                            }
                        }
                    )) {
                        Text(item.rawValue)
                    }
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
            Text("Activities to enjoy")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(Activity.allCases, id: \.self) { activity in
                    Toggle(isOn: Binding(
                        get: { selectedActivities.contains(activity) },
                        set: { isSelected in
                            if isSelected {
                                selectedActivities.insert(activity)
                            } else {
                                selectedActivities.remove(activity)
                            }
                        }
                    )) {
                        Text(activity.rawValue)
                    }
                }
            }
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Who’s coming along?")
                .font(.headline)
            
            ForEach(members) { member in
                HStack {
                    Image(systemName: member.imageUrl)
                    Text(member.name)
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Member")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(8)
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Any additional notes?")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding(.top, 5)
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button(action: saveTripDetails) {
                Text("Save Details")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: saveTripToCalendar) {
                Text("Save to Calendar")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveTripDetails() {
        guard let selectedDates = selectedDates else { return }
        
        let tripData: [String: Any] = [
            "city": selectedCity,
            "minBudget": minBudget,
            "maxBudget": maxBudget,
            "dates": [
                "startDate": selectedDates.startDate,
                "endDate": selectedDates.endDate
            ],
            "transport": selectedTransportMethods.map { $0.rawValue },
            "packingList": selectedPackingItems.map { $0.rawValue },
            "activities": selectedActivities.map { $0.rawValue },
            "members": members.map { $0.name },
            "notes": notes
        ]
        
        db.collection("trips").addDocument(data: tripData) { error in
            if let error = error {
                print("Error saving trip: \(error)")
            } else {
                print("Trip saved successfully!")
            }
        }
    }
    
    private func saveTripToCalendar() {
        guard let selectedDates = selectedDates else { return }
        eventKitManager.addEventToCalendar(title: "Trip to \(selectedCity)", startDate: selectedDates.startDate, endDate: selectedDates.endDate, notes: notes)
    }
}

struct DatePickerView: View {
    @Binding var selectedDates: TripPlannerDetailsView.DateRange?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            DatePicker("Start Date", selection: Binding(
                get: { selectedDates?.startDate ?? Date() },
                set: { selectedDates?.startDate = $0 }
            ), displayedComponents: [.date])
            
            DatePicker("End Date", selection: Binding(
                get: { selectedDates?.endDate ?? Date() },
                set: { selectedDates?.endDate = $0 }
            ), displayedComponents: [.date])
            
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .padding()
    }
}

struct EventKitManager {
    func requestCalendarPermission(completion: @escaping (Bool) -> Void) {
        // Implement the request permission logic here (use EventKit APIs)
    }
    
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String) {
        // Add event to calendar (use EventKit APIs)
    }
}

struct TripPlannerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlannerDetailsView()
    }
}
