import FirebaseAnalytics
import SwiftUI

/// Onboarding view shown to first-time users of the app
struct OnboardingView: View {
	// MARK: - Properties
	
	/// Completion handler called when onboarding is finished
	let onFinished: () -> Void
	
	/// Current page index
	@State private var currentPage = 0
	
	/// Progress value for the progress bar (0.0 to 1.0)
	@State private var progressValue: CGFloat = 0.25
	
	// MARK: - Onboarding Pages
	
	/// Array of onboarding page content
	private let pages: [OnboardingPage] = [
		OnboardingPage(
			image: nil,
			customImage: "AppIconLogo",
			title: "onboarding_welcome_title",
			description: "onboarding_welcome_description",
			tintColor: .tripBuddyPrimary
		),
		OnboardingPage(
			image: "list.bullet.clipboard",
			customImage: nil,
			title: "onboarding_organize_title",
			description: "onboarding_organize_description",
			tintColor: .tripBuddyAccent
		),
		OnboardingPage(
			image: "checkmark.circle.fill",
			customImage: nil,
			title: "onboarding_prepared_title",
			description: "onboarding_prepared_description",
			tintColor: .tripBuddySuccess
		),
		OnboardingPage(
			image: "arrow.triangle.2.circlepath",
			customImage: nil,
			title: "onboarding_completed_title",
			description: "onboarding_completed_description",
			tintColor: .tripBuddyAlert
		)
	]
	
	// MARK: - Body
	
	var body: some View {
		ZStack {
			// Main content
			VStack(spacing: 0) {
				// Top navigation with progress bar and skip button
				topNavigationBar
				
				// Paging view for slides
				TabView(selection: $currentPage) {
					ForEach(0..<pages.count, id: \.self) { index in
						OnboardingPageView(page: pages[index], pageIndex: index)
							.tag(index)
					}
				}
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
				.onChange(of: currentPage) { _, _ in
					updateProgressValue()
				}
				
				// Bottom navigation with page indicators and next button
				bottomNavigationBar
			}
		}
		.onAppear {
			// Initialize progress on appear
			updateProgressValue()
		}
	}
	
	// MARK: - UI Components
	
	/// Top navigation bar with progress indicator and skip button
	private var topNavigationBar: some View {
		HStack {
			// Progress bar
			ProgressBar(value: progressValue)
				.frame(height: 4)
				.padding(.leading)
			
			Spacer()
			
			// Skip/Finish button
			if currentPage < pages.count - 1 {
				Button("skip") {
					withAnimation {
						finishOnboarding(skipped: true)
					}
				}
				.padding()
				.foregroundColor(.tripBuddyTextSecondary)
			} else {
				Button("finish") {
					withAnimation {
						finishOnboarding(skipped: false)
					}
				}
				.padding()
				.foregroundColor(.tripBuddyTextSecondary)
			}
		}
		.padding(.top, 16)
	}
	
	/// Bottom navigation bar with page indicators and next button
	private var bottomNavigationBar: some View {
		HStack {
			// Page indicators
			HStack(spacing: 8) {
				ForEach(0..<pages.count, id: \.self) { index in
					Circle()
						.fill(index == currentPage ? pages[safePageIndex].tintColor : Color.gray.opacity(0.3))
						.frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
						.scaleEffect(index == currentPage ? 1.2 : 1.0)
						.animation(.spring(), value: currentPage)
				}
			}
			
			Spacer()
			
			// Next/Start button
			Button(action: {
				if currentPage < pages.count - 1 {
					withAnimation {
						currentPage += 1
					}
				} else {
					finishOnboarding(skipped: false)
				}
			}) {
				HStack {
					Text(currentPage == pages.count - 1 ? "start" : "next")
						.font(.headline)
						.fontWeight(.bold)
					
					Image(systemName: currentPage == pages.count - 1 ? "checkmark" : "arrow.right")
						.font(.headline)
				}
				.foregroundColor(.white)
				.padding(.horizontal, 20)
				.padding(.vertical, 15)
				.background(Capsule().fill(pages[safePageIndex].tintColor))
				.shadow(color: pages[safePageIndex].tintColor.opacity(0.5), radius: 5, x: 0, y: 3)
			}
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 30)
		.padding(.top, 20)
	}
	
