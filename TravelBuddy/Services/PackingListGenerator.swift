//
//  PackingListGenerator.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

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
		
		// Entferne Duplikate und fasse Mengen zusammen
		let uniqueItems = consolidateItems(items)
		
		return uniqueItems
	}
	
	// Basispakete
	static func basicItems() -> [PackItem] {
		return [
			PackItem(name: "Geldbeutel", category: .documents, isEssential: true),
			PackItem(name: "Handy + Ladegerät", category: .electronics, isEssential: true),
			PackItem(name: "Schlüssel", category: .other, isEssential: true),
			PackItem(name: "Zahnbürste", category: .toiletries, isEssential: true),
			PackItem(name: "Zahnpasta", category: .toiletries, isEssential: true),
			PackItem(name: "Deodorant", category: .toiletries),
			PackItem(name: "Duschgel", category: .toiletries),
			PackItem(name: "Unterwäsche", category: .clothing, quantity: 2),
			PackItem(name: "Socken", category: .clothing, quantity: 2)
		]
	}
	
	// Transport-spezifische Gegenstände
	static func airTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Flugtickets", category: .documents, isEssential: true),
			PackItem(name: "Reisepass/Ausweis", category: .documents, isEssential: true),
			PackItem(name: "Nackenkissen", category: .accessories),
			PackItem(name: "Ohrstöpsel", category: .accessories),
			PackItem(name: "Augenbinde", category: .accessories),
			PackItem(name: "Unterhaltung für Flug", category: .electronics)
		]
	}
	
	static func carTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Führerschein", category: .documents, isEssential: true),
			PackItem(name: "Fahrzeugschein", category: .documents, isEssential: true),
			PackItem(name: "Navigationsgerät/Karten", category: .electronics),
			PackItem(name: "Snacks für unterwegs", category: .other),
			PackItem(name: "Getränke", category: .other),
			PackItem(name: "Warnweste", category: .other, isEssential: true)
		]
	}
	
	static func trainTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Zugtickets", category: .documents, isEssential: true),
			PackItem(name: "Buch/Zeitschrift", category: .other),
			PackItem(name: "Snacks für unterwegs", category: .other)
		]
	}
	
	// Unterkunft-spezifische Gegenstände
	static func hotelItems() -> [PackItem] {
		return [
			PackItem(name: "Hotelbuchung", category: .documents, isEssential: true),
			PackItem(name: "Kreditkarte", category: .documents, isEssential: true)
		]
	}
	
	static func campingItems() -> [PackItem] {
		return [
			PackItem(name: "Zelt", category: .other, isEssential: true),
			PackItem(name: "Schlafsack", category: .other, isEssential: true),
			PackItem(name: "Isomatte", category: .other, isEssential: true),
			PackItem(name: "Taschenlampe", category: .electronics),
			PackItem(name: "Taschenmesser", category: .other),
			PackItem(name: "Campingkocher", category: .other),
			PackItem(name: "Wasserkanister", category: .other)
		]
	}
	
	// Aktivitäts-spezifische Gegenstände
	static func swimmingItems() -> [PackItem] {
		return [
			PackItem(name: "Badehose/Badeanzug", category: .clothing, isEssential: true),
			PackItem(name: "Handtuch", category: .toiletries),
			PackItem(name: "Sonnencreme", category: .toiletries),
			PackItem(name: "Sonnenbrille", category: .accessories)
		]
	}
	
	static func hikingItems() -> [PackItem] {
		return [
			PackItem(name: "Wanderschuhe", category: .clothing, isEssential: true),
			PackItem(name: "Wasserflasche", category: .accessories, isEssential: true),
			PackItem(name: "Rucksack", category: .accessories),
			PackItem(name: "Regenjacke", category: .clothing),
			PackItem(name: "Sonnenhut", category: .clothing),
			PackItem(name: "Wanderkarte", category: .other)
		]
	}
	
	static func businessItems() -> [PackItem] {
		return [
			PackItem(name: "Anzug/Business-Kleidung", category: .clothing, isEssential: true),
			PackItem(name: "Visitenkarten", category: .documents),
			PackItem(name: "Laptop + Ladegerät", category: .electronics, isEssential: true),
			PackItem(name: "Notizbuch", category: .other),
			PackItem(name: "Kugelschreiber", category: .other)
		]
	}
	
	// Kleidung basierend auf Reiselänge
	static func clothingItems(for days: Int) -> [PackItem] {
		// Berechne Anzahl basierend auf Tagen (z.B. min. 3, max. 7 T-Shirts)
		let tshirtCount = min(max(days, 3), 7)
		let socksCount = min(max(days, 3), 7)
		let underwearCount = min(max(days, 3), 7)
		
		return [
			PackItem(name: "T-Shirts", category: .clothing, quantity: tshirtCount),
			PackItem(name: "Hosen", category: .clothing, quantity: days > 7 ? 3 : 2),
			PackItem(name: "Socken", category: .clothing, quantity: socksCount),
			PackItem(name: "Unterwäsche", category: .clothing, quantity: underwearCount),
			PackItem(name: "Schlafanzug", category: .clothing)
		]
	}
	
	// Klimabasierte Gegenstände
	static func hotWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Sonnencreme", category: .toiletries, isEssential: true),
			PackItem(name: "Sonnenbrille", category: .accessories),
			PackItem(name: "Sonnenhut", category: .clothing),
			PackItem(name: "Leichte Kleidung", category: .clothing),
			PackItem(name: "Sandalen", category: .clothing)
		]
	}
	
	static func coldWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Winterjacke", category: .clothing, isEssential: true),
			PackItem(name: "Pullover", category: .clothing, quantity: 2),
			PackItem(name: "Schal", category: .clothing),
			PackItem(name: "Handschuhe", category: .clothing),
			PackItem(name: "Mütze", category: .clothing),
			PackItem(name: "Warme Socken", category: .clothing, quantity: 3),
			PackItem(name: "Thermounterwäsche", category: .clothing)
		]
	}
	
	// Hilfsfunktion zum Entfernen von Duplikaten und Zusammenfassen von Mengen
	static func consolidateItems(_ items: [PackItem]) -> [PackItem] {
		var uniqueItems = [String: PackItem]()
		
		for item in items {
			if let existingItem = uniqueItems[item.name] {
				// Wenn Item bereits existiert, nehme die höhere Menge und behalte isEssential=true
				let newQuantity = max(existingItem.quantity, item.quantity)
				let isEssential = existingItem.isEssential || item.isEssential
				
				let updatedItem = PackItem(
					name: item.name,
					category: existingItem.categoryEnum,
					isPacked: existingItem.isPacked,
					isEssential: isEssential,
					quantity: newQuantity
				)
				
				uniqueItems[item.name] = updatedItem
			} else {
				// Neues Item hinzufügen
				uniqueItems[item.name] = item
			}
		}
		
		return Array(uniqueItems.values)
	}
}
