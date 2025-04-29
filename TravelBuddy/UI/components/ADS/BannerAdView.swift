import GoogleMobileAds
import SwiftUI

struct BannerViewContainer: UIViewRepresentable {
	let adSize: AdSize

	init(_ adSize: AdSize) {
		self.adSize = adSize
	}

	func makeUIView(context: Context) -> UIView {
		// Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
		// frame size changes; wrapping in a UIView container insulates the GADBannerView from size
		// changes that impact the view returned from makeUIView.
		let view = UIView()
		view.addSubview(context.coordinator.bannerView)

		return view
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		context.coordinator.bannerView.adSize = adSize
	}

	func makeCoordinator() -> BannerCoordinator {
		return BannerCoordinator(self)
	}

	// [END create_banner_view]

	// [START create_banner]
	class BannerCoordinator: NSObject, BannerViewDelegate {
		private(set) lazy var bannerView: BannerView = {
			let banner = BannerView(adSize: parent.adSize)
			// [START load_ad]
			banner.adUnitID = "ca-app-pub-7916994689799868/7529214611"
			banner.load(Request())
			// [END load_ad]
			// [START set_delegate]
			banner.delegate = self
			// [END set_delegate]
			return banner
		}()

		let parent: BannerViewContainer

		init(_ parent: BannerViewContainer) {
			self.parent = parent
		}

		// [END create_banner]

		// MARK: - GADBannerViewDelegate methods

		func bannerViewDidReceiveAd(_ bannerView: BannerView) {
			print("DID RECEIVE AD.")
		}

		func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
			print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
		}
	}
}
