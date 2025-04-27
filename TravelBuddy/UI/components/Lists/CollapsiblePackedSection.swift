//
//  CollapsiblePackedSection.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A collapsible section for already packed items, grouped by categories
struct CollapsiblePackedSection: View {
	// MARK: - Properties
    
	let categories: [ItemCategory]
	let groupedPackedItems: [ItemCategory: [PackItem]]
	let isTripCompleted: Bool
	let onUpdate: (PackItem) -> Void
	let onDelete: (PackItem) -> Void
    
	@State private var isExpanded: Bool
    
	// MARK: - Initialization
    
	init(
		categories: [ItemCategory],
		groupedPackedItems: [ItemCategory: [PackItem]],
		isTripCompleted: Bool,
		onUpdate: @escaping (PackItem) -> Void,
		onDelete: @escaping (PackItem) -> Void,
		isExpanded: Bool = false
	) {
		self.categories = categories
		self.groupedPackedItems = groupedPackedItems
		self.isTripCompleted = isTripCompleted
		self.onUpdate = onUpdate
		self.onDelete = onDelete
		self._isExpanded = State(initialValue: isExpanded)
	}
    
	// MARK: - Computed Properties
    
	/// Total count of all packed items
	private var totalPackedCount: Int {
		groupedPackedItems.reduce(0) { $0 + $1.value.count }
	}
    
	// MARK: - Body
    
	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			packedItemsList
		} label: {
			sectionHeader
		}
		.padding(.horizontal)
		.tint(.tripBuddyAccent)
	}
    
	// MARK: - UI Components
    
	/// List of packed items grouped by category
	private var packedItemsList: some View {
		LazyVStack(alignment: .leading, spacing: 10) {
			ForEach(categories, id: \.self) { category in
				if let items = groupedPackedItems[category], !items.isEmpty {
					ForEach(items) { item in
						PackItemRow(
							item: item,
							isDisabled: isTripCompleted,
							onToggle: onUpdate
						)
						.padding(.horizontal)
						
						.contextMenu {
							if !isTripCompleted {
								Button(role: .destructive) {
									onDelete(item)
								} label: {
									Label("delete", systemImage: "trash")
								}
							}
						}
						.transition(.opacity.combined(with: .move(edge: .bottom)))
					}
				}
			}
		}
		.padding(.top, 5)
	}
    
	/// Header for a category within the packed items section
	private func categorySection(_ category: ItemCategory, items: [PackItem]) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			// Optional: Mini-header for the category
			HStack {
				Image(systemName: category.iconName)
					.foregroundColor(.tripBuddyTextSecondary)
                
				Text(category.displayName())
					.font(.footnote.weight(.medium))
					.foregroundColor(.tripBuddyTextSecondary)
			}
			.padding(.leading, 8)
			.padding(.top, 4)
            
			// Items in this category
		}
	}
    
	/// Header for the entire packed items section
	private var sectionHeader: some View {
		HStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.tripBuddySuccess)
            
			Text("already_packed_section_header")
				.font(.headline)
				.foregroundColor(.tripBuddyTextSecondary)
            
			Spacer()
            
			// Count badge
			Text("\(totalPackedCount)")
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
				.padding(.horizontal, 8)
				.background(Capsule().fill(Color.tripBuddyTextSecondary.opacity(0.1)))
		}
		.padding(.vertical, 5)
	}
}

// MARK: - Preview

#Preview {
	// Sample data for preview
	let categories: [ItemCategory] = [.clothing, .electronics, .toiletries]
	
	let clothingItems: [PackItem] = [
		PackItem(name: "T-Shirt", category: .clothing, isPacked: true, quantity: 3),
		PackItem(name: "Jeans", category: .clothing, isPacked: true)
	]
	
	let electronicsItems: [PackItem] = [
		PackItem(name: "Charger", category: .electronics, isPacked: true),
		PackItem(name: "Headphones", category: .electronics, isPacked: true)
	]
	
	let groupedItems: [ItemCategory: [PackItem]] = [
		.clothing: clothingItems,
		.electronics: electronicsItems
	]
	
	return VStack {
		CollapsiblePackedSection(
			categories: categories,
			groupedPackedItems: groupedItems,
			isTripCompleted: false,
			onUpdate: { _ in },
			onDelete: { _ in },
			isExpanded: true
		)
	}
	.padding()
	.background(Color.tripBuddyBackground)
}
