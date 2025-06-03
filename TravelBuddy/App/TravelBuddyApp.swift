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
		// --- Google Places Configuration (remains the same) ---
		if AppConstants.enableGoogleMapsAutocomplete {
			let activated = PlacesClient.provideAPIKey(Bundle.main.infoDictionary?["GOOGLE_API_KEY"] as! String)
			if !activated {
				print("Google Maps Autocomplete API key not provided or invalid")
			}
		}

		// --- Firebase Configuration (remains, but consent modifies its behavior) ---
		if AppConstants.enableAnalytics {
			FirebaseApp.configure()
			// Initial analytics configuration based on consent will be handled by AppTrackingManager
		}

		// --- Mobile Ads Configuration (Test devices can be set here) ---
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["21fade3f7a75ba7f7e112da1fae8f83b"]
		// The actual MobileAds.shared.start() will be called *after* consent is gathered.

		return true
	}
}

@main
struct TravelBuddyApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var userSettings = UserSettingsManager.shared
	@StateObject private var themeManager = ThemeManager.shared
	@StateObject private var localizationManager = LocalizationManager.shared
	@StateObject private var trackingManager = AppTrackingManager.shared

	@State private var modelContainer: ModelContainer?
	@State private var initializationError: Error? = nil

	@State private var isConsentFlowComplete = false // New state to manage content display

	// MARK: - Initialization

	init() {
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

		if AppConstants.enableDebugLogging {
			SmartItemRegistry.shared.printStats()
		}
	}

	// MARK: - App Scene Body

	var body: some Scene {
		WindowGroup {
			// --- UI Content ---
			if let container = modelContainer {
				Group {
					// Main app flow

					if !userSettings.hasCompletedOnboarding {
						OnboardingView()
					} else {
						TripsListView()
							.onAppear {
								AppTrackingManager.shared.gatherConsent { _ in

									AppTrackingManager.shared.startGoogleMobileAdsSDK()
								}
							}
					}
				}

				.modelContainer(container)
				.environmentObject(userSettings)
				.environmentObject(themeManager)
				.environmentObject(localizationManager)
				.environmentObject(trackingManager)
				.environment(\.locale, localizationManager.appLocale)
				.preferredColorScheme(themeManager.colorScheme)
			} else {
				errorView
			}
		}
	}

	private var errorView: some View {
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
