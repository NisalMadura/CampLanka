import SwiftUI
import EventKit
import FirebaseFirestore
import FirebaseAuth
import Contacts
import ContactsUI
import EventKitUI
import Foundation


struct Member: Identifiable {
    var id = UUID()
    var name: String
    var imageUrl: String
    var phoneNumber: String?
    var email: String?
    
    
    init(from contact: CNContact) {
        self.name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        self.imageUrl = "person.circle.fill"
        self.phoneNumber = contact.phoneNumbers.first?.value.stringValue
        self.email = contact.emailAddresses.first?.value as String?
    }
    
    
    init(name: String, imageUrl: String = "person.circle.fill", phoneNumber: String? = nil, email: String? = nil) {
        self.name = name
        self.imageUrl = imageUrl
        self.phoneNumber = phoneNumber
        self.email = email
    }
}

struct ContactPickerViewController: UIViewControllerRepresentable {
    @Binding var members: [Member]
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerViewController
        
        init(_ parent: ContactPickerViewController) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            
            let newMembers = contacts.map { Member(from: $0) }
            
            
            DispatchQueue.main.async {
                self.parent.members.append(contentsOf: newMembers)
                
                picker.dismiss(animated: true)
            }
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
}

struct MembersListView: View {
    @Binding var members: [Member]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(members) { member in
                    VStack {
                        Image(systemName: member.imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                        Text(member.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(width: 80)
                }
            }
            .padding(.horizontal)
        }
    }
}
extension TripPlannerDetailsView {
    var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's coming along?")
                .font(.headline)
            
            if members.isEmpty {
                Text("No members added yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                MembersListView(members: $members)
            }
            
            Button(action: {
                requestContactsAccess { granted in
                    if granted {
                        isShowingContactPicker = true
                    }
                }
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Add from Contacts")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingContactPicker) {
            ContactPickerViewController(members: $members)
        }
    }
}


func requestContactsAccess(completion: @escaping (Bool) -> Void) {
    let store = CNContactStore()
    
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized:
        completion(true)
    case .notDetermined:
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    default:
        DispatchQueue.main.async {
            completion(false)
            
            
        }
    }
}



struct TripPlannerDetailsView: View {
    
    let planId: String
    
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
    @State private var isShowingContactPicker = false
    @State private var members: [Member] = []
    // @State private var isShowingContactPicker = false
    @State private var showingSettingsAlert = false
    @State private var tripId: String?
    @State private var isEditMode: Bool = false
    
    
    @State private var customPackingItems: Set<String> = []
    @State private var newPackingItem: String = ""
    @State private var showingAddPackingItem = false
    
    @State private var customActivities: Set<String> = []
    @State private var newActivity: String = ""
    @State private var showingAddActivity = false
    
    
    @State private var newMemberName: String = ""
    @State private var showingAddMember = false
    
    @State private var eventKitManager = EventKitManager()
    @State private var isPermissionGranted = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSaveSuccess = false
    @State private var showingCalendarSuccess = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private var db = Firestore.firestore()
    
    init(planId: String) {
        self.planId = planId
        print("\(planId)")
    }
    
