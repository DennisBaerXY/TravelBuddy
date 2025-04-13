//
//  CollapsiblePackedSection.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

// TravelBuddy/Views/Components/CollapsiblePackedSection.swift
import SwiftUI

struct CollapsiblePackedSection: View {
	let categories: [ItemCategory]
	let groupedPackedItems: [ItemCategory: [PackItem]]
	let isTripCompleted: Bool
	let onUpdate: (PackItem) -> Void
	let onDelete: (PackItem) -> Void // Callback für Löschen
	@State var isExpanded: Bool = false // Initial ZUGEKLAPPT

	// Haptic Feedback
	private let deleteFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

	var totalPackedCount: Int {
		groupedPackedItems.reduce(0) { $0 + $1.value.count }
	}

	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			LazyVStack(alignment: .leading, spacing: 10) { // Geringerer Abstand bei gepackten?
				ForEach(categories, id: \.self) { category in
					// Zeige nur Kategorien an, die gepackte Items enthalten
					if let items = groupedPackedItems[category], !items.isEmpty {
						// Optional: Mini-Header für Kategorie
						// Text(category.localizedName).font(.caption).padding(.leading)

						ForEach(items) { item in
							PackItemRow(item: item, isDeactivated: isTripCompleted, onUpdate: onUpdate) // Pass isDeactivated
								.padding(.horizontal)
								.contextMenu {
									// Löschen im Context Menu
									if !isTripCompleted {
										Button(role: .destructive) {
											deleteFeedbackGenerator.impactOccurred() // Trigger haptic here
											onDelete(item)
										} label: {
											Label("delete", systemImage: "trash")
										}
									}
								}
								.transition(.opacity.combined(with: .move(edge: .bottom)))
						}
						// Optional: Trenner zwischen Kategorien hier
						// Divider().padding(.horizontal)
					}
				}
			}
			.padding(.top, 5)

		} label: {
			HStack {
				Image(systemName: "checkmark.circle.fill")
					.foregroundColor(.tripBuddySuccess)
				Text("already_packed_section_header")
					.font(.headline)
					.foregroundColor(.tripBuddyTextSecondary) // Gepackt weniger dominant
				Spacer()
				Text("\(totalPackedCount)")
					.font(.subheadline)
					.foregroundColor(.tripBuddyTextSecondary)
					.padding(.horizontal, 8)
					.background(Capsule().fill(Color.tripBuddyTextSecondary.opacity(0.1)))
			}
			.padding(.vertical, 5)
		}
		.padding(.horizontal)
		.tint(.tripBuddyAccent) // Farbe für Pfeil
		.onAppear {
			deleteFeedbackGenerator.prepare() // Prepare haptics
		}
	}
}

// Optional: Add a PreviewProvider if needed
// struct CollapsiblePackedSection_Previews: PreviewProvider { ... }
