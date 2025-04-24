//
//  TripCard.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A card view component that displays a trip summary
struct TripCard: View {
	// MARK: - Properties
    
	let trip: Trip
	var onTap: () -> Void
    
	// MARK: - Body
    
	var body: some View {
		Button(action: onTap) {
			cardContent
		}
		.buttonStyle(.plain)
	}
    
	// MARK: - Computed Views
    
	private var cardContent: some View {
		VStack(alignment: .leading, spacing: 15) {
			tripHeader
			destinationRow
			dateRow
			tripProgressView
		}
		.padding(20)
		.background(cardBackground)
		.opacity(trip.isCompleted ? 0.8 : 1.0)
		.overlay(
			RoundedRectangle(cornerRadius: 6)
				.fill()
				.frame(width: 6)
				.padding(.vertical, 10),
			alignment: .leading
		)
	}
    
	private var tripHeader: some View {
		HStack {
			Text(trip.name)
				.font(.title3.weight(.semibold))
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
				.font(.caption.weight(.medium))
				.foregroundColor(.tripBuddySuccess)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 5)
		.background(Capsule().fill(Color.tripBuddySuccess.opacity(0.1)))
	}
    
	private var transportIcons: some View {
		HStack(spacing: 6) {
			ForEach(trip.transportTypesEnum, id: \.self) { type in
				Image(systemName: type.iconName)
					.font(.callout)
					.foregroundColor(.tripBuddyAccent)
					.opacity(0.8)
			}
		}
	}
    
	private var destinationRow: some View {
		HStack {
			Image(systemName: "map.fill")
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
				.opacity(0.7)
            
			Text(trip.destination)
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}
    
	private var dateRow: some View {
		HStack {
			Image(systemName: "calendar")
				.foregroundColor(.tripBuddyPrimary)
				.font(.subheadline)
				.opacity(0.7)
            
			Text(dateRangeText)
				.font(.subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}
    
	private var dateRangeText: String {
		let startText = trip.startDate.formatted(date: .abbreviated, time: .omitted)
		let endText = trip.endDate.formatted(date: .abbreviated, time: .omitted)
		return "\(startText) - \(endText)"
	}
    
	private var tripProgressView: some View {
		Group {
			if trip.isCompleted {
				completedStatus
			} else {
				packingProgress
			}
		}
		.padding(.top, 5)
	}
    
	private var completedStatus: some View {
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
    
	private var packingProgress: some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack {
				Text("Fortschritt: \(Int(trip.packingProgress * 100))%")
					.font(.caption.weight(.semibold))
					.foregroundColor(Color.progressColor(for: trip.packingProgress))
                
				Spacer()
                
				Text("\(trip.packingItems?.filter { $0.isPacked }.count ?? 0) / \(trip.packingItems?.count ?? 1) \(String(localized: "items_packed_short"))")
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}
            
			ProgressView(value: trip.packingProgress)
				.progressViewStyle(LinearProgressViewStyle(tint: Color.progressColor(for: trip.packingProgress)))
				.scaleEffect(x: 1, y: 2.5, anchor: .center)
				.clipShape(Capsule())
		}
	}
    
	private var cardBackground: some View {
		RoundedRectangle(cornerRadius: 20)
			.fill(Color.tripBuddyCard)
			.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					.stroke(Color.tripBuddyText.opacity(trip.isCompleted ? 0.1 : 0.05), lineWidth: 1)
			)
	}
}

// MARK: - Preview

#Preview {
	let previewTrip = Trip(
		name: "Sommerurlaub",
		destination: "Barcelona, Spanien",
		startDate: Date(),
		endDate: Date().addingTimeInterval(86400 * 7),
		transportTypes: [.plane, .car],
		accommodationType: .hotel,
		activities: [.beach, .sightseeing],
		isBusinessTrip: false,
		numberOfPeople: 2,
		climate: .hot
	)
    
	return TripCard(trip: previewTrip) {
		print("Card tapped")
	}
	.padding()
	.background(Color.tripBuddyBackground)
}
