//
//  SelectableShow.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 30.04.25.
//

import SwiftUI

struct SelectableExampleView: View {
	var body: some View {
		VStack(alignment: .leading) {
			Section {
				LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
					ForEach(Activity.allCases.prefix(3)) { type in

						SelectableButton(
							systemImage: type.iconName,
							// Convert LocalizedStringKey to String
							text: type.displayName(),
							isSelected: type == Activity.business ? true : false
						) {}
					}
				}
			}
		}

		.padding()
		.frame(height: 250)

		.clipShape(.rect(cornerRadius: 15))
	}
}

#Preview {
	SelectableExampleView()
}
