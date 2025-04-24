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
    @State private var backgroundFlash = false
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 15) {
            itemCheckbox
            itemDetails
            Spacer()
            quantityBadge
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
            HStack {
                if item.isEssential {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.tripBuddyAlert)
                        .font(.caption)
                }
                
                Text(item.name)
                    .strikethrough(item.isPacked, color: .tripBuddyTextSecondary)
                    .fontWeight(item.isEssential ? .semibold : .regular)
                    .foregroundColor(item.isPacked ? .tripBuddyTextSecondary : .tripBuddyText)
            }
            
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
    
    /// The background for the row, with flash animation when checked
    private var rowBackground: some View {
        ZStack {
            // Base background
            backgroundForItem
            
            // Flash overlay
            RoundedRectangle(cornerRadius: 16)
                .fill(checkboxColor.opacity(0.2))
                .scaleEffect(backgroundFlash ? 1.0 : 0.8)
                .opacity(backgroundFlash ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: backgroundFlash)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Toggles the packed state of the item with animation
    private func toggleItem() {
        guard !isDisabled else { return }
        
        // Prepare for flash animation if going from unpacked to packed
        let wasUnchecked = !item.isPacked
        
        // Update the item
        var updatedItem = item
        updatedItem.isPacked.toggle()
        onToggle(updatedItem)
        
        // Trigger flash animation if item was just packed
        if wasUnchecked {
            backgroundFlash = true
            
            // Reset the flash state after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                backgroundFlash = false
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
        } else if item.isEssential {
            return Color.tripBuddyAlert.opacity(0.05)
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
        
        // Disabled item
        PackItemRow(
            item: PackItem(name: "Sunscreen", category: .toiletries),
            isDisabled: true
        ) { _ in }
    }
    .padding()
    .background(Color.tripBuddyBackground)
}