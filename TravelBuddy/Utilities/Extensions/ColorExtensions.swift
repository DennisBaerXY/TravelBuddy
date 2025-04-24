//
//  ColorExtensions.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//
import Foundation
import SwiftUI
extension Color {
	static func progressColor(for value: Double) -> Color {
		if value < 0.3 {
			return .tripBuddyAlert.opacity(0.8)
		} else if value < 1 {
			return .tripBuddyAccent.opacity(0.8)
		} else {
			return .tripBuddySuccess
		}
	}
}
