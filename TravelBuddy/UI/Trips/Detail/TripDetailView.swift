import SwiftData
import SwiftUI

struct TripDetailView: View {
	// MARK: - Environment & State

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@Environment(TripRepository.self) private var repository

	// Der Trip wird direkt übergeben und beobachtet
	@Bindable var trip: Trip

	// UI State direkt in der View
	@State private var selectedCategoryFilter: ItemCategory?
	@State private var searchText = ""
	@State private var showingAddItem = false
	@State private var showingCompletionAlert = false
	@State private var currentSortOption: SortOption = .name // Default: Aus UserSettings holen
	@State private var currentSortOrder: SortOrder = .ascending // Default: Aus UserSettings holen

	// Haptic Feedback
	private let hapticFeedback = HapticFeedback() // Beibehalten oder als Environment-Service

	// MARK: - Computed Properties (Filterung & Sortierung)

	private var items: [PackItem] {
		// Sortiere zuerst nach Priorität (essential) falls gewünscht
		let userSettings = UserSettingsManager.shared // Zugriff auf Settings
		let sortedByPriority = trip.packingItems?.sorted {
			if userSettings.prioritizeEssentialItems {
				if $0.isEssential != $1.isEssential {
					return $0.isEssential && !$1.isEssential // Essentials zuerst
				}
			}
			// Wenn Priorität gleich ist oder nicht priorisiert wird, Fallback (wird unten sortiert)
			return false
		} ?? []

		// Filtern
		let filtered = sortedByPriority.filter { item in
			let matchesSearch = searchText.isEmpty ||
				item.name.localizedStandardContains(searchText) // Standard-Suche ist oft besser
			let matchesCategory = selectedCategoryFilter == nil ||
				item.categoryEnum == selectedCategoryFilter
			return matchesSearch && matchesCategory
		}

		// Finale Sortierung anwenden
		return filtered.sorted { itemSortComparator(item1: $0, item2: $1) }
	}

	private var itemsToPack: [PackItem] {
		items.filter { !$0.isPacked }
	}

	private var packedItems: [PackItem] {
		items.filter { $0.isPacked }
	}

	// Gruppierte Items für die Sections
	private var groupedItemsToPack: [ItemCategory: [PackItem]] {
		Dictionary(grouping: itemsToPack, by: { $0.categoryEnum })
	}

	private var groupedPackedItems: [ItemCategory: [PackItem]] {
		Dictionary(grouping: packedItems, by: { $0.categoryEnum })
	}

	// Kategorien, die in den gefilterten/sortierten Items vorkommen
	private var categoriesToShowInSections: [ItemCategory] {
		let categoriesInToPack = Set(groupedItemsToPack.keys)
		let categoriesInPacked = Set(groupedPackedItems.keys)
		let allRelevantCategories = categoriesInToPack.union(categoriesInPacked)
		// Behalte die Reihenfolge von ItemCategory.allCases bei
		return ItemCategory.allCases.filter { allRelevantCategories.contains($0) }
	}

	// Kategorien, die überhaupt im Trip vorkommen (für Filterleiste)
	private var categoriesPresentInTrip: [ItemCategory] {
		guard let allItems = trip.packingItems else { return [] }
		let uniqueCategories = Set(allItems.map { $0.categoryEnum })
		// Behalte die Reihenfolge von ItemCategory.allCases bei
		return ItemCategory.allCases.filter { uniqueCategories.contains($0) }
	}

	/// Funktion, die zwei Items basierend auf den aktuellen Sortiereinstellungen vergleicht
	private func itemSortComparator(item1: PackItem, item2: PackItem) -> Bool {
		let orderMultiplier: Int = (currentSortOrder == .ascending) ? 1 : -1
		let comparison: ComparisonResult

		switch currentSortOption {
		case .name:
			comparison = item1.name.localizedStandardCompare(item2.name)
		case .category:
			// Optional: Sekundäre Sortierung nach Name innerhalb der Kategorie
			if item1.categoryEnum.rawValue == item2.categoryEnum.rawValue {
				comparison = item1.name.localizedStandardCompare(item2.name)
			} else {
				// Finde Indizes in allCases für stabile Sortierung
				let index1 = ItemCategory.allCases.firstIndex(of: item1.categoryEnum) ?? 0
				let index2 = ItemCategory.allCases.firstIndex(of: item2.categoryEnum) ?? 0
				comparison = index1 < index2 ? .orderedAscending : .orderedDescending
			}
		case .essential:
			// Essentials zuerst (unabhängig von orderMultiplier, da es binär ist)
			if item1.isEssential != item2.isEssential {
				return item1.isEssential && !item2.isEssential
			} else {
				// Sekundäre Sortierung nach Name
				comparison = item1.name.localizedStandardCompare(item2.name)
			}
		case .dateAdded:
			// Annahme: PackItem hat ein 'createdAt' Datum (muss ggf. hinzugefügt werden)
			// comparison = item1.createdAt.compare(item2.createdAt)
			comparison = item1.modificationDate.compare(item2.modificationDate) // Fallback: modificationDate
		}

		// Wende die Sortierrichtung an
		return comparison.rawValue * orderMultiplier < 0
	}

