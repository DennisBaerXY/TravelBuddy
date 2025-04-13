import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: [
		SortDescriptor(\Trip.isCompleted, order: .forward),
		SortDescriptor(\Trip.createdAt, order: .reverse)
	]) private var trips: [Trip]
	@State private var showingAddTrip = false
	@State private var isPremiumUser = false

	var body: some View {
		NavigationStack {
			ZStack {
				// *** NEU: Subtiler Hintergrundgradient ***
				LinearGradient(
					gradient: Gradient(colors: [Color.tripBuddyBackground.opacity(0.5), Color.tripBuddyBackground]),
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.ignoresSafeArea()

				if trips.isEmpty {
					// Optional: Den leeren Zustand freundlicher gestalten
					VStack(spacing: 25) { // Etwas mehr Abstand
						Image("AppIconLogo")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 120, height: 120)
							.clipShape(RoundedRectangle(cornerRadius: 24)) // Weichere Ecken
							.shadow(color: .black.opacity(0.1), radius: 10, y: 5)

						VStack(spacing: 10) { // Texte gruppieren
							Text("no.trips.planned.title") // Evtl. einen separaten Titel?
								.font(.title2) // Etwas kleiner als .title
								.fontWeight(.bold)
								.foregroundColor(.tripBuddyText)

							Text("add.trip.tip")
								.multilineTextAlignment(.center)
								.foregroundColor(.tripBuddyTextSecondary)
								.padding(.horizontal)
						}

						Button {
							showingAddTrip = true
						} label: {
							Label("create.first.trip", systemImage: "plus.circle.fill") // Icon hinzufügen
						}
						.buttonStyle(TripBuddyFilledButtonStyle()) // Eigener, freundlicherer Button-Stil (siehe unten)
						.padding(.top) // Abstand nach oben
					}
					.padding()

				} else {
					// Liste mit angepassten Cards
					ScrollView { // ScrollView statt List für mehr Layout-Kontrolle
						LazyVStack(spacing: 15) { // Abstand zwischen Karten
							ForEach(trips) { trip in
								NavigationLink(destination: TripDetailView(trip: trip)) {
									TripCardView(trip: trip)
								}
								// Entferne .listRowSeparator(.hidden), da wir ScrollView nutzen
							}
							// onDelete über ScrollView/LazyVStack ist komplexer, evtl. SwipeActions verwenden
							// Einfachheitshalber lassen wir onDelete hier weg oder fügen es später hinzu
						}
						.padding() // Padding für den gesamten ScrollView-Inhalt
					}
				}

				// Floating Action Button (FAB)
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							showingAddTrip = true
						}) {
							Image(systemName: "plus")
								.font(.title.weight(.semibold)) // Größer/Fetter
								.frame(width: 30, height: 30) // Größerer Touch-Bereich innen
								.padding(18) // Größeres Padding außen
								.background(Color.tripBuddyPrimary)
								.foregroundColor(.white)
								.clipShape(Circle())
								.shadow(color: .tripBuddyPrimary.opacity(0.5), radius: 8, y: 4) // Deutlicherer Schatten
								.scaleEffect(showingAddTrip ? 1.1 : 1.0) // Leichte Animation beim Öffnen (optional)
								.animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingAddTrip)
						}
						.padding(20) // Mehr Abstand zum Rand
					}
				}
			}
			.navigationTitle("my.trips")
			.toolbar {
				// ... (Toolbar wie zuvor) ...
			}
			.sheet(isPresented: $showingAddTrip) {
				AddTripView()
			}
		}
	}

	func deleteTrip(_ indexes: IndexSet) {
		for index in indexes {
			let trip = trips[index]
			modelContext.delete(trip)
		}
	}

	func presentPremiumUpgrade() {
		// Hier würde in der vollständigen App der Premium-Kauf-Flow starten
		isPremiumUser.toggle() // Nur für Demo-Zwecke
	}

	struct TripBuddyFilledButtonStyle: ButtonStyle {
		func makeBody(configuration: Configuration) -> some View {
			configuration.label
				.font(.headline.weight(.semibold))
				.padding(.horizontal, 25)
				.padding(.vertical, 15)
				.frame(minWidth: 0, maxWidth: .infinity) // Volle Breite
				.background(Color.tripBuddyPrimary)
				.foregroundColor(.white)
				.clipShape(Capsule()) // Freundliche Kapselform
				.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
				.opacity(configuration.isPressed ? 0.9 : 1.0)
				.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
		}
	}
}
