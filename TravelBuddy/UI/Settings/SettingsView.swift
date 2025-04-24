//
//  SettingsView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A view for configuring app settings and preferences
struct SettingsView: View {
	// MARK: - Environment
    
	@Environment(\.dismiss) private var dismiss
	@Environment(\.colorScheme) private var colorScheme
    
	// MARK: - State
    
	@ObservedObject private var userSettings = UserSettingsManager.shared
	@ObservedObject private var themeManager = ThemeManager.shared
	@State private var showingThemePicker = false
	@State private var showingLanguagePicker = false
	@State private var showingHelpCenter = false
	@State private var showingPremiumInfo = false
	@State private var showingResetConfirmation = false
    
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			List {
				// Account section
				Section(header: Text("Account")) {
					if userSettings.isPremiumUser {
						premiumAccountRow
					} else {
						getPremiumRow
					}
				}
                
				// Appearance section
				Section(header: Text("Appearance")) {
					appearanceRows
				}
                
				// Behavior section
				Section(header: Text("Behavior")) {
					behaviorRows
				}
                
				// Data section
				Section(header: Text("Data")) {
					dataRows
				}
                
				// Support section
				Section(header: Text("Support")) {
					supportRows
				}
                
				// About section
				Section(header: Text("About")) {
					aboutRows
				}
                
				// Development section (Hidden in production)
				if AppConstants.enableDebugLogging {
					Section(header: Text("Development")) {
						developmentRows
					}
				}
                
				// App information
				appInfoFooter
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
		.sheet(isPresented: $showingHelpCenter) {
			HelpCenterView()
		}
		.sheet(isPresented: $showingPremiumInfo) {
			PremiumInfoView()
		}
		.alert("Reset All Settings?", isPresented: $showingResetConfirmation) {
			Button("Cancel", role: .cancel) {}
			Button("Reset", role: .destructive) {
				userSettings.resetAllSettings()
			}
		} message: {
			Text("This will reset all settings to their default values. This action cannot be undone.")
		}
	}
    
	// MARK: - Account Section
    
	/// Row showing premium status
	private var premiumAccountRow: some View {
		HStack {
			Label {
				Text("Premium Account")
			} icon: {
				Image(systemName: "star.fill")
					.foregroundColor(.yellow)
			}
            
			Spacer()
            
			Text("Active")
				.font(.caption)
				.foregroundColor(.tripBuddySuccess)
		}
	}
    
