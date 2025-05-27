// MARK: - Smart Item Registry

import Foundation

/// Centralized registry for all packing items with intelligent loading and management
class SmartItemRegistry {
	// MARK: - Singleton

	static let shared = SmartItemRegistry()
    
	private init() {
		loadItems()
	}
    
	// MARK: - Properties

	private var allItems: [RegistryPackingItem] = []
	private var itemsByCategory: [ItemCategory: [RegistryPackingItem]] = [:]
	private var itemsByTag: [String: [RegistryPackingItem]] = [:]
	private var itemsById: [String: RegistryPackingItem] = [:]
    
	// MARK: - Public Interface
    
	/// Get all available items
	var items: [RegistryPackingItem] {
		return allItems
	}
    
	/// Get items by category
	func items(for category: ItemCategory) -> [RegistryPackingItem] {
		return itemsByCategory[category] ?? []
	}
    
	/// Get items by tag
	func items(withTag tag: String) -> [RegistryPackingItem] {
		return itemsByTag[tag] ?? []
	}
    
	/// Find item by ID
	func item(withId id: String) -> RegistryPackingItem? {
		return itemsById[id]
	}
    
	/// Search items by various criteria
	func search(
		categories: [ItemCategory]? = nil,
		tags: [String]? = nil,
		priorities: [RegistryPackingItem.ItemPriority]? = nil,
		essential: Bool? = nil
	) -> [RegistryPackingItem] {
		return allItems.filter { item in
			if let categories = categories, !categories.contains(item.category) {
				return false
			}
            
			if let tags = tags, !tags.contains(where: { item.tags.contains($0) }) {
				return false
			}
            
			if let priorities = priorities, !priorities.contains(item.priority) {
				return false
			}
            
			if let essential = essential, item.isEssential != essential {
				return false
			}
            
			return true
		}
	}
    
	// MARK: - Data Loading
    
	private func loadItems() {
		guard let url = Bundle.main.url(forResource: "smartitems", withExtension: "json"),
		      let data = try? Data(contentsOf: url)
		else {
			print("❌ Could not load smartitems.json")
			loadFallbackItems()
			return
		}
        
		do {
			let decoder = JSONDecoder()
			let itemData = try decoder.decode([RegistryPackingItem].self, from: data)
			processLoadedItems(itemData)
            
			if AppConstants.enableDebugLogging {
				print("✅ Loaded \(allItems.count) smart packing items")
			}
		} catch {
			print("❌ Error decoding smart packing items: \(error)")
			loadFallbackItems()
		}
	}
    
	private func processLoadedItems(_ items: [RegistryPackingItem]) {
		allItems = items
        
		// Build indices for fast lookup
		itemsByCategory = Dictionary(grouping: items) { $0.category }
		itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
		// Build tag index
		itemsByTag.removeAll()
		for item in items {
			for tag in item.tags {
				itemsByTag[tag, default: []].append(item)
			}
		}
	}
    
	// MARK: - Fallback Data
    
	private func loadFallbackItems() {
		print("⚠️ Loading fallback packing items")
        
		let fallbackItems = createFallbackItems()
		processLoadedItems(fallbackItems)
	}
    
	private func createFallbackItems() -> [RegistryPackingItem] {
		return [
			// Essential Documents
			RegistryPackingItem(
				id: "passport",
				nameKey: "item_passport",
				category: .documents,
				tags: ["travel", "international", "essential"],
				baseQuantity: 1,
				isEssential: true,
				priority: .critical,
				conditions: [
					ItemCondition(type: .transport, values: ["plane"], conOperator: .contains, weight: 1.0)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .fixed, minQuantity: 1, maxQuantity: 1)
				],
				alternatives: ["id"],
				seasonality: .yearRound,
				genderSpecific: .unisex
			),
            
			// Basic Clothing
			RegistryPackingItem(
				id: "underwear",
				nameKey: "item_underwear",
				category: .clothing,
				tags: ["clothing", "underwear", "daily", "essential"],
				baseQuantity: 1,
				isEssential: true,
				priority: .essential,
				conditions: [
					ItemCondition(type: .duration, values: ["1"], conOperator: .greaterThan, weight: 1.0)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .perDay, minQuantity: 2, maxQuantity: 10)
				],
				alternatives: [],
				seasonality: .yearRound,
				genderSpecific: .unisex
			),
            