	/// Returns true if all items in the trip are packed
	var allItemsCompleted: Bool {
		guard let items = trip.packingItems, !items.isEmpty else { return false }
		return items.allSatisfy { $0.isPacked }
	}

	/// Returns true if the sort settings are non-default
	var isSortingActive: Bool {
		currentSortOption != UserSettingsManager.shared.defaultSortOption || currentSortOrder != UserSettingsManager.shared.defaultSortOrder
	}

	/// Returns the localized string key for the current sort order
	var sortOrderLabelKey: LocalizedStringKey {
		currentSortOrder == .ascending ? "sort_ascending" : "sort_descending"
	}

	/// Returns the system image name for the current sort order
	var sortOrderIconName: String {
		currentSortOrder == .ascending ? "arrow.up.square" : "arrow.down.square"
	}

	/// Returns the appropriate localized string key for the empty state
	var noResultsTextKey: LocalizedStringKey {
		if !searchText.isEmpty {
			return "no_search_results"
		} else if selectedCategoryFilter != nil {
			return "no_items_in_category"
		} else if trip.packingItems?.isEmpty ?? true {
			return "no_items_yet_add_some" // Eigene Lokalisierung hinzufügen
		} else {
			return "all_items_packed_or_filtered" // Eigene Lokalisierung hinzufügen
		}
	}

	// MARK: - Body

	var body: some View {
		ZStack {
			Color.tripBuddyBackground.ignoresSafeArea()

			ScrollView {
				VStack(alignment: .leading, spacing: 15) {
					TripHeaderView(trip: trip) // Übergibt den @Bindable Trip

					searchAndFilterBar

					packingListContent
				}
				.padding(.bottom, 80)
			}

			floatingActionContent
		}
		.navigationTitle(trip.name) // Greift direkt auf Trip zu
		.toolbar { toolbarButtons }
		.sheet(isPresented: $showingAddItem) { addItemSheet }
		.alert("complete_trip_alert_title", isPresented: $showingCompletionAlert) {
			completionAlertButtons
		} message: {
			Text("complete_trip_alert_message")
		}
		.onAppear {
			// Lade initiale Sortiereinstellungen aus UserSettings
			currentSortOption = UserSettingsManager.shared.defaultSortOption
			currentSortOrder = UserSettingsManager.shared.defaultSortOrder
		}
		// Animationen können beibehalten oder angepasst werden
		.animation(.default, value: items) // Animiert Änderungen in der gefilterten Liste
		.animation(.default, value: currentSortOption)
		.animation(.default, value: currentSortOrder)
		.animation(.default, value: selectedCategoryFilter)
		.animation(.default, value: searchText)
	}

	// MARK: - Subviews (searchAndFilterBar, floatingActionContent etc. bleiben ähnlich)

