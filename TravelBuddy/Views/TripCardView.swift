import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(trip.name)
                    .font(.headline)
                
                Spacer()
                
                // Transport-Icons anzeigen
                HStack(spacing: 4) {
                    ForEach(trip.transportTypesEnum, id: \.self) { type in
                        Image(systemName: type.iconName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Reiseziel und Datum
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text(trip.destination)
                    .font(.subheadline)
            }
            
            HStack {
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
                        .font(.caption)
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
}