// MARK: - Smart Packing List Generator

import FirebaseAnalytics
import Foundation
/// AI-powered packing list generator that creates intelligent, context-aware recommendations
struct SmartPackingListGenerator {
	// MARK: - Dependencies

	private let registry = SmartItemRegistry.shared
	private let ruleEngine = SmartPackingRuleEngine()
    
	// MARK: - Main Generation Method
    
	/// Generates an intelligent packing list for a trip
	/// - Parameter trip: The trip to generate packing list for
	/// - Returns: Array of recommended PackItem objects with smart quantities and priorities
	static func generateSmartPackingList(for trip: Trip) -> [PackItem] {
		let generator = SmartPackingListGenerator()
		return generator.generateList(for: trip)
	}
    
	private func generateList(for trip: Trip) -> [PackItem] {
		// Step 1: Analyze trip context
		let context = trip.packingContext
        
		if AppConstants.enableDebugLogging {
			logTripAnalysis(context)
		}
        
		// Step 2: Get recommendations from rule engine
		let recommendations = ruleEngine.generateRecommendations(
			from: registry.items,
			for: context
		)
        
		// Step 3: Apply post-processing filters
		let filteredRecommendations = applyPostProcessingFilters(
			recommendations: recommendations,
			context: context
		)
        
		// Step 4: Convert to PackItem objects
		let packItems = convertToPackItems(
			recommendations: filteredRecommendations,
			context: context
		)
        
		if AppConstants.enableDebugLogging {
			logGenerationResults(recommendations: filteredRecommendations, packItems: packItems)
		}
		
		if AppConstants.enableAnalytics {
			SmartPackingListGenerator.logGenerationAnalytics(trip: trip, generatedItems: packItems)
		}
        
		return packItems
	}
    
	// MARK: - Post-Processing Filters
    
	private func applyPostProcessingFilters(
		recommendations: [PackingRecommendation],
		context: PackingContext
	) -> [PackingRecommendation] {
		var filtered = recommendations
        
		// Filter 1: Remove low-confidence items for short trips
		if context.calculatedFields.isShortTrip {
			filtered = filtered.filter { $0.confidence > 0.4 || $0.item.priority == .critical }
		}
        
		// Filter 2: Limit total number of items for reasonable list size
		let maxItems = calculateMaxItems(for: context)
		if filtered.count > maxItems {
			// Keep all critical/essential items, then take highest confidence
			let critical = filtered.filter { $0.item.priority == .critical || $0.item.isEssential }
			let others = filtered.filter { $0.item.priority != .critical && !$0.item.isEssential }
				.sorted { $0.confidence > $1.confidence }
				.prefix(maxItems - critical.count)
            
			filtered = critical + Array(others)
		}
        
		// Filter 3: Remove alternatives (if main item is already included)
		filtered = removeRedundantAlternatives(recommendations: filtered)
        
		// Filter 4: Apply smart bundling (group related items)
		filtered = applySmartBundling(recommendations: filtered, context: context)
        
		return filtered
	}
    
	private func calculateMaxItems(for context: PackingContext) -> Int {
		let basePenalty = 30
		let calculated = context.calculatedFields
        
		var maxItems = basePenalty
        
		// Adjust based on trip characteristics
		if calculated.isLongTrip {
			maxItems += 15
		} else if calculated.isShortTrip {
			maxItems -= 10
		}
        
		if calculated.hasOutdoorActivities {
			maxItems += 10
		}
        
		if calculated.isBusinessFocused {
			maxItems += 8
		}
        
		if context.trip.numberOfPeople > 1 {
			maxItems += 5 * (context.trip.numberOfPeople - 1)
		}
        
		return max(15, min(80, maxItems)) // Reasonable bounds
	}
    
	private func removeRedundantAlternatives(
		recommendations: [PackingRecommendation]
	) -> [PackingRecommendation] {
		var filtered: [PackingRecommendation] = []
		var includedIds: Set<String> = []
        
		// Sort by confidence to prefer better items
		let sorted = recommendations.sorted { $0.confidence > $1.confidence }
        
		for recommendation in sorted {
			let item = recommendation.item
            
			// Skip if already included
			if includedIds.contains(item.id) {
				continue
			}
            
			// Check if any alternatives are already included
			let hasAlternativeIncluded = item.alternatives.contains { includedIds.contains($0) }
            
			if !hasAlternativeIncluded {
				filtered.append(recommendation)
				includedIds.insert(item.id)
                
				// Mark alternatives as "covered" by this item
				for alternative in item.alternatives {
					includedIds.insert(alternative)
				}
			}
		}
        
		return filtered
	}
    
	private func applySmartBundling(
		recommendations: [PackingRecommendation],
		context: PackingContext
	) -> [PackingRecommendation] {
		// Group related items and adjust quantities/priorities
		var bundled = recommendations
        
		// Bundle 1: Electronics with chargers
		bundled = bundleElectronicsWithChargers(recommendations: bundled)
        
		// Bundle 2: Activity-specific gear
		bundled = bundleActivityGear(recommendations: bundled, context: context)
        
		// Bundle 3: Weather-appropriate clothing sets
		bundled = bundleWeatherClothing(recommendations: bundled, context: context)
        
		return bundled
	}
    
	private func bundleElectronicsWithChargers(
		recommendations: [PackingRecommendation]
	) -> [PackingRecommendation] {
		// Find electronics that need chargers
		let electronics = recommendations.filter {
			$0.item.category == .electronics &&
				$0.item.tags.contains("needs_charger")
		}
        
		let chargers = recommendations.filter {
			$0.item.tags.contains("charger")
		}
        
		// Boost confidence of chargers when electronics are present
		var updated = recommendations
		if !electronics.isEmpty, !chargers.isEmpty {
			for i in 0..<updated.count {
				if updated[i].item.tags.contains("charger") {
					var recommendation = updated[i]
					recommendation.confidence = min(1.0, recommendation.confidence + 0.3)
					updated[i] = recommendation
				}
			}
		}
        
		return updated
	}
    