			// Weather-specific items
			RegistryPackingItem(
				id: "sunscreen",
				nameKey: "item_sunscreen",
				category: .toiletries,
				tags: ["sun", "protection", "summer", "beach"],
				baseQuantity: 1,
				isEssential: false,
				priority: .recommended,
				conditions: [
					ItemCondition(type: .climate, values: ["hot", "warm"], conOperator: .contains, weight: 0.9),
					ItemCondition(type: .activity, values: ["beach", "swimming"], conOperator: .contains, weight: 0.8)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .weatherDependent, minQuantity: 1, maxQuantity: 2)
				],
				alternatives: [],
				seasonality: .summer,
				genderSpecific: .unisex
			),
            
			// Business items
			RegistryPackingItem(
				id: "business_suit",
				nameKey: "item_business_suit",
				category: .clothing,
				tags: ["business", "formal", "professional"],
				baseQuantity: 1,
				isEssential: false,
				priority: .essential,
				conditions: [
					ItemCondition(type: .businessTrip, values: ["true"], conOperator: .equals, weight: 1.0),
					ItemCondition(type: .activity, values: ["business"], conOperator: .contains, weight: 0.9)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .conditional, minQuantity: 1, maxQuantity: 3)
				],
				alternatives: ["formal_dress"],
				seasonality: .yearRound,
				genderSpecific: .unisex
			),
            
			// Activity-specific
			RegistryPackingItem(
				id: "hiking_boots",
				nameKey: "item_hiking_boots",
				category: .clothing,
				tags: ["hiking", "outdoor", "footwear", "sports"],
				baseQuantity: 1,
				isEssential: true,
				priority: .critical,
				conditions: [
					ItemCondition(type: .activity, values: ["hiking"], conOperator: .contains, weight: 1.0)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .fixed, minQuantity: 1, maxQuantity: 1)
				],
				alternatives: ["sturdy_shoes"],
				seasonality: .yearRound,
				genderSpecific: .unisex
			),
            
			// Tech essentials
			RegistryPackingItem(
				id: "phone_charger",
				nameKey: "item_phone_charger",
				category: .electronics,
				tags: ["electronics", "essential", "daily", "charging"],
				baseQuantity: 1,
				isEssential: true,
				priority: .critical,
				conditions: [
					ItemCondition(type: .duration, values: ["1"], conOperator: .greaterThan, weight: 1.0)
				],
				quantityRules: [
					QuantityRule(condition: nil, formula: .fixed, minQuantity: 1, maxQuantity: 2)
				],
				alternatives: ["power_bank"],
				seasonality: .yearRound,
				genderSpecific: .unisex
			)
		]
	}
}

// MARK: - Registry Extensions for Localization

extension SmartItemRegistry {
	/// Get localized name for item
	func localizedName(for item: RegistryPackingItem) -> String {
		return NSLocalizedString(item.nameKey, comment: "Packing item: \(item.id)")
	}
    
	/// Get all localized names for debugging
	func getAllLocalizedNames() -> [(id: String, name: String)] {
		return allItems.map { item in
			(item.id, localizedName(for: item))
		}
	}
}

// MARK: - Registry Statistics (for debugging)

extension SmartItemRegistry {
	struct RegistryStats {
		let totalItems: Int
		let itemsByCategory: [ItemCategory: Int]
		let itemsByPriority: [RegistryPackingItem.ItemPriority: Int]
		let essentialItemsCount: Int
		let mostCommonTags: [(tag: String, count: Int)]
	}
    
	func getStats() -> RegistryStats {
		let categoryStats = Dictionary(grouping: allItems) { $0.category }
			.mapValues { $0.count }
        
		let priorityStats = Dictionary(grouping: allItems) { $0.priority }
			.mapValues { $0.count }
        
		let essentialCount = allItems.filter { $0.isEssential }.count
        
		// Count tag usage
		var tagCounts: [String: Int] = [:]
		for item in allItems {
			for tag in item.tags {
				tagCounts[tag, default: 0] += 1
			}
		}
        
		let topTags = tagCounts.sorted { $0.value > $1.value }
			.prefix(10)
			.map { (tag: $0.key, count: $0.value) }
        
		return RegistryStats(
			totalItems: allItems.count,
			itemsByCategory: categoryStats,
			itemsByPriority: priorityStats,
			essentialItemsCount: essentialCount,
			mostCommonTags: topTags
		)
	}
    
	func printStats() {
		let stats = getStats()
		print("\n📊 Smart Item Registry Statistics:")
		print("Total Items: \(stats.totalItems)")
		print("Essential Items: \(stats.essentialItemsCount)")
		print("\nBy Category:")
		for (category, count) in stats.itemsByCategory.sorted(by: { $0.value > $1.value }) {
			print("  \(category.rawValue): \(count)")
		}
		print("\nBy Priority:")
		for (priority, count) in stats.itemsByPriority.sorted(by: { $0.value > $1.value }) {
			print("  \(priority.rawValue): \(count)")
		}
		print("\nTop Tags:")
		for (tag, count) in stats.mostCommonTags {
			print("  \(tag): \(count)")
		}
		print()
	}
}
