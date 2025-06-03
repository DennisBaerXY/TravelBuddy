// MARK: - Smart Rule Engine for Packing Recommendations

import Foundation

/// Intelligent rule engine that evaluates items based on trip context
class SmartPackingRuleEngine {
	// MARK: - Main Recommendation Method
    
	/// Generates intelligent packing recommendations based on trip context
	/// - Parameters:
	///   - items: Available items from registry
	///   - context: Trip context for evaluation
	/// - Returns: Sorted recommendations with confidence scores
	func generateRecommendations(
		from items: [RegistryPackingItem],
		for context: PackingContext
	) -> [PackingRecommendation] {
		var recommendations: [PackingRecommendation] = []
        
		for item in items {
			if let recommendation = evaluateItem(item, context: context) {
				recommendations.append(recommendation)
			}
		}
        
		// Sort by confidence and priority
		return recommendations.sorted { lhs, rhs in
			if lhs.item.priority.weight != rhs.item.priority.weight {
				return lhs.item.priority.weight > rhs.item.priority.weight
			}
			return lhs.confidence > rhs.confidence
		}
	}
    
	// MARK: - Item Evaluation
    
	private func evaluateItem(
		_ item: RegistryPackingItem,
		context: PackingContext
	) -> PackingRecommendation? {
		var totalScore: Double = 0
		var matchedConditions: [PackingRecommendation.RecommendationReason] = []
		var shouldInclude = false
        
		// Base priority score
		totalScore += item.priority.weight
        
		// Evaluate all conditions for this item
		for condition in item.conditions {
			let (matches, score, reason) = evaluateCondition(condition, context: context)
			if matches {
				shouldInclude = true
				totalScore += score * condition.weight
				if let reason = reason {
					matchedConditions.append(reason)
				}
			}
		}
        
		// Don't recommend items that don't match any conditions (unless critical)
		if !shouldInclude && item.priority != .critical {
			return nil
		}
        
		// Essential items always get included if they match basic trip requirements
		if item.isEssential || item.priority == .critical {
			shouldInclude = true
			totalScore = max(totalScore, 0.7) // Ensure essential items have decent score
		}
        
		// Calculate confidence (normalize score to 0-1 range)
		let confidence = min(1.0, max(0.0, totalScore))
        
		// Skip low-confidence recommendations unless essential
		if confidence < 0.3, !item.isEssential, item.priority != .critical {
			return nil
		}
        
		// Calculate quantity
		let quantity = calculateQuantity(for: item, context: context)
        
		return PackingRecommendation(
			item: item,
			recommendedQuantity: quantity,
			confidence: confidence,
			reasons: matchedConditions,
			isAutoSelected: confidence > 0.6 || item.priority == .critical
		)
	}
    
	// MARK: - Condition Evaluation
    
	private func evaluateCondition(
		_ condition: ItemCondition,
		context: PackingContext
	) -> (matches: Bool, score: Double, reason: PackingRecommendation.RecommendationReason?) {
		let trip = context.trip
		let calculated = context.calculatedFields
        
		var matches = false
		var score: Double = 0
		var reasonType: PackingRecommendation.RecommendationReason.ReasonType = .essential
		var reasonDescription = ""
        
		switch condition.type {
		case .transport:
			let tripTransports = trip.transportTypesEnum.map { $0.rawValue }
			matches = condition.values.contains { tripTransports.contains($0) }
			if matches {
				score = 0.7
				reasonType = .transport
				reasonDescription = "Needed for \(condition.values.joined(separator: ", ")) travel"
			}
            
		case .accommodation:
			matches = condition.values.contains(trip.accommodationTypeEnum.rawValue)
			if matches {
				score = 0.6
				reasonType = .accommodation
				reasonDescription = "Suitable for \(trip.accommodationTypeEnum.rawValue) stay"
			}
            
		case .activity:
			let tripActivities = trip.activitiesEnum.map { $0.rawValue }
			matches = condition.values.contains { tripActivities.contains($0) }
			if matches {
				score = 0.8
				reasonType = .activity
				reasonDescription = "Essential for planned activities"
			}
            
		case .climate:
			matches = condition.values.contains(trip.climateEnum.rawValue)
			if matches {
				score = 0.9 // Weather is very important
				reasonType = .weather
				reasonDescription = "Perfect for \(trip.climateEnum.rawValue) weather"
			}
            
		case .duration:
			matches = evaluateNumericCondition(
				value: Double(calculated.tripDuration),
				conditionValues: condition.values,
				conOperator: condition.conOperator
			)
			if matches {
				score = 0.5
				reasonType = .duration
				reasonDescription = "Appropriate for \(calculated.tripDuration)-day trip"
			}
            
		case .groupSize:
			matches = evaluateNumericCondition(
				value: Double(trip.numberOfPeople),
				conditionValues: condition.values,
				conOperator: condition.conOperator
			)
			if matches {
				score = 0.4
				reasonType = .essential
				reasonDescription = "Needed for group of \(trip.numberOfPeople)"
			}
            
		case .businessTrip:
			let isBusinessValue = condition.values.first == "true"
			matches = calculated.isBusinessFocused == isBusinessValue
			if matches {
				score = calculated.isBusinessFocused ? 0.9 : 0.3
				reasonType = .essential
				reasonDescription = calculated.isBusinessFocused ? "Essential for business" : "Casual trip appropriate"
			}
            
		case .season:
			if let seasonStr = condition.values.first,
			   let season = RegistryPackingItem.Seasonality(rawValue: seasonStr)
			{
				matches = calculated.seasonAtDestination == season
				if matches {
					score = 0.8
					reasonType = .weather
					reasonDescription = "Perfect for \(season.rawValue) season"
				}
			}
            
		case .temperature:
			if let weather = context.weather {
				matches = condition.values.contains(weather.temperatureRange.rawValue)
				if matches {
					score = 0.9
					reasonType = .weather
					reasonDescription = "Essential for \(weather.temperatureRange.rawValue) temperatures"
				}
			}
            
		case .timeOfDay, .destination:
			// Future enhancements
			matches = false
		}
        
		let reason = matches ? PackingRecommendation.RecommendationReason(
			type: reasonType,
			description: reasonDescription,
			weight: condition.weight
		) : nil
        
		return (matches, score, reason)
	}
    
