import SwiftData
import SwiftUI

@main
struct TravelBuddyApp: App {
	// MARK: - State

	@AppStorage(AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
	private var hasCompletedOnboarding = false

	// SwiftData Container
	private var sharedModelContainer: ModelContainer

	init() {
		let schema = Schema([Trip.self, PackItem.self])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false,
			cloudKitDatabase: AppConstants.enableCloudSync ? .automatic : .none
		)

		do {
			sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			// Handle error appropriately in production
			fatalError("Could not create ModelContainer: \(error)")
		}
		
		// Reset for development if needed
		if AppConstants.resetPreferencesOnLaunch {
			resetAppState()
		}
		
		// Add sample data if needed
		if AppConstants.includeSampleData && !UserDefaults.standard.bool(forKey: "hasInsertedSampleData") {
			createSampleData()
			UserDefaults.standard.set(true, forKey: "hasInsertedSampleData")
		}
	}

	// MARK: - App Scene

	var body: some Scene {
		WindowGroup {
			Group {
				if hasCompletedOnboarding {
					// Main app view
					TripsListView()
				} else {
					// Onboarding view
					OnboardingView {
						withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
							hasCompletedOnboarding = true
						}
					}
					.transition(.opacity)
				}
			}
			// SwiftData Container in environment
			.modelContainer(sharedModelContainer)
			.environmentObject(UserSettingsManager.shared)
			.environmentObject(ThemeManager.shared)
		}
	}
	
	// MARK: - Development utilities
	
	private func resetAppState() {
		UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
		hasCompletedOnboarding = false
		
		if AppConstants.enableDebugLogging {
			print("App state has been reset")
		}
	}
	
	private func createSampleData() {
		let context = sharedModelContainer.mainContext
		
		// Create beach vacation
		let beach = TripServices.createTripWithPackingList(
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
		
		// Create business trip
		let business = TripServices.createTripWithPackingList(
			in: context,
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
		
		// Create completed trip
		let completed = TripServices.createTripWithPackingList(
			in: context,
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
		TripServices.completeTrip(completed, in: context)
		
		if AppConstants.enableDebugLogging {
			print("Sample data created")
		}
	}
}
