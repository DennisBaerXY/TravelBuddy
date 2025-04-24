//
//  AddItemView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import SwiftUI

struct AddItemView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var itemName = ""
	@State private var selectedCategory: ItemCategory = .other
	@State private var isEssential = false
	@State private var quantity = 1
	
	var onAddItem: (PackItem) -> Void
	
	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("item")) {
					TextField("name", text: $itemName)
				}
				
				Section(header: Text("category")) {
					Picker("category", selection: $selectedCategory) {
						ForEach(ItemCategory.allCases, id: \.self) { category in
							Label(category.localizedName, systemImage: category.iconName)
								.tag(category)
						}
					}
				}
				
				Section(header: Text("details")) {
					Toggle("essential", isOn: $isEssential)
					
					Stepper("quantity_count: \(quantity)", value: $quantity, in: 1 ... 20)
				}
			}
			.navigationTitle("new_item")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("add") {
						addItem()
					}
					.disabled(itemName.isEmpty)
				}
			}
		}
	}
	
	func addItem() {
		let newItem = PackItem(
			name: itemName,
			category: selectedCategory,
			isPacked: false,
			isEssential: isEssential,
			quantity: quantity
		)
		
		onAddItem(newItem)
		dismiss()
	}
}
