import SwiftUI

struct OnboardingView: View {
	// Callback, wenn das Onboarding abgeschlossen ist
	let onFinished: () -> Void
	
	// State für den aktuellen Slide
	@State private var currentPage = 0
	// Für Fortschrittsanzeige
	@State private var progressValue: CGFloat = 0.25
	
	// Onboarding-Slides
	private let pages: [OnboardingPage] = [
		OnboardingPage(
			image: nil,
			customImage: "AppIconLogo",
			title: "Willkommen bei TripBuddy",
			description: "Der ultimative Reisebegleiter für deine Abenteuer.",
			tintColor: Color.blue
		),
		OnboardingPage(
			image: "list.bullet.clipboard",
			customImage: nil,
			title: "Organisiere Deine Reisen",
			description: "Erstelle individuelle Packlisten für jede Reise und behalte den Überblick.",
			tintColor: Color.orange
		),
		OnboardingPage(
			image: "checkmark.circle.fill",
			customImage: nil,
			title: "Immer vorbereitet",
			description: "Nie wieder etwas vergessen! TripBuddy hilft dir, alles Wichtige einzupacken.",
			tintColor: Color.green
		),
		OnboardingPage(
			image: "arrow.triangle.2.circlepath",
			customImage: nil,
			title: "Abgeschlossen? Kein Problem!",
			description: "Reise beendet? Markiere sie als abgeschlossen, um später darauf zurückzugreifen.",
			tintColor: Color.purple
		)
	]
	
	var body: some View {
		ZStack {
			// Einfacher weißer Hintergrund statt Gradient
			
			// Hauptinhalt
			VStack(spacing: 0) {
				// Oberer Bereich mit Überspringen-Button und Fortschrittsbalken
				HStack {
					// Fortschrittsbalken
					ProgressBar(value: progressValue)
						.frame(height: 4)
						.padding(.leading)
					
					Spacer()
					
					// Überspringen-Button (außer auf dem letzten Slide)
					if currentPage < pages.count - 1 {
						Button("Überspringen") {
							withAnimation {
								skipOnboarding()
							}
						}
						.padding()
						.foregroundColor(.tripBuddyTextSecondary)
					} else {
						Button("Abschließen") {
							withAnimation {
								skipOnboarding()
							}
						}
						.padding()
						.foregroundColor(.tripBuddyTextSecondary)
					}
				}
				.padding(.top, 16)
				
				// Hauptbereich mit Slides - Zurück zum TabView für einfaches Swipen
				TabView(selection: $currentPage) {
					ForEach(0..<pages.count, id: \.self) { index in
						OnboardingPageView(page: pages[index])
							.tag(index)
					}
				}
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Verstecke Standard-Indikatoren
				.onChange(of: currentPage) { _, _ in
					updateProgressValue()
				}
				
				// Unterer Bereich mit Navigations-Buttons
				HStack {
					// Indikatoren für die Seiten
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
					
					// Weiter/Starten-Button
					Button(action: {
						if currentPage < pages.count - 1 {
							withAnimation {
								currentPage += 1
							}
						} else {
							skipOnboarding()
						}
					}) {
						HStack {
							Text(currentPage == pages.count - 1 ? "Starten" : "Weiter")
								.font(.headline)
								.fontWeight(.bold)
							
							Image(systemName: currentPage == pages.count - 1 ? "checkmark" : "arrow.right")
								.font(.headline)
						}
						.foregroundColor(.tripBuddyText)
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
		}
		.onAppear {
			// Initiale Animation für die Fortschrittsleiste
			updateProgressValue()
		}
	}
	
	// Sicherheitsmaßnahme, um IndexOutOfRange zu vermeiden
	private var safePageIndex: Int {
		min(max(currentPage, 0), pages.count - 1)
	}
	
	private func skipOnboarding() {
		// Sanfte Ausblendungsanimation
		withAnimation(.easeOut(duration: 0.5)) {
			onFinished()
		}
	}
	
	private func updateProgressValue() {
		// Berechne den Fortschritt auf der Basis der aktuellen Seite
		withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
			progressValue = CGFloat(currentPage + 1) / CGFloat(pages.count)
		}
	}
}

// Fortschrittsbalken-Komponente
struct ProgressBar: View {
	var value: CGFloat // 0.0 bis 1.0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				Rectangle()
					.foregroundColor(.gray.opacity(0.2))
				
				Rectangle()
					.foregroundColor(.blue)
					.frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
			}
			.cornerRadius(2)
		}
	}
}

// Einzelner Onboarding-Slide mit verbesserten Animationen
struct OnboardingPageView: View {
	let page: OnboardingPage
	@State private var isAnimating = false
	
	var body: some View {
		VStack(spacing: 30) {
			Spacer()
			
			// Symbol oder benutzerdefiniertes Bild
			Group {
				if let customImage = page.customImage {
					// Verwende das App-Icon-Bild
					Image(customImage)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 120, height: 120)
						.cornerRadius(16)
				} else if let systemImage = page.image {
					// Verwende SF Symbol
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
			
			// Titel
			Text(page.title)
				.font(.title)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.offset(y: isAnimating ? 0 : 15)
				.opacity(isAnimating ? 1 : 0)
				.foregroundColor(.tripBuddyTextSecondary)
			
			// Beschreibung
			Text(page.description)
				.font(.body)
				.multilineTextAlignment(.center)
				.foregroundColor(.secondary)
				.padding(.horizontal, 40)
				.offset(y: isAnimating ? 0 : 10)
				.opacity(isAnimating ? 1 : 0)
			
			Spacer()
			Spacer()
		}
		.padding()
		.onAppear {
			withAnimation(.easeOut(duration: 0.7)) {
				isAnimating = true
			}
		}
		.onDisappear {
			isAnimating = false
		}
	}
}

// Erweiterte Datenstruktur für einen Onboarding-Slide
struct OnboardingPage {
	let image: String?
	let customImage: String?
	let title: String
	let description: String
	let tintColor: Color
}
