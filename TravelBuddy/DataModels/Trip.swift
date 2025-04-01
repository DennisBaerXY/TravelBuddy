//
//  Trip.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation
import SwiftData

@Model
final class Trip {
	// Entferne .unique-Constraint für die ID
	var id = UUID()
	var name: String = ""
	var destination: String = ""
	var startDate = Date()
	var endDate: Date = Date().addingTimeInterval(86400) // +1 Tag
	var transportTypes: [String] = []
	var accommodationType: String = AccommodationType.hotel.rawValue
	var activities: [String] = []
	var isBusinessTrip: Bool = false
	var numberOfPeople: Int = 1
	var climate: String = Climate.moderate.rawValue
	var isCompleted: Bool = false
	// Mache packingItems optional für CloudKit
	@Relationship(deleteRule: .cascade, inverse: \PackItem.trip) var packingItems: [PackItem]? = []
	var createdAt = Date()
	var modificationDate = Date()
		
	init(
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
	) {
		self.id = UUID()
		self.name = name
		self.destination = destination
		self.startDate = startDate
		self.endDate = endDate
		self.transportTypes = transportTypes.map { $0.rawValue }
		self.accommodationType = accommodationType.rawValue
		self.activities = activities.map { $0.rawValue }
		self.isBusinessTrip = isBusinessTrip
		self.numberOfPeople = numberOfPeople
		self.climate = climate.rawValue
		self.createdAt = Date()
		self.modificationDate = Date()
		self.isCompleted = false
	}
		
	func update() {
		modificationDate = Date()
	}
		
	// Berechneter Fortschrittswert (angepasst für optionales packingItems)
	var packingProgress: Double {
		guard let items = packingItems, !items.isEmpty else { return 0 }
		return Double(items.filter { $0.isPacked }.count) / Double(items.count)
	}
		
	// Die Konvertierungsmethoden bleiben gleich
	var transportTypesEnum: [TransportType] {
		transportTypes.compactMap { TransportType(rawValue: $0) }
	}
		
	var accommodationTypeEnum: AccommodationType {
		AccommodationType(rawValue: accommodationType) ?? .hotel
	}
		
	var activitiesEnum: [Activity] {
		activities.compactMap { Activity(rawValue: $0) }
	}
		
	var climateEnum: Climate {
		Climate(rawValue: climate) ?? .moderate
	}
}
