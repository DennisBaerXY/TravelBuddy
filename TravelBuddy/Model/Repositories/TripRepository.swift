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

/// Central repository for managing Trip data
/// Provides a clean API over SwiftData operations and handles all CRUD operations
@Observable
class TripRepository {
	// MARK: - Properties
    
	@Published var trips: [Trip] = []

	private var modelContext: ModelContext
	private var cancellables = Set<AnyCancellable>()
    
	// MARK: - Initialization
    
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		fetchTrips()
	}
    
	// MARK: - CRUD Operations
    
	/// Fetches all trips from the data store
	func fetchTrips() {
		let descriptor = FetchDescriptor<Trip>(
			sortBy: [
				SortDescriptor(\.isCompleted, order: .forward),
				SortDescriptor(\.createdAt, order: .reverse)
			]
		)
        
		do {
			trips = try modelContext.fetch(descriptor)
			
		} catch {
			print("Failed to fetch trips: \(error)")
		}
	}
    
	/// Creates a new trip with automatically generated packing items
	/// - Parameter tripData: The data for the new trip
	/// - Returns: The newly created Trip object
	@discardableResult
	func createTrip(name: String,
	                destination: String,
	                startDate: Date,
	                endDate: Date,
	                transportTypes: [TransportType],
	                accommodationType: AccommodationType,
	                activities: [Activity],
	                isBusinessTrip: Bool,
	                numberOfPeople: Int,
	                climate: Climate) -> Trip
	{
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
        
		// Generate packing items based on trip details
		let packingItems = PackingListGenerator.generatePackingList(for: newTrip)
        
		// Insert everything into the model context
		modelContext.insert(newTrip)
        
		if newTrip.packingItems == nil {
			newTrip.packingItems = []
		}
        
		for item in packingItems {
			modelContext.insert(item)
			newTrip.packingItems?.append(item)
		}
        
		newTrip.update()
		saveContext()
        
		// Update the published trips collection
		trips.append(newTrip)
        
		return newTrip
	}
    
	/// Deletes a trip from the data store
	/// - Parameter trip: The trip to delete
	func deleteTrip(_ trip: Trip) {
		modelContext.delete(trip)
		saveContext()
        
		if let index = trips.firstIndex(where: { $0.id == trip.id }) {
			trips.remove(at: index)
		}
	}
    
	/// Marks a trip as completed
	/// - Parameter trip: The trip to complete
	func completeTrip(_ trip: Trip) {
		trip.isCompleted = true
		trip.update()
		saveContext()
        
		// Update the local copy
		if let index = trips.firstIndex(where: { $0.id == trip.id }) {
			trips[index] = trip
		}
	}
    
	/// Adds a new packing item to a trip
	/// - Parameters:
	///   - trip: The trip to add the item to
	///   - itemData: The data for the new item
	/// - Returns: The newly created PackItem
	@discardableResult
	func addItemToTrip(_ trip: Trip, name: String, category: ItemCategory, isPacked: Bool = false, isEssential: Bool = false, quantity: Int = 1) -> PackItem {
		let newItem = PackItem(
			name: name,
			category: category,
			isPacked: isPacked,
			isEssential: isEssential,
			quantity: quantity
		)
        
		modelContext.insert(newItem)
		newItem.trip = trip
        
		if trip.packingItems == nil {
			trip.packingItems = []
		}
        
		trip.packingItems?.append(newItem)
		trip.update()
		saveContext()
        
		return newItem
	}
    
	/// Updates an existing packing item
	/// - Parameter item: The item to update
	func updatePackItem(_ item: PackItem) {
		item.update()
        
		// Also update the trip's modification date
		if let trip = item.trip {
			trip.update()
		}
        
		saveContext()
	}
    
	/// Deletes a packing item from a trip
	/// - Parameter item: The item to delete
	func deletePackItem(_ item: PackItem) {
		if let trip = item.trip, let index = trip.packingItems?.firstIndex(where: { $0.id == item.id }) {
			trip.packingItems?.remove(at: index)
			trip.update()
		}
        
		modelContext.delete(item)
		saveContext()
	}
    
	// MARK: - Helpers
    
	/// Saves changes to the model context
	private func saveContext() {
		do {
			try modelContext.save()
		} catch {
			print("Failed to save context: \(error)")
		}
	}
}
