import SwiftUI

/// A header view displaying trip information and summary
struct TripHeaderView: View {
	// MARK: - Properties
	
	/// The trip to display information for
	let trip: Trip
	
	/// Whether to show a compact version of the header
	var isCompact: Bool = false
	
	// MARK: - Body
	
	var body: some View {
		VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
			// Trip destination and dates
			HStack {
				destinationView
				
				Spacer()
				
				dateRangeView
			}
			
			// Optional divider for visual separation
			if !isCompact {
				Divider()
					.padding(.vertical, 4)
			}
			
			// Trip progress and status
			tripProgressView
		}
		.padding(isCompact ? 12 : 16)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.tripBuddyCard)
				.shadow(color: Color.tripBuddyText.opacity(0.1), radius: 5, x: 0, y: 2)
		)
		.padding(.horizontal)
	}
	
	// MARK: - Computed Views
	
	/// View showing the trip destination with icon
	private var destinationView: some View {
		HStack(spacing: 6) {
			Image(systemName: "location.fill")
				.foregroundColor(.tripBuddyPrimary)
				.opacity(0.7)
				.font(isCompact ? .subheadline : .body)
			
			Text(trip.destination)
				.font(isCompact ? .subheadline : .headline)
				.foregroundColor(.tripBuddyText)
				.lineLimit(1)
		}
	}
	
	/// View showing the date range with icon
	private var dateRangeView: some View {
		HStack(spacing: 6) {
			Image(systemName: "calendar")
				.foregroundColor(.tripBuddyPrimary)
				.opacity(0.7)
				.font(isCompact ? .caption : .subheadline)
			
			Text(formattedDateRange)
				.font(isCompact ? .caption : .subheadline)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}
	
	/// View showing the trip progress and status
	private var tripProgressView: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				// Status text with progress percentage
				Text("\(Int(trip.packingProgress * 100))% \(String(localized: "packed"))")
					.font(isCompact ? .subheadline : .headline)
					.foregroundColor(determineProgressColor(for: trip.packingProgress))
				
				Spacer()
				
				// Item count
				Text(itemCountText)
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}
			
			// Progress bar
			PackingProgressView(
				progress: trip.packingProgress,
				isCompact: isCompact
			)
		}
	}
	
	// MARK: - Helpers
	
	/// Determines the appropriate color for a progress value
	/// - Parameter value: Progress value between 0.0 and 1.0
	/// - Returns: Color for the progress
	private func determineProgressColor(for value: Double) -> Color {
		if value < 0.3 {
			return .tripBuddyAlert.opacity(0.8)
		} else if value < 1 {
			return .tripBuddyAccent.opacity(0.8)
		} else {
			return .tripBuddySuccess
		}
	}
	
	/// Formatted date range string
	private var formattedDateRange: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		if isCompact {
			// Use shorter format for compact view
			return trip.startDate.compactFormattedRange(to: trip.endDate)
		} else {
			return trip.startDate.formattedRange(to: trip.endDate)
		}
	}
	
	/// Item count text showing packed/total items
	private var itemCountText: String {
		let packedCount = trip.packingItems?.filter { $0.isPacked }.count ?? 0
		let totalCount = trip.packingItems?.count ?? 0
		return "\(packedCount)/\(totalCount) \(String(localized: "items_count"))"
	}
}

// MARK: - Alternative Variants

extension TripHeaderView {
	/// A minimal variant of the header just showing destination and dates
	static func minimal(trip: Trip) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				HStack(spacing: 4) {
					Image(systemName: "location.fill")
						.foregroundColor(.tripBuddyPrimary)
						.font(.caption)
					
					Text(trip.destination)
						.font(.subheadline.bold())
						.lineLimit(1)
				}
				
