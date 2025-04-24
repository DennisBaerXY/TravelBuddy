import SwiftData
import SwiftUI

struct TripsListView: View {
	// MARK: - Environment & State

	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject private var userSettings: UserSettingsManager
	
	// SwiftData Query for trips
	@Query(sort: [
		SortDescriptor(\Trip.isCompleted, order: .forward),
		SortDescriptor(\Trip.startDate, order: .forward)
	]) private var trips: [Trip]
	
	@State private var showingAddTrip = false
	@State private var showingSettings = false
	
	// MARK: - Computed Properties

	private var activeTrips: [Trip] {
		trips.filter { !$0.isCompleted }
	}
	
	private var completedTrips: [Trip] {
		trips.filter { $0.isCompleted && userSettings.showCompletedTrips }
	}
	
	// MARK: - Body

	var body: some View {
		NavigationStack {
			ZStack {
				Group {
					if trips.isEmpty {
						emptyStateView
					} else {
						tripsListView
					}
				}.padding(.horizontal)
				
				floatingAddButton
			}
			
			.navigationTitle("my.trips")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						showingSettings = true
					} label: {
						Label("Settings", systemImage: "gear")
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						showingSettings = true
					} label: {
						Label("Premium", systemImage: "star.fill")
							.foregroundColor(userSettings.isPremiumUser ? .yellow : .gray)
					}
				}
			}
			.sheet(isPresented: $showingAddTrip) {
				AddTripView()
			}
			.sheet(isPresented: $showingSettings) {
				SettingsView()
			}
		}
	}
	
	// MARK: - UI Components
	
	private var backgroundGradient: some View {
		LinearGradient(
			gradient: Gradient(colors: [
				Color.tripBuddyBackground.opacity(0.5),
				Color.tripBuddyBackground
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
	}
	
	private var emptyStateView: some View {
		VStack(spacing: 25) {
			Image("AppIconLogo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 120, height: 120)
				.clipShape(RoundedRectangle(cornerRadius: 24))
				.shadow(color: .black.opacity(0.1), radius: 10, y: 5)
			
			VStack(spacing: 10) {
				Text("no.trips.planned.title")
					.font(.title2)
					.fontWeight(.bold)
					.foregroundColor(.tripBuddyText)
				
				Text("add.trip.tip")
					.multilineTextAlignment(.center)
					.foregroundColor(.tripBuddyTextSecondary)
					.padding(.horizontal)
			}
			
			Button {
				showingAddTrip = true
			} label: {
				Label("create.first.trip", systemImage: "plus.circle.fill")
			}
			.primaryButtonStyle(isWide: true)
			.padding(.horizontal, 40)
			.padding(.top)
		}
		.padding()
	}
	
	private var tripsListView: some View {
		List {
			// Active trips
			if !activeTrips.isEmpty {
				Section(header: sectionHeader("active_trips", systemImage: "airplane")) {
					ForEach(activeTrips) { trip in
						NavigationLink(destination: TripDetailView(trip: trip)) {
							TripCard(trip: trip)
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: false) {
							Button(role: .destructive) {
								deleteTrip(trip)
							} label: {
								Label("delete", systemImage: "trash")
							}
							
							Button {
								completeTrip(trip)
							} label: {
								Label("complete_trip_button", systemImage: "checkmark.circle.fill")
							}
							.tint(.tripBuddySuccess)
						}
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
						.listRowBackground(Color.clear)
					}
				}
			}
			
			// Completed trips
			if !completedTrips.isEmpty {
				Section(header: sectionHeader("completed_trips", systemImage: "checkmark.circle")) {
					ForEach(completedTrips) { trip in
						NavigationLink(destination: TripDetailView(trip: trip)) {
							TripCard(trip: trip)
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: false) {
							Button(role: .destructive) {
								deleteTrip(trip)
							} label: {
								Label("delete", systemImage: "trash")
							}
						}
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
						.listRowBackground(Color.clear)
					}
				}
			}
		}
		.listStyle(.plain)
	}
	
	private func sectionHeader(_ titleKey: LocalizedStringKey, systemImage: String) -> some View {
		Label(titleKey, systemImage: systemImage)
			.font(.headline)
			.foregroundColor(.tripBuddyPrimary)
			.padding(.vertical, 5)
	}
	
	private var floatingAddButton: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Button(action: { showingAddTrip = true }) {
					Image(systemName: "plus")
						.font(.title.weight(.semibold))
						.frame(width: 30, height: 30)
						.padding(18)
						.background(Color.tripBuddyPrimary)
						.foregroundColor(.white)
						.clipShape(Circle())
						.shadow(color: .tripBuddyPrimary.opacity(0.5), radius: 8, y: 4)
				}
				.padding(20)
			}
		}
	}
	
	// MARK: - Actions
	
	private func deleteTrip(_ trip: Trip) {
		modelContext.delete(trip)
		try? modelContext.save()
	}
	
	private func completeTrip(_ trip: Trip) {
		TripServices.completeTrip(trip, in: modelContext)
	}
}

// MARK: - Preview

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	do {
		let container = try ModelContainer(for: Trip.self, PackItem.self, configurations: config)
		
		// Add sample data
		let context = container.mainContext
		
		// Create beach vacation
		_ = TripServices.createTripWithPackingList(
			in: context,
			name: "Beach Vacation",
			destination: "Hawaii",
			startDate: Date().addingTimeInterval(86400 * 14),
			endDate: Date().addingTimeInterval(86400 * 21),
			transportTypes: [.plane, .car],
			accommodationType: .hotel,
			activities: [.beach, .swimming, .relaxing],
			isBusinessTrip: false,
			numberOfPeople: 2,
			climate: .hot
		)
		
		return TripsListView()
			.modelContainer(container)
			.environmentObject(UserSettingsManager.shared)
			.environmentObject(ThemeManager.shared)
	} catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
