//
//  CollapsibleCategorySection.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A collapsible section for a category of packing items
struct CollapsibleCategorySection: View {
	// MARK: - Properties
    
	let category: ItemCategory
	let items: [PackItem]
	let isTripCompleted: Bool
	let onUpdate: (PackItem) -> Void
	let onDelete: (PackItem) -> Void
    
	@State private var isExpanded: Bool
    
	// MARK: - Initialization
    
	init(
		category: ItemCategory,
		items: [PackItem],
		isInitiallyExpanded: Bool = true,
		isTripCompleted: Bool,
		onUpdate: @escaping (PackItem) -> Void,
		onDelete: @escaping (PackItem) -> Void
	) {
		self.category = category
		self.items = items
		self.isTripCompleted = isTripCompleted
		self.onUpdate = onUpdate
		self.onDelete = onDelete
		self._isExpanded = State(initialValue: isInitiallyExpanded)
	}
    
	// MARK: - Body
    
	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			itemsList
		} label: {
			sectionHeader
		}
		.padding(.horizontal)
		.tint(.tripBuddyAccent)
	}
    
	// MARK: - UI Components
    
	/// The list of items in this category
	private var itemsList: some View {
		LazyVStack(spacing: 10) {
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
				.transition(.opacity.combined(with: .move(edge: .top)))
			}
		}
		.padding(.top, 5)
	}
    
	/// The header for the section with category icon, name, and count
	private var sectionHeader: some View {
		HStack {
			Image(systemName: category.iconName)
				.foregroundColor(.tripBuddyPrimary)
            
			Text(category.localizedName)
				.font(.headline)
				.foregroundColor(.tripBuddyText)
            
			Spacer()
            
			// Item count badge
			Text("\(items.count)")
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
	let items: [PackItem] = [
		PackItem(name: "T-Shirt", category: .clothing, quantity: 3),
		PackItem(name: "Jeans", category: .clothing),
		PackItem(name: "Socks", category: .clothing, quantity: 5)
	]
    
	VStack {
		CollapsibleCategorySection(
			category: .clothing,
			items: items,
			isInitiallyExpanded: true,
			isTripCompleted: false,
			onUpdate: { _ in },
			onDelete: { _ in }
		)
        
		CollapsibleCategorySection(
			category: .clothing,
			items: items,
			isInitiallyExpanded: false,
			isTripCompleted: true,
			onUpdate: { _ in },
			onDelete: { _ in }
		)
	}
	.padding()
	.background(Color.tripBuddyBackground)
}
