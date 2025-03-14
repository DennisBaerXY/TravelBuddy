//
//  ListView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 08.03.25.
//

import SwiftUI

struct ListView: View {
	@Bindable var packingList: PackingList
	var body: some View {
		List {
			ForEach(packingList.items ?? []) { item in
				HStack {
					Image(systemName: "tag")

					Text(item.name)

					Spacer()
					Text("x\(item.quantity)")
					// Checkbox
					Image(systemName: item.isChecked ?
						"checkmark" : "circle"
					)
					.contentTransition(.symbolEffect(.replace))

				}.onTapGesture { _ in
					item.isChecked.toggle()
				}
			}
		}.navigationTitle(packingList.name)
	}
}

#Preview {
	let testList = PackingList(name: "Ägypten", items: [
		Item(name: "Unterhosen", category: "Klamotten", quantity: 10),
		Item(name: "Socken", category: "Klamotten", quantity: 20)

	])
	NavigationStack {
		ListView(
			packingList: testList
		)
	}
}
