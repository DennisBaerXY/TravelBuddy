//
//  Trip.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation
import SwiftData

@Model
class Trip {
	var id: UUID
	var name: String
	var destination: String
	var startDate: Date
	var endDate: Date
	var transportTypes: [String] // Speichern als String-Array, da SwiftData keine direkten Enums unterstützt
	var accommodationType: String
	var activities: [String]
	var isBusinessTrip: Bool
	var numberOfPeople: Int
	var climate: String
	var isCompleted: Bool
	@Relationship(deleteRule: .cascade) var packingItems: [PackItem] = []
	var createdAt: Date
    
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
		self.isCompleted = false
	}
    
	// Berechneter Fortschrittswert
	var packingProgress: Double {
		packingItems.isEmpty ? 0 : Double(packingItems.filter { $0.isPacked }.count) / Double(packingItems.count)
	}
    
	// Hilfsmethoden zur Konvertierung von/zu Enums
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
