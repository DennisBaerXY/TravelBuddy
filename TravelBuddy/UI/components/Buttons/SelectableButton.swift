//
//  SelectableButton.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A selectable button with icon and text used for multi-choice selections
struct SelectableButton: View {
	// MARK: - Properties
    
	let systemImage: String
	let text: String
	let isSelected: Bool
	let action: () -> Void
    
	// MARK: - Body
    
	var body: some View {
		Button(action: action) {
			VStack(spacing: 8) {
				// Icon
				Image(systemName: systemImage)
					.font(.system(size: 28))
					.foregroundColor(isSelected ? .tripBuddyPrimary : .tripBuddyTextSecondary)
                
				// Text label
				Text(text)
					.font(.caption)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
					.foregroundColor(isSelected ? .tripBuddyPrimary : .tripBuddyTextSecondary)
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 80)
			.padding(5)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(isSelected ? Color.tripBuddyPrimary.opacity(0.1) : Color.tripBuddyCard)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(isSelected ? Color.tripBuddyPrimary : Color.clear, lineWidth: 2)
			)
			.scaleEffect(isSelected ? 1.05 : 1.0)
			.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Preview

#Preview {
	VStack(spacing: 20) {
		HStack(spacing: 10) {
			SelectableButton(
				systemImage: "airplane",
				text: "Plane",
				isSelected: true
			) {}
            
			SelectableButton(
				systemImage: "car",
				text: "Car",
				isSelected: false
			) {}
            
			SelectableButton(
				systemImage: "tram",
				text: "Train",
				isSelected: false
			) {}
		}
        
		HStack(spacing: 10) {
			SelectableButton(
				systemImage: "building.2",
				text: "Hotel",
				isSelected: true
			) {}
            
			SelectableButton(
				systemImage: "tent",
				text: "Camping",
				isSelected: false
			) {}
		}
	}
	.padding()
	.background(Color.tripBuddyBackground)
}

// MARK: - Preview

#Preview {
	VStack(spacing: 20) {
		HStack(spacing: 10) {
			SelectableButton(
				systemImage: "airplane",
				text: "Plane",
				isSelected: true
			) {}
				
			SelectableButton(
				systemImage: "car",
				text: "Car",
				isSelected: false
			) {}
				
			SelectableButton(
				systemImage: "tram",
				text: "Train",
				isSelected: false
			) {}
		}
			
		HStack(spacing: 10) {
			SelectableButton(
				systemImage: "building.2",
				text: "Hotel",
				isSelected: true
			) {}
				
			SelectableButton(
				systemImage: "tent",
				text: "Camping",
				isSelected: false
			) {}
		}
	}
	.padding()
	.background(Color.tripBuddyBackground)
}
