//
//  TravelBuddyApp.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 08.03.25.
//

import SwiftData
import SwiftUI

@main
struct TravelBuddyApp: App {
	@State private var hasCompletedOnboarding = UserDefaultsManager.shared.hasSeenOnboarding

	var body: some Scene {
		WindowGroup {
			if hasCompletedOnboarding {
				ContentView()
			} else {
				OnboardingView {
					// Onboarding als abgeschlossen markieren
					UserDefaultsManager.shared.hasSeenOnboarding = true
					hasCompletedOnboarding = true
				}
				.transition(.opacity)
			}
		}
		.modelContainer(for: [Trip.self, PackItem.self])
	}
}
