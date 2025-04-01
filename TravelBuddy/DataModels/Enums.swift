//
//  Enums.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation
import SwiftUI

enum TransportType: String, CaseIterable {
	case plane = "Flugzeug"
	case car = "Auto"
	case train = "Zug"
	case bus = "Bus"
	case ship = "Schiff"
	case bicycle = "Fahrrad"
	case onFoot = "Zu Fuß"
	
	var iconName: String {
		switch self {
		case .plane: return "airplane"
		case .car: return "car"
		case .train: return "tram"
		case .bus: return "bus"
		case .ship: return "ferry"
		case .bicycle: return "bicycle"
		case .onFoot: return "figure.walk"
		}
	}
	
	var localizedName: String {
		switch self {
		case .plane: return String(localized: "transport_plane")
		case .car: return String(localized: "transport_car")
		case .train: return String(localized: "transport_train")
		case .bus: return String(localized: "transport_bus")
		case .ship: return String(localized: "transport_ship")
		case .bicycle: return String(localized: "transport_bicycle")
		case .onFoot: return String(localized: "transport_on_foot")
		}
	}
}

enum AccommodationType: String, CaseIterable {
	case hotel = "Hotel"
	case apartment = "Apartment"
	case camping = "Camping"
	case hostels = "Hostel"
	case friends = "Bei Freunden"
	case airbnb = "Airbnb"
	
	var iconName: String {
		switch self {
		case .hotel: return "building.2"
		case .apartment: return "house"
		case .camping: return "tent"
		case .hostels: return "bed.double"
		case .friends: return "person.2"
		case .airbnb: return "house.lodge"
		}
	}
	
	var localizedName: String {
		switch self {
		case .hotel: return String(localized: "accommodation_hotel")
		case .apartment: return String(localized: "accommodation_apartment")
		case .camping: return String(localized: "accommodation_camping")
		case .hostels: return String(localized: "accommodation_hostel")
		case .friends: return String(localized: "accommodation_friends")
		case .airbnb: return String(localized: "accommodation_airbnb")
		}
	}
}

enum Activity: String, CaseIterable {
	case business = "Geschäftstermine"
	case swimming = "Schwimmen"
	case hiking = "Wandern"
	case skiing = "Skifahren"
	case sightseeing = "Sightseeing"
	case beach = "Strand"
	case sports = "Sport"
	case relaxing = "Entspannen"
	
	var iconName: String {
		switch self {
		case .business: return "briefcase"
		case .swimming: return "figure.pool.swim"
		case .hiking: return "mountain.2"
		case .skiing: return "figure.skiing.downhill"
		case .sightseeing: return "camera"
		case .beach: return "beach.umbrella"
		case .sports: return "sportscourt"
		case .relaxing: return "wineglass"
		}
	}
	
	var localizedName: String {
		switch self {
		case .business: return String(localized: "activity_business")
		case .swimming: return String(localized: "activity_swimming")
		case .hiking: return String(localized: "activity_hiking")
		case .skiing: return String(localized: "activity_skiing")
		case .sightseeing: return String(localized: "activity_sightseeing")
		case .beach: return String(localized: "activity_beach")
		case .sports: return String(localized: "activity_sports")
		case .relaxing: return String(localized: "activity_relaxing")
		}
	}
}

enum ItemCategory: String, CaseIterable {
	case clothing = "Kleidung"
	case documents = "Dokumente"
	case toiletries = "Toilettenartikel"
	case electronics = "Elektronik"
	case accessories = "Accessoires"
	case medication = "Medikamente"
	case other = "Sonstiges"
	
	var iconName: String {
		switch self {
		case .clothing: return "tshirt"
		case .documents: return "doc.text"
		case .toiletries: return "shower"
		case .electronics: return "laptopcomputer"
		case .accessories: return "bag"
		case .medication: return "pills"
		case .other: return "ellipsis"
		}
	}
	
	var localizedName: String {
		switch self {
		case .clothing: return String(localized: "category_clothing")
		case .documents: return String(localized: "category_documents")
		case .toiletries: return String(localized: "category_toiletries")
		case .electronics: return String(localized: "category_electronics")
		case .accessories: return String(localized: "category_accessories")
		case .medication: return String(localized: "category_medication")
		case .other: return String(localized: "category_other")
		}
	}
}

enum Climate: String, CaseIterable {
	case hot = "Heiß"
	case warm = "Warm"
	case moderate = "Gemäßigt"
	case cool = "Kühl"
	case cold = "Kalt"
	
	var iconName: String {
		switch self {
		case .hot: return "sun.max"
		case .warm: return "sun.min"
		case .moderate: return "cloud.sun"
		case .cool: return "wind"
		case .cold: return "snowflake"
		}
	}
	
	var localizedName: String {
		switch self {
		case .hot: return String(localized: "climate_hot")
		case .warm: return String(localized: "climate_warm")
		case .moderate: return String(localized: "climate_moderate")
		case .cool: return String(localized: "climate_cool")
		case .cold: return String(localized: "climate_cold")
		}
	}
}
