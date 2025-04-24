import GooglePlacesSwift
import SwiftUI

struct TripCard: View {
	// MARK: - Properties

	let trip: Trip
	@State private var placeImage: Image? = nil // State to hold the loaded image
	@State private var isLoadingImage = false // State to track loading
	
	// MARK: - Body

	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			tripHeader
			
			// Ortsbild (falls verfügbar)
			if isLoadingImage {
				ZStack {
					RoundedRectangle(cornerRadius: 12)
						.fill(Color.gray.opacity(0.1))
						.frame(height: 140)
					
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: .tripBuddyPrimary))
				}
				.padding(.vertical, 5)
			}
			// Wenn das Bild geladen ist, zeige es
			else if let image = placeImage {
				image
					.resizable()
					.aspectRatio(contentMode: .fill) // Füllt den Rahmen aus
					.frame(height: 140)
					.clipped() // Schneidet Überläufe ab
					// Verwende overlay mit ZStack für einen Farbverlauf am unteren Rand
					.overlay(
						ZStack(alignment: .bottom) {
							// Farbverlauf für bessere Lesbarkeit des darüberliegenden Textes
							LinearGradient(
								gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
								startPoint: .top,
								endPoint: .bottom
							)
							.frame(height: 50) // Nur unterer Bereich
						}
					)
					.clipShape(RoundedRectangle(cornerRadius: 12))
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.tripBuddyText.opacity(0.1), lineWidth: 1)
					)
					.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
					.padding(.vertical, 5)
			}
			destinationRow
			dateRow
			tripProgressView
		}
		.padding(20)
		.background(cardBackground)
		.opacity(trip.isCompleted ? 0.8 : 1.0)
		.overlay(
			RoundedRectangle(cornerRadius: 6)
				.fill(statusColor)
				.frame(width: 6)
				.padding(.vertical, 10),
			alignment: .leading
		)
		.onAppear { // Trigger image loading when the card appears
			if !trip.destinationPlaceId.isEmpty && placeImage == nil && !isLoadingImage {
				loadImageForPlace()
			}
		}
	}
	
	// MARK: - Computed Views & Properties
	
	private var statusColor: Color {
		if trip.isCompleted {
			return .tripBuddySuccess
		} else if trip.isActive {
			return .tripBuddyPrimary
		} else {
			return .tripBuddyAccent
		}
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
			ForEach(trip.transportTypesEnum) { type in
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
	
	private func loadImageForPlace() {
		print("Starting loading for \(trip.destinationPlaceId) ")
		// Only load if we have a place ID and haven't loaded yet
		guard !trip.destinationPlaceId.isEmpty, placeImage == nil, !isLoadingImage else {
			print("Not loading image")
			return
		}

		isLoadingImage = true

		Task { // Perform asynchronous loading in a Task
			// 1. Fetch Place Details (specifically asking for photos)
			let placesClient = PlacesClient.shared
				
			let fetchPlaceRequest = FetchPlaceRequest(placeID: trip.destinationPlaceId, placeProperties: [.photos])
				
			var fetchedPlace: Place
			switch await placesClient.fetchPlace(with: fetchPlaceRequest) {
			case .success(let place):
				fetchedPlace = place
				
			case .failure(let placesError):
				print("Error fetching place details: \(placesError)")
				isLoadingImage = false
				return
			}
				
			guard let photo = fetchedPlace.photos?.first else {
				print("Place has no photos")
				isLoadingImage = false
				return
			}
				
			let fetchPhotoRequest = FetchPhotoRequest(photo: photo, maxSize: CGSizeMake(400, 300))
			// 3. Fetch the actual photo image
			var image: UIImage = .init()
			switch await placesClient.fetchPhoto(with: fetchPhotoRequest) {
			case .success(let uiImage):
				image = uiImage
				print("Photo fetched successfully!")
			case .failure(let error):
				print("Error fetching photo: \(error)")
				isLoadingImage = false
				return
			}
			// 4. Update the state with the loaded image
			await MainActor.run { // Ensure UI update is on the main thread
				self.placeImage = Image(uiImage: image)
				self.isLoadingImage = false
			}
		}
	}
}
