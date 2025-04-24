import Foundation
import SwiftData
import SwiftUI

@Model
final class PackItem {
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
	
	func update() {
		modificationDate = Date()
	}
	
	func markAsPacked() {
		isPacked = true
		update()
	}
	
	func markAsUnpacked() {
		isPacked = false
		update()
	}
	
	func togglePacked() {
		isPacked.toggle()
		update()
	}
	
	// MARK: - Computed Properties

	var categoryEnum: ItemCategory {
		ItemCategory(rawValue: category) ?? .other
	}
	
	var displayName: String {
		if quantity > 1 {
			return "\(name) (\(quantity))"
		}
		return name
	}
	
	var iconName: String {
		categoryEnum.iconName
	}
	
	var categoryName: String {
		categoryEnum.localizedName
	}
	
	var description: String {
		let statusText = isPacked ? "✓" : "□"
		let essentialText = isEssential ? "!" : ""
		return "\(statusText) \(essentialText)\(name) (\(quantity))"
	}
	
	// MARK: - Sample data
	
	static func sampleEssential() -> PackItem {
		PackItem(
			name: "Passport",
			category: .documents,
			isPacked: false,
			isEssential: true
		)
	}
	
	static func sampleRegular() -> PackItem {
		PackItem(
			name: "T-Shirt",
			category: .clothing,
			isPacked: false,
			isEssential: false,
			quantity: 3
		)
	}
	
	static func samplePacked() -> PackItem {
		PackItem(
			name: "Toothbrush",
			category: .toiletries,
			isPacked: true,
			isEssential: false
		)
	}
}
