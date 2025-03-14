//
//  EditPackingListView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 11.03.25.
//

import SwiftData
import SwiftUI

struct CreateNewPackingList: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	@Bindable var packingList: PackingList

	@State private var errorMessage: String = ""

	var body: some View {
		Form {
			TextField("Name of Packing List", text: $packingList.name)
		}
		.navigationTitle("Create a new List")
		.onDisappear {}
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Cancel") {
					dismiss()
				}
			}

			ToolbarItem(placement: .topBarTrailing) {
				HStack {
					Button {
						if packingList.name.isEmpty {
							// TODO: If list is empty dont allow it or allow it
						}
						else {
							if packingList.modelContext == nil {
								modelContext.insert(packingList)
							}

							do {
								try modelContext.save()
								dismiss()
							}
							catch {
								print("Oops an error happend. Try again later or contact us!")
							}
						}
					} label: {
						Label("Save", systemImage: "plus.circle")
							.labelStyle(.titleAndIcon)
							.padding(.horizontal)
							.imageScale(.large)
					}
					.buttonStyle(.plain)
				}.disabled(packingList.name.isEmpty || errorMessage.count > 0)
			}
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: PackingList.self, configurations: config)

	NavigationStack {
		CreateNewPackingList(packingList: PackingList())
			.modelContainer(container)
	}
}
