//
//  PackingListGenerator.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import Foundation

/// Service responsible for generating packing lists based on trip properties
/// Uses smart rules to suggest appropriate items based on trip details
struct PackingListGenerator {
	// MARK: - Public Interface
	
	/// Generates a comprehensive packing list for a trip
	/// - Parameter trip: The trip to generate items for
	/// - Returns: An array of PackItem objects
	static func generatePackingList(for trip: Trip) -> [PackItem] {
		var items = [PackItem]()
		
		// Add basic items that everyone needs
		items.append(contentsOf: basicItems())
		
		// Add items based on transportation methods
		for transportType in trip.transportTypesEnum {
			switch transportType {
			case .plane:
				items.append(contentsOf: airTravelItems())
			case .car:
				items.append(contentsOf: carTravelItems())
			case .train:
				items.append(contentsOf: trainTravelItems())
			case .ship:
				items.append(contentsOf: shipTravelItems())
			default:
				break
			}
		}
		
		// Add items based on accommodation type
		switch trip.accommodationTypeEnum {
		case .hotel:
			items.append(contentsOf: hotelItems())
		case .camping:
			items.append(contentsOf: campingItems())
		case .apartment, .airbnb:
			items.append(contentsOf: apartmentItems())
		case .hostels:
			items.append(contentsOf: hostelItems())
		case .friends:
			items.append(contentsOf: stayingWithFriendsItems())
		}
		
		// Add items based on planned activities
		for activity in trip.activitiesEnum {
			switch activity {
			case .swimming:
				items.append(contentsOf: swimmingItems())
			case .hiking:
				items.append(contentsOf: hikingItems())
			case .business:
				items.append(contentsOf: businessItems())
			case .beach:
				items.append(contentsOf: beachItems())
			case .sports:
				items.append(contentsOf: sportsItems())
			case .skiing:
				items.append(contentsOf: skiingItems())
			case .sightseeing:
				items.append(contentsOf: sightseeingItems())
			case .relaxing:
				items.append(contentsOf: relaxingItems())
			}
		}
		
		// Calculate clothing quantities based on trip duration
		let numberOfDays = trip.numberOfDays
		items.append(contentsOf: clothingItems(for: numberOfDays, people: trip.numberOfPeople))
		
		// Add items based on destination climate
		switch trip.climateEnum {
		case .hot:
			items.append(contentsOf: hotWeatherItems())
		case .warm:
			items.append(contentsOf: warmWeatherItems())
		case .cold:
			items.append(contentsOf: coldWeatherItems())
		case .cool:
			items.append(contentsOf: coolWeatherItems())
		default:
			items.append(contentsOf: moderateWeatherItems())
		}
		
		// Add business-specific items if it's a business trip
		if trip.isBusinessTrip {
			items.append(contentsOf: additionalBusinessItems())
		}
		
		// Add family-specific items if traveling with multiple people
		if trip.numberOfPeople > 1 {
			items.append(contentsOf: multiPersonItems(count: trip.numberOfPeople))
		}
		
		// Consolidate items to remove duplicates and adjust quantities
		return consolidateItems(items)
	}
	
	// MARK: - Item Category Generators
	
	/// Essential items everyone should take on any trip
	static func basicItems() -> [PackItem] {
		return [
			PackItem(name: "Wallet", category: .documents, isEssential: true),
			PackItem(name: "Phone + Charger", category: .electronics, isEssential: true),
			PackItem(name: "Keys", category: .other, isEssential: true),
			PackItem(name: "Toothbrush", category: .toiletries, isEssential: true),
			PackItem(name: "Toothpaste", category: .toiletries, isEssential: true),
			PackItem(name: "Deodorant", category: .toiletries),
			PackItem(name: "Shower Gel", category: .toiletries),
			PackItem(name: "Underwear", category: .clothing, quantity: 2),
			PackItem(name: "Socks", category: .clothing, quantity: 2)
		]
	}
	
