//
//  DateExtensions.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Foundation

/// Extensions for the Date type to provide additional functionality
extension Date {
	// MARK: - Formatting
	
	/// Returns a formatted string with just the date (e.g., "Sep 21, 2025")
	var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: self)
	}
	
	/// Returns a formatted string with the day of week and date (e.g., "Monday, Sep 21")
	var formattedDayAndDate: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d"
		return formatter.string(from: self)
	}
	
	/// Returns a formatted string with short date and time (e.g., "9/21/25, 3:30 PM")
	var formattedDateTime: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter.string(from: self)
	}
	
	/// Returns a relative description of the date (e.g., "Today", "Yesterday", "3 days ago")
	var relativeDescription: String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: self, relativeTo: Date())
	}
	
	// MARK: - Date Components
	
	/// Returns the day component of the date
	var day: Int {
		return Calendar.current.component(.day, from: self)
	}
	
	/// Returns the month component of the date
	var month: Int {
		return Calendar.current.component(.month, from: self)
	}
	
	/// Returns the year component of the date
	var year: Int {
		return Calendar.current.component(.year, from: self)
	}
	
	/// Returns the hour component of the date
	var hour: Int {
		return Calendar.current.component(.hour, from: self)
	}
	
	/// Returns the minute component of the date
	var minute: Int {
		return Calendar.current.component(.minute, from: self)
	}
	
	/// Returns the name of the month (e.g., "September")
	var monthName: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM"
		return formatter.string(from: self)
	}
	
	/// Returns the name of the weekday (e.g., "Monday")
	var weekdayName: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		return formatter.string(from: self)
	}
	
	// MARK: - Date Calculations
	
	/// Returns a new date with the specified number of days added
	/// - Parameter days: Number of days to add (can be negative)
	/// - Returns: A new date with the days added
	func addingDays(_ days: Int) -> Date {
		return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
	}
	
	/// Returns a new date with the specified number of months added
	/// - Parameter months: Number of months to add (can be negative)
	/// - Returns: A new date with the months added
	func addingMonths(_ months: Int) -> Date {
		return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
	}
	
	/// Returns a new date with the specified number of years added
	/// - Parameter years: Number of years to add (can be negative)
	/// - Returns: A new date with the years added
	func addingYears(_ years: Int) -> Date {
		return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
	}
	
	/// Returns a new date with the time components set to the beginning of the day (00:00:00)
	var startOfDay: Date {
		return Calendar.current.startOfDay(for: self)
	}
	
	/// Returns a new date with the time components set to the end of the day (23:59:59)
	var endOfDay: Date {
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
	}
	
	/// Returns a new date that is the start of the current month
	var startOfMonth: Date {
		let components = Calendar.current.dateComponents([.year, .month], from: self)
		return Calendar.current.date(from: components) ?? self
	}
	
	/// Returns a new date that is the end of the current month
	var endOfMonth: Date {
		var components = DateComponents()
		components.month = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
	}
	
	// MARK: - Date Comparisons
	
	/// Returns true if the date is today
	var isToday: Bool {
		return Calendar.current.isDateInToday(self)
	}
	
	/// Returns true if the date is yesterday
	var isYesterday: Bool {
		return Calendar.current.isDateInYesterday(self)
	}
	
	/// Returns true if the date is tomorrow
	var isTomorrow: Bool {
		return Calendar.current.isDateInTomorrow(self)
	}
	
	/// Returns true if the date is in the past
	var isPast: Bool {
		return self < Date()
	}
	
	/// Returns true if the date is in the future
	var isFuture: Bool {
		return self > Date()
	}
	
	/// Returns true if the date is in the current week
	var isInCurrentWeek: Bool {
		return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
	}
	
	/// Returns true if the date is in the current month
	var isInCurrentMonth: Bool {
		return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
	}
	
	/// Returns true if the date is in the current year
	var isInCurrentYear: Bool {
		return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
	}
	
	/// Returns the number of days between this date and another date
	/// - Parameter date: The date to calculate the difference from
	/// - Returns: The number of days between the dates
	func daysBetween(date: Date) -> Int {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.day], from: self, to: date)
		return abs(components.day ?? 0)
	}
}

// MARK: - Date Range Formatting

/// Extension for creating a formatted date range string
extension Date {
	/// Creates a formatted string representing a date range
	/// - Parameter endDate: The end date of the range
	/// - Returns: A formatted string describing the date range
	func formattedRange(to endDate: Date) -> String {
		let startFormatter = DateFormatter()
		let endFormatter = DateFormatter()
		
		// If dates are in the same year, only show the year once
		if Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: endDate) {
			startFormatter.dateFormat = "MMM d"
			endFormatter.dateFormat = "MMM d, yyyy"
		} else {
			startFormatter.dateFormat = "MMM d, yyyy"
			endFormatter.dateFormat = "MMM d, yyyy"
		}
		
		return "\(startFormatter.string(from: self)) - \(endFormatter.string(from: endDate))"
	}
	
	/// Creates a compact formatted string representing a date range
	/// - Parameter endDate: The end date of the range
	/// - Returns: A compact formatted string describing the date range
	func compactFormattedRange(to endDate: Date) -> String {
		let startFormatter = DateFormatter()
		let endFormatter = DateFormatter()
		
		// If dates are in the same year, only show the year once
		if Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: endDate) {
			// If dates are in the same month, only show the month once
			if Calendar.current.component(.month, from: self) == Calendar.current.component(.month, from: endDate) {
				startFormatter.dateFormat = "d"
				endFormatter.dateFormat = "d MMM yyyy"
			} else {
				startFormatter.dateFormat = "d MMM"
				endFormatter.dateFormat = "d MMM yyyy"
			}
		} else {
			startFormatter.dateFormat = "d MMM yyyy"
			endFormatter.dateFormat = "d MMM yyyy"
		}
		
		return "\(startFormatter.string(from: self)) - \(endFormatter.string(from: endDate))"
	}
}
