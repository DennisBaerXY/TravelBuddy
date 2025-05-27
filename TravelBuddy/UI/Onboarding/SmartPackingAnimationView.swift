import SwiftUI

struct SmartPackingAnimationView: View {
	@Environment(\.colorScheme) var colorScheme
	@State private var animate = false
	@State private var isItemPacked = [false, false, false, false, false]
	@State private var lidClosed = false
	@State private var showCheckmark = false
	
	// App colors
	private var primaryColor: Color { Color("TripBuddyPrimary") }
	private var successColor: Color { Color("TripBuddySuccess") }
	private var accentColor: Color { Color("TripBuddyAccent") }
	private var alertColor: Color { Color("TripBuddyAlert") }
	private var cardColor: Color { Color("TripBuddyCard") }
	private var textColor: Color { Color("TripBuddyText") }
	
	var body: some View {
		VStack {
			// Simple box with items and lid
			ZStack {
				// Box base
				simpleBox
				
				// Items flying into box
				packingItems
				
				// Completion checkmark
				if showCheckmark {
					Image(systemName: "checkmark.circle.fill")
						.font(.system(size: 40))
						.foregroundColor(successColor)
						.offset(y: -80)
						.transition(.scale.combined(with: .opacity))
				}
			}
		}
		.onAppear {
			withAnimation(.easeIn(duration: 0.5)) {
				animate = true
			}
			startPackingAnimation()
		}
	}
	
	// Simple box design
	private var simpleBox: some View {
		ZStack {
			// Box body - positioned slightly lower to accommodate the lid at top
			Rectangle()
				.fill(cardColor)
				.frame(width: 160, height: 100)
				.overlay(
					Rectangle()
						.stroke(primaryColor.opacity(0.3), lineWidth: 2)
				)
				.offset(y: 10) // Slight offset to position the box lower
			
			// Box interior - slight shade to show depth
			if !lidClosed {
				Rectangle()
					.fill(cardColor.opacity(0.6))
					.frame(width: 140, height: 80)
					.offset(y: 10) // Match box body offset
			}
			
			// Box lid - positioned at the top of the box
			Rectangle()
				.fill(primaryColor.opacity(0.2))
				.frame(width: 160, height: 20)
				.overlay(
					Rectangle()
						.stroke(primaryColor.opacity(0.3), lineWidth: 2)
				)
				.offset(y: lidClosed ? -40 : -100) // Start at -40 (top of box) when closed
				.rotationEffect(
					.degrees(lidClosed ? 0 : -80),
					anchor: .bottom // Rotate from bottom of lid
				)
			
			// Simple handle on lid
			Rectangle()
				.fill(primaryColor)
				.frame(width: 40, height: 6)
				.cornerRadius(3)
				.offset(y: lidClosed ? -50 : -110) // Position on lid
				.rotationEffect(
					.degrees(lidClosed ? 0 : -80),
					anchor: .bottom // Rotate with lid
				)
		}
	}
	
	// Items to be packed
	private var packingItems: some View {
		ZStack {
			// Document (passport)
			PackingItem(
				systemName: "doc.text.fill",
				color: alertColor,
				isPacked: $isItemPacked[0],
				delay: 0.7,
				endPosition: CGPoint(x: -40, y: 20)
			)
			
			// Clothing (shirt)
			PackingItem(
				systemName: "tshirt.fill",
				color: primaryColor,
				isPacked: $isItemPacked[1],
				delay: 1.2,
				endPosition: CGPoint(x: 40, y: 20)
			)
			
			// Electronics (camera)
			PackingItem(
				systemName: "camera.fill",
				color: accentColor,
				isPacked: $isItemPacked[2],
				delay: 1.7,
				endPosition: CGPoint(x: 0, y: 30)
			)
			
			// Toiletries
			PackingItem(
				systemName: "shower.fill",
				color: successColor,
				isPacked: $isItemPacked[3],
				delay: 2.2,
				endPosition: CGPoint(x: -20, y: 0)
			)
			
			// Accessory (sunglasses)
			PackingItem(
				systemName: "eyeglasses",
				color: primaryColor.opacity(0.7),
				isPacked: $isItemPacked[4],
				delay: 2.7,
				endPosition: CGPoint(x: 20, y: 0)
			)
		}
	}
	
	// Start the sequential animation
	private func startPackingAnimation() {
		// Pack items one after another
		for i in 0 ..< isItemPacked.count {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 + Double(i) * 0.5) {
				withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
					isItemPacked[i] = true
				}
			}
		}
		
		// Close lid after packing
		DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
			withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
				lidClosed = true
			}
		}
		
		// Show checkmark after completion
		DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
				showCheckmark = true
			}
		}
	}
}

// Individual packing item that flies into the box
struct PackingItem: View {
	let systemName: String
	let color: Color
	@Binding var isPacked: Bool
	let delay: Double
	let endPosition: CGPoint
	
	@State private var appear = false
	
	var body: some View {
		Image(systemName: systemName)
			.font(.system(size: 28))
			.foregroundColor(color)
			.background(
				Circle()
					.fill(color.opacity(0.15))
					.frame(width: 40, height: 40)
			)
			.offset(
				x: isPacked ? endPosition.x : (endPosition.x > 0 ? 120 : -120),
				y: isPacked ? endPosition.y : -150
			)
			.scaleEffect(appear ? 1 : 0)
			.opacity(appear ? 1 : 0)
			.onAppear {
				withAnimation(.easeOut(duration: 0.5).delay(delay)) {
					appear = true
				}
			}
	}
}

#Preview {
	SmartPackingAnimationView()
		.frame(width: 250, height: 250)
		.background(Color("TripBuddyBackground"))
}
