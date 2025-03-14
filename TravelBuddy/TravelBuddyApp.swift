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
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(for: PackingList.self)
		.modelContainer(for: Item.self)
	}
}
