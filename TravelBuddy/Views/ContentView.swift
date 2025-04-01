import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: [
		SortDescriptor(\Trip.isCompleted, order: .forward),
		SortDescriptor(\Trip.createdAt, order: .reverse)
	]) private var trips: [Trip]
	@State private var showingAddTrip = false
	@State private var isPremiumUser = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				if trips.isEmpty {
					VStack(spacing: 20) {
						Image("AppIconLogo")
						
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 60, height: 60)
							.cornerRadius(12)
						Text("no.trips.planned")
							.font(.title2)
							.fontWeight(.medium)
						
						Text("add.trip.tip")
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding(.horizontal)
						
						Button("create.first.trip") {
							showingAddTrip = true
						}
						.buttonStyle(.borderedProminent)
						.padding(.top)
					}
					.padding()
				} else {
					List {
						ForEach(trips) { trip in
							NavigationLink(destination: TripDetailView(trip: trip)) {
								TripCardView(trip: trip)
							}
							.listRowSeparator(.hidden)
						}
						.onDelete(perform: deleteTrip)
					}
					.listStyle(.plain)
						
					.padding(.vertical)
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							showingAddTrip = true
						}) {
							Image(systemName: "plus")
								.font(.title2)
								.fontWeight(.semibold)
								.padding()
								.background(Color.blue)
								.foregroundColor(.white)
								.clipShape(Circle())
								.shadow(radius: 4)
						}
						.padding()
					}
				}
			}
			.navigationTitle("my.trips")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						// Zeige Benutzereinstellungen/Premium-Upgrade
						presentPremiumUpgrade()
					}) {
						Image(systemName: isPremiumUser ? "star.fill" : "star")
							.foregroundColor(isPremiumUser ? .yellow : .gray)
					}
				}
			}
			.sheet(isPresented: $showingAddTrip) {
				AddTripView()
			}
		}
	}
	
	func deleteTrip(_ indexes: IndexSet) {
		for index in indexes {
			let trip = trips[index]
			modelContext.delete(trip)
		}
	}
	
	func presentPremiumUpgrade() {
		// Hier würde in der vollständigen App der Premium-Kauf-Flow starten
		isPremiumUser.toggle() // Nur für Demo-Zwecke
	}
}
