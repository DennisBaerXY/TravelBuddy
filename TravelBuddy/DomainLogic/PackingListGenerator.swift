//
//  PackingListGenerator.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//
import Foundation

/// Service responsible for generating packing lists based on trip properties.
/// Uses pre-loaded item templates from PackingItemLoader.
struct PackingListGenerator {
	// Use the shared loader instance
	private static let loader = PackingItemLoader.shared

	/// Generates a suggested packing list for a given trip.
	/// - Parameter trip: The Trip object containing details for list generation.
	/// - Returns: An array of suggested PackItem objects.
	static func generatePackingList(for trip: Trip) -> [PackItem] {
		var suggestedItems = [PackItem]()

		// 1. Add Basic Items (always included)
		suggestedItems.append(contentsOf: loader.items(for: "basic"))

		// 2. Add Items Based on Transportation
		for transportType in trip.transportTypesEnum {
			switch transportType {
			case .plane: suggestedItems.append(contentsOf: loader.items(for: "airTravel"))
			case .car: suggestedItems.append(contentsOf: loader.items(for: "carTravel"))
			case .train: suggestedItems.append(contentsOf: loader.items(for: "trainTravel"))
			case .ship: suggestedItems.append(contentsOf: loader.items(for: "shipTravel"))
			// Add cases for .bus, .bicycle, .onFoot if needed and defined in JSON
			default: break
			}
		}

		// 3. Add Items Based on Accommodation
		switch trip.accommodationTypeEnum {
		case .hotel: suggestedItems.append(contentsOf: loader.items(for: "hotel"))
		case .camping: suggestedItems.append(contentsOf: loader.items(for: "camping"))
		case .apartment, .airbnb: suggestedItems.append(contentsOf: loader.items(for: "apartment")) // Merged key
		case .hostels: suggestedItems.append(contentsOf: loader.items(for: "hostel"))
		case .friends: suggestedItems.append(contentsOf: loader.items(for: "friends"))
		}

		// 4. Add Items Based on Activities
		for activity in trip.activitiesEnum {
			switch activity {
			case .swimming: suggestedItems.append(contentsOf: loader.items(for: "swimming"))
			case .hiking: suggestedItems.append(contentsOf: loader.items(for: "hiking"))
			case .business: suggestedItems.append(contentsOf: loader.items(for: "business"))
			case .beach: suggestedItems.append(contentsOf: loader.items(for: "beach"))
			case .sports: suggestedItems.append(contentsOf: loader.items(for: "sports"))
			case .skiing: suggestedItems.append(contentsOf: loader.items(for: "skiing"))
			case .sightseeing: suggestedItems.append(contentsOf: loader.items(for: "sightseeing"))
			case .relaxing: suggestedItems.append(contentsOf: loader.items(for: "relaxing"))
			}
		}

		// 5. Add Clothing Based on Duration & People (using loader's specialized method)
		suggestedItems.append(contentsOf: loader.clothingItems(for: trip.numberOfDays, people: trip.numberOfPeople))

		// 6. Add Climate-Specific Items
		switch trip.climateEnum {
		case .hot: suggestedItems.append(contentsOf: loader.items(for: "hotWeather"))
		case .warm: suggestedItems.append(contentsOf: loader.items(for: "warmWeather"))
		case .cold: suggestedItems.append(contentsOf: loader.items(for: "coldWeather"))
		case .cool: suggestedItems.append(contentsOf: loader.items(for: "coolWeather"))
		case .moderate: suggestedItems.append(contentsOf: loader.items(for: "moderateWeather"))
		}

		// 7. Add Additional Business-Specific Items (if applicable)
		if trip.isBusinessTrip {
			suggestedItems.append(contentsOf: loader.items(for: "additionalBusiness"))
		}

		// 8. Add Multi-Person Items
		if trip.numberOfPeople >= 2 {
			suggestedItems.append(contentsOf: loader.items(for: "multiPersonGeneral"))
		}
		if trip.numberOfPeople >= 3 { // Assuming family/children scenario
			suggestedItems.append(contentsOf: loader.items(for: "multiPersonFamily"))
		}

		// 9. Consolidate and Return (Remove duplicates, adjust quantities/essential status)
		return consolidateItems(suggestedItems)
	}

	/// Consolidates items to remove duplicates and combine quantities intelligently.
	/// Prioritizes keeping essential status and potentially higher quantities.
	/// - Parameter items: The full list of potentially duplicate items.
	/// - Returns: A deduplicated list with appropriate quantities and essential status.
	private static func consolidateItems(_ items: [PackItem]) -> [PackItem] {
		var uniqueItems = [String: PackItem]() // Use item name as key for deduplication

		for item in items {
			// Create a unique key (name + category might be better if names aren't unique across categories)
			let itemKey = item.name

			if let existingItem = uniqueItems[itemKey] {
				// If item already exists, merge intelligently:
				// - Take the higher quantity
				// - Keep if *either* original or new item is essential
				let newQuantity = max(existingItem.quantity, item.quantity)
				let isEssential = existingItem.isEssential || item.isEssential

				// Create a *new* PackItem instance reflecting the merged state
				// Note: We are creating *new* items, not modifying existing ones from the template cache
				let updatedItem = PackItem(
					name: existingItem.name, // Keep original name (already localized)
					category: existingItem.categoryEnum, // Keep original category
					isPacked: false, // Generated items start unpacked
					isEssential: isEssential,
					quantity: newQuantity
				)
				// It's crucial *not* to reuse IDs from templates here. Each generated item needs a unique ID.
				// updatedItem.id = existingItem.id (DO NOT DO THIS)

				uniqueItems[itemKey] = updatedItem

			} else {
				// If item is new, create a fresh instance.
				// This ensures we don't modify the original template from the loader.
				let newItemInstance = PackItem(
					name: item.name, // Already localized from loader
					category: item.categoryEnum,
					isPacked: false,
					isEssential: item.isEssential,
					quantity: item.quantity
				)
				uniqueItems[itemKey] = newItemInstance
			}
		}

		// Return the values (the consolidated PackItem instances)
		return Array(uniqueItems.values)
	}
}
