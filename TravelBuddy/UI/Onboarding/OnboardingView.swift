import Combine // Needed for Combine in UserSettingsManager if not already imported
import FirebaseAnalytics // Assuming Firebase is already set up as per your existing code
import SwiftUI

// MARK: - Onboarding Page Data Structure

// This struct defines the content for each page of the onboarding.
// Include this struct in the same file as NewOnboardingView.
struct OnboardingPageData: Identifiable {
	let id = UUID() // Unique identifier for ForEach
	let imageName: String? // Name of the image asset (e.g., "OnboardingBackground1")
	let animationIdentifier: String? // Identifier for which SwiftUI animation to show (e.g., "organize", "smart_packing")
	let iconName: String? // SF Symbol name (optional, used if no image/animation)
	let title: LocalizedStringKey
	let description: LocalizedStringKey
	let tintColor: Color // Accent color for elements on this page
	let showNameInput: Bool // Flag to show the name input field
	let showTravelStyleSelection: Bool // Flag to show travel style selection
	let pageIndex: Int // Index of the page

	// Helper to determine the primary visual asset type (for conditional rendering)
	var visualAssetType: VisualAssetType {
		if animationIdentifier != nil {
			return .swiftUIAnimation // Indicate to use a SwiftUI animation
		} else if let imageName = imageName {
			return .image(imageName)
		} else if let iconName = iconName {
			return .icon(iconName)
		}
		return .none // Fallback
	}

	enum VisualAssetType {
		case image(String)
		case icon(String)
		case swiftUIAnimation // New case for SwiftUI animations
		case none
	}
}

// MARK: - Onboarding Page Content View

// This view renders the content for a single onboarding page based on OnboardingPageData.
// Include this struct in the same file as NewOnboardingView.
struct OnboardingPageViewContent: View {
	let page: OnboardingPageData
	@Binding var userName: String // Binding for the interactive name input
	@Binding var selectedTravelStyle: TravelStyle // Binding for travel style selection
	let onTravelStyleSelected: (TravelStyle) -> Void // Action when a style is selected

	@State private var isAnimating = false // Animation state for elements

	var body: some View {
		VStack(spacing: 30) {
			Spacer() // Pushes content down

			// MARK: - Visual Asset (Image, SwiftUI Animation, or Icon)

			Group {
				switch page.visualAssetType {
				case .image:
					Image("personStanding")
						.resizable()
						.scaledToFit()
						.frame(width: 300, height: 300)
				case .swiftUIAnimation:
					// --- SwiftUI Animation Integration Point ---
					// Use the appropriate SwiftUI animation view based on the page's concept
					if page.animationIdentifier == "organize" {
						OrganizeAnimationView() // Use the Organize SwiftUI animation
							.frame(maxHeight: 200)
					} else if page.animationIdentifier == "smart_packing" {
						SmartPackingAnimationView() // Use the Smart Packing SwiftUI animation
							.frame(width: 250, height: 300) // Give it a size
					} else if page.animationIdentifier == "weather" {
						ClimateAnimationView()
					} else {
						// Fallback if animationIdentifier doesn't match a known SwiftUI animation
						Image(systemName: page.iconName ?? "questionmark.circle")
							.resizable()
							.scaledToFit()
							.frame(width: 120, height: 120)
							.foregroundColor(page.tintColor)
					}

				case .icon(let name):
					// SF Symbol icon
					Image(systemName: name)
						.resizable()
						.scaledToFit()
						.frame(width: 120, height: 120)
						.foregroundColor(page.tintColor) // Use the page's tint color
						.shadow(color: page.tintColor.opacity(0.3), radius: 10, x: 0, y: 5) // Shadow based on tint

				case .none:
					// Fallback if no visual asset is specified
					Image(systemName: "photo")
						.resizable()
						.scaledToFit()
						.frame(width: 100, height: 100)
						.foregroundColor(.gray.opacity(0.5))
				}
			}
			.padding(.horizontal) // Add some padding around the visual asset
			.offset(y: isAnimating ? 0 : 30) // Animation effect
			.opacity(isAnimating ? 1 : 0)
			.animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating) // Apply animation

			Spacer()

			// MARK: - Title

			Text(page.title)
				.font(.largeTitle.weight(.bold)) // Use a larger, bolder font
				.multilineTextAlignment(.center)
				.foregroundColor(.tripBuddyText) // Use the themed text color
				.padding(.horizontal)
				.offset(y: isAnimating ? 0 : 20) // Animation effect
				.opacity(isAnimating ? 1 : 0)
				.animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)

			// MARK: - Description

