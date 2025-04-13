//
//  TripDetailHeaderView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

// TravelBuddy/Views/Components/TripDetailHeaderView.swift
import SwiftUI

struct TripDetailHeaderView: View {
	// Use @ObservedObject if Trip might change from outside,
	// or just `let trip: Trip` if it's passed down and won't be replaced.
	// @Bindable is usually for the main view owning the data interaction.
	// Let's use `let` for simplicity here, assuming TripDetailView handles updates.
	let trip: Trip

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Image(systemName: "location.fill")
					.foregroundColor(.tripBuddyPrimary).opacity(0.7)
				Text(trip.destination).font(.headline)
				Spacer()
				Image(systemName: "calendar")
					.foregroundColor(.tripBuddyPrimary).opacity(0.7)
				Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
					.font(.subheadline)
			}
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text("\(Int(trip.packingProgress * 100))% \(String(localized: "packed"))")
						.font(.headline).foregroundColor(progressColor(for: trip.packingProgress))
					Spacer()
					Text("\((trip.packingItems?.filter { $0.isPacked }.count ?? 0))/\(trip.packingItems?.count ?? 0) \(String(localized: "items_count"))")
						.font(.caption).foregroundColor(.secondary)
				}
				ProgressView(value: trip.packingProgress)
					.progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
					.scaleEffect(x: 1, y: 1.5, anchor: .center)
					.clipShape(Capsule())
			}
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 16).fill(Color.tripBuddyCard)
			.shadow(color: Color.tripBuddyText.opacity(0.1), radius: 5, x: 0, y: 2))
		.padding(.horizontal)
	}
}

// Optional: Add PreviewProvider
// struct TripDetailHeaderView_Previews: PreviewProvider { ... }
