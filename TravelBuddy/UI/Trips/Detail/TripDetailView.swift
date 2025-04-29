import SwiftData
import SwiftUI

import GoogleMobileAds

import FirebaseAnalytics

struct TripDetailView: View {
	// MARK: - Environment & State

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	// The trip model
	@Bindable var trip: Trip

	// UI State
	@State private var selectedCategoryFilter: ItemCategory?
	@State private var searchText = ""
	@State private var showingAddItem = false
	@State private var showingCompletionAlert = false
	@State private var currentSortOption: SortOption = UserSettingsManager.shared.defaultSortOption
	@State private var currentSortOrder: SortOrder = UserSettingsManager.shared.defaultSortOrder

	// Haptic Feedback
	private let hapticFeedback = HapticFeedback()

	// MARK: - Computed Properties

	private var items: [PackItem] {
		PackItemSortingAndFiltering.applySortingAndFiltering(
			items: trip.packingItems, // Pass the original list of items
			searchText: searchText,
			selectedCategoryFilter: selectedCategoryFilter,
			sortOption: currentSortOption,
			sortOrder: currentSortOrder,
			prioritizeEssential: UserSettingsManager.shared.prioritizeEssentialItems // Get prioritization from settings
		)
	}

	private var itemsToPack: [PackItem] {
		items.filter { !$0.isPacked }
	}

	private var packedItems: [PackItem] {
		items.filter { $0.isPacked }
	}

	private var groupedItems: [ItemCategory: [PackItem]] {
		Dictionary(grouping: items, by: { $0.categoryEnum })
	}

	private var groupedItemsToPack: [ItemCategory: [PackItem]] {
		Dictionary(grouping: itemsToPack, by: { $0.categoryEnum })
	}

	private var groupedPackedItems: [ItemCategory: [PackItem]] {
		Dictionary(grouping: packedItems, by: { $0.categoryEnum })
	}

	private var categoriesToShowInSections: [ItemCategory] {
		let categoriesInToPack = Set(groupedItemsToPack.keys)
		let categoriesInPacked = Set(groupedPackedItems.keys)
		let allRelevantCategories = categoriesInToPack.union(categoriesInPacked)

		// Filter by presence in items
		let filteredCategories = ItemCategory.allCases.filter { allRelevantCategories.contains($0) }

		// Sort categories by name if that's the sort option
		if currentSortOption == .category {
			return PackItemSortingAndFiltering.sortCategoriesByName(
				categories: filteredCategories,
				sortOrder: currentSortOrder
			)
		} else {
			// Maintain original order from allCases if not sorting by category
			return filteredCategories
		}
	}

	private var categoriesPresentInTrip: [ItemCategory] {
		guard let allItems = trip.packingItems else { return [] }
		let uniqueCategories = Set(allItems.map { $0.categoryEnum })
		return ItemCategory.allCases.filter { uniqueCategories.contains($0) }
	}

	private var allItemsCompleted: Bool {
		guard let items = trip.packingItems, !items.isEmpty else { return false }
		return items.allSatisfy { $0.isPacked }
	}

	private var isSortingActive: Bool {
		currentSortOption != UserSettingsManager.shared.defaultSortOption ||
			currentSortOrder != UserSettingsManager.shared.defaultSortOrder
	}

	private var sortOrderLabelKey: LocalizedStringKey {
		currentSortOrder == .ascending ? "sort_ascending" : "sort_descending"
	}

	private var sortOrderIconName: String {
		currentSortOrder == .ascending ? "arrow.up.square" : "arrow.down.square"
	}

	private var noResultsTextKey: LocalizedStringKey {
		if !searchText.isEmpty {
			return "no_search_results"
		} else if selectedCategoryFilter != nil {
			return "no_items_in_category"
		} else if trip.packingItems?.isEmpty ?? true {
			return "no_items_in_list"
		} else {
			return "all_items_packed"
		}
	}

	// MARK: - Body

	var body: some View {
		GeometryReader { geometry in
			let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
			ZStack {
				Color.tripBuddyBackground.ignoresSafeArea()
				VStack {
					ScrollView {
						VStack(alignment: .leading, spacing: 15) {
							TripHeaderView(trip: trip, isCompact: true)

							searchAndFilterBar

							packingListContent
						}
						.padding(.bottom, 80)
					}

					// MONETIZATION: Add Ad Banner Here
					if !UserSettingsManager.shared.isPremiumUser {
						Spacer()
						BannerViewContainer(adSize)
							.frame(height: adSize.size.height)
					}
				}.padding(0)

				floatingActionContent
			}
		}

		.navigationTitle(trip.name)
		.toolbar { toolbarButtons }
		.sheet(isPresented: $showingAddItem) { addItemSheet }
		.alert("complete_trip_alert_title", isPresented: $showingCompletionAlert) {
			completionAlertButtons
		} message: {
			Text("complete_trip_alert_message")
		}
		.onAppear {
			// Load initial sort settings
			currentSortOption = UserSettingsManager.shared.defaultSortOption
			currentSortOrder = UserSettingsManager.shared.defaultSortOrder

			guard AppConstants.enableAnalytics else { return }

			Analytics.logEvent(AnalyticsEventScreenView, parameters: [
				AnalyticsParameterScreenName: "TripDetailView", // Predefined parameter
				AnalyticsParameterScreenClass: "TripDetailView", // Can be same as name for SwiftUI
				"trip_id": trip.id.uuidString // Custom parameter
			])
		}
		.animation(.default, value: items)
		.animation(.default, value: currentSortOption)
		.animation(.default, value: currentSortOrder)
		.animation(.default, value: selectedCategoryFilter)
		.animation(.default, value: searchText)
	}

