import GoogleMobileAds
import SwiftUI

struct BannerViewContainer: UIViewRepresentable {
	let adSize: AdSize
	@StateObject private var trackingManager = AppTrackingManager.shared
	
	init(_ adSize: AdSize) {
		self.adSize = adSize
	}
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		view.addSubview(context.coordinator.bannerView)
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		context.coordinator.bannerView.adSize = adSize
		context.coordinator.updateTrackingConsent(trackingManager.isTrackingAuthorized)
	}
	
	func makeCoordinator() -> BannerCoordinator {
		return BannerCoordinator(self)
	}
	
	class BannerCoordinator: NSObject, BannerViewDelegate {
		private(set) lazy var bannerView: BannerView = {
			let banner = BannerView()
			banner.adUnitID = getAdUnitID()
			banner.delegate = self
			return banner
		}()
		
		let parent: BannerViewContainer
		
		init(_ parent: BannerViewContainer) {
			self.parent = parent
		}
		
		private func getAdUnitID() -> String {
			// Use test ad unit ID in debug mode
			#if DEBUG
			return "ca-app-pub-3940256099942544/2934735716" // Test banner ad
			#else
			return "ca-app-pub-7916994689799868/7529214611" // Your production ad unit
			#endif
		}
		
		func updateTrackingConsent(_ isAuthorized: Bool) {
			let request = Request()
			
			if !isAuthorized {
				// User has not consented to tracking - request non-personalized ads
				let extras = Extras()
				extras.additionalParameters = ["npa": "1"]
				request.register(extras)
			}
			
			bannerView.load(request)
		}
		
		// MARK: - GADBannerViewDelegate methods
		
		func bannerViewDidReceiveAd(_ bannerView: BannerView) {
			if AppConstants.enableDebugLogging {
				print("✅ Ad received successfully")
			}
		}
		
		func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
			if AppConstants.enableDebugLogging {
				print("❌ Failed to receive ad: \(error.localizedDescription)")
			}
		}
	}
}
