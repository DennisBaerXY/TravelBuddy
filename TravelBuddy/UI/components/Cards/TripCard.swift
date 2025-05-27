import GooglePlacesSwift
import SwiftUI

struct TripCard: View {
	// MARK: - Properties

	let trip: Trip
	@State private var placeImage: Image? = nil
	@State private var isLoadingImage = false
	@State private var showCompletionEffect = false // New state for the celebration effect

	// MARK: - Body

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Bild-Bereich
			ZStack(alignment: .topLeading) {
				// Bild oder Platzhalter
				if isLoadingImage {
					placeholderView
				} else if let image = placeImage {
					image
						.resizable()
						.aspectRatio(16 / 9, contentMode: .fill)
						.frame(height: 160)
						.clipped()
				} else {
					defaultImageView
				}

				// Info-Overlay unten
				VStack(alignment: .leading, spacing: 2) {
					Spacer()
					// Transportart-Symbole
					HStack(spacing: 4) {
						Text(trip.destination)
							.font(.callout).bold()
							.foregroundStyle(.white)

						Spacer()

						if !trip.isCompleted {
							transportIcons
						}
					}
				}

				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(12)
				.padding(.bottom, 4)
				.background(
					LinearGradient(
						gradient: Gradient(colors: [.black.opacity(0.3), .black.opacity(0)]),
						startPoint: .bottom,
						endPoint: .top
					)
				)
			}
			.frame(height: 160)

			// Inhalt
			VStack(alignment: .leading, spacing: 12) {
				// Titel und Status
				HStack {
					Text(trip.name)
						.font(.headline)
						.foregroundColor(.tripBuddyText)

					Spacer()

					if trip.isCompleted {
						completedBadge
					}
				}

				// Datum
				HStack {
					Image(systemName: "calendar")
						.foregroundColor(.tripBuddyPrimary)
						.font(.subheadline)
						.opacity(0.7)

					Text(dateRangeText)
						.font(.subheadline)
						.foregroundColor(.tripBuddyText)
				}

				// Fortschritt
				if !trip.isCompleted {
					packingProgress // Use the enhanced PackingProgressView here
						.padding(.top, 5)
				} else {
					completedStatus
						.padding(.top, 5)
				}
			}
			.padding(16)
		}
		.background(cardBackground)
		.cornerRadius(16)
		.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
		.opacity(trip.isCompleted ? 0.9 : 1.0)
		.overlay( // Add an overlay for the completion effect
			Group {
				if showCompletionEffect {
					// Simple celebration effect: a quick glow and scale
					RoundedRectangle(cornerRadius: 16)
						.stroke(Color.tripBuddySuccess, lineWidth: 4)
						.scaleEffect(1.05)
						.opacity(0.5)
						.animation(.easeInOut(duration: 0.5).repeatCount(1, autoreverses: true), value: showCompletionEffect)
				}
			}
		)
		.onAppear {
			if !trip.destinationPlaceId.isEmpty && placeImage == nil && !isLoadingImage {
				loadImageForPlace()
			}
			// Check for immediate completion effect on appear
			if trip.packingProgress >= 1.0 && !trip.isCompleted {
				triggerCompletionEffect()
			}
		}
		.onChange(of: trip.packingProgress) { _, newValue in // Trigger effect when progress reaches 1.0
			if newValue >= 1.0 && !trip.isCompleted {
				triggerCompletionEffect()
			} else {
				showCompletionEffect = false // Reset if progress drops below 1.0
			}
		}
	}

	// MARK: - Computed Views

	private var placeholderView: some View {
		ZStack {
			Rectangle()
				.fill(Color.gray.opacity(0.1))
				.frame(height: 160)

			ProgressView()
				.progressViewStyle(CircularProgressViewStyle(tint: .white))
		}
	}

	private var defaultImageView: some View {
		ZStack {
			Rectangle()
				.fill(Color.tripBuddyAccent.opacity(0.1))
				.frame(height: 160)

			Image(systemName: "photo")
				.font(.system(size: 30))
				.foregroundColor(.tripBuddyAccent.opacity(0.5))
		}
	}

	private var statusBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			// Status-Badge
			HStack(spacing: 4) {
				if trip.isCompleted {
					Text("ABGESCHLOSSEN")
				} else if trip.isActive {
					Text("AKTIV")
				} else {
					Text("GEPLANT")
				}
			}
			.font(.caption.bold())
			.foregroundColor(.white)
			.padding(.horizontal, 8)
			.padding(.vertical, 4)
			.background(statusColor)
			.cornerRadius(4)

			// Info mit Pin-Icon
			if !trip.destination.isEmpty {
				HStack(spacing: 4) {
					Image(systemName: "info.circle.fill")
						.font(.caption2)
					Text(trip.destination)
						.font(.caption2)
						.lineLimit(1)
				}
				.foregroundColor(.white)
				.padding(.horizontal, 8)
				.padding(.vertical, 4)
				.background(Color.black.opacity(0.6))
				.cornerRadius(4)
			}
		}
		.padding(8)
	}

	private var statusColor: Color {
		if trip.isCompleted {
			return .tripBuddySuccess
		} else if trip.isActive {
			return .tripBuddyPrimary
		} else {
			return .tripBuddyAccent
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
					.padding(4)
					.background(Circle().fill(.tripBuddyBackground.opacity(0.3)))
			}
		}
	}

	private var dateRangeText: String {
		let startText = trip.startDate.formatted(date: .abbreviated, time: .omitted)
		let endText = trip.endDate.formatted(date: .abbreviated, time: .omitted)
		return "\(startText) - \(endText)"
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

	// Modified packingProgress to use the enhanced PackingProgressView
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

			// Use the enhanced PackingProgressView
			PackingProgressView(
				progress: trip.packingProgress,
				showCompletionIcon: true // Show the completion icon on the card
			)
		}
	}

	private var cardBackground: some View {
		Color.tripBuddyCard
	}

	// MARK: - Helper Methods

	private func loadImageForPlace() {
		guard !trip.destinationPlaceId.isEmpty, placeImage == nil, !isLoadingImage else {
			return
		}

		isLoadingImage = true

		Task {
			let placesClient = PlacesClient.shared
			let fetchPlaceRequest = FetchPlaceRequest(placeID: trip.destinationPlaceId, placeProperties: [.photos])

			var fetchedPlace: Place
			switch await placesClient.fetchPlace(with: fetchPlaceRequest) {
			case .success(let place):
				fetchedPlace = place
			case .failure(let error):
				print("Error fetching place details: \(error)")
				isLoadingImage = false
				return
			}

			guard let photo = fetchedPlace.photos?.first else {
				isLoadingImage = false
				return
			}

			// Höhere Auflösung für bessere Bildqualität anfordern
			let fetchPhotoRequest = FetchPhotoRequest(photo: photo, maxSize: CGSizeMake(800, 450))

			switch await placesClient.fetchPhoto(with: fetchPhotoRequest) {
			case .success(let uiImage):
				// Bild für Querformat-Darstellung optimieren
				let processedImage = processImageForLandscapeDisplay(uiImage)

				self.placeImage = Image(uiImage: processedImage)
				self.isLoadingImage = false

			case .failure(let error):
				print("Error fetching photo: \(error)")
				isLoadingImage = false
			}
		}
	}

	// Funktion zur Optimierung des Bildes für Querformat-Anzeige
	private func processImageForLandscapeDisplay(_ image: UIImage) -> UIImage {
		let aspectRatio = image.size.width / image.size.height

		// Wenn bereits Querformat (oder annähernd), dann unverändert zurückgeben
		if aspectRatio >= 1.2 {
			return image
		}

		// Für Hochformatbilder: Mittleren Bereich ausschneiden
		let desiredAspectRatio: CGFloat = 16 / 9

		// Bei einem Portrait-Bild: Querformatigen Ausschnitt nehmen
		let cropHeight = image.size.width / desiredAspectRatio
		let yOffset = (image.size.height - cropHeight) / 2

		let cropRect = CGRect(
			x: 0,
			y: max(0, yOffset),
			width: image.size.width,
			height: min(cropHeight, image.size.height)
		)

		if let cgImage = image.cgImage?.cropping(to: cropRect) {
			return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
		}

		return image
	}

	// New method to trigger the completion effect
	private func triggerCompletionEffect() {
		showCompletionEffect = true
		// Optionally reset the effect after a short delay
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.showCompletionEffect = false
		}
	}
}

