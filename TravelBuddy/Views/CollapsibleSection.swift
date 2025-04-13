//
//  CollapsibleSection.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

import SwiftUI
struct CollapsibleSection<Content: View>: View {
	let title: LocalizedStringKey
	let iconName: String
	let itemCount: Int
	let iconColor: Color
	var textColor: Color = .tripBuddyText
	var initiallyExpanded: Bool = true
	let content: () -> Content

	@State private var isExpanded: Bool

	init(title: LocalizedStringKey, iconName: String, itemCount: Int, iconColor: Color, textColor: Color = .tripBuddyText, initiallyExpanded: Bool = true, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.iconName = iconName
		self.itemCount = itemCount
		self.iconColor = iconColor
		self.textColor = textColor
		self.initiallyExpanded = initiallyExpanded
		self.content = content
		self._isExpanded = State(initialValue: initiallyExpanded)
	}

	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			LazyVStack(spacing: 10) {
				content()
			}
			.padding(.top, 5)
		} label: {
			HStack {
				Image(systemName: iconName)
					.foregroundColor(iconColor)
				Text(title)
					.font(.headline)
					.foregroundColor(textColor)
				Spacer()
				Text("\(itemCount)")
					.font(.subheadline)
					.foregroundColor(.tripBuddyTextSecondary)
					.padding(.horizontal, 8)
					.background(Capsule().fill(Color.tripBuddyTextSecondary.opacity(0.1)))
			}
			.padding(.vertical, 5)
		}
		.padding(.horizontal)
		.tint(.tripBuddyPrimary)
	}
}
