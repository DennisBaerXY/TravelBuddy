import SwiftUI

struct AddItemView: View {
	// MARK: - Environment & State

	@Environment(\.dismiss) private var dismiss
	
	// Form state
	@State private var itemName = ""
	@State private var selectedCategory: ItemCategory = .other
	@State private var isEssential = false
	@State private var quantity = 1
	
	// Callback
	var onAddItem: (PackItem) -> Void
	
	// MARK: - Body

	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("category")) {
					Picker("category", selection: $selectedCategory) {
						ForEach(ItemCategory.allCases) { category in
							Label(category.localizedName, systemImage: category.iconName)
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
	
	// MARK: - Actions

	private func addItem() {
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

#Preview {
	AddItemView { item in
		print("Added item: \(item.name)")
	}
}
