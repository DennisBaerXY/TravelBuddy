import SwiftUI

/// A view showing information about premium features
struct PremiumInfoView: View {
	// MARK: - Environment
    
	@Environment(\.dismiss) private var dismiss
    
	// MARK: - State
    
	@State private var selectedPlan: PremiumPlan = .monthly
    
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 30) {
					// Premium badge
					VStack {
						Image(systemName: "star.circle.fill")
							.font(.system(size: 80))
							.foregroundColor(.yellow)
                        
						Text("TravelBuddy Premium")
							.font(.title)
							.fontWeight(.bold)
					}
					.padding(.top, 20)
                    
					// Feature list
					VStack(alignment: .leading, spacing: 16) {
						premiumFeatureRow(icon: "infinity", title: "Unlimited Trips", description: "Create as many trips as you want")
						premiumFeatureRow(icon: "list.bullet.clipboard", title: "Advanced Packing Lists", description: "Get smarter, more personalized suggestions")
						premiumFeatureRow(icon: "square.grid.2x2", title: "Trip Templates", description: "Save and reuse your favorite trip setups")
						premiumFeatureRow(icon: "person.2.fill", title: "Trip Sharing", description: "Collaborate on trips with family and friends")
						premiumFeatureRow(icon: "rectangle.stack.badge.minus", title: "No Ads", description: "Enjoy a clean, ad-free experience")
					}
					.padding(.horizontal)
                    
					// Plan selection
					VStack(spacing: 12) {
						Text("Choose a Plan")
							.font(.headline)
                        
						HStack(spacing: 20) {
							planButton(plan: .monthly, price: "$2.99/month")
							planButton(plan: .yearly, price: "$24.99/year", savings: "Save 30%")
						}
					}
                    
					// Subscribe button
					Button {
						// Subscribe action
						UserSettingsManager.shared.isPremiumUser = true
						dismiss()
					} label: {
						Text("Subscribe Now")
							.font(.headline)
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.padding()
							.background(Color.tripBuddyPrimary)
							.cornerRadius(10)
					}
					.padding(.horizontal)
                    
					// Terms and restore buttons
					HStack {
						Button("Terms of Use") {
							// Show terms action
						}
                        
						Spacer()
                        
						Button("Restore Purchases") {
							// Restore purchases action
						}
					}
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
					.padding(.horizontal)
				}
				.padding(.bottom, 30)
			}
			.navigationTitle("Premium")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
	}
    
	// MARK: - UI Components
    
	/// Creates a premium feature row
	/// - Parameters:
	///   - icon: The icon name
	///   - title: The feature title
	///   - description: The feature description
	/// - Returns: A view representing the feature
	private func premiumFeatureRow(icon: String, title: String, description: String) -> some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: icon)
				.font(.title2)
				.foregroundColor(.yellow)
				.frame(width: 30)
            
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.headline)
                
				Text(description)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
	}
    
	/// Creates a plan selection button
	/// - Parameters:
	///   - plan: The premium plan
	///   - price: The price string
	///   - savings: Optional savings text
	/// - Returns: A view representing the plan button
	private func planButton(plan: PremiumPlan, price: String, savings: String? = nil) -> some View {
		Button {
			selectedPlan = plan
		} label: {
			VStack(spacing: 8) {
				Text(plan.displayName)
					.font(.headline)
                
				Text(price)
					.font(.subheadline)
                
				if let savings = savings {
					Text(savings)
						.font(.caption)
						.foregroundColor(.green)
				}
			}
			.padding()
			.frame(maxWidth: .infinity)
			.background(selectedPlan == plan ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
			.cornerRadius(10)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(selectedPlan == plan ? Color.yellow : Color.clear, lineWidth: 2)
			)
		}
		.buttonStyle(.plain)
	}
}