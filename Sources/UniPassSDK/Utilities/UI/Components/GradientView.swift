//
//  GradientView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 23/07/25.
//

import UIKit

class GradientView: BaseView {
    
    private var gradientLayer: CAGradientLayer?
    
    var startColor: UIColor = UIColor(hex: "#F2EDE1") {
        didSet { updateGradient() }
    }
    
    var endColor: UIColor = UIColor(hex: "#DED1F2") {
        didSet { updateGradient() }
    }
    
    override func setView() {
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        
        updateGradient()
        
        if let gradient = gradientLayer {
            layer.insertSublayer(gradient, at: 0)
        }
    }
    
    private func updateGradient() {
        guard let gradientLayer = gradientLayer else { return }
        
        let startColor = startColor
        let endColor = endColor
        
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]
        
        gradientLayer.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradient()
        }
    }
}
