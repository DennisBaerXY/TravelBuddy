import CoreLocation
import GooglePlacesSwift
import SwiftUI

/// ViewModel für die Google Places Autocomplete-Funktionalität
/// Verwaltet Ortssuche, Vorschläge und Ortsinformationen
@MainActor
class PlacesAutocompleteViewModel: ObservableObject {
	// MARK: - Published Properties
	
	/// Aktuelle Suchvorschläge
	@Published var suggestions: [AutocompleteSuggestion] = []
	
	/// Aktueller Suchtext
	@Published var searchText = ""
	
	/// Details zum ausgewählten Ort
	@Published var selectedPlace: Place?
	
	/// Bild des ausgewählten Ortes
	@Published var selectedPlaceImage: Image?
	
	/// Steuert die Anzeige der Vorschläge
	@Published var showPredictions = false
	
	/// Zeigt an, ob gerade Daten geladen werden
	@Published var isLoading = false
	
	/// Fehlermeldung, falls vorhanden
	@Published var errorMessage: String?
	
	// MARK: - Private Properties
	
	/// Der Google Places API Client
	private let placesClient = PlacesClient.shared
	
	/// Der aktuelle Session-Token für die Google Places API
	private var sessionToken = AutocompleteSessionToken()
	
	/// Ein Taskcancellable für laufende Suchanfragen
	private var searchTask: Task<Void, Never>?
	
	/// Verzögerung für Debouncing der Suche (in Sekunden)
	private let debounceDelay: TimeInterval = 0.3
	
	// MARK: - Öffentliche Methoden
	
	/// Sucht nach Orten basierend auf der Sucheingabe mit Debouncing
	/// - Parameter searchTerm: Der Suchbegriff
	func searchPlaces(searchTerm: String) {
		// Abbrechen vorheriger Suchanfragen
		searchTask?.cancel()
		
		// Neue Suchanfrage mit Verzögerung starten
		searchTask = Task {
			// Kurze Verzögerung für Debouncing
			try? await Task.sleep(for: .seconds(debounceDelay))
			
			// Sicherstellen, dass die Task nicht abgebrochen wurde
			guard !Task.isCancelled else { return }
			
			await findPredictions(for: searchTerm)
		}
	}
	
	/// Sucht nach Vorschlägen für den gegebenen Suchtext
	/// - Parameter query: Der Suchtext
	func findPredictions(for query: String) async {
		// Zurücksetzen des Fehlerstatus
		errorMessage = nil
		
		// Leeren Suchtext behandeln
		guard !query.isEmpty else {
			suggestions = []
			showPredictions = false
			return
		}
		
		isLoading = true
		defer { isLoading = false }
		
		// Filter für relevante Ortstypen
		let filter = AutocompleteFilter(types: [.regions], regionCode: LocalizationManager.shared.currentLanguage.countryCode)
		
		// Anfrage mit Session-Token vorbereiten
		let request = AutocompleteRequest(
			query: query,
			sessionToken: sessionToken,
			filter: filter
		)
		
		// API-Anfrage ausführen
		switch await placesClient.fetchAutocompleteSuggestions(with: request) {
		case .success(let autocompleteSuggestions):
			// Relevante Ergebnisse filtern
			suggestions = autocompleteSuggestions.filter { suggestion in
				switch suggestion {
				case .place:
					return true
				default:
					return false
				}
			}
			
			showPredictions = !suggestions.isEmpty
			
		case .failure(let placesError):
			suggestions = []
			showPredictions = false
			errorMessage = placesError.localizedDescription
			print("Places API Fehler: \(placesError.localizedDescription)")
		}
	}
	
	/// Holt detaillierte Informationen zu einem Ort anhand seiner ID
	/// - Parameter placeID: Die Google Place ID
	/// - Returns: Der formatierte Adressname oder nil bei Fehler
	func getPlaceDetails(for placeID: String) async -> String? {
		// Anfrage mit benötigten Feldern erstellen
		let fetchPlaceRequest = FetchPlaceRequest(
			placeID: placeID,
			placeProperties: [
				.displayName,
				.formattedAddress,
				
				.photos
			],
			sessionToken: sessionToken
		)
		
		// API-Anfrage ausführen
		switch await placesClient.fetchPlace(with: fetchPlaceRequest) {
		case .success(let place):
			// Nach erfolgreicher Abfrage Session-Token erneuern
			selectedPlace = place
			sessionToken = AutocompleteSessionToken()
			
			// Optionales Laden des Ortsbildes
			if let photos = place.photos, !photos.isEmpty {
				await fetchPlaceImage(photo: photos[0])
			}
			
			// Verwendbare Adresse zurückgeben
			return place.displayName ?? place.formattedAddress
			
		case .failure(let error):
			print("Fehler beim Abrufen der Ortsdetails: \(error.localizedDescription)")
			errorMessage = error.localizedDescription
			return nil
		}
	}
	
	/// Ruft das Bild für einen Ort ab
	/// - Parameter photo: Das Photo-Objekt von Google Places
	private func fetchPlaceImage(photo: Photo) async {
		let photoRequest = FetchPhotoRequest(
			photo: photo,
			maxSize: CGSizeMake(400, 300)
		)
		
		switch await placesClient.fetchPhoto(with: photoRequest) {
		case .success(let data):
			selectedPlaceImage = Image(uiImage: data)
			
		case .failure(let error):
			print("Fehler beim Laden des Bildes: \(error.localizedDescription)")
		}
	}
	
	/// Setzt alle Zustände zurück
	func reset() {
		searchText = ""
		suggestions = []
		showPredictions = false
		selectedPlace = nil
		selectedPlaceImage = nil
		errorMessage = nil
		sessionToken = AutocompleteSessionToken()
	}
}
