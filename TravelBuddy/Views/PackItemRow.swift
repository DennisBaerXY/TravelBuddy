import SwiftUI

struct PackItemRow: View {
	let item: PackItem
	let onUpdate: (PackItem) -> Void
	
	// Animation State
	@State private var offset: CGFloat = 0
	
	var body: some View {
		HStack {
			// Checkbox mit verbesserten Zuständen
			ZStack {
				Circle()
					.stroke(checkboxColor.opacity(0.8), lineWidth: 1.5) // Thinner stroke
					.frame(width: 26, height: 26)
					  
				if item.isPacked {
					Circle()
						.fill(checkboxColor.opacity(0.8)) // Slightly transparent for softness
						.frame(width: 18, height: 18)
						  
					Image(systemName: "checkmark")
						.font(.system(size: 12, weight: .medium)) // Less bold
						.foregroundColor(.white)
				}
			}
			.animation(.easeInOut(duration: 0.4), value: item.isPacked) // Slower, more soothing animation
				  
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					if item.isEssential {
						Image(systemName: "exclamationmark.circle.fill")
							.foregroundColor(.tripBuddyAlert)
							.font(.caption)
					}
					
					Text(item.name)
						.strikethrough(item.isPacked)
						.fontWeight(item.isEssential ? .semibold : .regular)
						.foregroundColor(item.isPacked ? .tripBuddyTextSecondary : .tripBuddyText)
				}
				
				Text(item.category)
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}
			
			Spacer()
			
			if item.quantity > 1 {
				HStack(spacing: 2) {
					Text("×")
						.font(.body)
						.foregroundColor(.tripBuddyTextSecondary)
					
					Text("\(item.quantity)")
						.font(.headline)
						.foregroundColor(.tripBuddyPrimary)
						.padding(4)
						.background(
							RoundedRectangle(cornerRadius: 4)
								.fill(Color.tripBuddyPrimary.opacity(0.1))
						)
				}
			}
		}
		.padding(.vertical, 12) // More padding
		.padding(.horizontal, 16)
		.background(
			RoundedRectangle(cornerRadius: 16) // More rounded
				.fill(backgroundForItem)
		)
		.overlay(
			RoundedRectangle(cornerRadius: 16)
				.stroke(borderForItem, lineWidth: 0.8) // Thinner stroke
		)
		// Add a gentle shadow
		.shadow(color: Color.tripBuddyText.opacity(0.05), radius: 3, x: 0, y: 1)
		.contentShape(Rectangle())
		// Gentle pulse animation when tapped
		.onTapGesture {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
				// Gentler visual effect
				offset = 3
			}
			   
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
				withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
					offset = 0
					   
					let updatedItem = item
					updatedItem.isPacked.toggle()
					onUpdate(updatedItem)
				}
			}
		}
		.offset(x: offset)
	}
	
	// Dynamische Farben basierend auf Status
	var checkboxColor: Color {
		if item.isEssential {
			return item.isPacked ? .tripBuddySuccess : .tripBuddyAlert
		} else {
			return item.isPacked ? .tripBuddySuccess : .tripBuddyPrimary
		}
	}
	
	var backgroundForItem: Color {
		if item.isPacked {
			return Color.tripBuddyBackground
		} else if item.isEssential {
			return Color.tripBuddyAlert.opacity(0.05)
		} else {
			return Color.tripBuddyCard
		}
	}
	
	var borderForItem: Color {
		if item.isPacked {
			return Color.tripBuddyTextSecondary.opacity(0.1)
		} else if item.isEssential {
			return Color.tripBuddyAlert.opacity(0.2)
		} else {
			return Color.tripBuddyTextSecondary.opacity(0.2)
		}
	}
}