				HStack(spacing: 4) {
					Image(systemName: "calendar")
						.foregroundColor(.tripBuddyPrimary)
						.font(.caption2)
					
					Text(trip.startDate.compactFormattedRange(to: trip.endDate))
						.font(.caption)
						.foregroundColor(.tripBuddyTextSecondary)
				}
			}
			
			Spacer()
			
			// Optional badge if needed
			if trip.isCompleted {
				Text("Completed")
					.font(.caption)
					.foregroundColor(.white)
					.padding(.horizontal, 8)
					.padding(.vertical, 3)
					.background(Color.tripBuddySuccess)
					.cornerRadius(8)
			}
		}
		.padding(10)
		.background(Color.tripBuddyCard)
		.cornerRadius(12)
	}
	
	/// A card variant with a colored background based on progress
	static func card(trip: Trip) -> some View {
		// Helper function to determine progress color
		func cardProgressColor(for value: Double) -> Color {
			if value < 0.3 {
				return .tripBuddyAlert.opacity(0.8)
			} else if value < 1 {
				return .tripBuddyAccent.opacity(0.8)
			} else {
				return .tripBuddySuccess
			}
		}
		
		return VStack(alignment: .leading, spacing: 12) {
			// Title and badge
			HStack {
				Text(trip.name)
					.font(.headline)
					.foregroundColor(.white)
				
				Spacer()
				
				// Transit icons
				HStack(spacing: 6) {
					ForEach(trip.transportTypesEnum, id: \.self) { type in
						Image(systemName: type.iconName)
							.font(.caption)
							.foregroundColor(.white.opacity(0.8))
					}
				}
			}
			
			// Destination
			HStack(spacing: 6) {
				Image(systemName: "location.fill")
					.foregroundColor(.white.opacity(0.9))
					.font(.caption)
				
				Text(trip.destination)
					.font(.subheadline)
					.foregroundColor(.white)
			}
			
			// Dates
			HStack(spacing: 6) {
				Image(systemName: "calendar")
					.foregroundColor(.white.opacity(0.9))
					.font(.caption)
				
				Text(trip.startDate.compactFormattedRange(to: trip.endDate))
					.font(.caption)
					.foregroundColor(.white.opacity(0.9))
			}
			
			Spacer(minLength: 4)
			
			// Progress
			PackingProgressView(
				progress: trip.packingProgress,
				isCompact: true,
				trackColor: .white.opacity(0.3),
				progressColor: .white
			)
			
			// Item count
			let packedCount = trip.packingItems?.filter { $0.isPacked }.count ?? 0
			let totalCount = trip.packingItems?.count ?? 0
			
			Text("\(packedCount)/\(totalCount) packed")
				.font(.caption2)
				.foregroundColor(.white.opacity(0.9))
		}
		.padding(16)
		.background(
			LinearGradient(
				gradient: Gradient(colors: [
					cardProgressColor(for: trip.packingProgress),
					cardProgressColor(for: trip.packingProgress).opacity(0.8)
				]),
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		)
		.cornerRadius(16)
	}
}

// MARK: - Preview

#Preview {
	let sampleTrip = Trip(
		name: "Summer Vacation",
		destination: "Barcelona, Spain",
		startDate: Date(),
		endDate: Date().addingTimeInterval(86400 * 7),
		transportTypes: [.plane, .car],
		accommodationType: .hotel,
		activities: [.beach, .sightseeing, .swimming],
		isBusinessTrip: false,
		numberOfPeople: 2,
		climate: .hot
	)
		
	// Add sample packing items
	let items = [
		PackItem(name: "Passport", category: .documents, isEssential: true),
		PackItem(name: "Swimwear", category: .clothing),
		PackItem(name: "Sunscreen", category: .toiletries),
		PackItem(name: "Camera", category: .electronics, isPacked: true),
		PackItem(name: "T-Shirts", category: .clothing, quantity: 5)
	]
		
	sampleTrip.packingItems = items
		
	// Set up the relationship
	for item in items {
		item.trip = sampleTrip
	}
		
	// Set some items as packed
	if let packingItems = sampleTrip.packingItems {
		for (index, item) in packingItems.enumerated() where index % 2 == 0 {
			item.isPacked = true
		}
	}
		
	return VStack(spacing: 20) {
		TripHeaderView(trip: sampleTrip)
			
		TripHeaderView(trip: sampleTrip, isCompact: true)
	}
	.padding(.vertical)
	.background(Color.tripBuddyBackground)
}