struct TripCard_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			// Light Mode
			ScrollView {
				VStack(spacing: 20) {
					// Aktive Reise mit Bild
					TripCard(trip: Trip.sampleTrip())
						.padding(.horizontal)

					// Geplante Reise ohne Bild
					TripCard(trip: Trip.sampleTrip())
						.padding(.horizontal)

					// Abgeschlossene Reise mit Bild
					TripCard(trip: Trip.sampleTrip())
						.padding(.horizontal)
				}
				.padding(.vertical)
			}
			.previewDisplayName("Light Mode")

			// Dark Mode
			ScrollView {
				TripCard(trip: Trip.sampleTrip())
					.padding()
			}
			.preferredColorScheme(.dark)
			.previewDisplayName("Dark Mode")

			// Accessibility: Larger Text
			TripCard(trip: Trip.sampleTrip())
				.environment(\.sizeCategory, .accessibilityLarge)
				.previewLayout(.sizeThatFits)
				.padding()
				.previewDisplayName("Large Text")

			// Compact View - iPhone SE
			TripCard(trip: Trip.sampleTrip())
				.padding(.horizontal)
				.previewDevice("iPhone SE (3rd generation)")
				.previewDisplayName("iPhone SE")

			// Landscape Preview
			TripCard(trip: Trip.sampleTrip())
				.padding(.horizontal)
				.previewLayout(.fixed(width: 667, height: 375))
				.previewDisplayName("Landscape iPhone")
		}
	}
}
