import GooglePlacesSwift
import SwiftUI

/// Eine View für die Auswahl von Orten mit Autocomplete-Funktionalität
struct PlacesAutocompleteView: View {
	// MARK: - Properties
	
	/// Das ViewModel für die Places-API-Interaktion
	@ObservedObject var viewModel: PlacesAutocompleteViewModel
	
	/// Binding zum Zielort-String
	@Binding var destination: String
	
	/// Binding zur Place ID (optional)
	@Binding var destinationPlaceID: String?
	
	/// FocusState für das Textfeld
	@FocusState var isFocused: Bool
	
	// MARK: - Body
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Suchfeld
			TextField(
				String(localized: "destination_placeholder"),
				text: $viewModel.searchText
			)
			.focused($isFocused)
			.padding(.vertical, 10)
			
			.cornerRadius(8)
			.overlay(
				HStack {
					Spacer()
					
					// Ladeindikator
					if viewModel.isLoading {
						ProgressView()
							.padding(.trailing, 8)
					}
					
					// Löschen-Button
					else if !viewModel.searchText.isEmpty {
						Button {
							viewModel.searchText = ""
							viewModel.suggestions = []
							viewModel.showPredictions = false
							
							destinationPlaceID = nil
							destination = ""
						} label: {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(.secondary)
						}
						.padding(.trailing, 8)
					}
				}
			)
			.onChange(of: viewModel.searchText) { _, newValue in
				// Suche starten
				viewModel.searchPlaces(searchTerm: newValue)
			}
			
			// Vorschlagsliste
			if viewModel.showPredictions && isFocused {
				ScrollView {
					LazyVStack(alignment: .leading, spacing: 1) {
						// Vorschläge anzeigen
						ForEach($viewModel.suggestions, id: \.self) { suggestion in
							
							switch suggestion.wrappedValue {
							case .place(let place):
								suggestionRow(for: place)
									.contentShape(Rectangle())
									.onTapGesture {
										selectPlace(place)
									}
							}
						}
					}
					.padding(.vertical, 4)
				}
				.background(Color(.systemBackground))
				.cornerRadius(8)
				.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
				.frame(maxHeight: 250)
				.transition(.opacity)
			}
			
			// Fehlermeldung
			if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
					.font(.caption)
					.foregroundColor(.red)
					.padding(.top, 4)
					.padding(.horizontal)
			}
		}
	}
	
	// MARK: - Helper Methods
	
	/// Zeigt eine Vorschlagszeile an
	/// - Parameter suggestion: Die Ortsvorschlag-Struktur
	/// - Returns: Eine View mit den Vorschlagsinformationen
	private func suggestionRow(for place: AutocompletePlaceSuggestion) -> some View {
		HStack(alignment: .center, spacing: 12) {
			// Icon
			Image(systemName: "mappin.circle.fill")
				.foregroundColor(.accentColor)
				.font(.headline)
			
			// Text
			VStack(alignment: .leading, spacing: 2) {
				Text(place.attributedPrimaryText)
					.font(.subheadline)
					.foregroundColor(.primary)
				
				if place.attributedSecondaryText != nil {
					Text(place.attributedSecondaryText ?? "")
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 12)
		.background(Color(.systemBackground))
		.contentShape(Rectangle())
	}
	
	/// Wählt einen Ort aus und lädt dessen Details
	/// - Parameter suggestion: Der ausgewählte Ortsvorschlag
	private func selectPlace(_ place: AutocompletePlaceSuggestion) {
		Task {
			if let address = await viewModel.getPlaceDetails(for: place.placeID) {
				// Werte aktualisieren
				destination = address
				destinationPlaceID = place.placeID
				viewModel.searchText = address
				
				// UI aktualisieren
				viewModel.showPredictions = false
				isFocused = false
			}
		}
	}
}

// MARK: - Hilfserweiterungen

extension Optional where Wrapped == String {
	/// Gibt den Wert zurück oder einen leeren String, wenn nil
	var orEmpty: String {
		self ?? ""
	}
}

// MARK: - Vorschau

#Preview {
	struct PreviewWrapper: View {
		@State private var destination = ""
		@State private var placeID: String?
		@StateObject private var viewModel = PlacesAutocompleteViewModel()
		
		var body: some View {
			VStack(spacing: 20) {
				PlacesAutocompleteView(
					viewModel: viewModel,
					destination: $destination,
					destinationPlaceID: $placeID
				)
				
				Text("Gewähltes Ziel: \(destination)")
				Text("Place ID: \(placeID.orEmpty)")
			}
			.padding()
		}
	}
	
	return PreviewWrapper()
}
