// MARK: - Enhanced Packing Item for Registry System

import Foundation

/// Enhanced packing item with intelligent metadata
struct RegistryPackingItem: Codable, Hashable, Identifiable {
	let id: String
	let nameKey: String // Localization key
	let category: ItemCategory
	let tags: [String] // For flexible categorization
	let baseQuantity: Int
	let isEssential: Bool
	let priority: ItemPriority
	let conditions: [ItemCondition] // When this item should be included
	let quantityRules: [QuantityRule] // How to calculate quantity
	let alternatives: [String] // Alternative item IDs
	let seasonality: Seasonality?
	let genderSpecific: Gender?
    
	enum ItemPriority: String, Codable, CaseIterable {
		case critical // Must have (documents, etc.)
		case essential // Very important (basic toiletries)
		case recommended // Good to have (extra clothes)
		case optional // Nice to have (books, games)
		case situational // Context dependent
        
		var weight: Double {
			switch self {
			case .critical: return 1.0
			case .essential: return 0.8
			case .recommended: return 0.6
			case .optional: return 0.4
			case .situational: return 0.3
			}
		}
	}
    
	enum Seasonality: String, Codable {
		case spring, summer, autumn, winter, yearRound
	}
    
	enum Gender: String, Codable {
		case male, female, unisex
	}
}

// MARK: - Item Conditions (When to include items)

struct ItemCondition: Codable, Hashable {
	let type: ConditionType
	let values: [String]
	let conOperator: ConditionOperator
	let weight: Double // How important this condition is (0.0 - 1.0)
    
	enum ConditionType: String, Codable {
		case transport
		case accommodation
		case activity
		case climate
		case duration // days
		case groupSize // number of people
		case season
		case timeOfDay
		case businessTrip
		case destination // country/region codes
		case temperature // ranges
	}
    
	enum ConditionOperator: String, Codable {
		case equals
		case contains
		case greaterThan
		case lessThan
		case between
		case not
	}
}

// MARK: - Quantity Rules (How much to pack)

struct QuantityRule: Codable, Hashable {
	let condition: ItemCondition?
	let formula: QuantityFormula
	let minQuantity: Int
	let maxQuantity: Int
    
	enum QuantityFormula: String, Codable {
		case fixed // Always same amount
		case perDay // quantity * days
		case perPerson // quantity * people
		case perDayPerPerson // quantity * days * people
		case conditional // Based on specific conditions
		case weatherDependent // Based on climate
	}
}

// MARK: - Packing Context (Trip Analysis)

struct PackingContext {
	let trip: Trip
	let weather: WeatherContext?
	let culturalContext: CulturalContext?
	let calculatedFields: CalculatedFields
    
	struct WeatherContext {
		let averageTemperature: Double?
		let precipitationChance: Double?
		let season: RegistryPackingItem.Seasonality
		let temperatureRange: TemperatureRange
        
		enum TemperatureRange: String, CaseIterable {
			case freezing // < 0°C
			case cold // 0-10°C
			case cool // 10-18°C
			case mild // 18-25°C
			case warm // 25-30°C
			case hot // > 30°C
		}
	}
    
	struct CulturalContext {
		let countryCode: String
		let modestDressingRequired: Bool
		let businessCultureFormal: Bool
		let tippingCulture: Bool
	}
    
	struct CalculatedFields {
		let tripDuration: Int
		let isWeekend: Bool
		let isInternational: Bool
		let isShortTrip: Bool // <= 3 days
		let isLongTrip: Bool // >= 14 days
		let seasonAtDestination: RegistryPackingItem.Seasonality
		let isBusinessFocused: Bool
		let hasOutdoorActivities: Bool
		let requiresFormalWear: Bool
		let requiresSpecialEquipment: Bool
	}
}

// MARK: - Smart Recommendation Result

struct PackingRecommendation {
	let item: RegistryPackingItem
	let recommendedQuantity: Int
	var confidence: Double // 0.0 - 1.0 how sure we are about this recommendation
	let reasons: [RecommendationReason]
	let isAutoSelected: Bool // Should be pre-selected in UI
    
	struct RecommendationReason {
		let type: ReasonType
		let description: String
		let weight: Double
        
		enum ReasonType {
			case essential, weather, activity, duration, cultural, transport, accommodation
		}
	}
}

// MARK: - Extension for Trip Analysis

extension Trip {
	var packingContext: PackingContext {
		let calculatedFields = PackingContext.CalculatedFields(
			tripDuration: numberOfDays,
			isWeekend: numberOfDays <= 3 && startDate.weekdayName.contains("Fri"),
			isInternational: !destination.isEmpty, // Could be enhanced with country detection
			isShortTrip: numberOfDays <= 3,
			isLongTrip: numberOfDays >= 14,
			seasonAtDestination: currentSeason,
			isBusinessFocused: isBusinessTrip || activitiesEnum.contains(.business),
			hasOutdoorActivities: activitiesEnum.contains(where: {
				[.hiking, .beach, .sports, .skiing].contains($0)
			}),
			requiresFormalWear: isBusinessTrip || activitiesEnum.contains(.business),
			requiresSpecialEquipment: activitiesEnum.contains(where: {
				[.skiing, .hiking, .sports, .swimming].contains($0)
			})
		)
        
		return PackingContext(
			trip: self,
			weather: weatherContext,
			culturalContext: nil, // Could be enhanced
			calculatedFields: calculatedFields
		)
	}
    
	private var currentSeason: RegistryPackingItem.Seasonality {
		let month = Calendar.current.component(.month, from: startDate)
		switch month {
		case 12, 1, 2: return .winter
		case 3, 4, 5: return .spring
		case 6, 7, 8: return .summer
		case 9, 10, 11: return .autumn
		default: return .yearRound
		}
	}
    
	private var weatherContext: PackingContext.WeatherContext {
		let tempRange: PackingContext.WeatherContext.TemperatureRange
		switch climateEnum {
		case .cold: tempRange = .cold
		case .cool: tempRange = .cool
		case .moderate: tempRange = .mild
		case .warm: tempRange = .warm
		case .hot: tempRange = .hot
		}
        
		return PackingContext.WeatherContext(
			averageTemperature: nil,
			precipitationChance: nil,
			season: currentSeason,
			temperatureRange: tempRange
		)
	}
}
