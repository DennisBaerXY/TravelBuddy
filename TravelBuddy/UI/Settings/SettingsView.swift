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
	@ObservedObject private var localeManager = LocalizationManager.shared
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
				Section(header: Text("account")) { // Was: "Account"
					if userSettings.isPremiumUser {
						premiumAccountRow
					} else {
						getPremiumRow
					}
				}
                
				// Appearance section
				Section(header: Text("appearance")) { // Was: "Appearance"
					appearanceRows
				}
                
				// Behavior section
				Section(header: Text("behavior")) { // Was: "Behavior"
					behaviorRows
				}
                
				// Data section
				Section(header: Text("data")) { // Was: "Data"
					dataRows
				}
                
				// Support section
				Section(header: Text("support")) { // Was: "Support"
					supportRows
				}
                
				// About section
				Section(header: Text("about")) { // Was: "About"
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
				Text("premium_account") // Was: "Premium Account"
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
					Text("get_premium")
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
			Picker("color_theme", selection: $themeManager.colorTheme) {
				ForEach(ColorTheme.allCases) { theme in
					Text(theme.displayName).tag(theme)
				}
			}
            
			// Dark mode toggle
			Picker("appearance", selection: $themeManager.colorSchemePreference) {
				ForEach(ColorSchemePreference.allCases, id: \.self) { preference in
					Text(preference.displayName).tag(preference)
				}
			}
            
			// Language picker
			Button {
				showingLanguagePicker = true
			} label: {
				HStack {
					Text("language") // Was: Sprache
                    
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
			Picker("default_sort", selection: $userSettings.defaultSortOption) {
				ForEach(SortOption.allCases) { option in
					Text(option.displayName()).tag(option)
				}
			}
            
			Picker("sort_order", selection: $userSettings.defaultSortOrder) {
				Text(SortOrder.ascending.displayName()).tag(SortOrder.ascending)
				Text(SortOrder.descending.displayName()).tag(SortOrder.descending)
			}
            
			// Essential items priority
			Toggle("prioritize_essential_items", isOn: $userSettings.prioritizeEssentialItems)
				.tint(.tripBuddyPrimary)
            
			// Show completed trips
			Toggle("show_completed_trips", isOn: $userSettings.showCompletedTrips)
				.tint(.tripBuddyPrimary)
            
			// Auto-suggest packing lists
			Toggle("auto_suggest_packing_lists", isOn: $userSettings.autoSuggestPackingLists)
				.tint(.tripBuddyPrimary)
            
			// Measurement system
			Picker("measurement_system", selection: $userSettings.preferredMeasurementSystem) {
				Text("metric").tag(MeasurementSystem.metric)
				Text("imperial").tag(MeasurementSystem.imperial)
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
		.environmentObject(UserSettingsManager.shared)
		.environmentObject(ThemeManager.shared)
}
