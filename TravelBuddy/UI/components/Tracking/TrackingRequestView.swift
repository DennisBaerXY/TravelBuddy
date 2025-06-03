//
//  TrackingRequestView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 03.06.25.
//

import AppTrackingTransparency
import SwiftUI

struct TrackingRequestView: View {
	@StateObject private var trackingManager = AppTrackingManager.shared
	@State private var showingRequest = false
	let onComplete: () -> Void
    
	var body: some View {
		VStack(spacing: 30) {
			// Icon
			Image(systemName: "shield.checkerboard")
				.font(.system(size: 80))
				.foregroundColor(.tripBuddyPrimary)
				.padding(.top, 40)
            
			// Title
			Text("tracking_request_title")
				.font(.title)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
            
			// Description
			VStack(spacing: 20) {
				FeatureRow(
					icon: "chart.line.uptrend.xyaxis",
					title: "tracking_benefit_analytics",
					description: "tracking_benefit_analytics_desc"
				)
                
				FeatureRow(
					icon: "megaphone",
					title: "tracking_benefit_ads",
					description: "tracking_benefit_ads_desc"
				)
                
				FeatureRow(
					icon: "lock.shield",
					title: "tracking_benefit_privacy",
					description: "tracking_benefit_privacy_desc"
				)
			}
			.padding(.horizontal)
            
			Spacer()
            
			// Buttons
			VStack(spacing: 12) {
				Button {
					showingRequest = true
					trackingManager.gatherConsent { _ in
						onComplete()
					}
				} label: {
					Text("Weiter")
						.frame(maxWidth: .infinity)
				}
				.primaryButtonStyle()
                
				// Privacy Policy Link
				Button {
					// Open privacy policy
				} label: {
					Text("learn_more_privacy")
						.font(.footnote)
						.foregroundColor(.tripBuddyTextSecondary)
				}
			}
			.padding(.horizontal, 30)
			.padding(.bottom, 30)
		}
		.background(Color.tripBuddyBackground)
	}
}

struct FeatureRow: View {
	let icon: String
	let title: LocalizedStringKey
	let description: LocalizedStringKey
    
	var body: some View {
		HStack(alignment: .top, spacing: 15) {
			Image(systemName: icon)
				.font(.title2)
				.foregroundColor(.tripBuddyPrimary)
				.frame(width: 30)
            
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.headline)
					.foregroundColor(.tripBuddyText)
                
				Text(description)
					.font(.caption)
					.foregroundColor(.tripBuddyTextSecondary)
					.fixedSize(horizontal: false, vertical: true)
			}
            
			Spacer()
		}
	}
}