	private func bundleActivityGear(
		recommendations: [PackingRecommendation],
		context: PackingContext
	) -> [PackingRecommendation] {
		// Boost confidence of activity-specific items when activity is planned
		var updated = recommendations
		let activities = context.trip.activitiesEnum.map { $0.rawValue }
        
		for i in 0..<updated.count {
			let item = updated[i].item
			let hasActivityMatch = activities.contains { activity in
				item.tags.contains(activity)
			}
            
			if hasActivityMatch {
				var recommendation = updated[i]
				recommendation.confidence = min(1.0, recommendation.confidence + 0.2)
				updated[i] = recommendation
			}
		}
        
		return updated
	}
    
	private func bundleWeatherClothing(
		recommendations: [PackingRecommendation],
		context: PackingContext
	) -> [PackingRecommendation] {
		// Ensure clothing items are balanced for the weather
		var updated = recommendations
		let climate = context.trip.climateEnum
        
		// Count clothing items by weather appropriateness
		let weatherAppropriate = recommendations.filter { recommendation in
			recommendation.item.category == .clothing &&
				recommendation.item.tags.contains(climate.rawValue)
		}
        
		// Boost confidence if we have few weather-appropriate clothes
		if weatherAppropriate.count < 3 {
			for i in 0..<updated.count {
				let item = updated[i].item
				if item.category == .clothing, item.tags.contains(climate.rawValue) {
					var recommendation = updated[i]
					recommendation.confidence = min(1.0, recommendation.confidence + 0.3)
					updated[i] = recommendation
				}
			}
		}
        
		return updated
	}
    
	// MARK: - Conversion to PackItem
    
	private func convertToPackItems(
		recommendations: [PackingRecommendation],
		context: PackingContext
	) -> [PackItem] {
		return recommendations.map { recommendation in
			let registryItem = recommendation.item
			let localizedName = registry.localizedName(for: registryItem)
            
			return PackItem(
				name: localizedName,
				category: registryItem.category,
				isPacked: false,
				isEssential: registryItem.isEssential,
				quantity: recommendation.recommendedQuantity
			)
		}
	}
    
	// MARK: - Logging and Debugging
    
	private func logTripAnalysis(_ context: PackingContext) {
		let trip = context.trip
		let calc = context.calculatedFields
        
		print("\n🧳 Smart Packing Analysis for: \(trip.name)")
		print("📍 Destination: \(trip.destination)")
		print("📅 Duration: \(calc.tripDuration) days")
		print("👥 People: \(trip.numberOfPeople)")
		print("🌡️ Climate: \(trip.climateEnum.rawValue)")
		print("🏃 Activities: \(trip.activitiesEnum.map { $0.rawValue }.joined(separator: ", "))")
		print("🚌 Transport: \(trip.transportTypesEnum.map { $0.rawValue }.joined(separator: ", "))")
		print("🏨 Accommodation: \(trip.accommodationTypeEnum.rawValue)")
		print("💼 Business: \(calc.isBusinessFocused ? "Yes" : "No")")
		print("🎯 Trip Type: \(tripTypeDescription(calc))")
        
		if let weather = context.weather {
			print("🌤️ Weather: \(weather.temperatureRange.rawValue), \(weather.season.rawValue)")
		}
		print()
	}
    
	private func tripTypeDescription(_ calc: PackingContext.CalculatedFields) -> String {
		var types: [String] = []
		if calc.isShortTrip { types.append("Short") }
		if calc.isLongTrip { types.append("Long") }
		if calc.isWeekend { types.append("Weekend") }
		if calc.isInternational { types.append("International") }
		if calc.hasOutdoorActivities { types.append("Outdoor") }
		if calc.requiresFormalWear { types.append("Formal") }
		return types.isEmpty ? "Standard" : types.joined(separator: ", ")
	}
    
	private func logGenerationResults(
		recommendations: [PackingRecommendation],
		packItems: [PackItem]
	) {
		print("✨ Generated \(recommendations.count) recommendations:")
        
		let byPriority = Dictionary(grouping: recommendations) { $0.item.priority }
		for priority in RegistryPackingItem.ItemPriority.allCases {
			if let items = byPriority[priority], !items.isEmpty {
				print("  \(priority.rawValue.capitalized): \(items.count)")
			}
		}
        
		let avgConfidence = recommendations.map { $0.confidence }.reduce(0, +) / Double(recommendations.count)
		print("📊 Average Confidence: \(String(format: "%.1f", avgConfidence * 100))%")
        
		let autoSelected = recommendations.filter { $0.isAutoSelected }.count
		print("✅ Auto-selected: \(autoSelected)/\(recommendations.count)")
		print()
	}
	
	private static func logGenerationAnalytics(
		trip: Trip,
		generatedItems: [PackItem],
	) {
		guard AppConstants.enableAnalytics else { return }
			
		Analytics.logEvent("smart_packing_generated", parameters: [
			"trip_duration": trip.numberOfDays,
			"items_generated": generatedItems.count,
			"essential_items": generatedItems.filter { $0.isEssential }.count,
			"trip_type": trip.isBusinessTrip ? "business" : "leisure",
			"destination": trip.destination,
			"transport_types": trip.transportTypesEnum.map { $0.rawValue }.joined(separator: ","),
			"activities": trip.activitiesEnum.map { $0.rawValue }.joined(separator: ",")
		])
	}
}
