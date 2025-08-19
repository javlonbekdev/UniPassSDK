//
//  CustomActivityView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 21/07/25.
//

import UIKit
import SnapKit

class CustomActivityView: BaseView {
    let activityView = UIView()
    let activity = UIActivityIndicatorView()
    
    override func setView() {
        self.isHidden = true
        self.backgroundColor = .label.withAlphaComponent(0.2)
        self.addSubview(activityView)
        
        activityView.setCorner(.medium)
        activityView.snp.makeConstraints { $0.center.equalToSuperview() }
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = activityView.bounds
        blurEffectView.setCorner(.medium)
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityView.addSubview(blurEffectView)
        
        activityView.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.style = .large
        activity.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func startAnimating() {
        activity.startAnimating()
        self.isHidden = false
    }
    
    func stopAnimating() {
        activity.stopAnimating()
        self.isHidden = true
    }
}