	private var searchAndFilterBar: some View {
		VStack(spacing: 10) {
			HStack {
				Image(systemName: "magnifyingglass").foregroundColor(.secondary)
				TextField("search_placeholder", text: $searchText)
					.textFieldStyle(PlainTextFieldStyle())
					.submitLabel(.search)

				if !searchText.isEmpty {
					Button { searchText = "" } label: {
						Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
					}
					.buttonStyle(.plain)
					.transition(.opacity.combined(with: .scale))
				}
			}
			.padding(10)
			.background(Color.tripBuddyCard)
			.cornerRadius(10)
			.padding(.horizontal)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 8) {
					CategoryFilterButton(
						title: String(localized: "all_items"),
						isSelected: selectedCategoryFilter == nil
					) { withAnimation { selectedCategoryFilter = nil } }

					ForEach(categoriesPresentInTrip, id: \.self) { category in
						CategoryFilterButton(
							title: category.localizedName,
							iconName: category.iconName,
							isSelected: selectedCategoryFilter == category
						) { withAnimation { selectedCategoryFilter = category } }
					}
				}
				.padding(.horizontal)
			}
		}
	}

	private var packingListContent: some View {
		VStack(alignment: .leading, spacing: 25) {
			// Items zum Packen
			if !itemsToPack.isEmpty {
				sectionHeader(
					titleKey: "to_pack_section_header \(itemsToPack.count)", // Direkte Zählung
					color: .tripBuddyPrimary
				)

				ForEach(categoriesToShowInSections, id: \.self) { category in
					// Zeige nur Sections an, für die es ungepackte Items gibt
					if let itemsInSection = groupedItemsToPack[category], !itemsInSection.isEmpty {
						CollapsibleCategorySection(
							category: category,
							items: itemsInSection, // Übergibt die bereits sortierten Items
							isTripCompleted: trip.isCompleted,
							onUpdate: { item in updateItem(item) }, // Verwende lokale Funktionen
							onDelete: { item in deleteItem(item) }
						)
					}
				}
			}

			// Bereits gepackte Items
			if !packedItems.isEmpty {
				if !itemsToPack.isEmpty { // Nur Divider zeigen, wenn beide Sections da sind
					Divider().padding(.horizontal)
				}

				CollapsiblePackedSection(
					categories: categoriesToShowInSections, // Übergibt relevante Kategorien
					groupedPackedItems: groupedPackedItems, // Übergibt gruppierte, sortierte Items
					isTripCompleted: trip.isCompleted,
					onUpdate: { item in updateItem(item) },
					onDelete: { item in deleteItem(item) }
				)
			}

			// Keine Ergebnisse Ansicht
			if items.isEmpty && (trip.packingItems?.isEmpty ?? true) { // Unterscheide: wirklich leer vs. leer nach Filter
				noItemsYetView // Eigene Ansicht für "noch keine Items"
			} else if itemsToPack.isEmpty && packedItems.isEmpty {
				emptyStateView // Ansicht für "leer nach Filterung/Suche"
			}
		}
	}

	private var emptyStateView: some View {
		VStack(spacing: 15) {
			Image(systemName: "archivebox")
				.font(.system(size: 40))
				.foregroundColor(.tripBuddyTextSecondary.opacity(0.7))

			Text(noResultsTextKey) // Dynamischer Text je nach Grund
				.foregroundColor(.tripBuddyTextSecondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40)
		}
		.padding(.vertical, 50)
		.frame(maxWidth: .infinity)
	}

	private var noItemsYetView: some View {
		VStack(spacing: 15) {
			Image(systemName: "list.bullet.clipboard")
				.font(.system(size: 40))
				.foregroundColor(.tripBuddyTextSecondary.opacity(0.7))
			Text("no_items_yet_add_some")
				.foregroundColor(.tripBuddyTextSecondary)
				.multilineTextAlignment(.center)
			Button("add_first_item") { showingAddItem = true } // Eigene Lokalisierung
				.primaryButtonStyle()
		}
		.padding(.vertical, 50)
		.frame(maxWidth: .infinity)
	}

	private var floatingActionContent: some View {
		VStack {
			Spacer()
			if allItemsCompleted && !trip.isCompleted {
				completeTripButton
					.transition(.scale.combined(with: .opacity))
			} else if trip.isCompleted {
				completedBanner
					.transition(.scale.combined(with: .opacity))
			}
		}
		.padding(.bottom, 30)
		.animation(.spring(response: 0.4, dampingFraction: 0.6), value: allItemsCompleted)
		.animation(.default, value: trip.isCompleted)
	}

	private var completeTripButton: some View {
		Button { showingCompletionAlert = true } label: {
			Label("complete_trip_button", systemImage: "checkmark.circle.fill")
		}
		.primaryButtonStyle(isWide: true)
		.padding(.horizontal, 50)
	}

	private var completedBanner: some View {
		HStack {
			Image(systemName: "checkmark.seal.fill")
			Text("completed_trip_banner")
		}
		.font(.headline)
		.foregroundColor(.white)
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.tripBuddySuccess)
		.cornerRadius(20)
		.padding(.horizontal, 30)
	}

	// MARK: - Toolbar and Sheets

	private var toolbarButtons: some ToolbarContent {
		ToolbarItemGroup(placement: .navigationBarTrailing) {
			// Sort menu
			Menu {
				Picker("sort_by_picker_label", selection: $currentSortOption) {
					ForEach(SortOption.allCases) { option in
						Text(option.localizedName).tag(option)
					}
				}

				Button {
					currentSortOrder.toggle()
				} label: {
					Label(sortOrderLabelKey, systemImage: sortOrderIconName)
				}
			} label: {
				Label("sort_options_label", systemImage: "arrow.up.arrow.down.circle") // Besseres Icon
					.foregroundColor(isSortingActive ? .tripBuddyAccent : .primary)
			}

			// Add item button (nur wenn Trip nicht abgeschlossen ist)
			if !trip.isCompleted {
				Button { showingAddItem = true } label: {
					Label("add_item_label", systemImage: "plus")
				}
			}

			// Optional: Edit Button für Trip-Details
			// Button { /* Zeige EditTripView */ } label: { Label("Edit", systemImage: "pencil") }
		}
	}

	private var addItemSheet: some View {
		// Übergibt nur die Closure zum Hinzufügen
		AddItemView { newItemFromSheet in
			addItem(newItemFromSheet)
		}
	}

	@ViewBuilder
	private var completionAlertButtons: some View {
		Button("cancel", role: .cancel) {}
		Button("complete_button") { completeTripAction() }
	}

	// MARK: - Helper Methods

	private func sectionHeader(titleKey: LocalizedStringKey, color: Color) -> some View {
		Text(titleKey)
			.font(.title3.weight(.semibold))
			.foregroundColor(color)
			.padding(.horizontal)
	}

	// MARK: - Data Actions (interagieren mit ModelContext/Repository)

	private func updateItem(_ item: PackItem) {
		guard !trip.isCompleted else { return }
		hapticFeedback.light()
		// Direkte Änderung am @Bindable Trip speichert automatisch via SwiftData
		// item.update() // Die 'update' Methode im Item ist ggf. nicht mehr nötig
		// Optional: Explizites Speichern, falls nötig
		// try? modelContext.save()
	}

	private func deleteItem(_ item: PackItem) {
		guard !trip.isCompleted else { return }
		hapticFeedback.medium()
		// Item aus dem Context löschen
		modelContext.delete(item)
		// Optional: Explizites Speichern
		// try? modelContext.save()
		// Die View aktualisiert sich dank @Bindable / item removal
	}

	private func addItem(_ newItem: PackItem) {
		// Setze die Beziehung zum aktuellen Trip
		newItem.trip = trip
		// Füge das Item dem Context hinzu
		modelContext.insert(newItem)
		// Optional: Explizites Speichern
		// try? modelContext.save()
		// Die View aktualisiert sich dank @Bindable trip / item insertion
	}

	private func completeTripAction() {
		// Verwende das Repository, um den Trip abzuschließen
		repository.completeTrip(trip)
		// Die Änderung an `trip.isCompleted` wird durch @Bindable reflektiert
	}
}

