import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    @State private var selectedCategory: String? = nil
    @State private var showingAddItem = false
    @State private var searchText = ""
    
    var filteredItems: [PackItem] {
        var items = trip.packingItems
        
        // Nach Kategorie filtern
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        // Nach Suchtext filtern
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                tripHeader
                
                // Suchleiste
                searchBar
                
                // Kategorie-Filter
                categoryFilter
                
                // Packliste
                packingList
            }
            .padding(.bottom)
        }
        .navigationTitle(trip.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView { newItem in
                modelContext.insert(newItem)
                trip.packingItems.append(newItem)
                try? modelContext.save()
            }
        }
    }
    
    var tripHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reiseziel und Datum
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text(trip.destination)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
            }
            
            // Fortschrittsbalken
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(trip.packingProgress * 100))% gepackt")
                        .font(.headline)
                        .foregroundColor(progressColor(for: trip.packingProgress))
                    
                    Spacer()
                    
                    Text("\(trip.packingItems.filter { $0.isPacked }.count)/\(trip.packingItems.count) Gegenstände")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: trip.packingProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: trip.packingProgress)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Suchen...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryFilterButton(
                    title: "Alle",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        iconName: category.iconName,
                        isSelected: selectedCategory == category.rawValue
                    ) {
                        selectedCategory = category.rawValue
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var packingList: some View {
        VStack(spacing: 12) {
            ForEach(filteredItems) { item in
                PackItemRow(item: item) { updatedItem in
                    if let index = trip.packingItems.firstIndex(where: { $0.id == updatedItem.id }) {
                        trip.packingItems[index].isPacked = updatedItem.isPacked
                        try? modelContext.save()
                    }
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        deleteItem(item)
                    }) {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func progressColor(for value: Double) -> Color {
        if value < 0.3 {
            return .red
        } else if value < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    func deleteItem(_ item: PackItem) {
        trip.packingItems.removeAll { $0.id == item.id }
        modelContext.delete(item)
        try? modelContext.save()
    }
}
