//
//  DevelopmentHelpers.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

// TravelBuddy/Utilities/Helpers/DevelopmentHelpers.swift
import Foundation
import SwiftData
import SwiftUI // Needed for UserSettingsManager access

/// Contains utility functions for development and debugging purposes.
struct DevelopmentHelpers {
	/// Resets certain app states for easier testing (e.g., onboarding).
	/// Note: Does not clear SwiftData.
	static func resetAppState() {
		// Reset onboarding flag in UserSettingsManager
		UserSettingsManager.shared.resetOnboarding() // Use the manager's method

		// Optionally reset other specific UserDefaults if needed, separate from UserSettingsManager
		// UserDefaults.standard.removeObject(forKey: "someOtherDebugFlag")

		if AppConstants.enableDebugLogging {
			print("App state has been reset (Onboarding flag).")
		}
	}

	/// Creates sample Trip and PackItem data in the provided ModelContext.
	/// - Parameter context: The ModelContext to insert the sample data into.
	static func createSampleData(context: ModelContext) {
		guard !UserDefaults.standard.bool(forKey: "hasInsertedSampleData") else {
			if AppConstants.enableDebugLogging {
				print("Sample data already exists. Skipping creation.")
			}
			return
		}

		if AppConstants.enableDebugLogging {
			print("Creating sample data...")
		}

		// Create beach vacation
		_ = TripServices.createTripWithPackingList(
			in: context,
			name: NSLocalizedString("Sample Beach Vacation", comment: "Sample trip name"),
			destination: NSLocalizedString("Hawaii", comment: "Sample destination"),
			startDate: Date().addingTimeInterval(86400 * 14), // 2 weeks from now
			endDate: Date().addingTimeInterval(86400 * 21), // 3 weeks from now
			transportTypes: [.plane, .car],
			accommodationType: .hotel,
			activities: [.beach, .swimming, .relaxing],
			isBusinessTrip: false,
			numberOfPeople: 2,
			climate: .hot
		)

		// Create business trip
		_ = TripServices.createTripWithPackingList(
			in: context,
			name: NSLocalizedString("Sample Business Conference", comment: "Sample trip name"),
			destination: NSLocalizedString("New York", comment: "Sample destination"),
			startDate: Date().addingTimeInterval(86400 * 3), // 3 days from now
			endDate: Date().addingTimeInterval(86400 * 5), // 5 days from now
			transportTypes: [.plane],
			accommodationType: .hotel,
			activities: [.business],
			isBusinessTrip: true,
			numberOfPeople: 1,
			climate: .moderate
		)

		// Create completed trip
		let completedTrip = TripServices.createTripWithPackingList(
			in: context,
			name: NSLocalizedString("Sample Weekend Getaway", comment: "Sample trip name"),
			destination: NSLocalizedString("Mountain Cabin", comment: "Sample destination"),
			startDate: Date().addingTimeInterval(-86400 * 10), // 10 days ago
			endDate: Date().addingTimeInterval(-86400 * 8), // 8 days ago
			transportTypes: [.car],
			accommodationType: .apartment,
			activities: [.hiking, .relaxing],
			isBusinessTrip: false,
			numberOfPeople: 4,
			climate: .cool
		)
		// Mark the trip as completed using the service
		TripServices.completeTrip(completedTrip, in: context)

		// Mark that sample data has been inserted to prevent re-insertion
		UserDefaults.standard.set(true, forKey: "hasInsertedSampleData")

		if AppConstants.enableDebugLogging {
			print("Sample data creation complete.")
		}
	}

	/// Clears all Trip and PackItem data from SwiftData. Use with caution!
	/// - Parameter context: The ModelContext to delete data from.
	static func clearAllSwiftData(context: ModelContext) {
		if AppConstants.enableDebugLogging {
			print("Clearing all SwiftData Trip and PackItem entities...")
		}
		do {
			try context.delete(model: Trip.self)
			try context.delete(model: PackItem.self)
			try context.save()
			UserDefaults.standard.set(false, forKey: "hasInsertedSampleData") // Allow re-insertion
			if AppConstants.enableDebugLogging {
				print("SwiftData cleared successfully.")
			}
		} catch {
			print("Error clearing SwiftData: \(error.localizedDescription)")
			// Consider more robust error handling/logging
		}
	}
}
