import SwiftUI

struct TripCardView: View {
	let trip: Trip
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			tripHeader
			destinationRow
			dateRow
			tripStatusView
		}
		.padding()
		.background(cardBackground)
		.opacity(trip.isCompleted ? 0.9 : 1.0)
	}
	
	// MARK: - Components
	
	private var tripHeader: some View {
		HStack {
			Text(trip.name)
				.font(.headline)
			
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
				.font(.caption)
				.foregroundColor(.tripBuddySuccess)
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(Color.tripBuddySuccess.opacity(0.1))
		)
	}
	
	private var transportIcons: some View {
		HStack(spacing: 4) {
			ForEach(trip.transportTypesEnum, id: \.self) { type in
				Image(systemName: type.iconName)
					.font(.callout)
					.foregroundColor(.tripBuddyAccent)
			}
		}
	}
	
	private var destinationRow: some View {
		HStack {
			Image(systemName: "location")
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
			
			Text(trip.destination)
				.font(.subheadline)
		}
	}
	
	private var dateRow: some View {
		HStack {
			Image(systemName: "calendar")
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
			
			Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
				.font(.subheadline)
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
	}
	
	private var completedStatusRow: some View {
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
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				Text(String("\(Int(trip.packingProgress * 100))%"))
					.font(.caption)
					.foregroundColor(progressColor(for: trip.packingProgress))
				
				Spacer()
				
				Text("\(trip.packingItems?.filter { $0.isPacked }.count ?? 0)/\(trip.packingItems?.count ?? 1) items_count")
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}
			
			ProgressView(value: trip.packingProgress)
				.progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
		}
	}
	
	private var cardBackground: some View {
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
	}
	
	// MARK: - Helper Methods
	
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