	// MARK: - Helpers
	
	/// Safe page index to prevent out of bounds errors
	private var safePageIndex: Int {
		min(max(currentPage, 0), pages.count - 1)
	}
	
	/// Updates the progress value based on the current page
	private func updateProgressValue() {
		withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
			progressValue = CGFloat(currentPage + 1) / CGFloat(pages.count)
		}
	}
	
	/// Completes the onboarding process
	private func finishOnboarding(skipped: Bool = false) {
		logOnboardingFinished(skipped: skipped)
		
		withAnimation(.easeOut(duration: 0.5)) {
			onFinished()
		}
	}
	
	// --- Helper to log finish/skip ---
	private func logOnboardingFinished(skipped: Bool) {
		guard AppConstants.enableAnalytics else { return }

		if skipped {
			// Log a custom "onboarding_skipped" event
			Analytics.logEvent("onboarding_skipped", parameters: [
				"skipped_at_page_index": currentPage // Log which page they skipped from
			])
		} else {
			// Log the standard "tutorial_complete" event
			Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
		}
	}
}

// MARK: - Progress Bar Component

/// A simple progress bar component
struct ProgressBar: View {
	let value: CGFloat // 0.0 to 1.0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				// Background track
				Rectangle()
					.foregroundColor(.gray.opacity(0.2))
				
				// Filled portion
				Rectangle()
					.foregroundColor(.blue)
					.frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
			}
			.cornerRadius(2)
		}
	}
}

// MARK: - Onboarding Page View

/// A single page in the onboarding sequence
struct OnboardingPageView: View {
	// MARK: - Properties
	
	let page: OnboardingPage
	let pageIndex: Int
	
	/// Animation state
	@State private var isAnimating = false
	
	// MARK: - Body
	
	var body: some View {
		VStack(spacing: 30) {
			Spacer()
			
			// Image/icon
			Group {
				if let customImage = page.customImage {
					// App icon image
					Image(customImage)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 120, height: 120)
						.cornerRadius(16)
				} else if let systemImage = page.image {
					// System SF Symbol
					Image(systemName: systemImage)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 120, height: 120)
						.foregroundColor(page.tintColor)
				}
			}
			.offset(y: isAnimating ? 0 : 20)
			.opacity(isAnimating ? 1 : 0)
			.shadow(color: page.tintColor.opacity(0.3), radius: 10, x: 0, y: 5)
			
			// Title
			Text(page.title)
				.font(.title)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.offset(y: isAnimating ? 0 : 15)
				.opacity(isAnimating ? 1 : 0)
				.foregroundColor(.tripBuddyText)
			
			// Description
			Text(page.description)
				.font(.body)
				.multilineTextAlignment(.center)
				.foregroundColor(.tripBuddyTextSecondary)
				.padding(.horizontal, 40)
				.offset(y: isAnimating ? 0 : 10)
				.opacity(isAnimating ? 1 : 0)
			
			Spacer()
			Spacer()
		}
		.padding()
		.onAppear {
			withAnimation(.easeOut(duration: 0.6)) {
				isAnimating = true
			}
			
			logOnboardingScreenView()
		}
		.onDisappear {
			isAnimating = false
		}
	}
	
	private func logOnboardingScreenView() {
		guard AppConstants.enableAnalytics else { return }

		Analytics.logEvent(AnalyticsEventScreenView, parameters: [
			AnalyticsParameterScreenName: "OnboardingPage_\(pageIndex)",
			AnalyticsParameterScreenClass: "OnboardingView",
			"onboarding_page_index": pageIndex,
			"onboarding_page_title": String(describing: page.title) // Convert LocalizedStringKey to String for analytics
		])
	}
}

// MARK: - Data Models

/// Data model for an onboarding page
struct OnboardingPage {
	let image: String?
	let customImage: String?
	let title: LocalizedStringKey // Changed from String to LocalizedStringKey
	let description: LocalizedStringKey // Changed from String to LocalizedStringKey
	let tintColor: Color
}

// MARK: - Preview

#Preview {
	OnboardingView {
		print("Onboarding completed")
	}
}
