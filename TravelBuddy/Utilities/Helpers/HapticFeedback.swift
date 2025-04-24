//
//  HapticFeedback.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

// Hilfsstruktur für HapticFeedback (kann ausgelagert werden)
import UIKit

struct HapticFeedback {
	private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
	private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)

	init() {
		lightGenerator.prepare()
		mediumGenerator.prepare()
	}

	func light() { lightGenerator.impactOccurred() }
	func medium() { mediumGenerator.impactOccurred() }
}
