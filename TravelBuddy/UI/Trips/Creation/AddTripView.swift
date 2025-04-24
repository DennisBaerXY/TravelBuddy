import SwiftData
import SwiftUI

struct AddTripView: View {
	// MARK: - Environment

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@FocusState private var isFocused: Bool
	
	// MARK: - State

	// Trip data
	@State private var tripName = ""
	@State private var destination = ""
	@State private var startDate = Date()
	@State private var endDate = Date().addingTimeInterval(86400 * 7) // One week default
	@State private var selectedTransport: [TransportType] = []
	@State private var selectedAccommodation: AccommodationType = .hotel
	@State private var selectedActivities: [Activity] = []
	@State private var isBusinessTrip = false
	@State private var numberOfPeople = 1
	@State private var selectedClimate: Climate = .moderate
	
	@State private var destinationPlaceId: String? = nil
	
	// UI state
	@State private var currentStep = 0
	@State private var validationMessage: String? = nil
	@State private var showingClimateInfo = false
	@State private var isKeyboardVisible = false
	
	@StateObject private var autocompleteViewModel = PlacesAutocompleteViewModel() // ViewModel hinzufügen
	@FocusState private var isDestinationFocused: Bool // FocusState für das neue Feld

	// MARK: - Constants

	private let totalSteps = 4
	
	// MARK: - Computed Properties
	
	private var navigationTitle: LocalizedStringKey {
		switch currentStep {
		case 0: return "new_trip_step1_title" // Trip details
		case 1: return "new_trip_step2_title" // Transport & Accommodation
		case 2: return "new_trip_step3_title" // Activities & Details
		case 3: return "new_trip_step4_title" // Review
		default: return "new_trip"
		}
	}
	
	private var shouldShowBackButton: Bool {
		currentStep > 0
	}
	
	private var isLastStep: Bool {
		currentStep == totalSteps - 1
	}
	
	private var dateRangeText: String {
		let startText = startDate.formatted(date: .abbreviated, time: .omitted)
		let endText = endDate.formatted(date: .abbreviated, time: .omitted)
		return "\(startText) - \(endText)"
	}
	
	private var transportText: String {
		if selectedTransport.isEmpty {
			return String(localized: "none")
		} else {
			return selectedTransport.map { $0.localizedName }.joined(separator: ", ")
		}
	}
	
	private var activitiesText: String {
		if selectedActivities.isEmpty {
			return String(localized: "none")
		} else {
			return selectedActivities.map { $0.localizedName }.joined(separator: ", ")
		}
	}
	
	// MARK: - Body
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Progress indicator
				StepProgressIndicator(
					currentStep: currentStep,
					totalSteps: totalSteps
				)
				.padding(.horizontal)
				.padding(.top, 10)
				
