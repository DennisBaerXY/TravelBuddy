//
//  ActivitySelectButton.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import SwiftUI

struct ActivitySelectButton: View {
	let activity: Activity
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: activity.iconName)
					.font(.system(size: 24))

				Text(activity.localizedName)
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
