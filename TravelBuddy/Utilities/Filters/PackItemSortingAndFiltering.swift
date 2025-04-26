//
//  PackItemSortingAndFiltering.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 26.04.25.
//

import Foundation

/// A helper struct for sorting and filtering PackItem arrays.
struct PackItemSortingAndFiltering {
	/// Filters and sorts an array of PackItem based on the provided criteria.
	/// - Parameters:
	///   - items: The array of PackItem to filter and sort.
	///   - searchText: The text to filter items by name.
	///   - selectedCategoryFilter: The category to filter items by.
	///   - sortOption: The primary sort option.
	///   - sortOrder: The sort order (ascending or descending).
	///   - prioritizeEssential: A boolean indicating whether essential items should be prioritized.
	/// - Returns: A filtered and sorted array of PackItem.
	static func applySortingAndFiltering(
		items: [PackItem]?,
		searchText: String,
		selectedCategoryFilter: ItemCategory?,
		sortOption: SortOption,
		sortOrder: SortOrder,
		prioritizeEssential: Bool
	) -> [PackItem] {
		guard let items = items else { return [] }

		// Apply priority sorting (essential items first)
		let sortedByPriority = items.sorted {
			if prioritizeEssential {
				if $0.isEssential != $1.isEssential {
					return $0.isEssential && !$1.isEssential // Essential comes before non-essential
				}
			}
			return false // Maintain original order if priority is the same or not prioritized
		}

		// Apply filtering
		let filtered = sortedByPriority.filter { item in
			let matchesSearch = searchText.isEmpty ||
				item.name.localizedStandardContains(searchText)
			let matchesCategory = selectedCategoryFilter == nil ||
				item.categoryEnum == selectedCategoryFilter
			return matchesSearch && matchesCategory
		}

		// Apply final sorting based on selected option and order
		return filtered.sorted { item1, item2 in
			let orderMultiplier: Int = (sortOrder == .ascending) ? 1 : -1

			switch sortOption {
			case .name:
				let comparison = item1.name.localizedStandardCompare(item2.name)
				return comparison.rawValue * orderMultiplier < 0
			case .category:
				// Sort by category name first
				let categoryComparison = item1.categoryEnum.localizedName.localizedStandardCompare(item2.categoryEnum.localizedName)
				if categoryComparison != .orderedSame {
					return categoryComparison.rawValue * orderMultiplier < 0
				} else {
					// If categories are the same, sort by item name
					let nameComparison = item1.name.localizedStandardCompare(item2.name)
					return nameComparison.rawValue * orderMultiplier < 0
				}
			case .essential:
				// Essential items first (already done by prioritizeEssential, but included here for completeness if not prioritized initially)
				if item1.isEssential != item2.isEssential {
					return (sortOrder == .ascending) ? (item1.isEssential && !item2.isEssential) : (!item1.isEssential && item2.isEssential)
				} else {
					// If essential status is the same, sort by name
					let nameComparison = item1.name.localizedStandardCompare(item2.name)
					return nameComparison.rawValue * orderMultiplier < 0
				}
			case .dateAdded:
				let comparison = item1.modificationDate.compare(item2.modificationDate)
				return comparison.rawValue * orderMultiplier < 0
			}
		}
	}

	/// Sorts an array of ItemCategory by localized name.
	/// - Parameters:
	///   - categories: The array of ItemCategory to sort.
	///   - sortOrder: The sort order (ascending or descending).
	/// - Returns: A sorted array of ItemCategory.
	static func sortCategoriesByName(
		categories: [ItemCategory],
		sortOrder: SortOrder
	) -> [ItemCategory] {
		categories.sorted { cat1, cat2 in
			let comparison = cat1.localizedName.localizedStandardCompare(cat2.localizedName)
			return (sortOrder == .ascending) ? comparison == .orderedAscending : comparison == .orderedDescending
		}
	}
}
