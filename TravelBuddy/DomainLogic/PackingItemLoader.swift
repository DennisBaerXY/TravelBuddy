//
//  PackingItemLoader.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Foundation
import SwiftUI // Needed for NSLocalizedString in this context

// Decodable struct matching the JSON item structure
struct PackingItemData: Decodable, Hashable {
	let name: String // This will be the localization key
	let category: String // Corresponds to ItemCategory.rawValue
	let isEssential: Bool?
	let quantity: Int?
}

// Decodable struct matching the top-level JSON array elements
struct ItemCategoryData: Decodable, Hashable {
	let categoryKey: String // Identifier like "basic", "airTravel", etc.
	let items: [PackingItemData]
}

// Service class to load and provide packing item templates
final class PackingItemLoader {
	// MARK: - Properties

	// Stores the loaded item templates, keyed by categoryKey from JSON
	private(set) var itemTemplates: [String: [PackItem]] = [:]

	// Shared instance for easy access
	static let shared = PackingItemLoader()

	// MARK: - Initialization

	// Private initializer to enforce singleton pattern and load data on creation
	private init() {
		loadItems()
	}

	// MARK: - Data Loading

	/// Loads item templates from the bundled JSON file.
	private func loadItems() {
		guard let url = Bundle.main.url(forResource: "packingitems", withExtension: "json"),
		      let data = try? Data(contentsOf: url)
		else {
			assertionFailure("Failed to find or load packingItems.json in the bundle.")
			return
		}

		let decoder = JSONDecoder()
		var decodedData = [ItemCategoryData]()
		do {
			decodedData = try decoder.decode([ItemCategoryData].self, from: data)
		} catch let DecodingError.keyNotFound(key, context) {
			fatalError("Failed to decode JSON: Key duo to missing key '\(key)' from bundle to missing key '\(key.stringValue)' - \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(_, context) {
			fatalError("Failed to decode from bundle due to type mismatch - \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			fatalError("Failed to decode from bundle due to missing \(type) value not found - \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(_) {
			fatalError("Failed to decode from bundle because it appears to be invalid Json")
		} catch {
			fatalError("Failed to decode from bundle: \(error.localizedDescription)")
		}

		var loadedTemplates = [String: [PackItem]]()
		for categoryInfo in decodedData {
			let packItems = categoryInfo.items.map { itemData -> PackItem in
				// --- Localization Happens Here ---
				// Use the 'name' from JSON as the key for NSLocalizedString
				let localizedName = NSLocalizedString(itemData.name, comment: "Packing item name: \(itemData.name)")

				return PackItem(
					name: localizedName, // Use the localized name
					category: ItemCategory(rawValue: itemData.category) ?? .other,
					isEssential: itemData.isEssential ?? false,
					quantity: itemData.quantity ?? 1
				)
			}
			loadedTemplates[categoryInfo.categoryKey] = packItems
		}

		itemTemplates = loadedTemplates

		if AppConstants.enableDebugLogging, itemTemplates.isEmpty {
			print("Warning: Packing item templates appear empty after loading.")
		} else if AppConstants.enableDebugLogging {
			print("Successfully loaded \(itemTemplates.values.flatMap { $0 }.count) packing item templates from JSON.")
		}
	}

	// MARK: - Accessing Items

	/// Retrieves item templates for a specific category key.
	/// - Parameter key: The category key (e.g., "basic", "airTravel").
	/// - Returns: An array of PackItem templates, or an empty array if the key is not found.
	func items(for key: String) -> [PackItem] {
		return itemTemplates[key] ?? []
	}

	/// Retrieves clothing item templates, adjusting quantities based on duration and people.
	/// - Parameters:
	///   - days: The number of days for the trip.
	///   - people: The number of people traveling.
	/// - Returns: An array of clothing PackItem templates with adjusted quantities.
	func clothingItems(for days: Int, people: Int = 1) -> [PackItem] {
		// Define base quantities (these could also be in JSON if more complex rules needed)
		let tshirtCount = min(max(days, 3), 7)
		let socksCount = min(max(days, 3), 7)
		let underwearCount = min(max(days, 3), 7)
		let pantsCount = days > 7 ? 3 : 2

		// Create specific clothing items - Names should match keys in Localizable.strings
		// Note: This part still hardcodes the *types* of clothing, but not the full list.
		// A more advanced system could define these relationships in JSON too.
		let items = [
			PackItem(name: NSLocalizedString("T-Shirts", comment: ""), category: .clothing, quantity: tshirtCount * people),
			PackItem(name: NSLocalizedString("Pants", comment: ""), category: .clothing, quantity: pantsCount * people),
			PackItem(name: NSLocalizedString("Socks", comment: ""), category: .clothing, quantity: socksCount * people),
			PackItem(name: NSLocalizedString("Underwear", comment: ""), category: .clothing, quantity: underwearCount * people),
			PackItem(name: NSLocalizedString("Pajamas", comment: ""), category: .clothing, quantity: 1 * people), // Simpler logic for pajamas
			PackItem(name: NSLocalizedString("Casual Shoes", comment: ""), category: .clothing, quantity: 1 * people) // Usually one pair per person
		]
		return items
	}
}
