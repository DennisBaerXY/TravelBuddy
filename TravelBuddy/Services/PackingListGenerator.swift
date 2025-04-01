import Foundation

class PackingListGenerator {
    
    static func generatePackingList(for trip: Trip) -> [PackItem] {
        var items = [PackItem]()
        
        // Basispakete für alle Reisen
        items.append(contentsOf: basicItems())
        
        // Je nach Transportmittel
        for transportType in trip.transportTypesEnum {
            switch transportType {
            case .plane:
                items.append(contentsOf: airTravelItems())
            case .car:
                items.append(contentsOf: carTravelItems())
            case .train:
                items.append(contentsOf: trainTravelItems())
            default:
                break
            }
        }
        
        // Je nach Unterkunft
        switch trip.accommodationTypeEnum {
        case .hotel:
            items.append(contentsOf: hotelItems())
        case .camping:
            items.append(contentsOf: campingItems())
        default:
            break
        }
        
        // Je nach Aktivitäten
        for activity in trip.activitiesEnum {
            switch activity {
            case .swimming:
                items.append(contentsOf: swimmingItems())
            case .hiking:
                items.append(contentsOf: hikingItems())
            case .business:
                items.append(contentsOf: businessItems())
            default:
                break
            }
        }
        
        // Je nach Anzahl der Personen
        // Berechnung der Kleidungsmenge basierend auf Reisetagen
        let numberOfDays = Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
        items.append(contentsOf: clothingItems(for: numberOfDays))
        
        // Je nach Klima am Zielort
        switch trip.climateEnum {
        case .hot:
            items.append(contentsOf: hotWeatherItems())
        case .cold:
            items.append(contentsOf: coldWeatherItems())
        default:
            break
        }
        
        return items
    }
    
    // Implementierung der verschiedenen Item-Listen (wie zuvor)
    static func basicItems() -> [PackItem] {
        return [
            PackItem(name: "Geldbeutel", category: .documents, isEssential: true),
            PackItem(name: "Handy + Ladegerät", category: .electronics, isEssential: true),
            // ... weitere Items
        ]
    }
    
    static func airTravelItems() -> [PackItem] {
        // Implementierung wie zuvor
        return []
    }
    
    // ... weitere Methoden für spezifische Item-Listen
}