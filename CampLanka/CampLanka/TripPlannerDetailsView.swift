import SwiftUI
import EventKit
import FirebaseFirestore
import FirebaseAuth

struct TripPlannerDetailsView: View {
    // Existing state variables...
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
    
    // New state variables for custom items
    @State private var customPackingItems: Set<String> = []
    @State private var newPackingItem: String = ""
    @State private var showingAddPackingItem = false
    
    @State private var customActivities: Set<String> = []
    @State private var newActivity: String = ""
    @State private var showingAddActivity = false
    
    @State private var members: [Member] = [
        Member(name: "Member01", imageUrl: "person.circle.fill"),
        Member(name: "Member02", imageUrl: "person.circle.fill")
    ]
    @State private var newMemberName: String = ""
    @State private var showingAddMember = false
    
    @State private var eventKitManager = EventKitManager()
    @State private var isPermissionGranted = false
    
    
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
                        .sheet(isPresented: $showingDatePicker) {
                            DatePickerView(selectedDates: $selectedDates, isPresented: $showingDatePicker)
                        }
                        .sheet(isPresented: $showingAddPackingItem) {
                            addItemSheet
                        }
                        .sheet(isPresented: $showingAddActivity) {
                            addActivitySheet
                        }
                        .sheet(isPresented: $showingAddMember) {
                            addMemberSheet
                        }
                        .onAppear {
                            eventKitManager.requestCalendarPermission { granted in
                                isPermissionGranted = granted
                            }
                        }
                    }
                }
    
    // MARK: - View Components
    
    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where do you want to go?")
                .font(.headline)
            
            HStack {
                TextField("Location", text: $selectedCity)
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
                  
                  // Display custom packing items
                  ForEach(Array(customPackingItems), id: \.self) { item in
                      Toggle(isOn: .constant(true)) {
                          Text(item)
                      }
                  }
              }
              
              Button(action: { showingAddPackingItem.toggle() }) {
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
                    
                    // Display custom activities
                    ForEach(Array(customActivities), id: \.self) { activity in
                        Toggle(isOn: .constant(true)) {
                            Text(activity)
                        }
                    }
                }
                
                Button(action: { showingAddActivity.toggle() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Activity")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
        }
        
    // Add Item Sheet View
        private var addItemSheet: some View {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("Enter new item", text: $newPackingItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !newPackingItem.isEmpty {
                            customPackingItems.insert(newPackingItem)
                            newPackingItem = ""
                            showingAddPackingItem = false
                        }
                    }) {
                        Text("Add Item")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationBarTitle("Add New Item", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    showingAddPackingItem = false
                })
            }
        }
        
    private var addActivitySheet: some View {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("Enter new activity", text: $newActivity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !newActivity.isEmpty {
                            customActivities.insert(newActivity)
                            newActivity = ""
                            showingAddActivity = false
                        }
                    }) {
                        Text("Add Activity")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationBarTitle("Add New Activity", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    showingAddActivity = false
                })
            }
        }
    // Add Member Sheet View
        private var addMemberSheet: some View {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("Enter member name", text: $newMemberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !newMemberName.isEmpty {
                            members.append(Member(name: newMemberName, imageUrl: "person.circle.fill"))
                            newMemberName = ""
                            showingAddMember = false
                        }
                    }) {
                        Text("Add Member")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationBarTitle("Add New Member", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    showingAddMember = false
                })
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
    
    func saveTripDetails() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let tripData: [String: Any] = [
            "userID": userID,
            "selectedCity": selectedCity,
            "startDate": selectedDates?.startDate ?? Date(),
            "endDate": selectedDates?.endDate ?? Date(),
            "minBudget": minBudget,
            "maxBudget": maxBudget,
            "transportMethods": selectedTransportMethods.map { $0.rawValue },
            "packingItems": selectedPackingItems.map { $0.rawValue } + Array(customPackingItems),
            "activities": selectedActivities.map { $0.rawValue } + Array(customActivities),
            "numberOfPeople": numberOfPeople,
            "notes": notes,
            "members": members.map { ["name": $0.name, "imageUrl": $0.imageUrl] }
        ]
        
        db.collection("trips").addDocument(data: tripData) { error in
            if let error = error {
                print("Error saving trip details: \(error.localizedDescription)")
            } else {
                print("Trip details successfully saved!")
            }
        }
    }

        private func saveTripToCalendar() {
            guard let selectedDates = selectedDates else { return }
            
            let notes = """
            Budget: \(minBudget)-\(maxBudget)$
            Transport: \(selectedTransportMethods.map { $0.rawValue }.joined(separator: ", "))
            Activities: \(selectedActivities.map { $0.rawValue }.joined(separator: ", "))
            Notes: \(notes)
            """
            
            eventKitManager.addEventToCalendar(
                title: "Trip to \(selectedCity)",
                startDate: selectedDates.startDate,
                endDate: selectedDates.endDate,
                notes: notes
            )
        }
    }

// MARK: - DatePickerView
struct DatePickerView: View {
    @Binding var selectedDates: TripPlannerDetailsView.DateRange?
    @Binding var isPresented: Bool
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(selectedDates: Binding<TripPlannerDetailsView.DateRange?>, isPresented: Binding<Bool>) {
        self._selectedDates = selectedDates
        self._isPresented = isPresented
        let dates = selectedDates.wrappedValue ?? TripPlannerDetailsView.DateRange(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )
        self._startDate = State(initialValue: dates.startDate)
        self._endDate = State(initialValue: dates.endDate)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                
                DatePicker(
                    "End Date",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: [.date]
                )
            }
            .padding()
            .navigationTitle("Select Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedDates = TripPlannerDetailsView.DateRange(
                            startDate: startDate,
                            endDate: endDate
                        )
                        isPresented = false
                    }
                }
            }
            .onChange(of: startDate) { newStartDate in
                if endDate < newStartDate {
                    endDate = Calendar.current.date(byAdding: .day, value: 1, to: newStartDate) ?? newStartDate
                }
            }
        }
    }
}

    // MARK: - EventKitManager
    class EventKitManager: ObservableObject {
        private let eventStore = EKEventStore()
        @Published var isAuthorized = false
        
        func requestCalendarPermission(completion: @escaping (Bool) -> Void) {
            if #available(iOS 17.0, *) {
                Task {
                    do {
                        let granted = try await eventStore.requestFullAccessToEvents()
                        DispatchQueue.main.async {
                            self.isAuthorized = granted
                            completion(granted)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {
                        self.isAuthorized = granted
                        completion(granted)
                    }
                }
            }
        }
        
        func addEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String) {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = notes
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch {
                print("Error saving event: \(error.localizedDescription)")
            }
        }
    }

    struct TripPlannerDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            TripPlannerDetailsView()
        }
    }
