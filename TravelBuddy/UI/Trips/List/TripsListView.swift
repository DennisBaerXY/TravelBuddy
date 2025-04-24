import SwiftData
import SwiftUI

struct TripsListView: View {
	// MARK: - Environment & State

	@Environment(\.modelContext) private var modelContext
	@Environment(TripRepository.self) private var repository // Zugriff auf Repository für Aktionen
	@EnvironmentObject private var userSettings: UserSettingsManager // Für Premium-Status

	// SwiftData Query für Trips, sortiert
	@Query(sort: [
		SortDescriptor(\Trip.isCompleted, order: .forward), // Nicht abgeschlossene zuerst
		SortDescriptor(\Trip.createdAt, order: .reverse) // Neueste zuerst
	]) private var trips: [Trip]

	@State private var showingAddTrip = false
	@State private var showingSettings = false // Für Settings-Sheet

	// MARK: - Computed Properties

	private var activeTrips: [Trip] {
		trips.filter { !$0.isCompleted }
	}

	private var completedTrips: [Trip] {
		trips.filter { $0.isCompleted }
	}

	private var isEmpty: Bool {
		trips.isEmpty
	}

	// MARK: - Body

	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient

				if isEmpty {
					emptyStateView
				} else {
					tripsListView
				}

				floatingActionButton
			}
			.navigationTitle("my.trips")
			.toolbar {
				leadingToolbarItem
				trailingToolbarItems // Zusammengefasst für Klarheit
			}
			.sheet(isPresented: $showingAddTrip) {
				// AddTripView benötigt das Repository zum Speichern
				AddTripView(repository: repository)
			}
			.sheet(isPresented: $showingSettings) {
				SettingsView() // Settings brauchen ggf. EnvironmentObjects
			}
			// .refreshable { } // SwiftData @Query aktualisiert automatisch, manuelles Refresh oft unnötig
		}
	}

	// MARK: - Subviews

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
			Image("AppIconLogo") // Stelle sicher, dass das Bild existiert
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
			// Aktive Reisen
			if !activeTrips.isEmpty {
				Section(header: sectionHeader("Active Trips", systemImage: "airplane")) {
					ForEach(activeTrips) { trip in
						navigationLink(for: trip)
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								deleteButton(for: trip)
								completeButton(for: trip)
							}
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
							.listRowBackground(Color.clear)
					}
				}
			}

			// Abgeschlossene Reisen
			if !completedTrips.isEmpty {
				Section(header: sectionHeader("Completed Trips", systemImage: "checkmark.circle")) {
					ForEach(completedTrips) { trip in
						navigationLink(for: trip)
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								deleteButton(for: trip)
							}
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
							.listRowBackground(Color.clear)
					}
				}
			}
		}
		.listStyle(.plain) // Oder .grouped, je nach Präferenz
		.padding(.bottom, 60) // Platz für FAB
	}

	private func navigationLink(for trip: Trip) -> some View {
		NavigationLink(destination: TripDetailView(trip: trip)) { // Übergibt nur den Trip
			TripCard(trip: trip) {} // onTap wird durch NavigationLink gehandhabt
		}
	}

	private func sectionHeader(_ titleKey: LocalizedStringKey, systemImage: String) -> some View {
		Label(titleKey, systemImage: systemImage)
			.font(.headline)
			.foregroundColor(.tripBuddyPrimary)
			.padding(.vertical, 5)
	}

	private var floatingActionButton: some View {
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

	// MARK: - Toolbar Items

	private var leadingToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				showingSettings = true
			} label: {
				Label("Settings", systemImage: "gear")
			}
		}
	}

	private var trailingToolbarItems: some ToolbarContent {
		ToolbarItemGroup(placement: .navigationBarTrailing) {
			// Premium Button (Beispiel, Logik im UserSettingsManager)
			Button {
				showingSettings = true // Oder dedizierte Premium-Info zeigen
			} label: {
				Label("Premium", systemImage: "star.fill")
					.foregroundColor(userSettings.isPremiumUser ? .yellow : .gray)
			}

			// Optional: EditButton für Bulk-Delete
			// EditButton()
		}
	}

	// MARK: - Swipe Actions

	private func deleteButton(for trip: Trip) -> some View {
		Button(role: .destructive) {
			deleteTrip(trip)
		} label: {
			Label("delete", systemImage: "trash")
		}
	}

	private func completeButton(for trip: Trip) -> some View {
		Button {
			completeTrip(trip)
		} label: {
			Label("complete_trip_button", systemImage: "checkmark.circle.fill")
		}
		.tint(.green) // Oder .tripBuddySuccess
	}

	// MARK: - Data Actions

	private func deleteTrip(_ trip: Trip) {
		// Verwende das Repository für die Löschlogik
		repository.deleteTrip(trip)
		// @Query aktualisiert die View automatisch
	}

	private func completeTrip(_ trip: Trip) {
		repository.completeTrip(trip)
		// @Query aktualisiert die View automatisch
	}
}

// MARK: - Preview

#Preview {
	// Preview benötigt einen konfigurierten Container und das Repository
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	do {
		let container = try ModelContainer(for: Trip.self, PackItem.self, configurations: config)
		let repository = TripRepository(modelContext: container.mainContext)
		// Beispiel-Daten hinzufügen
		_ = repository.createTrip(name: "Preview Trip", destination: "Test City", startDate: Date(), endDate: Date().addingDays(5), transportTypes: [.car], accommodationType: .hotel, activities: [.hiking], isBusinessTrip: false, numberOfPeople: 1, climate: .moderate)
		let completed = repository.createTrip(name: "Completed Preview", destination: "Past City", startDate: Date().addingDays(-10), endDate: Date().addingDays(-5), transportTypes: [.train], accommodationType: .airbnb, activities: [.relaxing], isBusinessTrip: false, numberOfPeople: 2, climate: .cool)
		repository.completeTrip(completed)

		return TripsListView()
			.modelContainer(container)
			.environment(repository)
			.environmentObject(UserSettingsManager.shared) // Mock oder echtes Objekt
			.environmentObject(ThemeManager.shared)
	} catch {
		fatalError("Failed to create container: \(error)")
	}
}
