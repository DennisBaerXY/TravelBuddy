import SwiftUI

struct PackItemRow: View {
	// Das 'item' kommt vom übergeordneten View (TripDetailView)
	// und repräsentiert den aktuellen Zustand im Model.
	let item: PackItem
	let isDeactivated: Bool
	let onUpdate: (PackItem) -> Void // Callback zum Ändern des Models

	// Lokaler State nur für transiente Animationen (wie Hintergrund-Flash)
	@State private var backgroundFlash = false

	// Haptic Feedback Generator
	private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

	var body: some View {
		HStack(spacing: 15) {
			// --- Checkbox ---
			// Die Darstellung hängt jetzt DIREKT von item.isPacked ab.
			ZStack {
				Circle() // Äußerer Ring
					.strokeBorder(checkboxColor, lineWidth: 2)
					.frame(width: 26, height: 26)
					.opacity(item.isPacked ? 0.5 : 1) // Ring wird blasser wenn checked

				Circle() // Innerer Füllkreis (animiert durch item.isPacked)
					.fill(checkboxColor)
					.frame(width: 20, height: 20)
					.scaleEffect(item.isPacked ? 1.0 : 0.01) // Skaliert basierend auf item.isPacked

				Image(systemName: "checkmark") // Checkmark (animiert durch item.isPacked)
					.font(.system(size: 12, weight: .bold))
					.foregroundColor(.white)
					.scaleEffect(item.isPacked ? 1.0 : 0.5)
					.opacity(item.isPacked ? 1.0 : 0.0)
			}
			// --- WICHTIG: Animation wird durch die Änderung von item.isPacked getriggert ---
			.animation(.spring(response: 0.35, dampingFraction: 0.6), value: item.isPacked)

			// --- Item Details (Text, Kategorie, etc.) ---
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					if item.isEssential {
						Image(systemName: "exclamationmark.triangle.fill")
							.foregroundColor(.tripBuddyAlert)
							.font(.caption)
					}
					Text(item.name)
						.strikethrough(item.isPacked, color: .tripBuddyTextSecondary)
						.fontWeight(item.isEssential ? .semibold : .regular)
						.foregroundColor(item.isPacked ? .tripBuddyTextSecondary : .tripBuddyText)
				}
				Text(item.categoryEnum.localizedName)
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
			}

			Spacer()

			// --- Quantity Anzeige ---
			if item.quantity > 1 {
				Text("×\(item.quantity)")
					.font(.subheadline.weight(.semibold))
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.background(Color.tripBuddyPrimary.opacity(0.1))
					.clipShape(Capsule())
					.foregroundColor(.tripBuddyPrimary)
			}
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 15)
		.background(backgroundForItem)
		.overlay( // Hintergrund-Highlight-Animation (bleibt lokal)
			RoundedRectangle(cornerRadius: 16)
				.fill(checkboxColor.opacity(0.2))
				.scaleEffect(backgroundFlash ? 1.0 : 0.8)
				.opacity(backgroundFlash ? 1 : 0)
				// Animation nur für den Flash-Effekt
				.animation(.easeOut(duration: 0.4), value: backgroundFlash)
		)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.contentShape(Rectangle()) // Ganze Zeile klickbar
		.onTapGesture {
			guard !isDeactivated else { return }
			// 1. Haptisches Feedback
			feedbackGenerator.impactOccurred()

			// Wichtig für Flash-Animation: War es vorher ungecheckt?
			let wasUnchecked = !item.isPacked

			let updatedItem = item // Kopie erstellen
			updatedItem.isPacked.toggle() // Zustand auf Kopie ändern
			onUpdate(updatedItem) // Kopie mit neuem Zustand übergeben

			// 3. Transiente Animationen auslösen (Hintergrund-Flash)
			if wasUnchecked { // Nur beim Abhaken flashen
				backgroundFlash = true
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
					backgroundFlash = false
				}
			}
			// Die Checkbox-Animation wird automatisch durch die Änderung von item.isPacked ausgelöst.
		}
		.allowsHitTesting(!isDeactivated)
		.onAppear {
			// Bereite den Generator vor
			feedbackGenerator.prepare()
			// KEINE Initialisierung von isCheckedForAnimation mehr nötig
		}
	}

	// --- Computed Properties für Farben/Hintergrund (unverändert) ---
	var checkboxColor: Color {
		if item.isEssential && !item.isPacked {
			return .tripBuddyAlert
		} else if item.isPacked {
			return .tripBuddySuccess
		} else {
			return .tripBuddyPrimary.opacity(0.8)
		}
	}

	var backgroundForItem: Color {
		if item.isPacked {
			return Color.tripBuddyCard.opacity(0.7)
		} else if item.isEssential {
			return Color.tripBuddyAlert.opacity(0.05)
		} else {
			return Color.tripBuddyCard
		}
	}
}