			Text(page.description)
				.font(.body)
				.multilineTextAlignment(.center)
				.foregroundColor(.tripBuddyTextSecondary) // Use the themed secondary text color
				.padding(.horizontal, 40)
				.offset(y: isAnimating ? 0 : 10) // Animation effect
				.opacity(isAnimating ? 1 : 0)
				.animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)

			Spacer() // Pushes content up
		}
		.onAppear {
			isAnimating = true // Start animation when view appears
		}
		.onDisappear {
			isAnimating = false // Reset animation when view disappears
		}
	}
}

// MARK: - Main New Onboarding View

// This is the main view that orchestrates the onboarding flow.
// This struct should replace your existing OnboardingView struct.
struct OnboardingView: View {
	// MARK: - Environment & State

	@Environment(\.dismiss) private var dismiss // To dismiss the onboarding view
	@EnvironmentObject private var userSettings: UserSettingsManager // Access user settings

	// State for the onboarding flow
	@State private var currentPage = 0 // Current page index
	@State private var userName: String = "" // State for the user's name input
	@State private var selectedTravelStyle: TravelStyle = .unknown // State for selected travel style

	// MARK: - Onboarding Pages Data

	// Define the content for each onboarding page
	private let pages: [OnboardingPageData] = [
		OnboardingPageData(
			imageName: "AppLogoIcon", // Placeholder image name (add to Assets)
			animationIdentifier: nil, // No SwiftUI animation on this page
			iconName: nil,
			title: "Smart Packinglist for Any Trip", // Add this key to Localizable.strings
			description: "Nie mehr Packstress! TravelBuddy erstellt deine optimale Packliste – einfach, smart, überzeugend", // Add this key to Localizable.strings
			tintColor: Color("TripBuddyPrimary"), // Use color from assets
			showNameInput: true, // Show name input on this page
			showTravelStyleSelection: false,
			pageIndex: 0
		),
		OnboardingPageData(
			imageName: nil,
			animationIdentifier: "organize", // Use this identifier to trigger the Organize SwiftUI animation
			iconName: "list.bullet.clipboard", // Fallback icon if animation fails/not used
			title: "onboarding_organize_title", // Add this key to Localizable.strings
			description: "onboarding_organize_description", // Add this key to Localizable.strings
			tintColor: Color("TripBuddyAccent"), // Use color from assets
			showNameInput: false,
			showTravelStyleSelection: false,
			pageIndex: 1
		),
		OnboardingPageData(
			imageName: nil,
			animationIdentifier: nil, // Use this identifier to trigger the Smart Packing SwiftUI animation
			iconName: "hourglass.tophalf.filled", // Fallback icon
			title: "onboarding_smart_title", // Add this key to Localizable.strings
			description: "onboarding_smart_description", // Add this key to Localizable.strings
			tintColor: Color("TripBuddySuccess"), // Use color from assets
			showNameInput: false,
			showTravelStyleSelection: false,
			pageIndex: 2
		),

		OnboardingPageData(
			imageName: nil,
			animationIdentifier: "smart_packing", // No SwiftUI animation on this page
			iconName: nil,
			title: "onboarding_ready_title", // Add this key to Localizable.strings
			description: "onboarding_ready_description", // Add this key to Localizable.strings
			tintColor: Color("TripBuddyAccent"), // Use color from assets
			showNameInput: false,
			showTravelStyleSelection: false,
			pageIndex: 3 // This is the final page
		)
	]

	// MARK: - Computed Properties

	// Calculate the progress value for the progress bar
	private var progressValue: CGFloat {
		CGFloat(currentPage + 1) / CGFloat(pages.count)
	}

	// Determine if it's the last page
	private var isLastPage: Bool {
		currentPage == pages.last?.pageIndex
	}

	// Get the tint color for the current page
	private var currentPageTintColor: Color {
		pages[safe: currentPage]?.tintColor ?? Color("TripBuddyPrimary") // Fallback color from assets
	}

	// MARK: - Body

	var body: some View {
		ZStack {
			// Background color
			Color("TripBuddyBackground").ignoresSafeArea() // Use color from assets

			VStack(spacing: 0) {
				// Top navigation with progress bar and skip button
				topNavigationBar

				// Paging view for slides
				TabView(selection: $currentPage) {
					ForEach(pages) { page in
						OnboardingPageViewContent(
							page: page,
							userName: $userName,
							selectedTravelStyle: $selectedTravelStyle,
							onTravelStyleSelected: { style in
								selectedTravelStyle = style // Update state when a style is selected
							}
						)
						.tag(page.pageIndex) // Use the pageIndex as the tag
					}
				}
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default page indicators
				.animation(.easeInOut, value: currentPage) // Animate page transitions
				// Disable swipe gesture if you want to force button navigation
				// .highPriorityGesture(DragGesture()) // Example to disable swipe

				// Bottom navigation with page indicators and next/start button
				bottomNavigationBar
			}
		}
		.onAppear {
			// Log onboarding start event
			if AppConstants.enableAnalytics {
				Analytics.logEvent("onboarding_start", parameters: nil) // Custom event
			}
		}
	}