				// Content area with step views
				TabView(selection: $currentStep) {
					basicInfoView.tag(0)
					transportAccommodationView.tag(1)
					activitiesAndDetailsView.tag(2)
					reviewView.tag(3)
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
				.background(Color.tripBuddyBackground)
				
				// Navigation controls
				navigationControlView
			}
			.background(Color.tripBuddyBackground)
			.navigationTitle(navigationTitle)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("cancel") { dismiss() }
				}
			}
			.onChange(of: isFocused) { _, newValue in
				isKeyboardVisible = newValue
			}
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}
	
	// MARK: - Step Views
	
	private var basicInfoView: some View {
		VStack(alignment: .leading, spacing: 25) { // Use VStack like other steps
			// Heading text similar to other steps
			Text("trip_details_prompt") // Use the prompt text
				.font(.title2.weight(.semibold))
				.foregroundColor(.tripBuddyText) // Ensure text color matches theme
				.padding(.top)

			// Section for Trip Name and Destination
			VStack(alignment: .leading, spacing: 15) { // Group related fields
				Text("trip_details") // Section Title
					.font(.headline)
					.foregroundColor(.tripBuddyText) // Use theme color

				// Trip Name Input
				TextField(String(localized: "trip_name_placeholder"), text: $tripName)
					.focused($isFocused)
					.padding(10)
					.background(Color.tripBuddyCard) // Use card background for consistency
					.cornerRadius(10)
					.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tripBuddyTextSecondary.opacity(0.2), lineWidth: 1)) // Subtle border

				// Destination Autocomplete Input
				PlacesAutocompleteView(
					viewModel: autocompleteViewModel,
					destination: $destination,
					destinationPlaceID: $destinationPlaceId,
					isFocused: _isDestinationFocused
				)
				.padding(10)
				.background(Color.tripBuddyCard) // Use card background
				.cornerRadius(10)
				.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tripBuddyTextSecondary.opacity(0.2), lineWidth: 1)) // Subtle border
				.onChange(of: destination) { _, newValue in
					if newValue.isEmpty {
						autocompleteViewModel.searchText = ""
					}
				}
			}

			Divider().padding(.vertical, 5) // Visual separator

			// Section for Travel Dates
			VStack(alignment: .leading, spacing: 15) { // Group related fields
				Text("travel_dates") // Section Title
					.font(.headline)
					.foregroundColor(.tripBuddyText) // Use theme color

				// Use HStacks for better layout of DatePickers if needed, or keep Vstack
				DatePicker("from_date", selection: $startDate, displayedComponents: .date)
					.tint(.tripBuddyPrimary) // Apply accent color

				DatePicker("to_date", selection: $endDate, in: startDate..., displayedComponents: .date)
					.tint(.tripBuddyPrimary) // Apply accent color
			}
			Spacer()
		}
		.padding(.horizontal) // Add horizontal padding to the ScrollView
		.background(Color.tripBuddyBackground) // Set the background for the whole step view
		.scrollDismissesKeyboard(.interactively) // Keep keyboard dismissal behavior
	}
	
	private var transportAccommodationView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				// Heading text
				Text("transport_and_accommodation_prompt")
					.font(.title2.weight(.semibold))
					.padding(.bottom, 5)
				
				// Transport options section
				transportOptionsSection
				
				// Accommodation options section
				accommodationOptionsSection
			}
			.padding()
		}
		.padding(.horizontal)
	}

	// Break down into smaller components to avoid compiler issues
	private var transportOptionsSection: some View {
		Section {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
				ForEach(TransportType.allCases) { type in
					SelectableButton(
						systemImage: type.iconName,
						// Convert LocalizedStringKey to String
						text: type.localizedName,
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
		} header: {
			Text("how_do_you_travel")
				.font(.headline)
				.padding(.leading, -15)
		}
	}

	private var accommodationOptionsSection: some View {
		Section {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
				ForEach(AccommodationType.allCases) { type in
					SelectableButton(
						systemImage: type.iconName,
						// Convert LocalizedStringKey to String
						text: type.localizedName,
						isSelected: selectedAccommodation == type
					) {
						selectedAccommodation = type
					}
				}
			}
		} header: {
			Text("where_do_you_stay")
				.font(.headline)
				.padding(.leading, -15)
		}
	}
	
	private var activitiesAndDetailsView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("activities_and_details_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)
				
				// Activities selection
				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(Activity.allCases) { activity in
							SelectableButton(
								systemImage: activity.iconName,
								text: activity.localizedName,
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
				} header: {
					Text("what_do_you_plan").font(.headline).padding(.leading, -15)
				}
				
				// Additional details
				Section(header: Text("other_details").font(.headline).padding(.leading, -15)) {
					Toggle("business_trip", isOn: $isBusinessTrip)
						.tint(.tripBuddyPrimary)
					
					// Number of people
					HStack {
						Text("number_of_people")
						Spacer()
						HStack {
							Button {
								if numberOfPeople > 1 {
									numberOfPeople -= 1
								}
							} label: {
								Image(systemName: "minus.circle.fill")
							}
							
							Text("\(numberOfPeople)")
								.font(.headline)
								.frame(minWidth: 30)
							
							Button {
								if numberOfPeople < 10 {
									numberOfPeople += 1
								}
							} label: {
								Image(systemName: "plus.circle.fill")
							}
						}
						.font(.title2)
						.foregroundColor(.tripBuddyPrimary)
						.buttonStyle(.plain)
					}
				}
				
				// Climate selection
				Section {
					Picker("climate", selection: $selectedClimate) {
						ForEach(Climate.allCases) { climate in
							Label(climate.localizedName, systemImage: climate.iconName)
								.tag(climate)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
				} header: {
					HStack {
						Text("climate").font(.headline)
						Spacer()
						Button {
							showingClimateInfo = true
						} label: {
							Image(systemName: "info.circle")
								.foregroundColor(.tripBuddyAccent)
						}
						.popover(isPresented: $showingClimateInfo, arrowEdge: .top) {
							Text("climate_info_popover_text")
								.font(.caption)
								.padding()
								.frame(idealWidth: 250)
						}
					}
					.padding(.leading, -15)
				}
			}
			.padding()
		}
		.padding(.horizontal)
	}
	
	private var reviewView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) { // Main VStack with spacing
				// Heading text
				Text("review_prompt")
					.font(.title2.weight(.semibold))
					.foregroundColor(.tripBuddyText)
					.padding(.bottom, 5)

				// Use the new ReviewSectionCard for each section
				ReviewSectionCard(title: "trip_details") { // Trip Details Section
					ReviewRowItem(label: "trip_name", value: tripName, iconName: "text.quote")
					ReviewRowItem(label: "destination", value: destination, iconName: "map")
					ReviewRowItem(label: "travel_dates", value: dateRangeText, iconName: "calendar")
				}

				ReviewSectionCard(title: "transport_and_accommodation") { // Transport & Accommodation Section
					ReviewRowItem(label: "transport", value: transportText, iconName: "airplane") // Use a representative icon
					ReviewRowItem(
						label: "accommodation",
						value: selectedAccommodation.localizedName,
						iconName: selectedAccommodation.iconName // Use accommodation icon
					)
				}

				ReviewSectionCard(title: "activities_and_details") { // Activities & Details Section
					ReviewRowItem(label: "activities", value: activitiesText, iconName: "figure.walk") // Use a representative icon
					ReviewRowItem(label: "climate", value: selectedClimate.localizedName, iconName: selectedClimate.iconName)
					ReviewRowItem(label: "business_trip", value: isBusinessTrip ? String(localized: "yes") : String(localized: "no"), iconName: "briefcase")
					ReviewRowItem(label: "number_of_people", value: "\(numberOfPeople)", iconName: "person.2")
				}
			}
			.padding() // Padding for the main VStack content
		}
		.padding(.horizontal) // Horizontal padding for the ScrollView
		.background(Color.tripBuddyBackground) // Background for the whole step
	}

	private var navigationControlView: some View {
		VStack(spacing: 5) {
			// Validation message
			if let message = validationMessage {
				Text(message)
					.font(.caption)
					.foregroundColor(.tripBuddyAlert)
					.padding(.horizontal)
					.transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
			}
			
			HStack {
				// Back button
				if shouldShowBackButton {
					Button {
						goToPreviousStep()
					} label: {
						Label("back", systemImage: "chevron.left")
					}
					.secondaryButtonStyle()
				} else {
					// Empty space to maintain layout
					Spacer().frame(width: 80)
				}
				
				Spacer()
				
				// Next/Create button
				if isLastStep {
					Button {
						if createTrip() {
							dismiss()
						}
					} label: {
						Label("create_list", systemImage: "checkmark.circle.fill")
					}
					.primaryButtonStyle()
				} else {
					Button {
						goToNextStep()
					} label: {
						Label("next", systemImage: "chevron.right")
					}
					.primaryButtonStyle()
				}
			}
			.padding()
		}
		.background(.tripBuddyBackground)
		.animation(.default, value: validationMessage)
	}
	
	// MARK: - Navigation Methods
	
	private func goToNextStep() {
		if validateCurrentStep() {
			withAnimation {
				isKeyboardVisible = false
				currentStep += 1
				validationMessage = nil
			}
		}
	}
	
	private func goToPreviousStep() {
		withAnimation {
			currentStep -= 1
			validationMessage = nil
		}
	}
	
	// MARK: - Validation
	
	private func validateCurrentStep() -> Bool {
		var isValid = true
		var message: String? = nil
		
		switch currentStep {
		case 0: // Trip details
			if tripName.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_trip_name")
			} else if destination.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_destination")
			}
			
		case 1: // Transport & Accommodation
			if selectedTransport.isEmpty {
				isValid = false
				message = String(localized: "validation_missing_transport")
			}
			
		default: // No validation needed
			break
		}
		
		validationMessage = isValid ? nil : message
		return isValid
	}
	
	private func validateForm() -> Bool {
		var isValid = true
		var message: String? = nil
		
		if tripName.isEmpty {
			isValid = false
			message = String(localized: "validation_missing_trip_name")
		} else if destination.isEmpty || ((destinationPlaceId?.isEmpty) != nil) {
			isValid = false
			message = String(localized: "validation_missing_trip_destination")
		}
		
		validationMessage = isValid ? nil : message
		return isValid
	}
	
	// MARK: - Trip Creation
	
	private func createTrip() -> Bool {
		if validateForm() {
			return false
		}
		
		// Create the trip directly with our TripServices
		let trip = TripServices.createTripWithPackingList(
			in: modelContext,
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
		
		return trip.id != UUID()
	}
}

