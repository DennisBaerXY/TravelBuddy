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
	
	// UI state
	@State private var currentStep = 0
	@State private var validationMessage: String? = nil
	@State private var showingClimateInfo = false
	@State private var isKeyboardVisible = false
	
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
		Form {
			Section {
				TextField(String(localized: "trip_name_placeholder"), text: $tripName)
					.focused($isFocused)
				
				TextField(String(localized: "destination_placeholder"), text: $destination)
					.focused($isFocused)
			} header: {
				Text("trip_details_prompt")
			}
			
			Section(header: Text("travel_dates")) {
				DatePicker("from_date", selection: $startDate, displayedComponents: .date)
				DatePicker("to_date", selection: $endDate, in: startDate..., displayedComponents: .date)
			}
		}
		.scrollDismissesKeyboard(.interactively)
	}
	
	private var transportAccommodationView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("transport_and_accommodation_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)
				
				// Transport options
				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(TransportType.allCases) { type in
							SelectableButton(
								systemImage: type.iconName,
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
					Text("how_do_you_travel").font(.headline).padding(.leading, -15)
				}
				
				// Accommodation options
				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(AccommodationType.allCases) { type in
							SelectableButton(
								systemImage: type.iconName,
								text: type.localizedName,
								isSelected: selectedAccommodation == type
							) {
								selectedAccommodation = type
							}
						}
					}
				} header: {
					Text("where_do_you_stay").font(.headline).padding(.leading, -15)
				}
			}
			.padding()
		}
		.padding(.horizontal)
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
			VStack(alignment: .leading, spacing: 20) {
				Text("review_prompt")
					.font(.title2.weight(.semibold))
				
				ReviewSection(title: "trip_details") {
					ReviewRow(label: "trip_name", value: tripName)
					ReviewRow(label: "destination", value: destination)
					ReviewRow(label: "travel_dates", value: dateRangeText)
				}
				
				ReviewSection(title: "transport_and_accommodation") {
					ReviewRow(label: "transport", value: transportText)
					ReviewRow(label: "accommodation", value: selectedAccommodation.localizedName)
				}
				
				ReviewSection(title: "activities_and_details") {
					ReviewRow(label: "activities", value: activitiesText)
					ReviewRow(label: "climate", value: selectedClimate.localizedName)
					ReviewRow(label: "business_trip", value: isBusinessTrip ? String(localized: "yes") : String(localized: "no"))
					ReviewRow(label: "number_of_people", value: "\(numberOfPeople)")
				}
			}
			.padding()
		}
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
		.background(.thinMaterial)
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
	
	// MARK: - Trip Creation
	
	private func createTrip() -> Bool {
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
				.frame(width: 120, alignment: .leading)
			
			Text(value.isEmpty ? "-" : value)
				.font(.subheadline.weight(.medium))
				.foregroundColor(.tripBuddyText)
			
			Spacer()
		}
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
