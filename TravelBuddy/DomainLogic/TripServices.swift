//
//  TripRepository.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Combine
import Foundation

import SwiftData
import SwiftUI

import Foundation
import SwiftData

// Helper object to encapsulate complex operations
struct TripServices {
	// Create a trip with auto-generated packing list
	static func createTripWithPackingList(
		in modelContext: ModelContext,
		name: String,
		destination: String,
		startDate: Date,
		endDate: Date,
		transportTypes: [TransportType],
		accommodationType: AccommodationType,
		activities: [Activity],
		isBusinessTrip: Bool,
		numberOfPeople: Int,
		climate: Climate
	) -> Trip {
		// Create new trip
		let newTrip = Trip(
			name: name,
			destination: destination,
			startDate: startDate,
			endDate: endDate,
			transportTypes: transportTypes,
			accommodationType: accommodationType,
			activities: activities,
			isBusinessTrip: isBusinessTrip,
			numberOfPeople: numberOfPeople,
			climate: climate
		)
		
		// Insert trip into context
		modelContext.insert(newTrip)
		
		// Generate packing items
		let packingItems = PackingListGenerator.generatePackingList(for: newTrip)
		
		// Ensure packingItems array exists
		if newTrip.packingItems == nil {
			newTrip.packingItems = []
		}
		
		// Add all items to the trip
		for item in packingItems {
			modelContext.insert(item)
			item.trip = newTrip
			newTrip.packingItems?.append(item)
		}
		
		// Update and save
		newTrip.update()
		try? modelContext.save()
		
		return newTrip
	}
	
	// Complete a trip
	static func completeTrip(_ trip: Trip, in modelContext: ModelContext) {
		trip.isCompleted = true
		trip.update()
		try? modelContext.save()
	}
	
	// Add item to trip
	static func addItemToTrip(_ trip: Trip, in modelContext: ModelContext, item: PackItem) {
		modelContext.insert(item)
		item.trip = trip
		
		if trip.packingItems == nil {
			trip.packingItems = []
		}
		
		trip.packingItems?.append(item)
		trip.update()
		try? modelContext.save()
	}
}
