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
	
	@State private var showingPremiumInfo = false
	@State private var showingResetConfirmation = false
	
	@State private var isShowingError = false
	
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			List {
				// Behavior section
				Section(header: Text("behavior")) {
					behaviorRows
				}
                
				// Support section
				Section(header: Text("support")) {
					supportRows
				}
                
				// About section
				Section(header: Text("about")) {
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
			.foregroundStyle(.tripBuddyText)
			.listStyle(.grouped)
			.scrollContentBackground(.hidden)
			
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
		.alert("Something went wrong", isPresented: $isShowingError) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Please try again later.")
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
		VStack {
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
			#if DEBUG
			
			Button("Reset") {
				UserSettingsManager.shared.isPremiumUser = false
			}
			
			#endif
		}
	}
    
	// MARK: - Appearance Section
    
	/// Rows for appearance settings
	private var appearanceRows: some View {
		Group {
			// Dark mode toggle
			Picker("appearance", selection: $themeManager.colorSchemePreference) {
				ForEach(ColorSchemePreference.allCases, id: \.self) { preference in
					Text(preference.displayName).tag(preference)
				}
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
            
			// Show completed trips
			Toggle("show_completed_trips", isOn: $userSettings.showCompletedTrips)
				.tint(.tripBuddyPrimary)
            
//			// Auto-suggest packing lists
//			Toggle("auto_suggest_packing_lists", isOn: $userSettings.autoSuggestPackingLists)
//				.tint(.tripBuddyPrimary)
		}
	}
    
	// MARK: - Support Section
    
	/// Rows for support options
	private var supportRows: some View {
		Group {
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
				// Share app action
				Task {
					do {
						try await AppTrackingManager.shared.presentPrivacyOptionsForm()
					} catch {
						isShowingError = true
					}
				}
			} label: {
				Label("Privacy Settings", systemImage: "switch.2")
			}
			
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
            
			Text("© 2025 Baer Solutions")
				.font(.caption2)
				.foregroundColor(.secondary)
				.padding(.top, 8)
		}
		.frame(maxWidth: .infinity)
		.padding()
	}
}

// MARK: - Preview

#Preview {
	SettingsView()
		.environmentObject(UserSettingsManager.shared)
		.environmentObject(ThemeManager.shared)
}
