//
//  CategoryFilterButton.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

// Komponenten/CategoryFilterButton.swift
import SwiftUI

struct CategoryFilterButton: View {
	let title: String
	var iconName: String? = nil
	let isSelected: Bool
	let action: () -> Void
	var body: some View {
		Button(action: action) {
			HStack {
				if let iconName = iconName {
					Image(systemName: iconName)
						.font(.caption)
				}
				Text(title)
					.font(.subheadline)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 8)
			.background(isSelected ? Color.tripBuddyPrimary : Color(.systemGray6))
			.foregroundColor(isSelected ? .white : .primary)
			.cornerRadius(20)
		}
	}
}
