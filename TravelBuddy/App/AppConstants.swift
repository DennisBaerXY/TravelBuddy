//
//  AppConstants.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Foundation
import SwiftUI

/// A central location for application-wide constants and configuration values
enum AppConstants {
	// MARK: - Feature Flags
    
	/// Controls whether CloudKit synchronization is enabled
	static let enableCloudSync = true
    
	/// Controls whether analytics are enabled
	static let enableAnalytics = true
    
	/// Controls whether debug logging is enabled
	static let enableDebugLogging = true
    
	// MARK: - UI Constants
    
	/// Standard corner radius for cards and containers
	static let cornerRadius: CGFloat = 16
    
	/// Standard padding for screen margins
	static let screenPadding: CGFloat = 16
    
	/// Spacing between elements in a stack
	static let standardSpacing: CGFloat = 12
    
	/// Standard shadow radius for elevated components
	static let shadowRadius: CGFloat = 8
    
	// MARK: - Animation Constants
    
	/// Standard duration for animations
	static let animationDuration: Double = 0.3
    
	/// Spring animation configuration for lively responses
	static let springAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.7)
    
	// MARK: - Data Defaults
    
	/// Default number of days for a new trip
	static let defaultTripDuration: Int = 7
    
	/// Maximum number of trips allowed for free users
	static let freeUserTripLimit: Int = 3
    
	/// Maximum number of items allowed per trip for free users
	static let freeUserItemLimit: Int = 25
    
	// MARK: - Storage Keys
    
	enum UserDefaultsKeys {
		/// Key for tracking onboarding completion
		static let hasCompletedOnboarding = "hasCompletedOnboarding"
        
		/// Key for storing user premium status
		static let userPremiumStatus = "userPremiumStatus"
        
		/// Key for storing the last time the app was used
		static let lastUsedDate = "lastUsedDate"
	}
    
	// MARK: - CloudKit Container IDs
    
	enum CloudKit {
		/// Container identifier for CloudKit storage
		static let containerId = "iCloud.com.dennisdevlops.TravelBuddy.Trips"
	}
    
	// MARK: - Debugging & Development
    
	/// Controls whether to include sample data in development
	static let includeSampleData = false
    
	/// Controls whether to reset user preferences on launch (dev only)
	static let resetPreferencesOnLaunch = false
}
