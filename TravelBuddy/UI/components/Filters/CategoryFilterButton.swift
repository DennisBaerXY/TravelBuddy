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
			HStack(spacing: 5) {
				if let iconName = iconName {
					Image(systemName: iconName)
						.font(.footnote)
				}
				Text(title)
					.font(.footnote)
			}
			.padding(.vertical, 6)
			.padding(.horizontal, 12)
			.background(isSelected ? Color.tripBuddyPrimary : Color.tripBuddyCard)
			.foregroundColor(isSelected ? .white : .tripBuddyText)
			.cornerRadius(20)
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					.stroke(isSelected ? Color.clear : Color.tripBuddyText.opacity(0.2), lineWidth: 1)
			)
		}
		.buttonStyle(PlainButtonStyle())
	}
}
