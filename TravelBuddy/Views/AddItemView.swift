// AddItemView.swift - Ansicht zum Hinzufügen eines neuen Gegenstands
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
                Section(header: Text("Gegenstand")) {
                    TextField("Name", text: $itemName)
                }
                
                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    Toggle("Unverzichtbar", isOn: $isEssential)
                    
                    Stepper("Anzahl: \(quantity)", value: $quantity, in: 1...20)
                }
            }
            .navigationTitle("Neuer Gegenstand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
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