	// MARK: - UI Components

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
						title: "all_items",
						isSelected: selectedCategoryFilter == nil
					) { withAnimation { selectedCategoryFilter = nil } }

					ForEach(categoriesPresentInTrip, id: \.self) { category in
						CategoryFilterButton(
							title: category.displayName(),
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
			// Items to pack
			if !items.isEmpty {
				sectionHeader(
					titleKey: "to_pack_section_header \(itemsToPack.count)",
					color: .tripBuddyPrimary
				)

				ForEach(categoriesToShowInSections, id: \.self) { category in
					if let itemsInSection = groupedItems[category], !itemsInSection.isEmpty {
						CollapsibleCategorySection(
							category: category,
							items: itemsInSection,
							isTripCompleted: trip.isCompleted,
							onUpdate: { item in updateItem(item) },
							onDelete: { item in deleteItem(item) }
						)
					}
				}

				// Packed Items Section (remains grouped by category within the collapsible section)
				if !packedItems.isEmpty {
					CollapsiblePackedSection(
						categories: categoriesToShowInSections,
						groupedPackedItems: groupedPackedItems,
						isTripCompleted: trip.isCompleted,
						onUpdate: { item in updateItem(item) },
						onDelete: { item in deleteItem(item) }
					)
				}
			}

			// Empty state view
			if items.isEmpty {
				if trip.packingItems?.isEmpty ?? true {
					noItemsYetView
				} else {
					emptyStateView
				}
			}
		}
	}

	private var emptyStateView: some View {
		VStack(spacing: 15) {
			Image(systemName: "archivebox")
				.font(.system(size: 40))
				.foregroundColor(.tripBuddyTextSecondary.opacity(0.7))

			Text(noResultsTextKey)
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

			Text("no_items_in_list")
				.foregroundColor(.tripBuddyTextSecondary)
				.multilineTextAlignment(.center)

			Button("add_item_label") { showingAddItem = true }
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
						Text(option.localizedString()).tag(option)
					}
				}

				Button {
					currentSortOrder.toggle()
				} label: {
					Label(sortOrderLabelKey, systemImage: sortOrderIconName)
				}
			} label: {
				Label("sort_options_label", systemImage: "arrow.up.arrow.down.circle")
					.foregroundColor(isSortingActive ? .tripBuddyAccent : .primary)
			}

			// Add item button
			if !trip.isCompleted {
				Button { showingAddItem = true } label: {
					Label("add_item_label", systemImage: "plus")
				}
			}
		}
	}

	private var addItemSheet: some View {
		AddItemView { newItem in
			addItem(newItem)
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

	// MARK: - Data Actions

	private func updateItem(_ item: PackItem) {
		guard !trip.isCompleted else { return }
		hapticFeedback.light()
		item.update()
		try? modelContext.save()
	}

	private func deleteItem(_ item: PackItem) {
		guard !trip.isCompleted else { return }
		hapticFeedback.medium()
		modelContext.delete(item)
		try? modelContext.save()
	}

	private func addItem(_ newItem: PackItem) {
		TripServices.addItemToTrip(trip, in: modelContext, item: newItem)
	}

	private func completeTripAction() {
		TripServices.completeTrip(trip, in: modelContext)
	}
}

// MARK: - Preview

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	do {
		let container = try ModelContainer(for: Trip.self, PackItem.self, configurations: config)
		let context = container.mainContext

		// Create a sample trip for preview
		let previewTrip = Trip(
			name: "Preview Vacation",
			destination: "Barcelona, Spain",
			startDate: Date(),
			endDate: Date().addingTimeInterval(86400 * 7),
			transportTypes: [.plane, .car],
			accommodationType: .hotel,
			activities: [.beach, .swimming],
			isBusinessTrip: false,
			numberOfPeople: 2,
			climate: .hot
		)
		context.insert(previewTrip)

		// Add some sample items
		let items = [
			PackItem(name: "Passport", category: .documents, isEssential: true),
			PackItem(name: "T-Shirts", category: .clothing, quantity: 3),
			PackItem(name: "Sunscreen", category: .toiletries),
			PackItem(name: "Camera", category: .electronics, isPacked: true),
			PackItem(name: "Swimwear", category: .clothing),
			PackItem(name: "Adapter", category: .electronics),
			PackItem(name: "Book", category: .other)
		]

		for item in items {
			context.insert(item)
			item.trip = previewTrip
		}

		return NavigationStack {
			TripDetailView(trip: previewTrip)
		}
		.modelContainer(container)
	} catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
