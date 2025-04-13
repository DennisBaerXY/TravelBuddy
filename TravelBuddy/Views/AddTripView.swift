import SwiftData
import SwiftUI

struct AddTripView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss

	// Trip Properties (wie zuvor)
	@State private var tripName = ""
	@State private var destination = ""
	@State private var startDate = Date()
	@State private var endDate = Date().addingTimeInterval(86400 * 7)
	@State private var selectedTransport: [TransportType] = []
	@State private var selectedAccommodation: AccommodationType = .hotel
	@State private var selectedActivities: [Activity] = []
	@State private var isBusinessTrip = false
	@State private var numberOfPeople = 1
	@State private var selectedClimate: Climate = .moderate

	// State für den Prozess
	@State private var currentStep = 0
	let totalSteps = 4 // *** NEU: 4 Schritte inkl. Zusammenfassung ***
	@FocusState private var focusedField: Bool

	// *** NEU: State für Validierungsnachrichten ***
	@State private var validationMessage: String? = nil

	// *** NEU: State für Info-Popover ***
	@State private var showingClimateInfo = false

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Visueller Schritt-Indikator (wie zuvor)
				HStack(spacing: 8) {
					ForEach(0 ..< totalSteps, id: \.self) { index in
						Capsule()
							.fill(index == currentStep ? Color.tripBuddyPrimary : Color.tripBuddyPrimary.opacity(0.2))
							.frame(height: 6)
					}
				}
				.padding(.horizontal)
				.padding(.top, 10)
				.animation(.easeInOut, value: currentStep)

				TabView(selection: $currentStep) {
					basicInfoView.tag(0)
					transportAccommodationView.tag(1)
					activitiesAndDetailsView.tag(2)
					reviewView.tag(3) // *** NEU: Review-Schritt ***
				}

				// *** NEU: Slide-Übergang und Index-Ausblendung ***
				.tabViewStyle(.page(indexDisplayMode: .never))

				.background(Color.tripBuddyBackground)

				// Navigation Buttons & Validierungsmeldung
				navigationControlView
			}
			.background(Color.tripBuddyBackground)
			.navigationTitle(navigationTitleForStep())
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) { // Abbruch nach links für Standard-Pattern
					Button(String(localized: "cancel")) { dismiss() }
				}
			}
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}

	// MARK: - Views für die Schritte

	// Schritt 1: Grundlegende Informationen (mit Section)
	var basicInfoView: some View {
		Form { // Form für bessere Strukturierung und Tastatur-Handling
			Section {
				TextField(String(localized: "trip_name_placeholder"), text: $tripName)
					.focused($focusedField)
				TextField(String(localized: "destination_placeholder"), text: $destination)
					.focused($focusedField)
			} header: {
				Text("trip_details_prompt") // Titel in Section Header
			}

			Section(header: Text("travel_dates")) {
				DatePicker("from_date", selection: $startDate, displayedComponents: .date)
				DatePicker("to_date", selection: $endDate, in: startDate..., displayedComponents: .date)
			}
		}
		.scrollDismissesKeyboard(.interactively) // Tastatur beim Scrollen ausblenden
	}

	// Schritt 2: Transport & Unterkunft (mit Section)
	var transportAccommodationView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("transport_and_accommodation_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)

				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(TransportType.allCases, id: \.self) { type in
							SelectableButton(systemImage: type.iconName, text: type.localizedName, isSelected: selectedTransport.contains(type)) {
								if selectedTransport.contains(type) { selectedTransport.removeAll { $0 == type } } else { selectedTransport.append(type) }
							}
						}
					}
				} header: {
					Text("how_do_you_travel").font(.headline).padding(.leading, -15) // Header linksbündig
				}

				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(AccommodationType.allCases, id: \.self) { type in
							SelectableButton(systemImage: type.iconName, text: type.localizedName, isSelected: selectedAccommodation == type) {
								selectedAccommodation = type
							}
						}
					}
				} header: {
					Text("where_do_you_stay").font(.headline).padding(.leading, -15)
				}
			}
			.padding()
		}.padding(.horizontal)
	}

	// Schritt 3: Aktivitäten & weitere Details (mit Section und Info-Button)
	var activitiesAndDetailsView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("activities_and_details_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)

				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(Activity.allCases, id: \.self) { activity in
							SelectableButton(systemImage: activity.iconName, text: activity.localizedName, isSelected: selectedActivities.contains(activity)) {
								if selectedActivities.contains(activity) { selectedActivities.removeAll { $0 == activity } } else { selectedActivities.append(activity) }
							}
						}
					}
				} header: {
					Text("what_do_you_plan").font(.headline).padding(.leading, -15)
				}

				Section(header: Text("other_details").font(.headline).padding(.leading, -15)) {
					Toggle("business_trip", isOn: $isBusinessTrip).tint(.tripBuddyPrimary)
					HStack {
						Text("number_of_people")
						Spacer()
						HStack {
							Button { if numberOfPeople > 1 { numberOfPeople -= 1 } } label: { Image(systemName: "minus.circle.fill") }
							Text("\(numberOfPeople)").font(.headline).frame(minWidth: 30)
							Button { if numberOfPeople < 10 { numberOfPeople += 1 } } label: { Image(systemName: "plus.circle.fill") }
						}
						.font(.title2).foregroundColor(.tripBuddyPrimary).buttonStyle(.plain)
					}
				}

				Section {
					Picker("climate", selection: $selectedClimate) {
						ForEach(Climate.allCases, id: \.self) { climate in
							Label(climate.localizedName, systemImage: climate.iconName).tag(climate)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
				} header: {
					HStack { // Header mit Info-Button
						Text("climate").font(.headline)
						Spacer()
						Button {
							showingClimateInfo = true
						} label: {
							Image(systemName: "info.circle")
								.foregroundColor(.tripBuddyAccent) // Akzentfarbe für Info
						}
						// *** NEU: Popover für die Klima-Info ***
						.popover(isPresented: $showingClimateInfo, arrowEdge: .top) {
							Text("climate_info_popover_text") // Lokalisierter Erklärungstext
								.font(.caption)
								.padding()
								.frame(idealWidth: 250) // Begrenzung der Breite
						}
					}
					.padding(.leading, -15)
				}
			}
			.padding()
		}.padding(.horizontal)
	}

	// *** NEU: Schritt 4: Zusammenfassung ***
	var reviewView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("review_prompt") // Z.B. "Bitte überprüfe deine Angaben:"
					.font(.title2.weight(.semibold))

				ReviewSection(title: "trip_details") {
					ReviewRow(label: "trip_name", value: tripName)
					ReviewRow(label: "destination", value: destination)
					ReviewRow(label: "travel_dates", value: "\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(endDate.formatted(date: .abbreviated, time: .omitted))")
				}

				ReviewSection(title: "transport_and_accommodation") {
					ReviewRow(label: "transport", value: selectedTransport.map { $0.localizedName }.joined(separator: ", "))
					ReviewRow(label: "accommodation", value: selectedAccommodation.localizedName)
				}

				ReviewSection(title: "activities_and_details") {
					ReviewRow(label: "activities", value: selectedActivities.isEmpty ? String(localized: "none") : selectedActivities.map { $0.localizedName }.joined(separator: ", "))
					ReviewRow(label: "climate", value: selectedClimate.localizedName)
					ReviewRow(label: "business_trip", value: isBusinessTrip ? String(localized: "yes") : String(localized: "no"))
					ReviewRow(label: "number_of_people", value: "\(numberOfPeople)")
				}
			}
			.padding()
		}
	}

	// MARK: - Navigation & Hilfskomponenten

	// Zusammengefasste Navigationsleiste unten
	var navigationControlView: some View {
		VStack(spacing: 5) {
			// *** NEU: Validierungsnachricht anzeigen ***
			if let message = validationMessage {
				Text(message)
					.font(.caption)
					.foregroundColor(.tripBuddyAlert)
					.padding(.horizontal)
					.transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top))) // Sanfte Einblendung
			}

			HStack {
				// Zurück-Button
				Button {
					withAnimation { currentStep -= 1 }
					validationMessage = nil // Nachricht löschen
				} label: { Label("back", systemImage: "chevron.left") }
					.buttonStyle(TripBuddyOutlineButtonStyle())
					.opacity(currentStep > 0 ? 1 : 0) // Nur anzeigen, wenn nicht erster Schritt

				Spacer() // Flexibler Abstand

				// Nächster/Fertig-Button
				if currentStep < totalSteps - 1 {
					Button {
						if validateCurrentStep() {
							withAnimation {
								focusedField = false
								currentStep += 1
								validationMessage = nil // Nachricht löschen
							}
						}
					} label: { Label("next", systemImage: "chevron.right") }
						.buttonStyle(TripBuddyFilledButtonStyle())
				} else {
					// Letzter Schritt: "Liste erstellen"-Button
					Button(action: createTrip) {
						Label("create_list", systemImage: "checkmark.circle.fill")
					}
					.buttonStyle(TripBuddyFilledButtonStyle())
					// Keine Deaktivierung hier, da alle Daten bereits validiert sein sollten
				}
			}
			.padding()
		}
		.background(.thinMaterial)
		.animation(.default, value: validationMessage) // Animieren bei Nachrichtenänderung
	}

	// Dynamischer Navigationstitel
	func navigationTitleForStep() -> String {
		switch currentStep {
		case 0: return String(localized: "new_trip_step1_title")
		case 1: return String(localized: "new_trip_step2_title")
		case 2: return String(localized: "new_trip_step3_title")
		case 3: return String(localized: "new_trip_step4_title") // Z.B. "Überprüfen"
		default: return String(localized: "new_trip")
		}
	}

	// *** NEU: Validierungslogik ***
	func validateCurrentStep() -> Bool {
		var isValid = true
		var message: String? = nil

		switch currentStep {
		case 0:
			if tripName.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_trip_name")
			} else if destination.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_destination")
			}
		case 1:
			if selectedTransport.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_transport")
			}
		// Füge hier Validierungen für andere Schritte hinzu, falls nötig
		case 2:
			break // Keine zwingenden Felder in diesem Schritt aktuell
		default:
			break
		}

		// Setze die Validierungsnachricht nur, wenn ungültig
		validationMessage = isValid ? nil : message
		return isValid
	}

	// MARK: - Trip Erstellung

	func createTrip() {
		// Erstelle neue Reise (Logik wie zuvor)
		let newTrip = Trip(
			name: tripName, destination: destination, startDate: startDate, endDate: endDate,
			transportTypes: selectedTransport, accommodationType: selectedAccommodation,
			activities: selectedActivities, isBusinessTrip: isBusinessTrip,
			numberOfPeople: numberOfPeople, climate: selectedClimate
		)
		let packingItems = PackingListGenerator.generatePackingList(for: newTrip)
		modelContext.insert(newTrip)
		if newTrip.packingItems == nil { newTrip.packingItems = [] }
		for item in packingItems {
			modelContext.insert(item)
			newTrip.packingItems?.append(item)
		}
		newTrip.update()
		try? modelContext.save()
		dismiss()
	}
}

// MARK: - Hilfskomponenten für Review-Schritt

struct ReviewSection<Content: View>: View {
	let title: LocalizedStringKey
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.headline)
				.foregroundColor(.tripBuddyPrimary)
			Divider()
			content
		}
		.padding(.bottom)
	}
}

struct ReviewRow: View {
	let label: LocalizedStringKey
	let value: String

	var body: some View {
		HStack(alignment: .top) {
			Text(label)
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
				.frame(width: 120, alignment: .leading) // Feste Breite für Label
			Text(value.isEmpty ? "-" : value) // Zeige "-" bei leerem Wert
				.font(.subheadline.weight(.medium))
				.foregroundColor(.tripBuddyText)
			Spacer()
		}
	}
}