	/// Items for air travel
	static func airTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Boarding Pass", category: .documents, isEssential: true),
			PackItem(name: "Passport/ID", category: .documents, isEssential: true),
			PackItem(name: "Travel Pillow", category: .accessories),
			PackItem(name: "Earplugs", category: .accessories),
			PackItem(name: "Eye Mask", category: .accessories),
			PackItem(name: "Entertainment", category: .electronics),
			PackItem(name: "Empty Water Bottle", category: .accessories),
			PackItem(name: "Travel Adapters", category: .electronics),
			PackItem(name: "Compression Socks", category: .clothing)
		]
	}
	
	/// Items for car travel
	static func carTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Driver's License", category: .documents, isEssential: true),
			PackItem(name: "Vehicle Registration", category: .documents, isEssential: true),
			PackItem(name: "Navigation Device/Maps", category: .electronics),
			PackItem(name: "Snacks", category: .other),
			PackItem(name: "Drinks", category: .other),
			PackItem(name: "Safety Vest", category: .other, isEssential: true),
			PackItem(name: "First Aid Kit", category: .medication),
			PackItem(name: "Car Charger", category: .electronics),
			PackItem(name: "Blanket", category: .other),
			PackItem(name: "Sunglasses", category: .accessories)
		]
	}
	
	/// Items for train travel
	static func trainTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Train Tickets", category: .documents, isEssential: true),
			PackItem(name: "Book/Magazine", category: .other),
			PackItem(name: "Snacks", category: .other),
			PackItem(name: "Water Bottle", category: .other),
			PackItem(name: "Headphones", category: .electronics),
			PackItem(name: "Travel Pillow", category: .accessories)
		]
	}
	
	/// Items for ship/ferry travel
	static func shipTravelItems() -> [PackItem] {
		return [
			PackItem(name: "Ferry/Cruise Tickets", category: .documents, isEssential: true),
			PackItem(name: "Sea Sickness Medication", category: .medication),
			PackItem(name: "Deck Shoes", category: .clothing),
			PackItem(name: "Binoculars", category: .accessories),
			PackItem(name: "Lightweight Jacket", category: .clothing)
		]
	}
	
	/// Items for hotel stays
	static func hotelItems() -> [PackItem] {
		return [
			PackItem(name: "Hotel Reservation", category: .documents, isEssential: true),
			PackItem(name: "Credit Card", category: .documents, isEssential: true),
			PackItem(name: "Do Not Disturb Sign", category: .other),
			PackItem(name: "Tip Money", category: .other)
		]
	}
	
	/// Items for camping
	static func campingItems() -> [PackItem] {
		return [
			PackItem(name: "Tent", category: .other, isEssential: true),
			PackItem(name: "Sleeping Bag", category: .other, isEssential: true),
			PackItem(name: "Sleeping Pad", category: .other, isEssential: true),
			PackItem(name: "Flashlight", category: .electronics),
			PackItem(name: "Multi-tool", category: .other),
			PackItem(name: "Camping Stove", category: .other),
			PackItem(name: "Water Container", category: .other),
			PackItem(name: "Matches/Lighter", category: .other),
			PackItem(name: "Cooking Utensils", category: .other),
			PackItem(name: "Food Storage", category: .other),
			PackItem(name: "Insect Repellent", category: .toiletries),
			PackItem(name: "Biodegradable Soap", category: .toiletries)
		]
	}
	
	/// Items for apartment/Airbnb stays
	static func apartmentItems() -> [PackItem] {
		return [
			PackItem(name: "Rental Confirmation", category: .documents, isEssential: true),
			PackItem(name: "Check-in Instructions", category: .documents, isEssential: true),
			PackItem(name: "Host Contact Info", category: .documents),
			PackItem(name: "House Rules", category: .documents)
		]
	}
	
	/// Items for hostel stays
	static func hostelItems() -> [PackItem] {
		return [
			PackItem(name: "Hostel Reservation", category: .documents, isEssential: true),
			PackItem(name: "Padlock", category: .accessories, isEssential: true),
			PackItem(name: "Earplugs", category: .accessories),
			PackItem(name: "Eye Mask", category: .accessories),
			PackItem(name: "Flip-flops", category: .clothing, isEssential: true),
			PackItem(name: "Quick-dry Towel", category: .toiletries)
		]
	}
	
	/// Items for staying with friends
	static func stayingWithFriendsItems() -> [PackItem] {
		return [
			PackItem(name: "Host Gift", category: .other),
			PackItem(name: "Host Address", category: .documents),
			PackItem(name: "House Keys (if provided)", category: .other)
		]
	}
	
	/// Items for swimming activities
	static func swimmingItems() -> [PackItem] {
		return [
			PackItem(name: "Swimwear", category: .clothing, isEssential: true),
			PackItem(name: "Towel", category: .toiletries),
			PackItem(name: "Sunscreen", category: .toiletries),
			PackItem(name: "Sunglasses", category: .accessories),
			PackItem(name: "Flip-flops", category: .clothing),
			PackItem(name: "Swim Cap", category: .accessories),
			PackItem(name: "Goggles", category: .accessories)
		]
	}
	
	/// Items for hiking activities
	static func hikingItems() -> [PackItem] {
		return [
			PackItem(name: "Hiking Boots", category: .clothing, isEssential: true),
			PackItem(name: "Water Bottle", category: .accessories, isEssential: true),
			PackItem(name: "Backpack", category: .accessories),
			PackItem(name: "Rain Jacket", category: .clothing),
			PackItem(name: "Sun Hat", category: .clothing),
			PackItem(name: "Hiking Map", category: .other),
			PackItem(name: "Compass", category: .accessories),
			PackItem(name: "First Aid Kit", category: .medication),
			PackItem(name: "Whistle", category: .accessories),
			PackItem(name: "Sunscreen", category: .toiletries),
			PackItem(name: "Insect Repellent", category: .toiletries),
			PackItem(name: "Blister Plasters", category: .medication)
		]
	}
	
	/// Items for business activities
	static func businessItems() -> [PackItem] {
		return [
			PackItem(name: "Business Attire", category: .clothing, isEssential: true),
			PackItem(name: "Business Cards", category: .documents),
			PackItem(name: "Laptop + Charger", category: .electronics, isEssential: true),
			PackItem(name: "Notebook", category: .other),
			PackItem(name: "Pens", category: .other),
			PackItem(name: "Presentation Materials", category: .documents),
			PackItem(name: "Portfolio", category: .accessories)
		]
	}
	
	/// Items for beach activities
	static func beachItems() -> [PackItem] {
		return [
			PackItem(name: "Swimwear", category: .clothing, isEssential: true),
			PackItem(name: "Beach Towel", category: .toiletries),
			PackItem(name: "Sunscreen", category: .toiletries, isEssential: true),
			PackItem(name: "Sun Hat", category: .clothing),
			PackItem(name: "Sunglasses", category: .accessories),
			PackItem(name: "Beach Bag", category: .accessories),
			PackItem(name: "Flip-flops", category: .clothing),
			PackItem(name: "Beach Games", category: .other),
			PackItem(name: "Water Bottle", category: .accessories),
			PackItem(name: "Cover-up", category: .clothing)
		]
	}
	
	/// Items for sports activities
	static func sportsItems() -> [PackItem] {
		return [
			PackItem(name: "Sports Clothing", category: .clothing, isEssential: true),
			PackItem(name: "Athletic Shoes", category: .clothing, isEssential: true),
			PackItem(name: "Water Bottle", category: .accessories),
			PackItem(name: "Sports Equipment", category: .other),
			PackItem(name: "Sports Bag", category: .accessories),
			PackItem(name: "Towel", category: .toiletries)
		]
	}
	
	/// Items for skiing activities
	static func skiingItems() -> [PackItem] {
		return [
			PackItem(name: "Ski Jacket", category: .clothing, isEssential: true),
			PackItem(name: "Ski Pants", category: .clothing, isEssential: true),
			PackItem(name: "Thermal Base Layers", category: .clothing, isEssential: true),
			PackItem(name: "Ski Gloves", category: .clothing, isEssential: true),
			PackItem(name: "Ski Socks", category: .clothing, quantity: 3),
			PackItem(name: "Ski Hat/Helmet", category: .clothing, isEssential: true),
			PackItem(name: "Ski Goggles", category: .accessories, isEssential: true),
			PackItem(name: "Sunscreen", category: .toiletries, isEssential: true),
			PackItem(name: "Lip Balm", category: .toiletries),
			PackItem(name: "Ski Pass", category: .documents, isEssential: true),
			PackItem(name: "Hand Warmers", category: .accessories)
		]
	}
	
	/// Items for sightseeing activities
	static func sightseeingItems() -> [PackItem] {
		return [
			PackItem(name: "Comfortable Walking Shoes", category: .clothing, isEssential: true),
			PackItem(name: "Camera", category: .electronics),
			PackItem(name: "City Map/Guide", category: .other),
			PackItem(name: "Day Bag", category: .accessories),
			PackItem(name: "Sunglasses", category: .accessories),
			PackItem(name: "Water Bottle", category: .accessories),
			PackItem(name: "Umbrella", category: .accessories),
			PackItem(name: "Entrance Tickets", category: .documents),
			PackItem(name: "Travel Journal", category: .other)
		]
	}
	
	/// Items for relaxing/wellness activities
	static func relaxingItems() -> [PackItem] {
		return [
			PackItem(name: "Comfortable Loungewear", category: .clothing),
			PackItem(name: "Book", category: .other),
			PackItem(name: "Music Player + Headphones", category: .electronics),
			PackItem(name: "Essential Oils", category: .toiletries),
			PackItem(name: "Face Mask", category: .toiletries),
			PackItem(name: "Bath Salts", category: .toiletries)
		]
	}
	
	/// Additional business-specific items
	static func additionalBusinessItems() -> [PackItem] {
		return [
			PackItem(name: "Travel Insurance", category: .documents),
			PackItem(name: "Business Documents", category: .documents, isEssential: true),
			PackItem(name: "Power Bank", category: .electronics),
			PackItem(name: "Travel Adapters", category: .electronics),
			PackItem(name: "Business Phone", category: .electronics),
			PackItem(name: "Portable Scanner", category: .electronics)
		]
	}
	
	/// Items for hot weather
	static func hotWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Sunscreen SPF 50+", category: .toiletries, isEssential: true),
			PackItem(name: "Sunglasses", category: .accessories),
			PackItem(name: "Sun Hat", category: .clothing),
			PackItem(name: "Lightweight Clothing", category: .clothing),
			PackItem(name: "Sandals", category: .clothing),
			PackItem(name: "After Sun Lotion", category: .toiletries),
			PackItem(name: "Insect Repellent", category: .toiletries),
			PackItem(name: "Refillable Water Bottle", category: .accessories, isEssential: true)
		]
	}
	
	/// Items for warm weather
	static func warmWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Sunscreen", category: .toiletries, isEssential: true),
			PackItem(name: "Sunglasses", category: .accessories),
			PackItem(name: "Light Jacket", category: .clothing),
			PackItem(name: "Short Sleeve Shirts", category: .clothing, quantity: 3),
			PackItem(name: "Shorts", category: .clothing, quantity: 2),
			PackItem(name: "Light Pants", category: .clothing),
			PackItem(name: "Hat", category: .clothing)
		]
	}
	
	/// Items for moderate weather
	static func moderateWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Light Jacket", category: .clothing),
			PackItem(name: "Long Pants", category: .clothing, quantity: 2),
			PackItem(name: "Long Sleeve Shirts", category: .clothing, quantity: 2),
			PackItem(name: "Short Sleeve Shirts", category: .clothing, quantity: 2),
			PackItem(name: "Light Sweater", category: .clothing),
			PackItem(name: "Rain Jacket", category: .clothing)
		]
	}
	
	/// Items for cool weather
	static func coolWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Jacket", category: .clothing, isEssential: true),
			PackItem(name: "Long Pants", category: .clothing, quantity: 2),
			PackItem(name: "Sweaters", category: .clothing, quantity: 2),
			PackItem(name: "Long Sleeve Shirts", category: .clothing, quantity: 3),
			PackItem(name: "Scarf", category: .clothing),
			PackItem(name: "Light Gloves", category: .clothing),
			PackItem(name: "Rain Jacket", category: .clothing)
		]
	}
	
	/// Items for cold weather
	static func coldWeatherItems() -> [PackItem] {
		return [
			PackItem(name: "Winter Jacket", category: .clothing, isEssential: true),
			PackItem(name: "Sweaters", category: .clothing, quantity: 2),
			PackItem(name: "Scarf", category: .clothing),
			PackItem(name: "Gloves", category: .clothing, isEssential: true),
			PackItem(name: "Winter Hat", category: .clothing, isEssential: true),
			PackItem(name: "Thermal Socks", category: .clothing, quantity: 3),
			PackItem(name: "Thermal Underwear", category: .clothing),
			PackItem(name: "Snow Boots", category: .clothing),
			PackItem(name: "Lip Balm", category: .toiletries),
			PackItem(name: "Hand Cream", category: .toiletries)
		]
	}
	
	/// Clothing items based on trip duration
	static func clothingItems(for days: Int, people: Int = 1) -> [PackItem] {
		// Calculate items based on trip length with minimums and maximums
		let tshirtCount = min(max(days, 3), 7)
		let socksCount = min(max(days, 3), 7)
		let underwearCount = min(max(days, 3), 7)
		
		return [
			PackItem(name: "T-Shirts", category: .clothing, quantity: tshirtCount),
			PackItem(name: "Pants", category: .clothing, quantity: days > 7 ? 3 : 2),
			PackItem(name: "Socks", category: .clothing, quantity: socksCount),
			PackItem(name: "Underwear", category: .clothing, quantity: underwearCount),
			PackItem(name: "Pajamas", category: .clothing),
			PackItem(name: "Casual Shoes", category: .clothing)
		]
	}
	
	/// Additional items for multiple travelers
	static func multiPersonItems(count: Int) -> [PackItem] {
		var items = [PackItem]()
		
		// For multiple travelers, especially families
		if count >= 2 {
			items.append(contentsOf: [
				PackItem(name: "Power Strip", category: .electronics),
				PackItem(name: "Group Photo", category: .other),
				PackItem(name: "Travel Games", category: .other)
			])
		}
		
		// For travelers with children (assuming 3+ means children)
		if count >= 3 {
			items.append(contentsOf: [
				PackItem(name: "Children's Entertainment", category: .other),
				PackItem(name: "Snacks", category: .other, quantity: 2),
				PackItem(name: "Wet Wipes", category: .toiletries),
				PackItem(name: "First Aid Kit", category: .medication, isEssential: true)
			])
		}
		
		return items
	}
	
	// MARK: - Helper Methods
	
	/// Consolidates items to remove duplicates and combine quantities
	/// - Parameter items: The full list of potentially duplicate items
	/// - Returns: A deduplicated list with appropriate quantities
	static func consolidateItems(_ items: [PackItem]) -> [PackItem] {
		var uniqueItems = [String: PackItem]()
		
		for item in items {
			if let existingItem = uniqueItems[item.name] {
				// If item already exists, take the higher quantity and keep isEssential=true
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
				// Add new item
				uniqueItems[item.name] = item
			}
		}
		
		return Array(uniqueItems.values)
	}
}
