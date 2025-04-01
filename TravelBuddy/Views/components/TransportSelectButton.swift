//
//  TransportSelectButton.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import SwiftUI

struct TransportSelectButton: View {
	let type: TransportType
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: type.iconName)
					.font(.system(size: 24))

				Text(type.localizedName)
					.font(.caption)
					.lineLimit(1)
					.minimumScaleFactor(0.6)
			}
			.frame(minWidth: 80, minHeight: 80)
			.foregroundColor(isSelected ? .white : .primary)
			.background(isSelected ? Color.tripBuddyPrimary : Color(.systemGray6))
			.cornerRadius(12)
		}
	}
}
