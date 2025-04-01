import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7) // Eine Woche später
    @State private var selectedTransport: [TransportType] = []
    @State private var selectedAccommodation: AccommodationType = .hotel
    @State private var selectedActivities: [Activity] = []
    @State private var isBusinessTrip = false
    @State private var numberOfPeople = 1
    @State private var selectedClimate: Climate = .moderate
    
    @State private var currentStep = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentStep) {
                    // Schritt 1: Grundlegende Informationen
                    basicInfoView
                        .tag(0)
                    
                    // Schritt 2: Transport & Unterkunft
                    transportAccommodationView
                        .tag(1)
                    
                    // Schritt 3: Aktivitäten & weitere Details
                    activitiesAndDetailsView
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Navigation Buttons
                navigationButtons
            }
            .navigationTitle("Neue Reise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Schritt 1: Grundlegende Informationen
    var basicInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reisedetails")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading) {
                Text("Wie soll deine Reise heißen?")
                    .font(.headline)
                TextField("z.B. Sommerurlaub Italien", text: $tripName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading) {
                Text("Wohin geht die Reise?")
                    .font(.headline)
                TextField("z.B. Rom, Italien", text: $destination)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading) {
                Text("Wann geht es los?")
                    .font(.headline)
                DatePicker("Von", selection: $startDate, displayedComponents: .date)
                DatePicker("Bis", selection: $endDate, displayedComponents: .date)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Schritt 2: Transport & Unterkunft
    var transportAccommodationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Transport & Unterkunft")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading) {
                    Text("Wie reist du?")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(TransportType.allCases, id: \.self) { type in
                            TransportSelectButton(
                                type: type,
                                isSelected: selectedTransport.contains(type)
                            ) {
                                if selectedTransport.contains(type) {
                                    selectedTransport.removeAll { $0 == type }
                                } else {
                                    selectedTransport.append(type)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Wo übernachtest du?")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(AccommodationType.allCases, id: \.self) { type in
                            AccommodationSelectButton(
                                type: type,
                                isSelected: selectedAccommodation == type
                            ) {
                                selectedAccommodation = type
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // Schritt 3: Aktivitäten & weitere Details
    var activitiesAndDetailsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Aktivitäten & Details")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading) {
                    Text("Was hast du vor?")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(Activity.allCases, id: \.self) { activity in
                            ActivitySelectButton(
                                activity: activity,
                                isSelected: selectedActivities.contains(activity)
                            ) {
                                if selectedActivities.contains(activity) {
                                    selectedActivities.removeAll { $0 == activity }
                                } else {
                                    selectedActivities.append(activity)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Weitere Details")
                        .font(.headline)
                    
                    Toggle("Geschäftsreise", isOn: $isBusinessTrip)
                    
                    HStack {
                        Text("Anzahl Personen")
                        Spacer()
                        Stepper("\(numberOfPeople)", value: $numberOfPeople, in: 1...10)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Klimazone am Reiseziel")
                        .font(.headline)
                    
                    Picker("Klima", selection: $selectedClimate) {
                        ForEach(Climate.allCases, id: \.self) { climate in
                            Label(climate.rawValue, systemImage: climate.iconName)
                                .tag(climate)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
        }
    }
    
    // Navigation Buttons
    var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < 2 {
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Weiter")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: createTrip) {
                    Text("Packliste erstellen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(tripName.isEmpty || destination.isEmpty || selectedTransport.isEmpty)
            }
        }
        .padding()
    }
    
    func createTrip() {
        // Neue Reise erstellen
        let newTrip = Trip(
            name: tripName,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            transportTypes: selectedTransport,
            accommodationType: selectedAccommodation,
            activities: selectedActivities,
            isBusinessTrip: isBusinessTrip,
            numberOfPeople: numberOfPeople,
            climate: selectedClimate
        )
        
        // Packliste generieren
        let packingItems = PackingListGenerator.generatePackingList(for: newTrip)
        
        // Reise in SwiftData speichern
        modelContext.insert(newTrip)
        
        // Packliste hinzufügen
        for item in packingItems {
            modelContext.insert(item)
            newTrip.packingItems.append(item)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
