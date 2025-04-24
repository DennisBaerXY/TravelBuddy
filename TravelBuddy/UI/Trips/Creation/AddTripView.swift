import SwiftData
import SwiftUI

/// View for creating a new trip with a multi-step form process
struct AddTripView: View {
	// MARK: - Environment & State
	
	@Environment(\.dismiss) private var dismiss
	@StateObject private var viewModel: AddTripViewModel
	@FocusState private var isFocused: Bool
	
	// MARK: - Initialization
	
	init(repository: TripRepository) {
		// Initialize the view model with the repository
		_viewModel = StateObject(wrappedValue: AddTripViewModel(repository: repository))
	}
	
	// MARK: - Body
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Progress indicator
				StepProgressIndicator(
					currentStep: viewModel.currentStep,
					totalSteps: viewModel.totalSteps
				)
				.padding(.horizontal)
				.padding(.top, 10)
				
				// Content area with step views
				TabView(selection: $viewModel.currentStep) {
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
			.navigationTitle(viewModel.navigationTitle)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(String(localized: "cancel")) { dismiss() }
				}
			}
			.onChange(of: isFocused) { _, newValue in
				viewModel.isKeyboardVisible = newValue
			}
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}
	
	// MARK: - Step Views
	
	/// Step 1: Basic trip information
	private var basicInfoView: some View {
		Form {
			Section {
				TextField(String(localized: "trip_name_placeholder"), text: $viewModel.tripName)
					.focused($isFocused)
				
				TextField(String(localized: "destination_placeholder"), text: $viewModel.destination)
					.focused($isFocused)
			} header: {
				Text("trip_details_prompt")
			}
			
			Section(header: Text("travel_dates")) {
				DatePicker("from_date", selection: $viewModel.startDate, displayedComponents: .date)
				DatePicker("to_date", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
			}
		}
		.scrollDismissesKeyboard(.interactively)
	}
	
	/// Step 2: Transport and accommodation
	private var transportAccommodationView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("transport_and_accommodation_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)
				
				// Transport options
				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(TransportType.allCases, id: \.self) { type in
							SelectableButton(
								systemImage: type.iconName,
								text: type.localizedName,
								isSelected: viewModel.selectedTransport.contains(type)
							) {
								if viewModel.selectedTransport.contains(type) {
									viewModel.selectedTransport.removeAll { $0 == type }
								} else {
									viewModel.selectedTransport.append(type)
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
						ForEach(AccommodationType.allCases, id: \.self) { type in
							SelectableButton(
								systemImage: type.iconName,
								text: type.localizedName,
								isSelected: viewModel.selectedAccommodation == type
							) {
								viewModel.selectedAccommodation = type
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
	
	/// Step 3: Activities and details
	private var activitiesAndDetailsView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("activities_and_details_prompt")
					.font(.title2.weight(.semibold)).padding(.bottom, 5)
				
				// Activities selection
				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
						ForEach(Activity.allCases, id: \.self) { activity in
							SelectableButton(
								systemImage: activity.iconName,
								text: activity.localizedName,
								isSelected: viewModel.selectedActivities.contains(activity)
							) {
								if viewModel.selectedActivities.contains(activity) {
									viewModel.selectedActivities.removeAll { $0 == activity }
								} else {
									viewModel.selectedActivities.append(activity)
								}
							}
						}
					}
				} header: {
					Text("what_do_you_plan").font(.headline).padding(.leading, -15)
				}
				
				// Additional details
				Section(header: Text("other_details").font(.headline).padding(.leading, -15)) {
					Toggle("business_trip", isOn: $viewModel.isBusinessTrip)
						.tint(.tripBuddyPrimary)
					
					// Number of people
					HStack {
						Text("number_of_people")
						Spacer()
						HStack {
							Button {
								if viewModel.numberOfPeople > 1 {
									viewModel.numberOfPeople -= 1
								}
							} label: {
								Image(systemName: "minus.circle.fill")
							}
							
							Text("\(viewModel.numberOfPeople)")
								.font(.headline)
								.frame(minWidth: 30)
							
							Button {
								if viewModel.numberOfPeople < 10 {
									viewModel.numberOfPeople += 1
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
					Picker("climate", selection: $viewModel.selectedClimate) {
						ForEach(Climate.allCases, id: \.self) { climate in
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
							viewModel.showingClimateInfo = true
						} label: {
							Image(systemName: "info.circle")
								.foregroundColor(.tripBuddyAccent)
						}
						.popover(isPresented: $viewModel.showingClimateInfo, arrowEdge: .top) {
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
	
	/// Step 4: Review and confirm
	private var reviewView: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("review_prompt")
					.font(.title2.weight(.semibold))
				
				ReviewSection(title: "trip_details") {
					ReviewRow(label: "trip_name", value: viewModel.tripName)
					ReviewRow(label: "destination", value: viewModel.destination)
					ReviewRow(label: "travel_dates", value: dateRangeText)
				}
				
				ReviewSection(title: "transport_and_accommodation") {
					ReviewRow(label: "transport", value: transportText)
					ReviewRow(label: "accommodation", value: viewModel.selectedAccommodation.localizedName)
				}
				
				ReviewSection(title: "activities_and_details") {
					ReviewRow(label: "activities", value: activitiesText)
					ReviewRow(label: "climate", value: viewModel.selectedClimate.localizedName)
					ReviewRow(label: "business_trip", value: viewModel.isBusinessTrip ? String(localized: "yes") : String(localized: "no"))
					ReviewRow(label: "number_of_people", value: "\(viewModel.numberOfPeople)")
				}
			}
			.padding()
		}
	}
	
	/// Navigation controls at the bottom of the screen
	private var navigationControlView: some View {
		VStack(spacing: 5) {
			// Validation message
			if let message = viewModel.validationMessage {
				Text(message)
					.font(.caption)
					.foregroundColor(.tripBuddyAlert)
					.padding(.horizontal)
					.transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
			}
			
			HStack {
				// Back button
				if viewModel.shouldShowBackButton {
					Button {
						viewModel.goToPreviousStep()
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
				if viewModel.isLastStep {
					Button {
						if viewModel.createTrip() {
							dismiss()
						}
					} label: {
						Label("create_list", systemImage: "checkmark.circle.fill")
					}
					.primaryButtonStyle()
				} else {
					Button {
						viewModel.goToNextStep()
					} label: {
						Label("next", systemImage: "chevron.right")
					}
					.primaryButtonStyle()
				}
			}
			.padding()
		}
		.background(.thinMaterial)
		.animation(.default, value: viewModel.validationMessage)
	}
	
	// MARK: - Helper Computed Properties
	
	/// Formatted date range text
	private var dateRangeText: String {
		let startText = viewModel.startDate.formatted(date: .abbreviated, time: .omitted)
		let endText = viewModel.endDate.formatted(date: .abbreviated, time: .omitted)
		return "\(startText) - \(endText)"
	}
	
	/// Formatted transport text
	private var transportText: String {
		if viewModel.selectedTransport.isEmpty {
			return String(localized: "none")
		} else {
			return viewModel.selectedTransport.map { $0.localizedName }.joined(separator: ", ")
		}
	}
	
	/// Formatted activities text
	private var activitiesText: String {
		if viewModel.selectedActivities.isEmpty {
			return String(localized: "none")
		} else {
			return viewModel.selectedActivities.map { $0.localizedName }.joined(separator: ", ")
		}
	}
}

// MARK: - Helper Structs

/// Displays a progress bar with steps
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

/// Displays a section title for the review screen
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

/// Displays a label-value row for the review screen
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
	let container = try! ModelContainer(for: Trip.self, PackItem.self, configurations: config)
	let repository = TripRepository(modelContext: container.mainContext)
	
	return AddTripView(repository: repository)
		.modelContainer(container)
}
