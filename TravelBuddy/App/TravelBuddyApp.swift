import SwiftData
import SwiftUI

@main
struct TravelBuddyApp: App {
	// MARK: - State

	@AppStorage(AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
	private var hasCompletedOnboarding = false

	// SwiftData Container
	private var sharedModelContainer: ModelContainer

	// Repository wird im Environment bereitgestellt
	@State private var tripRepository: TripRepository

	init() {
		let schema = Schema([Trip.self, PackItem.self])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false, // Set to true for testing if needed
			cloudKitDatabase: AppConstants.enableCloudSync ? .automatic : .none
		)

		do {
			let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
			sharedModelContainer = container

			tripRepository = TripRepository(modelContext: container.mainContext)

		} catch {
			// Im Produktionscode geeignetes Error Handling implementieren
			fatalError("Could not create ModelContainer: \(error)")
		}
	}

	// MARK: - App Scene

	var body: some Scene {
		WindowGroup {
			Group {
				if hasCompletedOnboarding {
					// Hauptansicht direkt rendern
					TripsListView()
				} else {
					// Onboarding-Ansicht
					OnboardingView {
						withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
							hasCompletedOnboarding = true
						}
					}
					.transition(.opacity)
				}
			}
			.onAppear(perform: setupApp)
			// SwiftData Container und Repository im Environment bereitstellen
			.modelContainer(sharedModelContainer)
			.environment(tripRepository) // Repository im Environment verfügbar machen
			.environmentObject(UserSettingsManager.shared) // Beispiel: Globale Settings
			.environmentObject(ThemeManager.shared) // Beispiel: Theme Manager
		}
	}

	// MARK: - Setup

	private func setupApp() {
		// Reset für Entwicklung, falls nötig
		if AppConstants.resetPreferencesOnLaunch {
			resetAppState()
		}

		// Beispiel-Daten erstellen, falls nötig
		if AppConstants.includeSampleData && !UserDefaults.standard.bool(forKey: "hasInsertedSampleData") {
			// Stelle sicher, dass das Repository initialisiert ist
			// createSampleData() // Muss das Repository verwenden
			UserDefaults.standard.set(true, forKey: "hasInsertedSampleData")
		}

		if AppConstants.enableDebugLogging {
			print("App launched. Onboarding status: \(hasCompletedOnboarding)")
		}
		// AnalyticsService.shared.trackAppLaunch() // Optional
	}

	private func resetAppState() {
		UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
		hasCompletedOnboarding = false
		// Ggf. weitere Resets (z.B. UserSettingsManager.shared.resetAllSettings())
		if AppConstants.enableDebugLogging {
			print("App state has been reset")
		}
	}

	// Beispiel-Daten Erstellung (angepasst, um Repository zu verwenden)
	// Diese Funktion könnte auch ins Repository verschoben werden
	private func createSampleData() {
		let beach = tripRepository.createTrip(
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

		let business = tripRepository.createTrip(
			name: "Business Conference",
			destination: "New York",
			startDate: Date().addingTimeInterval(86400 * 3),
			endDate: Date().addingTimeInterval(86400 * 5),
			transportTypes: [.plane],
			accommodationType: .hotel,
			activities: [.business],
			isBusinessTrip: true,
			numberOfPeople: 1,
			climate: .moderate
		)

		let completed = tripRepository.createTrip(
			name: "Weekend Getaway",
			destination: "Mountain Cabin",
			startDate: Date().addingTimeInterval(-86400 * 10),
			endDate: Date().addingTimeInterval(-86400 * 8),
			transportTypes: [.car],
			accommodationType: .apartment,
			activities: [.hiking, .relaxing],
			isBusinessTrip: false,
			numberOfPeople: 4,
			climate: .cool
		)
		tripRepository.completeTrip(completed) // Markiere Trip als abgeschlossen

		if AppConstants.enableDebugLogging {
			print("Sample data created")
		}
	}
}
