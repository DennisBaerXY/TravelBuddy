// TravelBuddy/Views/TripDetailView.swift
import SwiftData
import SwiftUI

struct TripDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Bindable var trip: Trip

	// MARK: - State Variables

	@State private var selectedCategoryFilter: ItemCategory? = nil
	@State private var searchText = ""
	@State private var showingAddItem = false
	@State private var showingCompletionAlert = false
	@State private var currentSortOption: SortOption = .name // Use global enum
	@State private var currentSortOrder: SortOrder = .ascending // Use global enum

	// Haptic Feedback Generator (Moved from subviews)
	private let generalFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

	// MARK: - Computed Properties for Filtering/Sorting

	private var filteredAndGroupedItems: (toPack: [ItemCategory: [PackItem]], packed: [ItemCategory: [PackItem]]) {
		guard let allItems = trip.packingItems else { return (toPack: [:], packed: [:]) }

		let filtered = allItems.filter { item in
			let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
			let matchesCategory = selectedCategoryFilter == nil || item.categoryEnum == selectedCategoryFilter
			return matchesSearch && matchesCategory
		}

		let itemsToPack = filtered.filter { !$0.isPacked }
		let packedItems = filtered.filter { $0.isPacked }

		// Group and sort items within each category
		let groupedToPack = Dictionary(grouping: itemsToPack, by: { $0.categoryEnum })
			.mapValues { $0.sorted(by: itemSortComparator) }

		let groupedPacked = Dictionary(grouping: packedItems, by: { $0.categoryEnum })
			.mapValues { $0.sorted(by: itemSortComparator) }

		return (toPack: groupedToPack, packed: groupedPacked)
	}

	// Sort comparator based on current state
	private func itemSortComparator(item1: PackItem, item2: PackItem) -> Bool {
		let orderMultiplier: Double = (currentSortOrder == .ascending) ? 1.0 : -1.0
		var comparisonResult: ComparisonResult = .orderedSame

		switch currentSortOption {
		case .name:
			comparisonResult = item1.name.localizedCaseInsensitiveCompare(item2.name)
			// Add other sort cases here if needed
		}

		// Apply sort order
		return comparisonResult == .orderedAscending && orderMultiplier == 1.0 ||
			comparisonResult == .orderedDescending && orderMultiplier == -1.0
	}

	// Categories actually present in the original trip data
	private var categoriesPresentInTrip: [ItemCategory] {
		guard let allItems = trip.packingItems else { return [] }
		let uniqueCategories = Set(allItems.map { $0.categoryEnum })
		return ItemCategory.allCases.filter { uniqueCategories.contains($0) }
	}

	// Categories to display in sections after filtering
	private var categoriesToShowInSections: [ItemCategory] {
		let categoriesInToPack = Set(filteredAndGroupedItems.toPack.keys)
		let categoriesInPacked = Set(filteredAndGroupedItems.packed.keys)
		let allRelevantCategories = categoriesInToPack.union(categoriesInPacked)
		return ItemCategory.allCases.filter { allRelevantCategories.contains($0) }
	}

	// Check if all *original* items are packed
	var allOriginalItemsCompleted: Bool {
		guard let items = trip.packingItems, !items.isEmpty else { return false }
		return items.allSatisfy { $0.isPacked }
	}

	// MARK: - Body

	var body: some View {
		ZStack {
			Color.tripBuddyBackground.ignoresSafeArea()

			ScrollView {
				VStack(alignment: .leading, spacing: 15) {
					TripDetailHeaderView(trip: trip) // Use extracted header view
					searchBar
					categoryFilterButtons
					packingListSectionsView
						.padding(.top) // Add some space before the list sections
				}
				.padding(.bottom, 80) // Space for floating button
			}

			// Floating Buttons / Banners
			floatingActionContent
		}
		.navigationTitle(trip.name)
		.toolbar { ToolbarItemGroup(placement: .navigationBarTrailing) {
			// Sort Menu
			Menu {
				Picker("sort_by_picker_label", selection: $currentSortOption) {
					ForEach(SortOption.allCases) { option in
						Text(option.localizedName).tag(option)
					}
				}

				Button {
					currentSortOrder.toggle() // Use the toggle helper from the enum
				} label: {
					Label(sortOrderLabelKey, systemImage: sortOrderIconName)
				}

			} label: {
				Label("sort_options_label", systemImage: "line.3.horizontal.decrease.circle")
					.foregroundColor(isSortingActive ? .tripBuddyAccent : .primary) // Highlight if sorting is active
			}

			// Add Item Button (only if trip is not completed)
			if !trip.isCompleted {
				Button {
					showingAddItem = true
				} label: {
					Label("add_item_label", systemImage: "plus")
				}
			}
		} } // Use extracted toolbar content
		.sheet(isPresented: $showingAddItem) { addItemSheet }
		.alert("complete_trip_alert_title", isPresented: $showingCompletionAlert) {
			completionAlertButtons
		} message: {
			Text("complete_trip_alert_message")
		}
		// Apply animations to list changes
		.animation(.default, value: categoriesToShowInSections)
		.animation(.default, value: filteredAndGroupedItems.toPack)
		.animation(.default, value: filteredAndGroupedItems.packed)
		.animation(.default, value: currentSortOption)
		.animation(.default, value: currentSortOrder)
		.onAppear {
			generalFeedbackGenerator.prepare() // Prepare haptics
		}
	}

	// MARK: - Subviews (Computed Properties)

	private var searchBar: some View {
		HStack {
			Image(systemName: "magnifyingglass").foregroundColor(.secondary)
			TextField(String(localized: "search_placeholder"), text: $searchText)
				.textFieldStyle(PlainTextFieldStyle())
				.submitLabel(.search) // Keep submit label

			if !searchText.isEmpty {
				Button { searchText = "" } label: {
					Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
				.transition(.opacity.combined(with: .scale)) // Add transition
			}
		}
		.padding(10)
		.background(Color.tripBuddyCard)
		.cornerRadius(10)
		.padding(.horizontal)
		.animation(.easeInOut, value: searchText.isEmpty) // Animate clear button
	}

	private var categoryFilterButtons: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				CategoryFilterButton(title: String(localized: "all_items"), isSelected: selectedCategoryFilter == nil) {
					withAnimation { selectedCategoryFilter = nil }
				}
				// Use categories *present in the trip* for filter buttons
				ForEach(categoriesPresentInTrip, id: \.self) { category in
					CategoryFilterButton(title: category.localizedName, iconName: category.iconName, isSelected: selectedCategoryFilter == category) {
						withAnimation { selectedCategoryFilter = category }
					}
				}
			}
			.padding(.horizontal)
		}
	}

	private var packingListSectionsView: some View {
		let itemsData = filteredAndGroupedItems
		let categoriesToDisplay = categoriesToShowInSections

		return VStack(alignment: .leading, spacing: 25) {
			// --- Section: To Pack ---
			if !itemsData.toPack.isEmpty {
				sectionHeader(titleKey: "to_pack_section_header \(itemsData.toPack.reduce(0) { $0 + $1.value.count })", color: .tripBuddyPrimary)

				ForEach(categoriesToDisplay, id: \.self) { category in
					if let items = itemsData.toPack[category], !items.isEmpty {
						// Use extracted component
						CollapsibleCategorySection(
							category: category,
							items: items,
							isInitiallyExpanded: true,
							isTripCompleted: trip.isCompleted,
							onUpdate: handleItemUpdate,
							onDelete: handleItemDelete
						)
					}
				}
			}

			// --- Section: Already Packed ---
			if !itemsData.packed.isEmpty {
				Divider().padding(.horizontal)
				// Use extracted component
				CollapsiblePackedSection(
					categories: categoriesToDisplay,
					groupedPackedItems: itemsData.packed,
					isTripCompleted: trip.isCompleted,
					onUpdate: handleItemUpdate,
					onDelete: handleItemDelete,
					isExpanded: false // Start collapsed
				)
			}

			// --- Fallback Views ---
			if itemsData.toPack.isEmpty, itemsData.packed.isEmpty {
				noResultsView
			}
		}
	}

	private var noResultsView: some View {
		VStack(spacing: 15) { // Add spacing
			Image(systemName: "archivebox") // Different icon?
				.font(.system(size: 40)) // Larger icon
				.foregroundColor(.tripBuddyTextSecondary.opacity(0.7))
			Text(noResultsTextKey)
				.foregroundColor(.tripBuddyTextSecondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40) // Ensure text wraps nicely
		}
		.padding(.vertical, 50) // More vertical padding
		.frame(maxWidth: .infinity)
	}

	private var noResultsTextKey: LocalizedStringKey {
		if !searchText.isEmpty {
			return "no_search_results"
		} else if selectedCategoryFilter != nil {
			return "no_items_in_category"
		} else {
			return "no_items_in_list" // All items are packed or list is empty
		}
	}

	private var floatingActionContent: some View {
		VStack {
			Spacer()
			if allOriginalItemsCompleted && !trip.isCompleted {
				completeTripButton
					.transition(.scale.combined(with: .opacity))
			} else if trip.isCompleted {
				completedBanner
					.transition(.scale.combined(with: .opacity))
			}
		}
		.padding(.bottom, 30)
		.animation(.spring(response: 0.4, dampingFraction: 0.6), value: allOriginalItemsCompleted)
		.animation(.default, value: trip.isCompleted)
	}

	private var completeTripButton: some View {
		Button {
			showingCompletionAlert = true
		} label: {
			Label("complete_trip_button", systemImage: "checkmark.circle.fill")
		}
		.buttonStyle(TripBuddyFilledButtonStyle()) // Use a defined style
		.padding(.horizontal, 50) // Make button wider
	}

	private var completedBanner: some View {
		HStack {
			Image(systemName: "checkmark.seal.fill")
			Text("completed_trip_banner")
		}
		.font(.headline)
		.foregroundColor(.tripBuddyText) // Use white text on colored banner
		.padding()
		.frame(maxWidth: .infinity) // Take full width
		.background(Color.tripBuddySuccess)
		.cornerRadius(20)
		.padding(.horizontal, 30) // Padding around banner
	}

	// MARK: - Toolbar

	// Helper for Sort Order Button
	private var sortOrderLabelKey: LocalizedStringKey {
		currentSortOrder == .ascending ? "sort_ascending" : "sort_descending"
	}

	private var sortOrderIconName: String {
		currentSortOrder == .ascending ? "arrow.up.square" : "arrow.down.square"
	}

	private var isSortingActive: Bool {
		currentSortOption != .name || currentSortOrder != .ascending
	}

	// MARK: - Sheets and Alerts

	private var addItemSheet: some View {
		// Pass only the necessary callback, not the whole trip
		AddItemView { newItem in
			addItemToTrip(newItem)
		}
	}

	@ViewBuilder
	private var completionAlertButtons: some View {
		Button("cancel", role: .cancel) {}
		Button("complete_button") {
			markTripAsCompleted()
		}
	}

	// MARK: - Helper Views

	private func sectionHeader(titleKey: LocalizedStringKey, color: Color) -> some View {
		Text(titleKey)
			.font(.title3.weight(.semibold))
			.foregroundColor(color)
			.padding(.horizontal)
	}

	// MARK: - Data Handling Actions

	private func handleItemUpdate(_ updatedItem: PackItem) {
		guard !trip.isCompleted else { return }

		// Find the index of the item to update
		if let index = trip.packingItems?.firstIndex(where: { $0.id == updatedItem.id }) {
			// Update the item directly within the @Bindable trip's array
			trip.packingItems?[index].isPacked = updatedItem.isPacked
			trip.packingItems?[index].update() // Update modification date if needed
			trip.update() // Update trip's modification date
			// Note: Explicit save might not be needed with @Bindable + SwiftData autosave
			// but can be added if issues arise: try? modelContext.save()
		}
	}

	private func handleItemDelete(_ itemToDelete: PackItem) {
		guard !trip.isCompleted else { return }
		generalFeedbackGenerator.impactOccurred() // Use the central generator

		// Remove from the @Bindable array first (triggers UI update)
		trip.packingItems?.removeAll { $0.id == itemToDelete.id }

		// Then delete from the model context
		modelContext.delete(itemToDelete)

		trip.update() // Update trip's modification date
		// try? modelContext.save() // Optional explicit save
	}

	private func addItemToTrip(_ newItem: PackItem) {
		// Item is already created by AddItemView, just needs to be linked and saved
		modelContext.insert(newItem) // Insert into context
		newItem.trip = trip // Set relationship

		// Ensure packingItems array is initialized
		if trip.packingItems == nil {
			trip.packingItems = []
		}
		trip.packingItems?.append(newItem)

		trip.update() // Update trip's modification date
		// try? modelContext.save() // Optional explicit save
	}

	private func markTripAsCompleted() {
		trip.isCompleted = true
		trip.update()
		// try? modelContext.save() // Optional explicit save
	}
}

// MARK: - Preview (Optional: Update Preview)

// struct TripDetailView_Previews: PreviewProvider { ... }
