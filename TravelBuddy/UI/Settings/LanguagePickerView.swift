//
//  LanguagePickerView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A view for selecting the app language
struct LanguagePickerView: View {
	// MARK: - Environment
    
	@Environment(\.dismiss) private var dismiss
    
	// MARK: - State
    
	@State private var selectedLanguage = LocalizationManager.shared.currentLanguage
    
	// MARK: - Body
    
	var body: some View {
		NavigationStack {
			List {
				ForEach(AppLanguage.allCases, id: \.self) { language in
					Button {
						selectedLanguage = language
						LocalizationManager.shared.setLanguage(language)
						dismiss()
					} label: {
						HStack {
							Text("\(language.flag) \(language.displayName)")
								.foregroundColor(.primary)
                            
							Spacer()
                            
							if language == selectedLanguage {
								Image(systemName: "checkmark")
									.foregroundColor(.tripBuddyPrimary)
							}
						}
					}
				}
			}
			.navigationTitle("Select Language")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
		}
	}
}
