// TripDetailView.swift
import SwiftData
import SwiftUI

struct TripDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Bindable var trip: Trip
	@State private var selectedCategory: String? = nil
	@State private var showingAddItem = false
	@State private var searchText = ""
	@State private var showingCompletionAlert = false
				
	var filteredItems: [PackItem] {
		// Sichere Unwrapping der optionalen packingItems
		guard let items = trip.packingItems else { return [] }
					
		var filteredItems = items
					
		// Nach Kategorie filtern
		if let category = selectedCategory {
			filteredItems = filteredItems.filter { $0.category == category }
		}
					
		// Nach Suchtext filtern
		if !searchText.isEmpty {
			filteredItems = filteredItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
		}
					
		// Sortierung: Unerledigte vor erledigten
		return filteredItems.sorted { ($0.isPacked) == false && ($1.isPacked) == true }
	}
			
	// Prüfen, ob alle Elemente abgehakt sind und die Liste nicht leer ist
	var allItemsCompleted: Bool {
		guard let items = trip.packingItems, !items.isEmpty else { return false }
		return items.allSatisfy { $0.isPacked }
	}
				
	var body: some View {
		ZStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					// Header
					tripHeader
								
					// Suchleiste
					searchBar
								
					// Kategorie-Filter
					categoryFilter
								
					// Packliste
					packingList
							
					// Hinweis, wenn Reise abgeschlossen ist
					if trip.isCompleted {
						completedBanner
					}
				}
				.padding(.bottom)
			}
					
			// Schwebender Button zum Abschließen der Liste
			if allItemsCompleted && !(trip.isCompleted) {
				VStack {
					Spacer()
					Button(action: {
						showingCompletionAlert = true
					}) {
						HStack {
							Image(systemName: "checkmark.circle.fill")
							Text("Reise abschließen")
						}
						.font(.headline)
						.padding()
						.background(Color.green)
						.foregroundColor(.white)
						.cornerRadius(30)
						.shadow(radius: 4)
					}
					.padding(.bottom, 20)
				}
			}
		}
		.navigationTitle(trip.name)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				if !(trip.isCompleted) {
					Button(action: {
						showingAddItem = true
					}) {
						Image(systemName: "plus")
					}
				}
			}
		}
		.sheet(isPresented: $showingAddItem) {
			AddItemView { newItem in
				modelContext.insert(newItem)
					
				// Inverse Beziehung für CloudKit setzen
				newItem.trip = trip
					
				// packingItems-Array initialisieren, falls es null ist
				if trip.packingItems == nil {
					trip.packingItems = []
				}
					
				// Element zur Packliste hinzufügen
				trip.packingItems?.append(newItem)
					
				// modificationDate für CloudKit aktualisieren
				trip.update()
					
				try? modelContext.save()
			}
		}
		.alert("Reise abschließen", isPresented: $showingCompletionAlert) {
			Button("Abbrechen", role: .cancel) {}
			Button("Abschließen") {
				markTripAsCompleted()
			}
		} message: {
			Text("Alle Elemente wurden abgehakt. Möchtest du die Reise als abgeschlossen markieren?")
		}
	}
			
	var completedBanner: some View {
		VStack {
			HStack {
				Image(systemName: "checkmark.seal.fill")
					.foregroundColor(.green)
				Text("Diese Reise wurde abgeschlossen")
					.font(.headline)
					.foregroundColor(.green)
				Spacer()
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(Color.green.opacity(0.1))
			)
		}
		.padding(.horizontal)
	}
			
	func markTripAsCompleted() {
		// Reise als abgeschlossen markieren
		trip.isCompleted = true
			
		// modificationDate für CloudKit aktualisieren
		trip.update()
			
		try? modelContext.save()
	}
				
	var tripHeader: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Reiseziel und Datum
			HStack {
				Image(systemName: "location")
					.foregroundColor(.tripBuddyPrimary)
					.font(.subheadline)
							
				Text(trip.destination)
					.font(.headline)
							
				Spacer()
							
				Image(systemName: "calendar")
					.foregroundColor(.tripBuddyPrimary)
					.font(.subheadline)
							
				Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted)) ")
					.font(.subheadline)
			}
						
			// Fortschrittsbalken
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text("\(Int(trip.packingProgress * 100))% ")
						.font(.headline)
						.foregroundColor(progressColor(for: trip.packingProgress))
								
					Spacer()
								
					Text("\((trip.packingItems?.filter { $0.isPacked }.count ?? 0))/\(trip.packingItems?.count ?? 0) items_count")
						.font(.caption)
						.foregroundColor(.secondary)
				}
							
				ProgressView(value: trip.packingProgress)
					.progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.tripBuddyCard)
				.shadow(color: Color.tripBuddyText.opacity(0.1), radius: 5, x: 0, y: 2)
		)
		.padding(.horizontal)
	}
				
	var searchBar: some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.foregroundColor(.secondary)
						
			TextField("search_placeholder", text: $searchText)
				.textFieldStyle(PlainTextFieldStyle())
					
			if !searchText.isEmpty {
				Button(action: {
					searchText = ""
				}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
				}
			}
		}
		.padding(10)
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.padding(.horizontal)
	}
				
	var categoryFilter: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				CategoryFilterButton(
					title: String(localized: "all_items"),
					isSelected: selectedCategory == nil
				) {
					selectedCategory = nil
				}
							
				ForEach(ItemCategory.allCases, id: \.self) { category in
					CategoryFilterButton(
						title: category.localizedName,
						iconName: category.iconName,
						isSelected: selectedCategory == category.rawValue
					) {
						selectedCategory = category.rawValue
					}
				}
			}
			.padding(.horizontal)
		}
	}
				
	var packingList: some View {
		VStack(spacing: 12) {
			if filteredItems.isEmpty {
				Text("no_items")
					.foregroundColor(.secondary)
					.padding(.vertical, 40)
			} else {
				ForEach(filteredItems) { item in
					PackItemRow(item: item) { updatedItem in
						if !(trip.isCompleted) {
							if let index = trip.packingItems?.firstIndex(where: { $0.id == updatedItem.id }) {
								trip.packingItems?[index].isPacked = updatedItem.isPacked
									
								// modificationDate für CloudKit aktualisieren
								trip.packingItems?[index].update()
								trip.update()
									
								try? modelContext.save()
							}
						}
					}
					.contentShape(Rectangle()) // Stellt sicher, dass die gesamte Zeile klickbar ist
				
					.opacity(trip.isCompleted ? 0.8 : 1.0)
						
					.contextMenu {
						if !(trip.isCompleted) {
							Button(role: .destructive, action: {
								deleteItem(item)
							}) {
								Label("delete", systemImage: "trash")
							}
						}
					}
				}
			}
					
		}.padding(.horizontal)
	}
				
	func progressColor(for value: Double) -> Color {
		if value < 0.3 {
			return .tripBuddyAlert
		} else if value < 0.7 {
			return .tripBuddyAccent
		} else {
			return .tripBuddySuccess
		}
	}
				
	func deleteItem(_ item: PackItem) {
		if !(trip.isCompleted) {
			trip.packingItems?.removeAll { $0.id == item.id }
			modelContext.delete(item)
				
			// modificationDate für CloudKit aktualisieren
			trip.update()
				
			try? modelContext.save()
		}
	}
}
