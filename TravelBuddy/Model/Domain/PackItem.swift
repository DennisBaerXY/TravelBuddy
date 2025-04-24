//
//  PackItem.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation
import SwiftData

/// PackItem model representing an item to pack for a trip
/// Core data model with SwiftData annotations for persistence
@Model
final class PackItem {
	// MARK: - Properties
	
	// Core properties
	var id = UUID()
	var name: String = ""
	var category: String = ItemCategory.other.rawValue
	var isPacked: Bool = false
	var isEssential: Bool = false
	var quantity: Int = 1
	
	// Relationship to parent trip
	@Relationship var trip: Trip?
	
	// Metadata
	var modificationDate = Date()

	// MARK: - Initialization
	
	/// Creates a new packing item with the specified properties
	init(
		name: String,
		category: ItemCategory,
		isPacked: Bool = false,
		isEssential: Bool = false,
		quantity: Int = 1
	) {
		self.id = UUID()
		self.name = name
		self.category = category.rawValue
		self.isPacked = isPacked
		self.isEssential = isEssential
		self.quantity = quantity
		self.modificationDate = Date()
	}

	// MARK: - Methods
	
	/// Updates the modification date to track changes
	func update() {
		modificationDate = Date()
	}
	
	/// Updates the item status to packed
	func markAsPacked() {
		isPacked = true
		update()
	}
	
	/// Updates the item status to unpacked
	func markAsUnpacked() {
		isPacked = false
		update()
	}
	
	/// Toggles the packed status of the item
	func togglePacked() {
		isPacked.toggle()
		update()
	}
	
	// MARK: - Computed Properties

	/// Converts the stored category string to enum value
	var categoryEnum: ItemCategory {
		ItemCategory(rawValue: category) ?? .other
	}
	
	/// Returns a string representation of the item with quantity
	var displayName: String {
		if quantity > 1 {
			return "\(name) (\(quantity))"
		}
		return name
	}
	
	/// Returns the icon name for the item's category
	var iconName: String {
		categoryEnum.iconName
	}
	
	/// Returns the localized name for the item's category
	var categoryName: String {
		categoryEnum.localizedName
	}
}

// MARK: - Extensions

extension PackItem {
	/// Returns a simple description of the item
	var description: String {
		let statusText = isPacked ? "✓" : "□"
		let essentialText = isEssential ? "!" : ""
		return "\(statusText) \(essentialText)\(name) (\(quantity))"
	}
}

// MARK: - Preview Helpers

extension PackItem {
	/// Creates a sample essential item for previews and testing
	static func sampleEssential() -> PackItem {
		PackItem(
			name: "Passport",
			category: .documents,
			isPacked: false,
			isEssential: true
		)
	}
	
	/// Creates a sample regular item for previews and testing
	static func sampleRegular() -> PackItem {
		PackItem(
			name: "T-Shirt",
			category: .clothing,
			isPacked: false,
			isEssential: false,
			quantity: 3
		)
	}
	
	/// Creates a sample packed item for previews and testing
	static func samplePacked() -> PackItem {
		PackItem(
			name: "Toothbrush",
			category: .toiletries,
			isPacked: true,
			isEssential: false
		)
	}
}
