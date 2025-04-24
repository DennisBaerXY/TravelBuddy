//
//  Trip.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//
import Foundation
import SwiftData

/// Trip model representing a travel journey
/// Core data model with SwiftData annotations for persistence
@Model
class Trip {
	// MARK: - Properties
	
	// Core properties
	var id = UUID()
	var name: String = ""
	var destination: String = ""
	var startDate = Date()
	var endDate: Date = Date().addingTimeInterval(86400) // +1 day default
	
	// Trip details
	var transportTypes: [String] = []
	var accommodationType: String = AccommodationType.hotel.rawValue
	var activities: [String] = []
	var isBusinessTrip: Bool = false
	var numberOfPeople: Int = 1
	var climate: String = Climate.moderate.rawValue
	
	// Status tracking
	var isCompleted: Bool = false
	
	// Relationship to packing items
	@Relationship(deleteRule: .cascade, inverse: \PackItem.trip)
	var packingItems: [PackItem]? = []
	
	// Metadata
	var createdAt = Date()
	var modificationDate = Date()
	
	// MARK: - Initialization
	
	/// Creates a new trip with the specified properties
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
	
	// MARK: - Methods
	
	/// Updates the modification date to track changes
	func update() {
		modificationDate = Date()
	}
	
	// MARK: - Computed Properties
	
	/// Calculates the packing progress as a percentage (0.0 to 1.0)
	var packingProgress: Double {
		guard let items = packingItems, !items.isEmpty else { return 0 }
		return Double(items.filter { $0.isPacked }.count) / Double(items.count)
	}
	
	/// Returns the number of days for this trip
	var numberOfDays: Int {
		Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
	}
	
	/// Returns whether this trip is currently active (today falls within the trip dates)
	var isActive: Bool {
		let today = Date()
		return today >= startDate && today <= endDate
	}
	
	/// Returns whether this trip is upcoming (starts in the future)
	var isUpcoming: Bool {
		Date() < startDate
	}
	
	// MARK: - Type Conversions
	
	/// Converts the stored transport type strings to enum values
	var transportTypesEnum: [TransportType] {
		transportTypes.compactMap { TransportType(rawValue: $0) }
	}
	
	/// Converts the stored accommodation type string to enum value
	var accommodationTypeEnum: AccommodationType {
		AccommodationType(rawValue: accommodationType) ?? .hotel
	}
	
	/// Converts the stored activity strings to enum values
	var activitiesEnum: [Activity] {
		activities.compactMap { Activity(rawValue: $0) }
	}
	
	/// Converts the stored climate string to enum value
	var climateEnum: Climate {
		Climate(rawValue: climate) ?? .moderate
	}
}

extension Bool: Comparable {
	public static func <(lhs: Self, rhs: Self) -> Bool {
		// the only true inequality is false < true
		!lhs && rhs
	}
}

// MARK: - Extensions

extension Trip {
	/// Returns a localized string describing the trip duration
	var formattedDuration: String {
		let formatter = DateIntervalFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: startDate, to: endDate)
	}
	
	/// Returns a short status description of the trip
	var statusDescription: String {
		if isCompleted {
			return String(localized: "Completed")
		} else if isActive {
			return String(localized: "Active")
		} else {
			return String(localized: "Upcoming")
		}
	}
}

// MARK: - Preview Helpers

extension Trip {
	/// Creates a sample trip for previews and testing
	static func sampleTrip() -> Trip {
		Trip(
			name: "Summer Vacation",
			destination: "Bali, Indonesia",
			startDate: Date(),
			endDate: Date().addingTimeInterval(86400 * 7),
			transportTypes: [.plane, .car],
			accommodationType: .hotel,
			activities: [.beach, .swimming, .relaxing],
			isBusinessTrip: false,
			numberOfPeople: 2,
			climate: .hot
		)
	}
}
