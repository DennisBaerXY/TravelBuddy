// TripCardView.swift
import SwiftUI

struct TripCardView: View {
	let trip: Trip

	var body: some View {
		VStack(alignment: .leading, spacing: 15) { // Mehr Abstand intern
			tripHeader
			destinationRow
			dateRow
			tripStatusView
		}
		.padding(20) // Mehr Innenabstand
		.background(cardBackground)
		.opacity(trip.isCompleted ? 0.8 : 1.0) // Abgeschlossene leicht transparenter
		.overlay( // Optional: Akzentfarbe als kleiner Indikator links
			RoundedRectangle(cornerRadius: 6)
				.fill(progressColor(for: trip.packingProgress).opacity(trip.isCompleted ? 0 : 0.8))
				.frame(width: 6)
				.padding(.vertical, 10), // Kleiner als die Karte
			alignment: .leading
		)
	}

	// MARK: - Components

	private var tripHeader: some View {
		HStack {
			Text(trip.name)
				.font(.title3.weight(.semibold)) // Größer/Fetter
				.foregroundColor(.tripBuddyText)
			Spacer()
			if trip.isCompleted {
				completedBadge
			} else {
				transportIcons
			}
		}
	}

	private var completedBadge: some View {
		HStack(spacing: 4) {
			Image(systemName: "checkmark.seal.fill")
				.foregroundColor(.tripBuddySuccess)
			Text("Abgeschlossen")
				.font(.caption.weight(.medium)) // Leicht fetter
				.foregroundColor(.tripBuddySuccess)
		}
		.padding(.horizontal, 10) // Mehr Padding
		.padding(.vertical, 5)
		.background(Capsule().fill(Color.tripBuddySuccess.opacity(0.1))) // Kapselform
	}

	private var transportIcons: some View {
		HStack(spacing: 6) { // Mehr Abstand
			ForEach(trip.transportTypesEnum, id: \.self) { type in
				Image(systemName: type.iconName)
					.font(.callout)
					.foregroundColor(.tripBuddyAccent)
					.opacity(0.8) // Leicht dezenter
			}
		}
	}

	private var destinationRow: some View {
		HStack {
			Image(systemName: "map.fill") // Gefülltes Icon
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
				.opacity(0.7)

			Text(trip.destination)
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary) // Dezenter
		}
	}

	private var dateRow: some View {
		HStack {
			Image(systemName: "calendar")
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
				.opacity(0.7)

			Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary) // Dezenter
		}
	}

	private var tripStatusView: some View {
		Group {
			if trip.isCompleted {
				completedStatusRow
			} else {
				progressView
			}
		}
		.padding(.top, 5) // Etwas Abstand nach oben
	}

	private var completedStatusRow: some View {
		// ... (kann bleiben oder leicht angepasst werden) ...
		HStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.tripBuddySuccess)
			Text("Packliste komplett")
				.font(.caption)
				.foregroundColor(.tripBuddySuccess)

			Spacer()

			Text("\(trip.packingItems?.count ?? 0) Gegenstände")
				.font(.caption)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}

	private var progressView: some View {
		VStack(alignment: .leading, spacing: 5) { // Mehr Abstand
			HStack {
				Text("Fortschritt: \(Int(trip.packingProgress * 100))%") // Klarere Beschriftung
					.font(.caption.weight(.semibold)) // Etwas fetter
					.foregroundColor(progressColor(for: trip.packingProgress))

				Spacer()

				Text("\(trip.packingItems?.filter { $0.isPacked }.count ?? 0) / \(trip.packingItems?.count ?? 1) \(String(localized: "items_packed_short"))") // Kürzer: "Items gepackt"
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}

			ProgressView(value: trip.packingProgress)
				.progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
				.scaleEffect(x: 1, y: 2.5, anchor: .center) // Deutlich dickerer Balken
				.clipShape(Capsule()) // Abgerundet
		}
	}

	private var cardBackground: some View {
		RoundedRectangle(cornerRadius: 20) // Stärkere Rundung
			.fill(Color.tripBuddyCard) // Material verwenden für Tiefe? .fill(.regularMaterial)
			.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4) // Weicherer Schatten
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					// Kein Rand oder nur sehr subtil
					.stroke(Color.tripBuddyText.opacity(trip.isCompleted ? 0.1 : 0.05), lineWidth: 1)
			)
	}

	// MARK: - Helper Methods

	
	
}
