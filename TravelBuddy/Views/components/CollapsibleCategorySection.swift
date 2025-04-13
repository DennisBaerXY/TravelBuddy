//
//  CollapsibleCategorySection.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

// TravelBuddy/Views/Components/CollapsibleCategorySection.swift
import SwiftUI

struct CollapsibleCategorySection: View {
	let category: ItemCategory
	let items: [PackItem]
	@State var isExpanded: Bool // Lokaler State für diese Kategorie
	let isTripCompleted: Bool
	let onUpdate: (PackItem) -> Void
	let onDelete: (PackItem) -> Void // Callback für Löschen hinzugefügt

	// Haptic Feedback für Löschen (könnte auch übergeben werden)
	private let deleteFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

	init(category: ItemCategory, items: [PackItem], isInitiallyExpanded: Bool = true, isTripCompleted: Bool, onUpdate: @escaping (PackItem) -> Void, onDelete: @escaping (PackItem) -> Void) {
		self.category = category
		self.items = items
		self._isExpanded = State(initialValue: isInitiallyExpanded)
		self.isTripCompleted = isTripCompleted
		self.onUpdate = onUpdate
		self.onDelete = onDelete
	}

	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			// Liste der Items in dieser Kategorie
			LazyVStack(spacing: 10, pinnedViews: []) {
				ForEach(items) { item in
					PackItemRow(item: item, isDeactivated: isTripCompleted, onUpdate: onUpdate) // Pass isDeactivated
						.padding(.horizontal) // Padding für die Rows
						.contextMenu {
							// Löschen im Context Menu
							if !isTripCompleted { // Nur wenn Reise nicht abgeschlossen
								Button(role: .destructive) {
									deleteFeedbackGenerator.impactOccurred() // Trigger haptic here
									onDelete(item) // Callback aufrufen
								} label: {
									Label("delete", systemImage: "trash")
								}
							}
						}
						.transition(.opacity.combined(with: .move(edge: .top)))
				}
			}
			.padding(.top, 5)

		} label: {
			// Angepasster Header für die Kategorie
			HStack {
				Image(systemName: category.iconName)
					.foregroundColor(.tripBuddyPrimary)
				Text(category.localizedName)
					.font(.headline)
					.foregroundColor(.tripBuddyText)
				Spacer()
				Text("\(items.count)") // Anzahl Items
					.font(.subheadline)
					.foregroundColor(.tripBuddyTextSecondary)
					.padding(.horizontal, 8)
					.background(Capsule().fill(Color.tripBuddyTextSecondary.opacity(0.1)))
			}
			.padding(.vertical, 5)
		}
		.padding(.horizontal) // Padding für die gesamte DisclosureGroup
		.tint(.tripBuddyAccent) // Farbe für den Pfeil
		.onAppear {
			deleteFeedbackGenerator.prepare() // Prepare haptics
		}
	}
}

// Optional: Add a PreviewProvider if needed
// struct CollapsibleCategorySection_Previews: PreviewProvider { ... }
