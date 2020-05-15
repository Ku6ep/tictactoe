//
//  BaseViewController.swift
//  SampleTicTacToe
//
//  Created by Anton Umnitsyn on 12.05.2020.
//  Copyright © 2020 Anton Umnitsyn. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds

class BaseViewController: UIViewController {

    let kArrayStore = "arrayStoreKey"
    let kCellsCountStore = "cellsCountStoreKey"
    let kNextTurn = "nextTurnStore"
    var bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
    public var imagesArray: Array<UIImage>! = Array()

    private func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        bannerView.delegate = self
    }
    
    func clearStoredData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

extension BaseViewController : UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension BaseViewController : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.viewController(forKey: .to)?.view,
            let fromView = transitionContext.viewController(forKey: .from)?.view
        else {
            return
        }
        let isPresentingSecondView = fromView == self.view
        let presentingView = isPresentingSecondView ? toView : fromView
        if isPresentingSecondView {
            presentingView.alpha = 0
        }
        transitionContext.containerView.addSubview(isPresentingSecondView ? toView : fromView)
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            presentingView.alpha = isPresentingSecondView ? 1 : 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

extension BaseViewController : GADBannerViewDelegate {
/// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
        DLog("Receive AD")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
    didFailToReceiveAdWithError error: GADRequestError) {
        DLog("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        DLog("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        DLog("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        DLog("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        DLog("adViewWillLeaveApplication")
    }
}

extension BaseViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func preloadImages(urlStringsArray: Array<String>) {
        var count = 0
        for urlString in urlStringsArray {
            guard let imageServerUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            if let url = URL(string: imageServerUrl) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("ERROR LOADING IMAGES FROM URL: \(error ?? "Unknown" as! Error)")
                    }
                    else {
                        let url = self.getDocumentsDirectory().appendingPathComponent("file\(count).png")
                        count += 1
                        do {
                            try data?.write(to: url)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }).resume()
            }
        }
    }
}