// MARK: - Preview

#Preview {
	// Erstelle notwendige Objekte für die Preview
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	do {
		let container = try ModelContainer(for: Trip.self, PackItem.self, configurations: config)
		let repository = TripRepository(modelContext: container.mainContext)

		// Erstelle einen Beispiel-Trip und füge ihn dem Context hinzu
		let previewTrip = Trip(
			name: "Preview Vacation",
			destination: "Test Destination",
			startDate: Date(),
			endDate: Date().addingDays(7),
			transportTypes: [.plane],
			accommodationType: .hotel,
			activities: [.beach],
			isBusinessTrip: false,
			numberOfPeople: 1,
			climate: .hot
		)
		container.mainContext.insert(previewTrip) // Wichtig: Trip in den Context einfügen

		// Füge Beispiel-Items hinzu und setze die Beziehung
		let item1 = PackItem(name: "Passport", category: .documents, isEssential: true)
		item1.trip = previewTrip
		container.mainContext.insert(item1)

		let item2 = PackItem(name: "Sunscreen", category: .toiletries)
		item2.trip = previewTrip
		container.mainContext.insert(item2)

		let item3 = PackItem(name: "Charger", category: .electronics, isPacked: true)
		item3.trip = previewTrip
		container.mainContext.insert(item3)

		return NavigationStack {
			// Übergib den Trip aus dem Context an die View
			TripDetailView(trip: previewTrip)
		}
		.modelContainer(container) // Stelle den Container bereit
		.environment(repository) // Stelle das Repository bereit
		.environmentObject(UserSettingsManager.shared) // Stelle Settings bereit
	} catch {
		fatalError("Failed to create container: \(error)")
	}
}
