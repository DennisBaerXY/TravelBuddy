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
			title: "Willkommen bei TravelBuddy",
			description: "Der ultimative Reisebegleiter für deine Abenteuer.",
			tintColor: .tripBuddyPrimary
		),
		OnboardingPage(
			image: "list.bullet.clipboard",
			customImage: nil,
			title: "Organisiere Deine Reisen",
			description: "Erstelle individuelle Packlisten für jede Reise und behalte den Überblick.",
			tintColor: .tripBuddyAccent
		),
		OnboardingPage(
			image: "checkmark.circle.fill",
			customImage: nil,
			title: "Immer vorbereitet",
			description: "Nie wieder etwas vergessen! TripBuddy hilft dir, alles Wichtige einzupacken.",
			tintColor: .tripBuddySuccess
		),
		OnboardingPage(
			image: "arrow.triangle.2.circlepath",
			customImage: nil,
			title: "Abgeschlossen? Kein Problem!",
			description: "Reise beendet? Markiere sie als abgeschlossen, um später darauf zurückzugreifen.",
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
						OnboardingPageView(page: pages[index])
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
				Button("Überspringen") {
					withAnimation {
						finishOnboarding()
					}
				}
				.padding()
				.foregroundColor(.tripBuddyTextSecondary)
			} else {
				Button("Abschließen") {
					withAnimation {
						finishOnboarding()
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
					finishOnboarding()
				}
			}) {
				HStack {
					Text(currentPage == pages.count - 1 ? "Starten" : "Weiter")
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
	private func finishOnboarding() {
		withAnimation(.easeOut(duration: 0.5)) {
			onFinished()
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
		}
		.onDisappear {
			isAnimating = false
		}
	}
}

// MARK: - Data Models

/// Data model for an onboarding page
struct OnboardingPage {
	let image: String?
	let customImage: String?
	let title: String
	let description: String
	let tintColor: Color
}

// MARK: - Preview

#Preview {
	OnboardingView {
		print("Onboarding completed")
	}
}
