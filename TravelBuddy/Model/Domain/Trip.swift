import Foundation
import SwiftData

@Model
class Trip {
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
	
	// MARK: - Computed Properties
	
	var packingProgress: Double {
		guard let items = packingItems, !items.isEmpty else { return 0 }
		return Double(items.filter { $0.isPacked }.count) / Double(items.count)
	}
	
	var numberOfDays: Int {
		Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
	}
	
	var isActive: Bool {
		let today = Date()
		return today >= startDate && today <= endDate
	}
	
	var isUpcoming: Bool {
		Date() < startDate
	}
	
	// MARK: - Type Conversions
	
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
	
	// MARK: - Helpers
	
	func update() {
		modificationDate = Date()
	}
	
	var formattedDuration: String {
		let formatter = DateIntervalFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: startDate, to: endDate)
	}
	
	var statusDescription: String {
		if isCompleted {
			return String(localized: "Completed")
		} else if isActive {
			return String(localized: "Active")
		} else {
			return String(localized: "Upcoming")
		}
	}
	
	// MARK: - Static helpers
	
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

// Helper extension for comparability
extension Bool: Comparable {
	public static func <(lhs: Self, rhs: Self) -> Bool {
		!lhs && rhs
	}
}
