import SwiftData
import SwiftUI

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
	@FocusState private var focusedField: Bool
	
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
			.navigationTitle(String(localized: "new_trip"))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(String(localized: "cancel")) {
						dismiss()
					}
				}
			}
		}
	}
	
	// Schritt 1: Grundlegende Informationen mit einfachen DatePicker
	var basicInfoView: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text("trip_details")
				.font(.largeTitle)
				.bold()
			
			VStack(alignment: .leading) {
				Text("trip_name")
					.font(.headline)
				TextField("trip_name_placeholder", text: $tripName)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.focused($focusedField)
			}
			
			VStack(alignment: .leading) {
				Text("destination")
					.font(.headline)
				TextField("destination_placeholder", text: $destination)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.focused($focusedField)
			}
			
			VStack(alignment: .leading) {
				Text("travel_dates")
					.font(.headline)
				
				// Einfacher DatePicker für das Startdatum
				DatePicker("from_date", selection: $startDate, displayedComponents: .date)
					.focused($focusedField)
				
				// Einfacher DatePicker für das Enddatum
				DatePicker("to_date", selection: $endDate, in: startDate..., displayedComponents: .date)
					.focused($focusedField)
			}
			
			Spacer()
		}
		.padding()
	}
	
	// Schritt 2: Transport & Unterkunft
	var transportAccommodationView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("transport_and_accommodation")
					.font(.largeTitle)
					.bold()
				
				VStack(alignment: .leading) {
					Text("how_do_you_travel")
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
					Text("where_do_you_stay")
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
				Text("activities_and_details")
					.font(.largeTitle)
					.bold()
				
				VStack(alignment: .leading) {
					Text("what_do_you_plan")
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
					Text("other_details")
						.font(.headline)
					
					Toggle("business_trip", isOn: $isBusinessTrip)
					
					HStack {
						Text("number_of_people")
						Spacer()
						Stepper("\(numberOfPeople)", value: $numberOfPeople, in: 1 ... 10)
					}
				}
				
				VStack(alignment: .leading) {
					Text("climate")
						.font(.headline)
					
					Picker("climate", selection: $selectedClimate) {
						ForEach(Climate.allCases, id: \.self) { climate in
							Label(climate.localizedName, systemImage: climate.iconName)
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
						Text("back")
					}
				}
				.buttonStyle(.bordered)
			}
			
			Spacer()
			
			if currentStep < 2 {
				Button(action: {
					withAnimation {
						focusedField = false
						currentStep += 1
					}
				}) {
					HStack {
						Text("next")
						Image(systemName: "chevron.right")
					}
				}
				.buttonStyle(.borderedProminent)
				.disabled(tripName.isEmpty || destination.isEmpty)
			} else {
				Button(action: createTrip) {
					Text("create_list")
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
