//
//  PackItemRow.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A reusable row component for displaying a packing item
struct PackItemRow: View {
	// MARK: - Properties
		
	let item: PackItem
	let isDisabled: Bool
	let onToggle: (PackItem) -> Void
		
	// Local state for animations
	@State private var animationProgress = 0.0
		
	// MARK: - Body
		
	var body: some View {
		HStack(spacing: 15) {
			itemDetails
			Spacer()
			if item.isEssential {
				Image(systemName: "exclamationmark.triangle.fill")
					.foregroundColor(.tripBuddyAlert)
					.font(.subheadline)
			}
			quantityBadge
			
			itemCheckbox
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 15)
		.background(rowBackground)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.contentShape(Rectangle()) // Make the entire row tappable
		.onTapGesture(perform: toggleItem)
		.allowsHitTesting(!isDisabled)
	}
		
	// MARK: - Computed Views
		
	/// The checkbox component for the item
	private var itemCheckbox: some View {
		ZStack {
			// Outer ring
			Circle()
				.strokeBorder(checkboxColor, lineWidth: 2)
				.frame(width: 26, height: 26)
				.opacity(item.isPacked ? 0.5 : 1)
				
			// Inner fill circle
			Circle()
				.fill(checkboxColor)
				.frame(width: 20, height: 20)
				.scaleEffect(item.isPacked ? 1.0 : 0.01)
				
			// Checkmark
			Image(systemName: "checkmark")
				.font(.system(size: 12, weight: .bold))
				.foregroundColor(.white)
				.scaleEffect(item.isPacked ? 1.0 : 0.5)
				.opacity(item.isPacked ? 1.0 : 0.0)
		}
		.animation(.spring(response: 0.35, dampingFraction: 0.6), value: item.isPacked)
	}
		
	/// The details section showing the item name and category
	private var itemDetails: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(item.name)
				.strikethrough(item.isPacked, color: .tripBuddyTextSecondary)
				.fontWeight(item.isEssential ? .semibold : .regular)
				.foregroundColor(item.isPacked ? .tripBuddyTextSecondary : .tripBuddyText)
				
				.strikethrough(isDisabled == true)
			
			Text(item.categoryEnum.localizedName)
				.font(.caption)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}
		
	/// The quantity badge shown for items with quantity > 1
	@ViewBuilder
	private var quantityBadge: some View {
		if item.quantity > 1 {
			Text("×\(item.quantity)")
				.font(.subheadline.weight(.semibold))
				.padding(.horizontal, 8)
				.padding(.vertical, 4)
				.background(Color.tripBuddyPrimary.opacity(0.1))
				.clipShape(Capsule())
				.foregroundColor(.tripBuddyPrimary)
		}
	}
		
	/// The background for the row, with improved animation when checked
	private var rowBackground: some View {
		ZStack {
			// Base background
			backgroundForItem
				
			// Animated highlight overlay
			if animationProgress > 0 {
				RoundedRectangle(cornerRadius: 16)
					.fill(
						RadialGradient(
							gradient: Gradient(colors: [
								checkboxColor.opacity(0.0),
								checkboxColor.opacity(0.7)
								
							]),
							center: .leading,
							startRadius: 5,
							endRadius: 150
						)
					)
					.opacity(animationProgress)
					.animation(.easeOut(duration: 0.5), value: animationProgress)
			}
		}
	}
		
	// MARK: - Helper Methods
		
	/// Toggles the packed state of the item with animation
	private func toggleItem() {
		guard !isDisabled else { return }
			
		// Prepare for animation if going from unpacked to packed
		let wasUnchecked = !item.isPacked
			
		// Update the item
		var updatedItem = item
		updatedItem.isPacked.toggle()
		onToggle(updatedItem)
			
		// Trigger animation if item was just packed
		if wasUnchecked {
			withAnimation(.easeIn(duration: 0.1)) {
				animationProgress = 1.0
			}
				
			// Fade out the animation gradually
			withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
				animationProgress = 0.0
			}
		}
	}
		
	// MARK: - Computed Properties
		
	/// Determines the appropriate color for the checkbox based on item state
	private var checkboxColor: Color {
		if item.isEssential && !item.isPacked {
			return .tripBuddyAlert
		} else if item.isPacked {
			return .tripBuddySuccess
		} else {
			return .tripBuddyPrimary.opacity(0.8)
		}
	}
		
	/// Determines the appropriate background color for the row based on item state
	private var backgroundForItem: Color {
		if item.isPacked {
			return Color.tripBuddyCard.opacity(0.7)
		
		} else if isDisabled {
			return Color.tripBuddyCard.opacity(0.7)
		} else {
			return Color.tripBuddyCard
		}
	}
}

// MARK: - Preview

#Preview {
	VStack {
		// Regular item
		PackItemRow(
			item: PackItem(name: "T-Shirt", category: .clothing, quantity: 3),
			isDisabled: false
		) { _ in }
			
		// Essential item
		PackItemRow(
			item: PackItem(name: "Passport", category: .documents, isEssential: true),
			isDisabled: false
		) { _ in }
			
		// Packed item
		PackItemRow(
			item: PackItem(name: "Charger", category: .electronics, isPacked: true),
			isDisabled: false
		) { _ in }
		PackItemRow(
			item: PackItem(name: "Passport", category: .documents, isPacked: true, isEssential: true),
			isDisabled: false
		) { _ in }
			
		// Disabled item
		PackItemRow(
			item: PackItem(name: "Sunscreen", category: .toiletries),
			isDisabled: true
		) { _ in }
	}
	.padding()
	.background(Color.tripBuddyBackground)
}