// MARK: - Helper Components

struct StepProgressIndicator: View {
	let currentStep: Int
	let totalSteps: Int
	
	var body: some View {
		HStack(spacing: 8) {
			ForEach(0 ..< totalSteps, id: \.self) { index in
				Capsule()
					.fill(index == currentStep ? Color.tripBuddyPrimary : Color.tripBuddyPrimary.opacity(0.2))
					.frame(height: 6)
			}
		}
		.animation(.easeInOut, value: currentStep)
	}
}

// Replaces the old ReviewSection with a card style
struct ReviewSectionCard<Content: View>: View {
	let title: LocalizedStringKey
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) { // Increased spacing inside card
			// Section Title
			Text(title)
				.font(.headline)
				.foregroundColor(.tripBuddyPrimary)
				.padding(.bottom, 5) // Space below title

			// Content Rows
			content
		}
		.padding(15) // Padding inside the card
		.background(Color.tripBuddyCard) // Card background color
		.cornerRadius(AppConstants.cornerRadius) // Use standard corner radius
		.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // Subtle shadow
	}
}

// Replaces the old ReviewRow with a more detailed item style
struct ReviewRowItem: View {
	let label: String // Keep label as String for keys
	let value: String
	let iconName: String? // Optional icon for visual flair

	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			// Optional Icon
			if let iconName = iconName {
				Image(systemName: iconName)
					.foregroundColor(.tripBuddyPrimary)
					.frame(width: 20, alignment: .center) // Align icon
					.padding(.top, 2) // Align icon slightly better with text
			} else {
				// Add spacing placeholder if no icon to maintain alignment
				Spacer().frame(width: 20)
			}

			// Label and Value
			VStack(alignment: .leading, spacing: 2) {
				Text(LocalizedStringKey(label)) // Use LocalizedStringKey here
					.font(.subheadline)
					.foregroundColor(.tripBuddyTextSecondary)

				Text(value.isEmpty ? "-" : value)
					.font(.body) // Slightly larger font for value
					.foregroundColor(.tripBuddyText)
					.lineLimit(nil) // Allow multiple lines if needed
					.fixedSize(horizontal: false, vertical: true) // Prevent text truncation vertically
			}

			Spacer() // Push content to the left
		}
		.padding(.bottom, 5) // Small padding below each row item
	}
}

// MARK: - Preview

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	do {
		let container = try ModelContainer(for: Trip.self, PackItem.self, configurations: config)
			
		return AddTripView()
			.modelContainer(container)
			.environmentObject(UserSettingsManager.shared)
			.environmentObject(ThemeManager.shared)
	} catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
