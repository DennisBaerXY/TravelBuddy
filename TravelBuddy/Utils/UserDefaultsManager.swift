//
//  UserDefaultsManager.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

// UserDefaultsManager.swift
import Foundation

class UserDefaultsManager {
	static let shared = UserDefaultsManager()

	private let hasSeenOnboardingKey = "hasSeenOnboarding"

	var hasSeenOnboarding: Bool {
		get {
			return UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey)
		}
	}

	// Hilfsmethode zum Zurücksetzen für Debug-Zwecke
	func resetOnboarding() {
		hasSeenOnboarding = false
		print("Onboarding zurückgesetzt.")
	}
}