    private func loadTripData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        
        db.collection("plans")
            .document(planId)
            .getDocument { document, error in
                if let error = error {
                    print("Error loading trip data: \(error)")
                    return
                }
                
                guard let document = document,
                      document.exists,
                      let data = document.data() else {
                    print("Document does not exist")
                    return
                }
                
                
                let documentUserId = data["userId"] as? String ?? ""
                let isSubmitted = data["isSubmitted"] as? Bool ?? false
                
                if isSubmitted && documentUserId == userId {
                    
                    DispatchQueue.main.async {
                        selectedCity = data["city"] as? String ?? ""
                        
                        if let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
                           let endDate = (data["endDate"] as? Timestamp)?.dateValue() {
                            selectedDates = DateRange(startDate: startDate, endDate: endDate)
                        }
                        
                        if let budget = data["budget"] as? [String: String] {
                            minBudget = budget["min"] ?? ""
                            maxBudget = budget["max"] ?? ""
                        }
                        
                        if let transportArray = data["transportMethods"] as? [String] {
                            selectedTransportMethods = Set(transportArray.compactMap { TransportMethod(rawValue: $0) })
                        }
                        
                        if let packingArray = data["packingItems"] as? [String] {
                            let predefinedItems = Set(packingArray.compactMap { PackingItem(rawValue: $0) })
                            let customItems = Set(packingArray.filter { PackingItem(rawValue: $0) == nil })
                            
                            selectedPackingItems = predefinedItems
                            customPackingItems = customItems
                        }
                        
                        if let activitiesArray = data["activities"] as? [String] {
                            let predefinedActivities = Set(activitiesArray.compactMap { Activity(rawValue: $0) })
                            let customActivitiesList = Set(activitiesArray.filter { Activity(rawValue: $0) == nil })
                            
                            selectedActivities = predefinedActivities
                            customActivities = customActivitiesList
                        }
                        
                        numberOfPeople = data["numberOfPeople"] as? Int ?? 1
                        notes = data["notes"] as? String ?? ""
                        
                        if let membersData = data["members"] as? [[String: Any]] {
                            members = membersData.map { memberData in
                                Member(
                                    name: memberData["name"] as? String ?? "",
                                    phoneNumber: memberData["phoneNumber"] as? String,
                                    email: memberData["email"] as? String
                                )
                            }
                        }
                        
                        isEditMode = true
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        clearFormFields()
                        isEditMode = false
                    }
                }
            }
    }
    
    
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
    
    
    
    struct DateRange {
        var startDate: Date
        var endDate: Date
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
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
        .onAppear{
            loadTripData()
        }
    }
    
    
    
    
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
                    
                }
                
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
                .background(Color.green)
                .cornerRadius(8)
            }
        }
    }
    
    
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
                        .background(Color.green)
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
    
    private var addMemberSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter member name", text: $newMemberName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !newMemberName.isEmpty {
                        let newMember = Member(name: newMemberName)
                        members.append(newMember)
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
    // @State private var isShowingContactPicker = false
    @State private var fetchedContacts: [CNContact] = []
    
    private var contactPicker: some View {
        NavigationView {
            List {
                ForEach(fetchedContacts, id: \.identifier) { contact in
                    Button(action: {
                        let newMember = Member(from: contact)
                        members.append(newMember)
                        isShowingContactPicker = false
                    }) {
                        Text("\(contact.givenName) \(contact.familyName)")
                    }
                }
            }
            .navigationBarTitle("Select a Contact", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isShowingContactPicker = false
            })
        }
    }
    
    private var membersSkection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Who’s coming along?")
                .font(.headline)
            
            List {
                ForEach(members) { member in
                    HStack {
                        Image(systemName: member.imageUrl)
                        Text(member.name)
                    }
                }
                .onDelete { indexSet in
                    members.remove(atOffsets: indexSet)
                }
            }
            .frame(height: 200)
            
            Button(action: {
                fetchedContacts = fetchContacts()
                isShowingContactPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add from Contacts")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShowingContactPicker) {
            contactPicker
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
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    func requestContkactsAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    func fetchContacts() -> [CNContact] {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataAvailableKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts = [CNContact]()
        
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        return contacts
    }
    
    func saveTripDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "Please sign in to save trip details")
            return
        }
        
        guard !selectedCity.isEmpty, let selectedDates = selectedDates else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        let tripData: [String: Any] = [
            "userId": userId,
            "city": selectedCity,
            "startDate": selectedDates.startDate,
            "endDate": selectedDates.endDate,
            "budget": [
                "min": minBudget,
                "max": maxBudget
            ],
            "transportMethods": Array(selectedTransportMethods.map { $0.rawValue }),
            "packingItems": Array(selectedPackingItems.map { $0.rawValue }) + Array(customPackingItems),
            "activities": Array(selectedActivities.map { $0.rawValue }) + Array(customActivities),
            "numberOfPeople": numberOfPeople,
            "notes": notes,
            "members": members.map { [
                "name": $0.name,
                "phoneNumber": $0.phoneNumber ?? "",
                "email": $0.email ?? ""
            ]},
            "updatedAt": FieldValue.serverTimestamp(),
            "isSubmitted": true
            
        ]
        
        let plansCollection = db.collection("plans")
        
        // Always use the passed planId instead of creating a new document
        plansCollection.document(planId).setData(tripData, merge: true) { error in
            if let error = error {
                showAlert(title: "Error", message: "Error saving trip details: \(error.localizedDescription)")
            } else {
                showAlert(title: "Success", message: "Trip plan updated successfully!")
                self.isEditMode = true
            }
        }
    }
    private func setupAuthStateObserver() {
        Auth.auth().addStateDidChangeListener { [self] auth, user in
            if user != nil {
                self.loadTripData()
            } else {
                
                if self.isEditMode == false {
                    self.clearFormFields()
                    self.tripId = nil
                }
            }
        }
    }
    
    
    private func saveTripToCaloendar() {
        guard let selectedDates = selectedDates else {
            showAlert(title: "Error", message: "Please select trip dates first")
            return
        }
        
        guard !selectedCity.isEmpty else {
            showAlert(title: "Error", message: "Please enter a destination")
            return
        }
        
        let notes = """
          Budget: \(minBudget)-\(maxBudget)$
          Transport: \(selectedTransportMethods.map { $0.rawValue }.joined(separator: ", "))
          Activities: \(selectedActivities.map { $0.rawValue }.joined(separator: ", "))
          Notes: \(notes)
          """
        
        
        let event = EKEvent(eventStore: eventKitManager.eventStore)
        event.title = "Trip to \(selectedCity)"
        event.startDate = selectedDates.startDate
        event.endDate = selectedDates.endDate
        event.notes = notes
        
        
        let reminder = EKReminder(eventStore: eventKitManager.eventStore)
        reminder.title = "Prepare for trip to \(selectedCity)"
        reminder.notes = "Your trip to \(selectedCity) is coming up!"
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: -1, to: selectedDates.startDate) ?? selectedDates.startDate)
        reminder.priority = 1
        
        do {
            try eventKitManager.eventStore.save(event, span: .thisEvent)
            try eventKitManager.eventStore.save(reminder, commit: true)
            showAlert(title: "Success", message: "Trip has been added to your calendar and reminders!")
        } catch {
            showAlert(title: "Error", message: "Failed to save to calendar: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    private func clearFormFields() {
        selectedCity = ""
        selectedDates = nil
        minBudget = ""
        maxBudget = ""
        selectedTransportMethods = []
        selectedPackingItems = []
        selectedActivities = []
        numberOfPeople = 1
        notes = ""
        members = []
        customPackingItems = []
        customActivities = []
        tripId=nil
    }
}


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


