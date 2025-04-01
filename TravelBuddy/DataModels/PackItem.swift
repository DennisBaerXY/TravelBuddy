//
//  PackItem.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation
import SwiftData

@Model
final class PackItem {
	// Entferne .unique-Constraint für die ID
	var id = UUID()
	var name: String = ""
	var category: String = ItemCategory.other.rawValue
	var isPacked: Bool = false
	var isEssential: Bool = false
	var quantity: Int = 1
	// Behalte die inverse Beziehung
	@Relationship var trip: Trip?
	var modificationDate = Date()

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

	func update() {
		modificationDate = Date()
	}

	var categoryEnum: ItemCategory {
		ItemCategory(rawValue: category) ?? .other
	}
}
