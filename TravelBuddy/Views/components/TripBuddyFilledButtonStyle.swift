//
//  TripBuddyFilledButtonStyle.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

import SwiftUI

struct TripBuddyFilledButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			// Schrift: Prominent und gut lesbar
			.font(.headline.weight(.semibold))
			// Padding: Großzügig für eine gute Klickfläche und Optik
			.padding(.horizontal, 25)
			.padding(.vertical, 15)
			// Rahmen: Nimmt die verfügbare Breite ein (optional, je nach Kontext)
			// .frame(minWidth: 0, maxWidth: .infinity) // Auskommentiert, damit er sich anpasst, wenn nicht volle Breite gewünscht
			// Hintergrund: Gefüllt mit der Primärfarbe
			.background(Color.tripBuddyPrimary)
			// Vordergrund: Kontrastfarbe für Text/Icon
			.foregroundColor(.white)
			// Form: Freundliche Kapselform
			.clipShape(Capsule())
			// Interaktion: Leichte Skalierung und Transparenz beim Drücken
			.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
			.opacity(configuration.isPressed ? 0.9 : 1.0)
			// Animation: Sanfter Übergang für den Drück-Effekt
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// Optional: Eine Preview hinzufügen, um den Stil isoliert zu testen
struct TripBuddyFilledButtonStyle_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			Button("Primäre Aktion") {}
				.buttonStyle(TripBuddyFilledButtonStyle())

			Button {} label: {
				Label("Aktion mit Icon", systemImage: "paperplane.fill")
			}
			.buttonStyle(TripBuddyFilledButtonStyle())
		}
		.padding()
	}
}
