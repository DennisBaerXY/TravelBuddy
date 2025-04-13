//
//  TransportSelectButton.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import SwiftUI

struct SelectableButton: View {
	let systemImage: String
	let text: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(spacing: 8) {
				Image(systemName: systemImage)
					.font(.system(size: 28)) // Größeres Icon
					.foregroundColor(isSelected ? .tripBuddyPrimary : .tripBuddyTextSecondary)

				Text(text)
					.font(.caption)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
					.foregroundColor(isSelected ? .tripBuddyPrimary : .tripBuddyTextSecondary)
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 80) // Volle Breite, feste Höhe
			.padding(5)
			.background(
				RoundedRectangle(cornerRadius: 16) // Stärkere Rundung
					.fill(isSelected ? Color.tripBuddyPrimary.opacity(0.1) : Color.tripBuddyCard)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(isSelected ? Color.tripBuddyPrimary : Color.clear, lineWidth: 2) // Deutlicher Rand wenn ausgewählt
			)
			.scaleEffect(isSelected ? 1.05 : 1.0) // Leichte Vergrößerung bei Auswahl
			.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
		}
		.buttonStyle(.plain) // Verhindert Standard-Button-Highlighting
	}
}
