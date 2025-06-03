//
//  AppTrackingManager.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 03.06.25.
//

import AdSupport
import AppTrackingTransparency
import FirebaseAnalytics
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

/// Manages App Tracking Transparency and configures analytics/ads based on user consent
@MainActor
final class AppTrackingManager: ObservableObject {
	// MARK: - Singleton

	static let shared = AppTrackingManager()
    
	// MARK: - Published Properties

	@Published private(set) var trackingAuthorizationStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
	@Published private(set) var hasRequestedTracking = false
	@Published private(set) var isTrackingAuthorized = false
    
	// MARK: - Private Properties

	// MARK: - Initialization

	private init() {
		// Check if we've already requested tracking
		hasRequestedTracking = UserSettingsManager.shared.trackingRequested
        
		// Get current authorization status
		updateTrackingStatus()
        
		// Configure based on current status
		configureSDKsBasedOnConsent()
	}
    
	// MARK: - Public Methods
    
	/// Request tracking authorization from the user
	/// - Parameter completion: Callback with the authorization status
	func requestTrackingAuthorization(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
		// Only request if we haven't already
		guard !hasRequestedTracking else {
			completion?(trackingAuthorizationStatus)
			return
		}
        
		// Request authorization
		ATTrackingManager.requestTrackingAuthorization { [weak self] status in
			DispatchQueue.main.async {
				guard let self = self else { return }
                
				// Update our properties
				self.trackingAuthorizationStatus = status
				self.isTrackingAuthorized = (status == .authorized)
				self.hasRequestedTracking = true
                
				// Save that we've requested
				UserSettingsManager.shared.trackingRequested = true
				
				// Configure SDKs based on the response
				self.configureSDKsBasedOnConsent()
                
				// Log the event
				self.logTrackingDecision(status: status)
                
				// Call completion
				completion?(status)
			}
		}
	}
    
	/// Check if we should request tracking (iOS 14.5+ and not determined)
	var shouldRequestTracking: Bool {
		if #available(iOS 14.5, *) {
			return trackingAuthorizationStatus == .notDetermined && !hasRequestedTracking
		}
		return false
	}
    
	/// Update the current tracking status
	func updateTrackingStatus() {
		if #available(iOS 14.5, *) {
			trackingAuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
			isTrackingAuthorized = (trackingAuthorizationStatus == .authorized)
		} else {
			// Pre iOS 14.5, tracking is implicitly allowed
			trackingAuthorizationStatus = .authorized
			isTrackingAuthorized = true
		}
	}
    
	// MARK: - Private Methods
    
	/// Configure Firebase Analytics and Google AdMob based on consent
	private func configureSDKsBasedOnConsent() {
		configureFirebaseAnalytics()
		configureGoogleAdMob()
	}
    
	/// Configure Firebase Analytics based on tracking consent
	private func configureFirebaseAnalytics() {
		if AppConstants.enableAnalytics {
			if isTrackingAuthorized {
				// User authorized tracking - enable full analytics
				Analytics.setAnalyticsCollectionEnabled(true)
				Analytics.setUserProperty("true", forName: "tracking_authorized")
                
				if AppConstants.enableDebugLogging {
					print("📊 Analytics: Full tracking enabled with user consent")
				}
			} else {
				// User declined or restricted - use limited analytics
				// Firebase Analytics can still collect anonymous data
				Analytics.setAnalyticsCollectionEnabled(true)
				Analytics.setUserProperty("false", forName: "tracking_authorized")
                
				// Disable advertising features
				Analytics.setUserProperty("false", forName: "allow_personalized_ads")
                
				if AppConstants.enableDebugLogging {
					print("📊 Analytics: Limited tracking mode (anonymous only)")
				}
			}
		}
	}
    
	/// Configure Google AdMob based on tracking consent
	private func configureGoogleAdMob() {
		let gadRequest = MobileAds.shared.requestConfiguration
        
		if isTrackingAuthorized {
			// User authorized tracking - enable personalized ads
			gadRequest.tagForChildDirectedTreatment = false
            
			if AppConstants.enableDebugLogging {
				print("📢 AdMob: Personalized ads enabled with user consent")
			}
		} else {
			// User declined - disable personalized ads
			// This ensures GDPR compliance
			let extras = Extras()
			extras.additionalParameters = ["npa": "1"] // non-personalized ads
            
			// Also inform AdMob about consent status
			gadRequest.tagForChildDirectedTreatment = false
			gadRequest.tagForUnderAgeOfConsent = false
            
			// For GDPR compliance
			ConsentInformation.shared.requestConsentInfoUpdate(with: nil) { error in
				if error == nil {
					// Set consent to non-personalized
					ConsentInformation.shared.reset()
				}
			}
            
			if AppConstants.enableDebugLogging {
				print("📢 AdMob: Non-personalized ads only (no tracking)")
			}
		}
	}
    
	/// Log the tracking decision for analytics
	private func logTrackingDecision(status: ATTrackingManager.AuthorizationStatus) {
		guard AppConstants.enableAnalytics else { return }
        
		let statusString: String
		switch status {
		case .authorized:
			statusString = "authorized"
		case .denied:
			statusString = "denied"
		case .restricted:
			statusString = "restricted"
		case .notDetermined:
			statusString = "not_determined"
		@unknown default:
			statusString = "unknown"
		}
        
		// Log event with limited data (respects user choice)
		Analytics.logEvent("att_permission_response", parameters: [
			"status": statusString
		])
	}
    
	/// Get IDFA if authorized (for debugging/testing)
	var advertisingIdentifier: String? {
		guard isTrackingAuthorized else { return nil }
		return ASIdentifierManager.shared().advertisingIdentifier.uuidString
	}
}

// MARK: - Helper Extensions

extension ATTrackingManager.AuthorizationStatus {
	var displayName: String {
		switch self {
		case .notDetermined:
			return "Not Determined"
		case .restricted:
			return "Restricted"
		case .denied:
			return "Denied"
		case .authorized:
			return "Authorized"
		@unknown default:
			return "Unknown"
		}
	}
}