	// MARK: - Numeric Condition Evaluation
    
	private func evaluateNumericCondition(
		value: Double,
		conditionValues: [String],
		conOperator: ItemCondition.ConditionOperator
	) -> Bool {
		guard let firstValue = conditionValues.first,
		      let numericValue = Double(firstValue)
		else {
			return false
		}
        
		switch conOperator {
		case .equals:
			return abs(value - numericValue) < 0.1
		case .greaterThan:
			return value > numericValue
		case .lessThan:
			return value < numericValue
		case .between:
			guard conditionValues.count >= 2,
			      let maxValue = Double(conditionValues[1])
			else {
				return false
			}
			return value >= numericValue && value <= maxValue
		case .contains, .not:
			return false // Not applicable for numeric values
		}
	}
    
	// MARK: - Quantity Calculation
    
	private func calculateQuantity(
		for item: RegistryPackingItem,
		context: PackingContext
	) -> Int {
		let trip = context.trip
		let calculated = context.calculatedFields
        
		// Start with base quantity
		var quantity = item.baseQuantity
        
		// Apply quantity rules
		for rule in item.quantityRules {
			// Check if rule condition is met (if any)
			if let condition = rule.condition {
				let (matches, _, _) = evaluateCondition(condition, context: context)
				if !matches { continue }
			}
            
			// Apply formula
			switch rule.formula {
			case .fixed:
				quantity = item.baseQuantity
                
			case .perDay:
				quantity = item.baseQuantity * calculated.tripDuration
                
			case .perPerson:
				quantity = item.baseQuantity * trip.numberOfPeople
                
			case .perDayPerPerson:
				quantity = item.baseQuantity * calculated.tripDuration * trip.numberOfPeople
                
			case .conditional:
				// Apply conditional logic based on specific item types
				quantity = calculateConditionalQuantity(item: item, context: context)
                
			case .weatherDependent:
				quantity = calculateWeatherDependentQuantity(item: item, context: context)
			}
            
			// Apply min/max constraints
			quantity = max(rule.minQuantity, min(rule.maxQuantity, quantity))
		}
        
		// Global constraints
		quantity = max(1, min(20, quantity)) // Reasonable bounds
        
		return quantity
	}
    
	// MARK: - Specialized Quantity Calculations
    
	private func calculateConditionalQuantity(
		item: RegistryPackingItem,
		context: PackingContext
	) -> Int {
		let trip = context.trip
		let calculated = context.calculatedFields
        
		// Smart quantity calculation based on item type and context
		switch item.category {
		case .clothing:
			return calculateClothingQuantity(item: item, context: context)
		case .toiletries:
			return calculated.isLongTrip ? 2 : 1
		case .electronics:
			return trip.numberOfPeople > 2 ? 2 : 1
		case .documents:
			return 1 // Always 1 for documents
		default:
			return item.baseQuantity
		}
	}
    
	private func calculateClothingQuantity(
		item: RegistryPackingItem,
		context: PackingContext
	) -> Int {
		let calculated = context.calculatedFields
		let days = calculated.tripDuration
        
		// Clothing-specific logic
		if item.tags.contains("underwear") || item.tags.contains("socks") {
			return min(days + 1, 7) // Extra day's worth, max 7
		} else if item.tags.contains("shirts") || item.tags.contains("tops") {
			return min(max(days / 2, 2), 5) // Roughly half the days
		} else if item.tags.contains("pants") || item.tags.contains("bottoms") {
			return calculated.isLongTrip ? 3 : 2
		} else if item.tags.contains("outerwear") {
			return 1 // Jackets, coats - usually just one
		}
        
		return item.baseQuantity
	}
    
	private func calculateWeatherDependentQuantity(
		item: RegistryPackingItem,
		context: PackingContext
	) -> Int {
		guard let weather = context.weather else {
			return item.baseQuantity
		}
        
		let baseQuantity = item.baseQuantity
		let calculated = context.calculatedFields
        
		// Adjust based on weather extremes
		switch weather.temperatureRange {
		case .freezing, .cold:
			// Need more warm items
			if item.tags.contains("warm") || item.tags.contains("winter") {
				return baseQuantity + (calculated.isLongTrip ? 1 : 0)
			}
		case .hot:
			// Need more cooling/protection items
			if item.tags.contains("sun") || item.tags.contains("cooling") {
				return baseQuantity + 1
			}
		default:
			break
		}
        
		return baseQuantity
	}
}

// MARK: - Helper Extensions

extension RegistryPackingItem.Seasonality {
	static func from(date: Date) -> Self {
		let month = Calendar.current.component(.month, from: date)
		switch month {
		case 12, 1, 2: return .winter
		case 3, 4, 5: return .spring
		case 6, 7, 8: return .summer
		case 9, 10, 11: return .autumn
		default: return .yearRound
		}
	}
}
