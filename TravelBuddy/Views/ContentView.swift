//
//  ContentView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 08.03.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) var modelContext
	@Query var packingLists: [PackingList]
	@State private var path = [PackingList]()
	var body: some View {
		NavigationStack(path: $path) {
			if packingLists.isEmpty {
				VStack(alignment: .center) {
					Spacer()
					Text("Lets start by creating your first packing list!")

					NavigationLink(destination: CreateNewPackingList(packingList: PackingList())) {
						Text("Create a new Packing List")
							.font(.headline)
							.foregroundColor(.white)
							.padding(.horizontal, 30)
							.padding(.vertical, 12)
							.background(Color.accentColor)
							.cornerRadius(10)
					}
					Spacer()
				}
			}
			List {
				ForEach(packingLists) { packingList in
					NavigationLink(destination: ListView(packingList: packingList)) {
						Text(packingList.name)
					}
				}
				.onDelete(perform: deleteList)
			}
			.navigationTitle("Travel Buddy")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: CreateNewPackingList(packingList: PackingList())) {
						Label("Add new", systemImage: "plus.circle.fill")
							.symbolRenderingMode(.multicolor)
					}
				}
			}
		}
	}

	func deleteList(offsets: IndexSet) {
		withAnimation {
			offsets.map { packingLists[$0] }.forEach(modelContext.delete)
			do {
				try modelContext.save()
			} catch {
				print("Error beim löschen von Packungslisten: \(error.localizedDescription)")
			}
		}
	}
}

#Preview("Filled") {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: PackingList.self, configurations: config)

	for i in 1 ... 10 {
		container.mainContext.insert(PackingList(name: "Test \(i)"))
	}

	return ContentView()
		.modelContainer(container)
}

#Preview("Empty") {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: PackingList.self, configurations: config)

	return ContentView()
		.modelContainer(container)
}
