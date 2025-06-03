//
//  EditItemView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 03.06.25.
//

//
//  EditItemView.swift
//  TravelBuddy
//
//  Updated to provide item editing functionality
//

import SwiftUI

struct EditItemView: View {
	// MARK: - Environment & State

	@Environment(\.dismiss) private var dismiss
	
	// The item to edit
	@Bindable var item: PackItem
	
	// Form state
	@State private var itemName: String
	@State private var selectedCategory: ItemCategory
	@State private var isEssential: Bool
	@State private var quantity: Int
	
	// Callback
	var onSave: (PackItem) -> Void
	
	// MARK: - Initialization
	
	init(item: PackItem, onSave: @escaping (PackItem) -> Void) {
		self.item = item
		self.onSave = onSave
		
		// Initialize state with current item values
		self._itemName = State(initialValue: item.name)
		self._selectedCategory = State(initialValue: item.categoryEnum)
		self._isEssential = State(initialValue: item.isEssential)
		self._quantity = State(initialValue: item.quantity)
	}
	
	// MARK: - Body

	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("category")) {
					Picker("category", selection: $selectedCategory) {
						ForEach(ItemCategory.allCases) { category in
							Label(category.displayName(), systemImage: category.iconName)
								.tag(category)
						}
					}
				}
				
				Section(header: Text("item")) {
					TextField("name", text: $itemName)
				}
				
				Section(header: Text("details")) {
					Toggle("essential", isOn: $isEssential)
					
					Stepper("quantity_count: \(quantity)", value: $quantity, in: 1 ... 20)
				}
			}
			.navigationTitle("edit_item")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("save") {
						saveItem()
					}
					.disabled(itemName.isEmpty)
				}
			}
		}
	}
	
	// MARK: - Actions

	private func saveItem() {
		// Update the item with new values
		item.name = itemName
		item.category = selectedCategory.rawValue
		item.isEssential = isEssential
		item.quantity = quantity
		item.update()
		
		onSave(item)
		dismiss()
	}
}

#Preview {
	let sampleItem = PackItem(
		name: "Sample Item",
		category: .clothing,
		isEssential: false,
		quantity: 1
	)
	
	return EditItemView(item: sampleItem) { item in
		print("Saved item: \(item.name)")
	}
}
