import SwiftUI

struct OrganizeAnimationView: View {
	@Environment(\.colorScheme) var colorScheme
	@State private var animate = false
	@State private var itemChecked = [false, false, false, false]
	
	// Define colors based on your asset catalog names
	private var primaryColor: Color { Color("TripBuddyPrimary") }
	private var accentColor: Color { Color("TripBuddyAccent") }
	private var successColor: Color { Color("TripBuddySuccess") }
	private var cardColor: Color { Color("TripBuddyCard") }
	private var textColor: Color { Color("TripBuddyText") }
	
	var body: some View {
		ZStack {
			// Background container - wider to match app style
			RoundedRectangle(cornerRadius: 16)
				.fill(cardColor)
				
				.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
			
			// App-like organization list
			VStack(spacing: 0) {
				// Header
				HStack {
					Image(systemName: "list.bullet")
						.foregroundColor(primaryColor)
						.font(.system(size: 18, weight: .semibold))
					
					Text("Rome")
						.font(.system(size: 18, weight: .semibold))
						.foregroundColor(textColor)
					
					Spacer()
				}
				.padding(.horizontal, 20)
				
				.padding(.bottom, 10)
				.opacity(animate ? 1 : 0)
		
				.animation(.easeOut(duration: 0.4), value: animate)
				
				// Divider
				Rectangle()
					.fill(Color.gray.opacity(0.2))
					.frame(height: 1)
					.padding(.horizontal, 10)
					.opacity(animate ? 1 : 0)
					.animation(.easeOut(duration: 0.4).delay(0.1), value: animate)
				
				// Trip list items
				VStack(spacing: 12) {
					// Trip 1
					ListItem(
						title: "Passport",
						important: true, isChecked: $itemChecked[0],
						
						animationDelay: 0.3
					)
					
					// Trip 2
					ListItem(
						title: "T-Shirts",
						important: false,
					
						isChecked: $itemChecked[1],
						animationDelay: 0.5
					)
					
					// Trip 3
					ListItem(
						title: "Shoes",
						important: false,
		
						isChecked: $itemChecked[2],
						animationDelay: 0.7
					)
				}.padding(.top, 10)
				
				Spacer()
			}
			.padding()
		}
		.onAppear {
			animate = true
			startCheckingAnimation()
		}
		.onDisappear {
			animate = false
			itemChecked = [false, false, false, false]
		}
	}
	
	// Start the animation to check items sequentially
	private func startCheckingAnimation() {
		// Check items one after another
		for i in 0 ..< itemChecked.count {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(i) * 0.5) {
				withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
					itemChecked[i] = true
				}
			}
		}
	}
}

// List item component
struct ListItem: View {
	let title: String
	let important: Bool

	@Binding var isChecked: Bool
	let animationDelay: Double
	
	@State private var appear = false
	
	var body: some View {
		HStack {
			// Icon
		
			// Text
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.system(size: 16, weight: .medium))
					.foregroundColor(Color("TripBuddyText"))
			}
			
			Spacer()
			if important {
				Image(systemName: "exclamationmark.triangle.fill")
					.foregroundColor(.tripBuddyAlert)
					.font(.subheadline)
			}
			
			// Checkmark on right side
			ZStack {
				Circle()
					.stroke(isChecked ? Color("TripBuddySuccess") : Color.gray.opacity(0.3), lineWidth: 2)
					.frame(width: 24, height: 24)
				
				if isChecked {
					Circle()
						.fill(Color("TripBuddySuccess"))
						.frame(width: 18, height: 18)
					
					Image(systemName: "checkmark")
						.font(.system(size: 12, weight: .bold))
						.foregroundColor(.white)
				}
			}
		}
		.padding(.horizontal, 20)
		.padding(.vertical, 8)
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(isChecked ? Color("TripBuddySuccess").opacity(0.08) : Color.clear)
		)
		.opacity(appear ? 1 : 0)
		.offset(x: appear ? 0 : -20)
		.animation(.easeOut(duration: 0.5).delay(animationDelay), value: appear)
		.onAppear {
			appear = true
		}
	}
}

#Preview {
	OrganizeAnimationView()
		.frame(width: 300, height: 300)
		.padding()
		.background(Color("TripBuddyBackground"))
}