	/// Row for upgrading to premium
	private var getPremiumRow: some View {
		Button {
			showingPremiumInfo = true
		} label: {
			HStack {
				Label {
					Text("Get Premium")
				} icon: {
					Image(systemName: "star.fill")
						.foregroundColor(.yellow)
				}
                
				Spacer()
                
				Image(systemName: "chevron.right")
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
	}
    
	// MARK: - Appearance Section
    
	/// Rows for appearance settings
	private var appearanceRows: some View {
		Group {
			// Theme picker
			Picker("Color Theme", selection: $themeManager.colorTheme) {
				ForEach(ColorTheme.allCases) { theme in
					Text(theme.displayName).tag(theme)
				}
			}
            
			// Dark mode toggle
			Picker("Appearance", selection: $themeManager.colorSchemePreference) {
				ForEach(ColorSchemePreference.allCases, id: \.self) { preference in
					Text(preference.displayName).tag(preference)
				}
			}
            
			// Language picker
			Button {
				showingLanguagePicker = true
			} label: {
				HStack {
					Text("Language")
                    
					Spacer()
                    
					Text(LocalizationManager.shared.currentLanguage.displayName)
						.foregroundColor(.secondary)
                    
					Image(systemName: "chevron.right")
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			.sheet(isPresented: $showingLanguagePicker) {
				LanguagePickerView()
			}
		}
	}
    
	// MARK: - Behavior Section
    
	/// Rows for behavior settings
	private var behaviorRows: some View {
		Group {
			// Sort preferences
			Picker("Default Sort", selection: $userSettings.defaultSortOption) {
				ForEach(SortOption.allCases) { option in
					Text(option.localizedName).tag(option)
				}
			}
            
			Picker("Sort Order", selection: $userSettings.defaultSortOrder) {
				Text("Ascending").tag(SortOrder.ascending)
				Text("Descending").tag(SortOrder.descending)
			}
            
			// Essential items priority
			Toggle("Prioritize Essential Items", isOn: $userSettings.prioritizeEssentialItems)
				.tint(.tripBuddyPrimary)
            
			// Show completed trips
			Toggle("Show Completed Trips", isOn: $userSettings.showCompletedTrips)
				.tint(.tripBuddyPrimary)
            
			// Auto-suggest packing lists
			Toggle("Auto-suggest Packing Lists", isOn: $userSettings.autoSuggestPackingLists)
				.tint(.tripBuddyPrimary)
            
			// Measurement system
			Picker("Measurement System", selection: $userSettings.preferredMeasurementSystem) {
				Text("Metric").tag(MeasurementSystem.metric)
				Text("Imperial").tag(MeasurementSystem.imperial)
			}
		}
	}
    
	// MARK: - Data Section
    
	/// Rows for data settings
	private var dataRows: some View {
		Group {
			Button {
				// Backup data action
				print("Backup data tapped")
			} label: {
				Label("Backup Data", systemImage: "arrow.up.doc")
			}
            
			Button {
				// Restore data action
				print("Restore data tapped")
			} label: {
				Label("Restore from Backup", systemImage: "arrow.down.doc")
			}
            
			Button {
				// Export data action
				print("Export data tapped")
			} label: {
				Label("Export Data", systemImage: "square.and.arrow.up")
			}
		}
	}
    
	// MARK: - Support Section
    
	/// Rows for support options
	private var supportRows: some View {
		Group {
			Button {
				showingHelpCenter = true
			} label: {
				Label("Help Center", systemImage: "questionmark.circle")
			}
            
			Button {
				// Contact support action
				print("Contact support tapped")
			} label: {
				Label("Contact Support", systemImage: "envelope")
			}
            
			Button {
				// Rate app action
				print("Rate app tapped")
			} label: {
				Label("Rate TravelBuddy", systemImage: "star")
			}
            
			Button {
				// Share app action
				print("Share app tapped")
			} label: {
				Label("Share TravelBuddy", systemImage: "square.and.arrow.up")
			}
		}
	}
    
	// MARK: - About Section
    
	/// Rows for about information
	private var aboutRows: some View {
		Group {
			Button {
				// Privacy policy action
				print("Privacy policy tapped")
			} label: {
				Label("Privacy Policy", systemImage: "hand.raised")
			}
            
			Button {
				// Terms of service action
				print("Terms tapped")
			} label: {
				Label("Terms of Service", systemImage: "doc.text")
			}
            
			Button {
				// Acknowledgements action
				print("Acknowledgements tapped")
			} label: {
				Label("Acknowledgements", systemImage: "text.book.closed")
			}
		}
	}
    
	// MARK: - Development Section
    
	/// Rows for development options (hidden in production)
	private var developmentRows: some View {
		Group {
			Button {
				// Reset onboarding for testing
				userSettings.resetOnboarding()
			} label: {
				Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
					.foregroundColor(.orange)
			}
            
			Button {
				showingResetConfirmation = true
			} label: {
				Label("Reset All Settings", systemImage: "trash")
					.foregroundColor(.red)
			}
            
			Toggle("Show Debug Logs", isOn: .constant(AppConstants.enableDebugLogging))
				.disabled(true)
				.tint(.tripBuddyPrimary)
		}
	}
    
	// MARK: - App Info Footer
    
	/// Footer showing app version information
	private var appInfoFooter: some View {
		VStack(spacing: 4) {
			Text("TravelBuddy")
				.font(.headline)
            
			Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
				.font(.caption)
				.foregroundColor(.secondary)
            
			Text("© 2025 Dennis DevLops")
				.font(.caption2)
				.foregroundColor(.secondary)
				.padding(.top, 8)
		}
		.frame(maxWidth: .infinity)
		.padding()
	}
}

// MARK: - Language Picker View

/// A view for selecting the app language
struct LanguagePickerView: View {
	// MARK: - Environment
    
	@Environment(\.dismiss) private var dismiss
    
	// MARK: - State
    
	@State private var selectedLanguage = LocalizationManager.shared.currentLanguage
    
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			List {
				ForEach(AppLanguage.allCases, id: \.self) { language in
					Button {
						selectedLanguage = language
						LocalizationManager.shared.setLanguage(language)
						dismiss()
					} label: {
						HStack {
							Text("\(language.flag) \(language.displayName)")
								.foregroundColor(.primary)
                            
							Spacer()
                            
							if language == selectedLanguage {
								Image(systemName: "checkmark")
									.foregroundColor(.tripBuddyPrimary)
							}
						}
					}
				}
			}
			.navigationTitle("Select Language")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
		}
	}
}

// MARK: - Premium Info View

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

// MARK: - Premium Plan

/// Available premium subscription plans
enum PremiumPlan {
	case monthly
	case yearly
    
	/// Display name for the plan
	var displayName: String {
		switch self {
		case .monthly: return "Monthly"
		case .yearly: return "Yearly"
		}
	}
}

// MARK: - Preview

#Preview {
	SettingsView()
}