class EventKitManager: ObservableObject {
    let eventStore = EKEventStore()
    @Published var isAuthorized = false
    
    func requestCalendarPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            Task {
                do {
                    let calendarAccess = try await eventStore.requestFullAccessToEvents()
                    let reminderAccess = try await eventStore.requestFullAccessToReminders()
                    DispatchQueue.main.async {
                        self.isAuthorized = calendarAccess && reminderAccess
                        completion(self.isAuthorized)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        } else {
            
            eventStore.requestAccess(to: .event) { [weak self] calendarGranted, _ in
                self?.eventStore.requestAccess(to: .reminder) { reminderGranted, _ in
                    DispatchQueue.main.async {
                        self?.isAuthorized = calendarGranted && reminderGranted
                        completion(calendarGranted && reminderGranted)
                    }
                }
            }
        }
    }
    
    func saveEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String, completion: @escaping (Bool, String) -> Void) {
        
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        guard authStatus == .authorized else {
            completion(false, "Calendar access not authorized")
            return
        }
        
        
        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            
            let calendars = eventStore.calendars(for: .event)
            guard let firstCalendar = calendars.first else {
                completion(false, "No calendar available")
                return
            }
            
            let event = EKEvent(eventStore: eventStore)
            event.calendar = firstCalendar
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = notes
            
            
            let alarm = EKAlarm(relativeOffset: -86400)
            event.addAlarm(alarm)
            
            do {
                try eventStore.save(event, span: .thisEvent)
                saveReminderForTrip(title: "Prepare for \(title)", notes: notes, dueDate: startDate)
                completion(true, "Event saved successfully")
            } catch {
                completion(false, "Failed to save event: \(error.localizedDescription)")
            }
            return
        }
        
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        
        
        let alarm = EKAlarm(relativeOffset: -86400)
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            saveReminderForTrip(title: "Prepare for \(title)", notes: notes, dueDate: startDate)
            completion(true, "Event saved successfully")
        } catch {
            completion(false, "Failed to save event: \(error.localizedDescription)")
        }
    }
    
    private func saveReminderForTrip(title: String, notes: String, dueDate: Date) {
        guard EKEventStore.authorizationStatus(for: .reminder) == .authorized else { return }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneDayBefore)
        
        
        let alarm = EKAlarm(absoluteDate: oneDayBefore)
        reminder.addAlarm(alarm)
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
        }
    }
}

extension TripPlannerDetailsView {
    private func saveTripToCalendar() {
        guard let selectedDates = selectedDates else {
            showAlert(title: "Error", message: "Please select trip dates first")
            return
        }
        
        guard !selectedCity.isEmpty else {
            showAlert(title: "Error", message: "Please enter a destination")
            return
        }
        
        let notes = """
          Trip to \(selectedCity)
          Budget: \(minBudget)-\(maxBudget)$
          Transport: \(selectedTransportMethods.map { $0.rawValue }.joined(separator: ", "))
          Activities: \(selectedActivities.map { $0.rawValue }.joined(separator: ", "))
          Additional Notes: \(self.notes)
          """
        
        
        eventKitManager.requestCalendarPermission { granted in
            if granted {
                
                eventKitManager.saveEventToCalendar(
                    title: "Trip to \(selectedCity)",
                    startDate: selectedDates.startDate,
                    endDate: selectedDates.endDate,
                    notes: notes
                ) { success, message in
                    DispatchQueue.main.async {
                        if success {
                            showAlert(title: "Success", message: "Trip has been added to your calendar and reminders!")
                        } else {
                            showAlert(title: "Error", message: message)
                        }
                    }
                }
            } else {
                showAlert(title: "Error", message: "Calendar access denied. Please enable calendar access in Settings.")
            }
        }
    }
}



struct TripPlannerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlannerDetailsView(planId: "SampleID")
    }
}