	// MARK: - UI Components

	/// Top navigation bar with progress indicator and skip button
	private var topNavigationBar: some View {
		HStack {
			// Progress bar
			ProgressBar(value: progressValue, color: currentPageTintColor) // Pass tint color to progress bar
				.frame(height: 6) // Slightly thicker progress bar
				.padding(.leading)
				.animation(.easeInOut(duration: 0.4), value: progressValue) // Animate progress changes

			Spacer()

			// Skip/Finish button
			Button(isLastPage ? "finish" : "skip") {
				finishOnboarding(skipped: !isLastPage) // Pass whether it was skipped
			}
			.padding()
			.foregroundColor(Color("TripBuddyTextSecondary")) // Use color from assets
			.animation(.easeInOut, value: isLastPage) // Animate button text change
		}
		.padding(.top, 16)
	}

	/// Bottom navigation bar with page indicators and next button
	private var bottomNavigationBar: some View {
		HStack {
			// Page indicators
			HStack(spacing: 8) {
				ForEach(0 ..< pages.count, id: \.self) { index in
					Circle()
						.fill(index == currentPage ? currentPageTintColor : Color.gray.opacity(0.3)) // Use current page tint
						.frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8) // Highlight current page
						.scaleEffect(index == currentPage ? 1.2 : 1.0)
						.animation(.spring(), value: currentPage) // Spring animation for indicator
				}
			}

			Spacer()

			// Next/Start button
			Button(action: {
				if isLastPage {
					finishOnboarding(skipped: false) // Finished onboarding
				} else {
					withAnimation {
						currentPage += 1 // Go to next page
					}
				}
			}) {
				HStack {
					Text(isLastPage ? "start" : "next")
						.font(.headline)
						.fontWeight(.bold)

					Image(systemName: isLastPage ? "checkmark" : "arrow.right")
						.font(.headline)
				}
				.foregroundColor(.white)
				.padding(.horizontal, 25) // More padding
				.padding(.vertical, 15)
				.background(Capsule().fill(currentPageTintColor)) // Use current page tint
				.shadow(color: currentPageTintColor.opacity(0.5), radius: 8, y: 4) // Shadow based on tint
			}
			.animation(.easeInOut, value: isLastPage) // Animate button text/icon change
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 30)
		.padding(.top, 20)
	}

	// MARK: - Actions

	/// Completes the onboarding process and updates user settings.
	private func finishOnboarding(skipped: Bool) {
		// Update user settings via the shared manager
		userSettings.hasCompletedOnboarding = true
		userSettings.preferredTravelStyle = selectedTravelStyle // Save selected travel style
		// Optionally save user name if you want to store it
		// userSettings.userName = userName // You'd need to add this property to UserSettingsManager

		// Log completion or skip event
		if AppConstants.enableAnalytics {
			if skipped {
				Analytics.logEvent("onboarding_skipped", parameters: [
					"skipped_at_page": currentPage // Log the page index where they skipped
				])
			} else {
				Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: [
					"preferred_travel_style": selectedTravelStyle.rawValue // Log the selected style
				])
			}
		}

		// Dismiss the onboarding view
		withAnimation(.easeOut(duration: 0.5)) {
			dismiss()
		}
	}
}

// MARK: - Progress Bar Component (Updated)

// A simple progress bar component with customizable color.
// Include this struct in the same file as NewOnboardingView.
struct ProgressBar: View {
	let value: CGFloat // 0.0 to 1.0
	let color: Color // Color of the progress fill

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				// Background track
				Capsule() // Use Capsule for rounded ends
					.fill(Color.gray.opacity(0.2))

				// Filled portion
				Capsule() // Use Capsule for rounded ends
					.fill(color) // Use the passed color
					.frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
			}
		}
	}
}

// MARK: - Helper Extension for Array Safety

// Include this extension in the same file as NewOnboardingView.
extension Collection {
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}

// MARK: - Preview

#Preview {
	// Need to provide UserSettingsManager in the environment for the preview
	OnboardingView()
		.environmentObject(UserSettingsManager.shared)
}
