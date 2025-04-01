import SwiftUI

struct TripCardView: View {
	let trip: Trip
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Header
			HStack {
				Text(trip.name)
					.font(.headline)
				
				Spacer()
				
				if trip.isCompleted {
					// Abgeschlossen-Badge
					HStack(spacing: 4) {
						Image(systemName: "checkmark.seal.fill")
							.foregroundColor(.tripBuddySuccess)
						Text("Abgeschlossen")
							.font(.caption)
							.foregroundColor(.tripBuddySuccess)
					}
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.background(
						RoundedRectangle(cornerRadius: 8)
							.fill(Color.tripBuddySuccess.opacity(0.1))
					)
				} else {
					// Transport-Icons anzeigen
					HStack(spacing: 4) {
						ForEach(trip.transportTypesEnum, id: \.self) { type in
							Image(systemName: type.iconName)
								.font(.callout)
								.foregroundColor(.tripBuddyAccent)
						}
					}
				}
			}
			
			// Reiseziel und Datum
			HStack {
				Image(systemName: "location")
					.foregroundColor(.tripBuddyPrimary)
					.font(.subheadline)
				
				Text(trip.destination)
					.font(.subheadline)
			}
			
			HStack {
				Image(systemName: "calendar")
					.foregroundColor(.tripBuddyPrimary)
					.font(.subheadline)
				
				Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
					.font(.subheadline)
			}
			
			// Fortschrittsbalken oder Abgeschlossen-Status
			if trip.isCompleted {
				// Alternative Anzeige für abgeschlossene Reisen
				HStack {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.tripBuddySuccess)
					Text("Packliste komplett")
						.font(.caption)
						.foregroundColor(.tripBuddySuccess)
									
					Spacer()
									
					Text("\(trip.packingItems.count) Gegenstände")
						.font(.caption)
						.foregroundColor(.tripBuddyTextSecondary)
				}
			} else {
				// Standard-Fortschrittsanzeige für aktive Reisen
				VStack(alignment: .leading, spacing: 4) {
					HStack {
						Text(String("\(Int(trip.packingProgress * 100))%"))
							.font(.caption)
							.foregroundColor(progressColor(for: trip.packingProgress))

						Spacer()

						Text("\(trip.packingItems.filter { $0.isPacked }.count)/\(trip.packingItems.count) items_count")
							.font(.caption)
							.foregroundColor(.tripBuddyTextSecondary)
					}

					ProgressView(value: trip.packingProgress)
						.progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
				}
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(trip.isCompleted ? Color.tripBuddyCard.opacity(0.7) : Color.tripBuddyCard)
				.overlay(
					RoundedRectangle(cornerRadius: 16)
						.strokeBorder(
							trip.isCompleted ? Color.tripBuddyAccent.opacity(0.3) : Color.clear,
							lineWidth: trip.isCompleted ? 2 : 0
						)
				)
				.shadow(color: Color.tripBuddyText.opacity(trip.isCompleted ? 0.05 : 0.1), radius: 5, x: 0, y: 2)
		)
		.opacity(trip.isCompleted ? 0.9 : 1.0)
	}
	
	func progressColor(for value: Double) -> Color {
		if value < 0.3 {
			return .tripBuddyAlert
		} else if value < 0.7 {
			return .tripBuddyAccent
		} else {
			return .tripBuddySuccess
		}
	}
}
