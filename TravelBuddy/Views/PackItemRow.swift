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
					.stroke(checkboxColor, lineWidth: 2)
					.frame(width: 24, height: 24)
				
				if item.isPacked {
					Circle()
						.fill(checkboxColor)
						.frame(width: 18, height: 18)
					
					Image(systemName: "checkmark")
						.font(.system(size: 12, weight: .bold))
						.foregroundColor(.white)
				}
			}
			
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
		.padding(.vertical, 10)
		.padding(.horizontal, 12)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(backgroundForItem)
		)
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(borderForItem, lineWidth: 1)
		)
		// Die gesamte Zeile klickbar machen
		.contentShape(Rectangle())
		.onTapGesture {
			// Animations-Sequenz beim Abhaken
			withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
				// Kleiner visueller Effekt beim Tippen
				offset = 5
			}
			
			// Kurze Verzögerung für besseres Feedback
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
					offset = 0
					
					// Status umschalten
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
