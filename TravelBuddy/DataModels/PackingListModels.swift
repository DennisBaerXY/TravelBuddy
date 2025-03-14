//
//  PackingListModels.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 08.03.25.
//

import Foundation
import SwiftData

@Model
class PackingList {
	@Attribute(.unique) var id: UUID
	var name: String
	var items: [Item]
	var createdAt: Date

	init(id: UUID = UUID(), name: String = "", items: [Item] = [], createdAt: Date = .now) {
		self.id = id
		self.name = name
		self.items = items
		self.createdAt = createdAt
	}
}

@Model
class Item {
	@Attribute(.unique) var id: UUID
	var name: String
	var category: String
	var quantity: Int
	var isChecked: Bool

	init(
		id: UUID = UUID(),
		name: String = "",
		category: String = "",
		quantity: Int = 1,
		isChecked: Bool = false
	) {
		self.id = id
		self.name = name
		self.category = category
		self.quantity = quantity
		self.isChecked = isChecked
	}
}
