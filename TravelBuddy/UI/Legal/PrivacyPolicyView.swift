//
//  PrivacyPolicyView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 27.05.25.
//

import SafariServices
import SwiftUI

struct PrivacyPolicyView: View {
	@Environment(\.dismiss) private var dismiss
    
	// URLs for your privacy policy and terms of service
	private let privacyPolicyURL = URL(string: "https://your-website.com/privacy-policy")!
	private let termsOfServiceURL = URL(string: "https://your-website.com/terms-of-service")!
    
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					// Privacy Policy Section
					VStack(alignment: .leading, spacing: 12) {
						Text("Privacy Policy")
							.font(.title2)
							.fontWeight(.bold)
                        
						Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
							.font(.caption)
							.foregroundColor(.secondary)
                        
						Text("Your privacy is important to us. This policy explains how TravelBuddy collects, uses, and protects your information.")
							.font(.body)
                        
						// Data Collection
						PolicySection(
							title: "Data We Collect",
							items: [
								"Trip information (destinations, dates, packing lists)",
								"Usage analytics to improve the app",
								"Device information for troubleshooting",
								"Location data (only when using place search)"
							]
						)
                        
						// Data Usage
						PolicySection(
							title: "How We Use Your Data",
							items: [
								"To provide and improve our services",
								"To sync your data across devices",
								"To show relevant advertisements (free version)",
								"To analyze app performance and usage patterns"
							]
						)
                        
						// Data Protection
						PolicySection(
							title: "Data Protection",
							items: [
								"Your data is encrypted in transit and at rest",
								"We use iCloud for secure data synchronization",
								"We don't sell your personal information",
								"You can delete your data at any time"
							]
						)
                        
						// Third-Party Services
						PolicySection(
							title: "Third-Party Services",
							items: [
								"Google Places API for location search",
								"Google AdMob for advertisements",
								"Firebase Analytics for app analytics",
								"iCloud for data synchronization"
							]
						)
                        
						// User Rights
						PolicySection(
							title: "Your Rights",
							items: [
								"Access your personal data",
								"Request data deletion",
								"Opt out of analytics",
								"Control ad personalization"
							]
						)
                        
						// Children's Privacy
						VStack(alignment: .leading, spacing: 8) {
							Text("Children's Privacy")
								.font(.headline)
							Text("TravelBuddy is not intended for children under 13. We do not knowingly collect personal information from children under 13.")
								.font(.body)
						}
                        
						// Contact Information
						VStack(alignment: .leading, spacing: 8) {
							Text("Contact Us")
								.font(.headline)
							Text("If you have questions about this privacy policy, please contact us at:")
								.font(.body)
							Link("support@travelbuddy.app", destination: URL(string: "mailto:support@travelbuddy.app")!)
								.font(.body)
								.foregroundColor(.blue)
						}
                        
						// External Link
						Button {
							openURL(privacyPolicyURL)
						} label: {
							Label("View Full Privacy Policy", systemImage: "arrow.up.right.square")
						}
						.padding(.top)
					}
					.padding()
				}
			}
			.navigationTitle("Privacy Policy")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}
    
	private func openURL(_ url: URL) {
		UIApplication.shared.open(url)
	}
}

struct PolicySection: View {
	let title: String
	let items: [String]
    
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.headline)
            
			ForEach(items, id: \.self) { item in
				HStack(alignment: .top) {
					Text("•")
					Text(item)
						.font(.body)
				}
			}
		}
	}
}

// Terms of Service View
struct TermsOfServiceView: View {
	@Environment(\.dismiss) private var dismiss
    
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					Text("Terms of Service")
						.font(.title2)
						.fontWeight(.bold)
                    
					Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
						.font(.caption)
						.foregroundColor(.secondary)
                    
					Text("By using TravelBuddy, you agree to these terms.")
						.font(.body)
                    
					TermsSection(
						title: "Acceptance of Terms",
						content: "By downloading, installing, or using TravelBuddy, you agree to be bound by these Terms of Service."
					)
                    
					TermsSection(
						title: "Use of Service",
						content: "TravelBuddy is provided for personal, non-commercial use. You may not use the app for any illegal or unauthorized purpose."
					)
                    
					TermsSection(
						title: "User Content",
						content: "You retain ownership of any content you create in TravelBuddy. You grant us a license to store and sync your data as necessary to provide the service."
					)
                    
					TermsSection(
						title: "Premium Subscription",
						content: "Premium features require a paid subscription. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period."
					)
                    
					TermsSection(
						title: "Limitation of Liability",
						content: "TravelBuddy is provided 'as is' without warranties. We are not liable for any damages arising from your use of the app."
					)
                    
					TermsSection(
						title: "Changes to Terms",
						content: "We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms."
					)
                    
					TermsSection(
						title: "Termination",
						content: "We reserve the right to terminate or suspend your access to TravelBuddy at any time for violation of these terms."
					)
                    
					TermsSection(
						title: "Contact",
						content: "For questions about these terms, contact us at support@travelbuddy.app"
					)
				}
				.padding()
			}
			.navigationTitle("Terms of Service")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}
}

struct TermsSection: View {
	let title: String
	let content: String
    
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.headline)
			Text(content)
				.font(.body)
		}
	}
}

#Preview("Privacy Policy") {
	PrivacyPolicyView()
}

#Preview("Terms of Service") {
	TermsOfServiceView()
}
