// TravelBuddy/UI/components/ADS/BannerAdView.swift
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform // Ensure UMP is imported

struct BannerViewContainer: UIViewRepresentable {
	let adSize: AdSize
	// No longer need to observe trackingManager here for consent, UMP handles it globally for ads.

	init(_ adSize: AdSize) {
		self.adSize = adSize
	}

	func makeUIView(context: Context) -> UIView {
		let view = UIView() // Create a simple UIView as the container
		// Add the banner view to the UIView hierarchy
		view.addSubview(context.coordinator.bannerView)
		// Set constraints for the banner to fill the container view
		context.coordinator.bannerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			context.coordinator.bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			context.coordinator.bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			context.coordinator.bannerView.topAnchor.constraint(equalTo: view.topAnchor),
			context.coordinator.bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		return view
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		// Check if the adSize has changed and update if necessary
		if context.coordinator.bannerView.adSize.size != adSize.size ||
			context.coordinator.bannerView.adSize.flags != adSize.flags
		{
			context.coordinator.bannerView.adSize = adSize
		}
		// Request an ad if one isn't already loaded or loading
		// UMP consent is handled globally; AdMob SDK will request appropriate ads.
		if context.coordinator.bannerView.rootViewController != nil && !context.coordinator.isAdLoadingOrLoaded {
			context.coordinator.loadAd()
		}
	}

	func makeCoordinator() -> BannerCoordinator {
		return BannerCoordinator(self)
	}

	class BannerCoordinator: NSObject, BannerViewDelegate {
		private(set) lazy var bannerView: BannerView = {
			let banner = BannerView()
			banner.adUnitID = getAdUnitID()
			banner.delegate = self
			// Attempt to find the root view controller for the banner
			banner.rootViewController = UIApplication.shared.connectedScenes
				.filter { $0.activationState == .foregroundActive }
				.map { $0 as? UIWindowScene }
				.compactMap { $0 }
				.first?.windows
				.filter { $0.isKeyWindow }.first?.rootViewController
			return banner
		}()

		let parent: BannerViewContainer
		var isAdLoadingOrLoaded = false // Track ad load state

		init(_ parent: BannerViewContainer) {
			self.parent = parent
			super.init()
			loadAd() // Initial ad load
		}

		private func getAdUnitID() -> String {
			#if DEBUG
			return "ca-app-pub-3940256099942544/2934735716" // Test banner ad
			#else
			// Replace with your PRODUCTION Ad Unit ID
			return "ca-app-pub-YOUR_ADMOB_APP_ID/YOUR_BANNER_AD_UNIT_ID"
			#endif
		}

		func loadAd() {
			guard !isAdLoadingOrLoaded else { return } // Don't load if already loading/loaded

			// The GADRequest object no longer needs explicit npa=1 if UMP is implemented correctly.
			// UMP informs the Google Mobile Ads SDK of the user's consent choices.
			let request = Request()
			isAdLoadingOrLoaded = true // Set loading flag
			bannerView.load(request)

			if AppConstants.enableDebugLogging {
				print("Banner Ad: Attempting to load ad. UMP CanRequestAds: \(ConsentInformation.shared.canRequestAds)")
			}
		}

		// MARK: - GADBannerViewDelegate methods

		func bannerViewDidReceiveAd(_ bannerView: BannerView) {
			if AppConstants.enableDebugLogging {
				print("✅ AdMob Banner: Ad received successfully")
			}
			isAdLoadingOrLoaded = true // Ad is loaded
		}

		func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
			if AppConstants.enableDebugLogging {
				print("❌ AdMob Banner: Failed to receive ad: \(error.localizedDescription)")
			}
			isAdLoadingOrLoaded = false // Reset flag on failure to allow retry
		}

		func bannerViewWillPresentScreen(_ bannerView: BannerView) {
			if AppConstants.enableDebugLogging {
				print("AdMob Banner: Will present screen")
			}
		}

		func bannerViewWillDismissScreen(_ bannerView: BannerView) {
			if AppConstants.enableDebugLogging {
				print("AdMob Banner: Will dismiss screen")
			}
		}

		func bannerViewDidDismissScreen(_ bannerView: BannerView) {
			if AppConstants.enableDebugLogging {
				print("AdMob Banner: Did dismiss screen")
			}
		}
	}
}
