//
//  AnalyticsService.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Combine
import Foundation
import SwiftUI

/// A service for tracking app usage and events
class AnalyticsService {
	// MARK: - Shared Instance
    
	/// Shared singleton instance
	static let shared = AnalyticsService()
    
	// MARK: - Properties
    
	/// Whether analytics are enabled
	private var isEnabled: Bool
    
	/// The current session ID
	private var sessionId: String
    
	/// The date when the session started
	private var sessionStartTime: Date
    
	/// The user ID (anonymous)
	private var userId: String
    
	/// The queue of events waiting to be processed
	private var eventQueue: [AnalyticsEvent] = []
    
	/// The timer for processing the event queue
	private var processingTimer: Timer?
    
	/// The maximum number of events to store in memory
	private let maxQueueSize = 100
    
	// MARK: - Initialization
    
	/// Creates a new analytics service
	private init() {
		// Check if analytics are enabled
		self.isEnabled = AppConstants.enableAnalytics
        
		// Generate a new session ID
		self.sessionId = UUID().uuidString
        
		// Set the session start time
		self.sessionStartTime = Date()
        
		// Get or generate a user ID
		if let savedUserId = UserDefaults.standard.string(forKey: "analytics_user_id") {
			self.userId = savedUserId
		} else {
			self.userId = UUID().uuidString
			UserDefaults.standard.set(userId, forKey: "analytics_user_id")
		}
        
		// Start the processing timer
		startProcessingTimer()
	}
    
	// MARK: - Public Methods
    
	/// Tracks an app launch event
	func trackAppLaunch() {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "app_launch",
			properties: [
				"session_id": sessionId,
				"app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
			]
		))
	}
    
	/// Tracks a screen view event
	/// - Parameter screenName: The name of the screen being viewed
	func trackScreenView(screenName: String) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "screen_view",
			properties: [
				"screen_name": screenName
			]
		))
	}
    
	/// Tracks a trip creation event
	/// - Parameter trip: The trip that was created
	func trackTripCreated(trip: Trip) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "trip_created",
			properties: [
				"trip_id": trip.id.uuidString,
				"trip_name": trip.name,
				"destination": trip.destination,
				"duration_days": Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0,
				"transportation_count": trip.transportTypes.count,
				"activities_count": trip.activities.count,
				"is_business_trip": trip.isBusinessTrip
			]
		))
	}
    
	/// Tracks a trip completion event
	/// - Parameter trip: The trip that was completed
	func trackTripCompleted(trip: Trip) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "trip_completed",
			properties: [
				"trip_id": trip.id.uuidString,
				"trip_name": trip.name,
				"destination": trip.destination,
				"duration_days": Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0,
				"item_count": trip.packingItems?.count ?? 0
			]
		))
	}
    
	/// Tracks a trip deletion event
	/// - Parameter tripId: The ID of the trip that was deleted
	func trackTripDeleted(tripId: UUID) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "trip_deleted",
			properties: [
				"trip_id": tripId.uuidString
			]
		))
	}
    
	/// Tracks an item packing event
	/// - Parameters:
	///   - item: The item that was packed
	///   - tripId: The ID of the trip the item belongs to
	func trackItemPacked(item: PackItem, tripId: UUID) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "item_packed",
			properties: [
				"item_id": item.id.uuidString,
				"item_name": item.name,
				"item_category": item.category,
				"trip_id": tripId.uuidString,
				"is_essential": item.isEssential
			]
		))
	}
    
	/// Tracks a feature usage event
	/// - Parameters:
	///   - feature: The feature that was used
	///   - properties: Additional properties to track
	func trackFeatureUsed(feature: String, properties: [String: Any] = [:]) {
		guard isEnabled else { return }
        
		var allProperties = properties
		allProperties["feature"] = feature
        
		track(event: AnalyticsEvent(
			name: "feature_used",
			properties: allProperties
		))
	}
    
	/// Tracks an error event
	/// - Parameters:
	///   - error: The error that occurred
	///   - context: Additional context about where the error occurred
	func trackError(error: Error, context: String) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: "error",
			properties: [
				"error_message": error.localizedDescription,
				"error_code": (error as NSError).code,
				"context": context
			]
		))
	}
    
	/// Tracks a custom event
	/// - Parameters:
	///   - name: The name of the event
	///   - properties: Additional properties to track
	func trackCustomEvent(name: String, properties: [String: Any] = [:]) {
		guard isEnabled else { return }
        
		track(event: AnalyticsEvent(
			name: name,
			properties: properties
		))
	}
    
	/// Starts a new session
	func startNewSession() {
		guard isEnabled else { return }
        
		sessionId = UUID().uuidString
		sessionStartTime = Date()
        
		track(event: AnalyticsEvent(
			name: "session_start",
			properties: [
				"session_id": sessionId
			]
		))
	}
    
	/// Ends the current session
	func endSession() {
		guard isEnabled else { return }
        
		let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        
		track(event: AnalyticsEvent(
			name: "session_end",
			properties: [
				"session_id": sessionId,
				"duration_seconds": Int(sessionDuration)
			]
		))
        
		// Ensure all events are processed
		processEventQueue()
	}
    
	/// Enables or disables analytics tracking
	/// - Parameter enabled: Whether to enable analytics
	func setEnabled(_ enabled: Bool) {
		isEnabled = enabled
        
		if enabled, processingTimer == nil {
			startProcessingTimer()
		} else if !enabled, processingTimer != nil {
			processingTimer?.invalidate()
			processingTimer = nil
		}
	}
    
	// MARK: - Private Methods
    
	/// Tracks an event by adding it to the queue
	/// - Parameter event: The event to track
	private func track(event: AnalyticsEvent) {
		// Add common properties to the event
		var eventWithCommonProps = event
		eventWithCommonProps.properties["session_id"] = sessionId
		eventWithCommonProps.properties["user_id"] = userId
		eventWithCommonProps.properties["timestamp"] = Int(Date().timeIntervalSince1970)
        
		// Add the event to the queue
		eventQueue.append(eventWithCommonProps)
        
		// Process the queue if it's getting large
		if eventQueue.count >= maxQueueSize {
			processEventQueue()
		}
	}
    
	/// Processes the event queue, sending events to the analytics backend
	private func processEventQueue() {
		guard !eventQueue.isEmpty else { return }
        
		if AppConstants.enableDebugLogging {
			for event in eventQueue {
				print("Analytics Event: \(event.name), Properties: \(event.properties)")
			}
		}
        
		// In a real implementation, this would send the events to a backend service
		// For this example, we'll just clear the queue
		eventQueue.removeAll()
	}
    
	/// Starts the timer for processing the event queue
	private func startProcessingTimer() {
		processingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
			self?.processEventQueue()
		}
	}
}

// MARK: - Analytics Event

/// Represents an analytics event
struct AnalyticsEvent {
	/// The name of the event
	let name: String
    
	/// Properties associated with the event
	var properties: [String: Any]
    
	/// The timestamp when the event occurred
	let timestamp: Date = .init()
}

// MARK: - View Extensions

/// Extension for tracking screen views in SwiftUI
extension View {
	/// Tracks a screen view when the view appears
	/// - Parameter screenName: The name of the screen to track
	/// - Returns: The view with tracking added
	func trackScreenView(_ screenName: String) -> some View {
		onAppear {
			AnalyticsService.shared.trackScreenView(screenName: screenName)
		}
	}
}
