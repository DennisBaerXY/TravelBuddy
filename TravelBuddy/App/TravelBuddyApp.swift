// TravelBuddy/App/TravelBuddyApp.swift
import SwiftData
import SwiftUI

import FirebaseAnalytics
import FirebaseCore
import GoogleMobileAds

import GooglePlacesSwift

// App Delegate
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication,
	                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{
		MobileAds.shared.start(completionHandler: nil)
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["21fade3f7a75ba7f7e112da1fae8f83b"]

		return true
	}
}

@main
struct TravelBuddyApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	// MARK: - State Objects & Environment

	// Use the UserSettingsManager singleton as the source of truth for settings
	@StateObject private var userSettings = UserSettingsManager.shared
	@StateObject private var themeManager = ThemeManager.shared
	@StateObject private var localizationManager = LocalizationManager.shared

	// State variable to hold the initialized ModelContainer or nil if setup failed
	@State private var modelContainer: ModelContainer?
	@State private var initializationError: Error? = nil

	// MARK: - Initialization

	init() {
		if AppConstants.enableAnalytics {
			FirebaseApp.configure()
			if AppConstants.enableDebugLogging {
				print("Firebase configured for Analytics")
			}
		} else {
			print("Firebase Analytics disabled via AppConstants.enableAnalytics")
		}

		if AppConstants.enableGoogleMapsAutocomplete {
			let activated = PlacesClient.provideAPIKey(Bundle.main.infoDictionary?["GOOGLE_API_KEY"] as! String)
			if !activated {
				print("Google Maps Autocomplete API key not provided or invalid")
			} else {
				print("Google Maps Autocomplete API key activated")
			}

		} else {
			print("Google Maps Autocomplete disabled via AppConstants.enableGoogleMapsAutocomplete")
		}

		// --- SwiftData Setup ---
		let schema = Schema([Trip.self, PackItem.self])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false, // Set to true for UI previews or testing if needed
			cloudKitDatabase: AppConstants.enableCloudSync ? .automatic : .none
		)

		do {
			let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
			_modelContainer = State(initialValue: container) // Assign to @State variable

			// --- Development Utilities ---
			// Reset specific states if configured (run before sample data)
			if AppConstants.resetPreferencesOnLaunch {
				// Optional: Clear SwiftData entirely AND reset onboarding
				// DevelopmentHelpers.clearAllSwiftData(context: container.mainContext)
				DevelopmentHelpers.resetAppState()
			}

			// Add sample data if needed and not already present
			if AppConstants.includeSampleData {
				DevelopmentHelpers.createSampleData(context: container.mainContext)
			}

		} catch {
			// --- Robust Error Handling ---
			// Store the error to potentially display an error message
			_initializationError = State(initialValue: error)
			_modelContainer = State(initialValue: nil) // Ensure container is nil on error
			print("❌ FATAL ERROR: Could not create ModelContainer: \(error.localizedDescription)")
		}
	}

	// MARK: - App Scene Body

	var body: some Scene {
		WindowGroup {
			// --- UI Content ---
			if let container = modelContainer {
				// If container setup was successful, show main content
				Group {
					// Check onboarding status from the single source of truth: UserSettingsManager
					if userSettings.hasCompletedOnboarding {
						TripsListView()

					} else {
						OnboardingView {
							// Update onboarding status via the manager
							withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
								userSettings.hasCompletedOnboarding = true
							}
						}
					}
				}
				// Inject ModelContainer and Managers into the environment
				.modelContainer(container)
				.environmentObject(userSettings) // Already initialized as @StateObject
				.environmentObject(themeManager) // Already initialized as @StateObject
				.environmentObject(localizationManager) // Inject the manager
				.environment(\.locale, localizationManager.appLocale) //
				.preferredColorScheme(themeManager.colorScheme) // Apply theme preference

			} else {
				// If container setup failed, show an error message
				VStack {
					Image(systemName: "exclamationmark.triangle.fill")
						.resizable()
						.scaledToFit()
						.frame(width: 50, height: 50)
						.foregroundColor(.red)
					Text("App Initialization Failed")
						.font(.title)
						.padding(.bottom)
					Text("TravelBuddy could not start correctly. Please try restarting the app.")
						.multilineTextAlignment(.center)
						.foregroundColor(.secondary)
						.padding(.horizontal)
					if let error = initializationError {
						Text("Error: \(error.localizedDescription)")
							.font(.caption)
							.foregroundColor(.gray)
							.padding()
					}
				}
			}
		}
	}
}
