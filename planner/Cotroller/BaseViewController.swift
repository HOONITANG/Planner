//
//  BaseViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/11/11.
//

import GoogleMobileAds
import UIKit

public class BaseViewController: UIViewController {
    public lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        return banner
    }()
}
extension BaseViewController: GADBannerViewDelegate {
    func setupBannerViewToBottom(height: CGFloat = 50) {
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: height))
        bannerView = GADBannerView(adSize: adSize)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bannerView)
//        NSLayoutConstraint.activate([
//            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            //view.bottomAnchor
//            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor  ),
//            bannerView.heightAnchor.constraint(equalToConstant: height)
//        ])
        view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: view.safeAreaLayoutGuide,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: 0),
                NSLayoutConstraint(item: bannerView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .centerX,
                multiplier: 1,
                constant: 0)])
        
        bannerView.adUnitID = K.googleAdsKey
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    
    // MARK: - Delegate
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        
    }
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
}
