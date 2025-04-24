//
//  HelpCenterView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A view showing help content and tutorials for the app
struct HelpCenterView: View {
	// MARK: - Environment
    
	@Environment(\.dismiss) private var dismiss
    
	// MARK: - State
    
	/// The selected help category
	@State private var selectedCategory: HelpCategory = .gettingStarted
    
	/// Whether a help article is currently expanded
	@State private var expandedArticleId: String?
    
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Category tabs
				categoryTabs
                
				// Divider below tabs
				Divider()
                
				// Content for the selected category
				ScrollView {
					VStack(alignment: .leading, spacing: 20) {
						switch selectedCategory {
						case .gettingStarted:
							gettingStartedContent
						case .packingLists:
							packingListsContent
						case .tripPlanning:
							tripPlanningContent
						case .settings:
							settingsContent
						case .troubleshooting:
							troubleshootingContent
						}
					}
					.padding()
				}
			}
			.navigationTitle("Help Center")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
			.background(Color.tripBuddyBackground)
		}
	}
    
	// MARK: - UI Components
    
	/// Horizontal tabs for selecting a help category
	private var categoryTabs: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 0) {
				ForEach(HelpCategory.allCases) { category in
					Button {
						withAnimation {
							selectedCategory = category
						}
					} label: {
						VStack(spacing: 8) {
							Image(systemName: category.iconName)
								.font(.headline)
                            
							Text(category.displayName)
								.font(.caption)
						}
						.padding(.vertical, 12)
						.padding(.horizontal, 16)
						.foregroundColor(selectedCategory == category ? .tripBuddyPrimary : .tripBuddyTextSecondary)
						.background(
							Rectangle()
								.fill(Color.clear)
								.overlay(
									Rectangle()
										.frame(height: 3)
										.foregroundColor(selectedCategory == category ? .tripBuddyPrimary : .clear),
									alignment: .bottom
								)
						)
					}
					.buttonStyle(.plain)
				}
			}
			.padding(.horizontal)
		}
	}
    
	/// Help content for the "Getting Started" category
	private var gettingStartedContent: some View {
		VStack(alignment: .leading, spacing: 20) {
			helpArticle(
				id: "welcome",
				title: "Welcome to TravelBuddy",
				content: """
				TravelBuddy is your ultimate travel companion app that helps you organize your trips and packing lists.
				
				With TravelBuddy, you can:
				• Create and organize your trips
				• Generate smart packing lists
				• Keep track of your packing progress
				• Never forget important items again
				
				This help center will guide you through all the features of the app and answer common questions.
				"""
			)
            
			helpArticle(
				id: "create-trip",
				title: "How to Create Your First Trip",
				content: """
				Creating a new trip in TravelBuddy is simple:
				
				1. From the main screen, tap the plus (+) button in the bottom right corner
				2. Enter a name for your trip and destination
				3. Select the travel dates
				4. Choose your transportation method and accommodation
				5. Select activities and other details
				6. Tap "Create Packing List" to finish
				
				TravelBuddy will automatically generate a packing list based on your selections!
				"""
			)
            
			helpArticle(
				id: "ui-navigation",
				title: "Navigating the App",
				content: """
				TravelBuddy has a simple, intuitive interface:
				
				• My Trips: The main screen showing all your trips
				• Trip Details: Tap on a trip to view and manage its packing list
				• Settings: Access app preferences and account settings
				
				Swipe gestures and intuitive icons make navigation easy!
				"""
			)
            
			tutorialCard(
				title: "Video Tutorial: Getting Started",
				description: "Watch this short video to learn the basics of TravelBuddy",
				buttonText: "Watch Video"
			)
		}
	}
    
	/// Help content for the "Packing Lists" category
	private var packingListsContent: some View {
		VStack(alignment: .leading, spacing: 20) {
			helpArticle(
				id: "manage-items",
				title: "Managing Your Packing Items",
				content: """
				Your packing list is divided into categories for easy organization:
				
				• Tap an item to mark it as packed
				• Swipe left on an item to delete it
				• Tap the + button to add a new item
				• Use the filter buttons to view specific categories
				
				The progress bar at the top shows your packing progress.
				"""
			)
            
			helpArticle(
				id: "essential-items",
				title: "Essential Items",
				content: """
				Essential items are marked with a warning icon and are particularly important for your trip.
				
				TravelBuddy automatically marks certain items as essential based on your trip details, such as:
				• Travel documents for international trips
				• Weather-appropriate clothing
				• Transportation tickets and booking confirmations
				
				You can also mark any item as essential yourself when adding or editing it.
				"""
			)
            
			helpArticle(
				id: "sorting-filtering",
				title: "Sorting and Filtering",
				content: """
				TravelBuddy offers several ways to organize your packing list:
				
				• Sort by name, category, or essential status
				• Filter by category using the buttons at the top
				• Search for specific items using the search bar
				
				Packed items automatically move to the "Already Packed" section at the bottom.
				"""
			)
		}
	}
    
	/// Help content for the "Trip Planning" category
	private var tripPlanningContent: some View {
		VStack(alignment: .leading, spacing: 20) {
			helpArticle(
				id: "trip-details",
				title: "Managing Trip Details",
				content: """
				TravelBuddy uses your trip details to generate a customized packing list:
				
				• Transportation: Different items for plane, car, train, etc.
				• Accommodation: Items specific to hotels, camping, etc.
				• Activities: Gear for swimming, hiking, business meetings, etc.
				• Climate: Weather-appropriate clothing and accessories
				
				The more details you provide, the more accurate your packing list will be!
				"""
			)
            
			helpArticle(
				id: "edit-trip",
				title: "Editing a Trip",
				content: """
				You can edit your trip details at any time:
				
				1. Open the trip from the main screen
				2. Tap the Edit button in the top right corner
				3. Update any details as needed
				4. Tap Save to apply your changes
				
				TravelBuddy will ask if you want to update your packing list based on the new details.
				"""
			)
            
			helpArticle(
				id: "completing-trips",
				title: "Completing Trips",
				content: """
				Once your trip is over or all items are packed:
				
				1. Tap the "Complete Trip" button at the bottom of the packing list
				2. Confirm that you want to mark the trip as completed
				
				Completed trips move to the "Completed" section of the main screen, where you can reference them for future trips.
				"""
			)
		}
	}
    
	/// Help content for the "Settings" category
	private var settingsContent: some View {
		VStack(alignment: .leading, spacing: 20) {
			helpArticle(
				id: "app-settings",
				title: "App Settings",
				content: """
				Customize TravelBuddy to suit your preferences:
				
				• Theme: Choose from light, dark, or system theme
				• Notifications: Configure packing reminders
				• Language: Select your preferred language
				• Measurement System: Switch between metric and imperial
				
				Access settings from the gear icon on the main screen.
				"""
			)
            
			helpArticle(
				id: "data-backup",
				title: "Data Backup and Sync",
				content: """
				TravelBuddy automatically backs up your data:
				
				• iCloud Sync: Your trips sync across all your Apple devices
				• Local Backup: The app creates regular backups on your device
				
				To manually backup or restore data:
				1. Go to Settings > Backup & Restore
				2. Choose "Create Backup" or "Restore"
				"""
			)
            
			helpArticle(
				id: "premium-features",
				title: "Premium Features",
				content: """
				TravelBuddy Premium offers additional features:
				
				• Unlimited trips (Free version: 3 trips)
				• Advanced packing list suggestions
				• Trip templates for faster planning
				• Trip sharing with family and friends
				• No advertisements
				
				Upgrade to Premium from the Settings menu.
				"""
			)
		}
	}
    
	/// Help content for the "Troubleshooting" category
	private var troubleshootingContent: some View {
		VStack(alignment: .leading, spacing: 20) {
			helpArticle(
				id: "sync-issues",
				title: "Sync Issues",
				content: """
				If you're having trouble with data syncing across devices:
				
				1. Ensure you're signed in to the same iCloud account on all devices
				2. Check that iCloud is enabled in your device settings
				3. Verify that TravelBuddy has permission to use iCloud
				4. Try restarting the app and your device
				
				Most sync issues resolve automatically within 24 hours.
				"""
			)
            
			helpArticle(
				id: "data-recovery",
				title: "Recovering Lost Data",
				content: """
				If you've lost data or a trip has disappeared:
				
				1. Go to Settings > Backup & Restore
				2. Select "Restore from Backup"
				3. Choose the most recent backup before the data loss
				
				If you can't find a suitable backup, contact our support team for assistance.
				"""
			)
            
			helpArticle(
				id: "contact-support",
				title: "Contact Support",
				content: """
				Need more help? Our support team is here for you:
				
				• Email: support@travelbuddy.app
				• Twitter: @TravelBuddyApp
				• Support Form: Available in Settings > Help & Support
				
				Please include as much detail as possible about your issue.
				"""
			)
            
			tutorialCard(
				title: "Common Issues FAQ",
				description: "Browse our frequently asked questions about common problems",
				buttonText: "View FAQ"
			)
		}
	}
    
	// MARK: - Helper Views
    
	/// Creates a help article with expandable content
	/// - Parameters:
	///   - id: Unique identifier for the article
	///   - title: Title of the article
	///   - content: Content of the article
	/// - Returns: A view representing the help article
	private func helpArticle(id: String, title: String, content: String) -> some View {
		let isExpanded = expandedArticleId == id
        
		return VStack(alignment: .leading, spacing: 10) {
			Button {
				withAnimation {
					expandedArticleId = isExpanded ? nil : id
				}
			} label: {
				HStack {
					Text(title)
						.font(.headline)
						.foregroundColor(.tripBuddyText)
                    
					Spacer()
                    
					Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
						.foregroundColor(.tripBuddyTextSecondary)
				}
			}
			.buttonStyle(.plain)
            
			if isExpanded {
				Text(content)
					.font(.body)
					.foregroundColor(.tripBuddyText)
					.padding(.top, 5)
					.transition(.opacity.combined(with: .move(edge: .top)))
			}
		}
		.padding(16)
		.background(Color.tripBuddyCard)
		.cornerRadius(12)
	}
    
	/// Creates a tutorial card with a button
	/// - Parameters:
	///   - title: Title of the tutorial
	///   - description: Description of the tutorial
	///   - buttonText: Text for the button
	/// - Returns: A view representing the tutorial card
	private func tutorialCard(title: String, description: String, buttonText: String) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Image(systemName: "play.circle.fill")
					.font(.title)
					.foregroundColor(.tripBuddyPrimary)
                
				Text(title)
					.font(.headline)
					.foregroundColor(.tripBuddyText)
			}
            
			Text(description)
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
				.padding(.top, 5)
            
			Button {
				// In a real app, this would show a video or tutorial
				print("Tutorial button tapped")
			} label: {
				Text(buttonText)
					.font(.headline)
					.foregroundColor(.white)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.background(Color.tripBuddyPrimary)
					.cornerRadius(8)
			}
			.padding(.top, 5)
		}
		.padding(16)
		.background(Color.tripBuddyCard)
		.cornerRadius(12)
	}
}

// MARK: - Help Category

/// Categories of help content
enum HelpCategory: String, CaseIterable, Identifiable {
	case gettingStarted
	case packingLists
	case tripPlanning
	case settings
	case troubleshooting
    
	var id: String { rawValue }
    
	/// Display name for the category
	var displayName: String {
		switch self {
		case .gettingStarted: return "Getting Started"
		case .packingLists: return "Packing Lists"
		case .tripPlanning: return "Trip Planning"
		case .settings: return "Settings"
		case .troubleshooting: return "Troubleshooting"
		}
	}
    
	/// Icon name for the category
	var iconName: String {
		switch self {
		case .gettingStarted: return "star"
		case .packingLists: return "checklist"
		case .tripPlanning: return "map"
		case .settings: return "gear"
		case .troubleshooting: return "questionmark.circle"
		}
	}
}

// MARK: - Preview

#Preview {
	HelpCenterView()
}
