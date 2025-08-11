//
//  UIView+Extensions.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

extension UIView {
    var cellWidth: CGFloat { 400 }
    var screenSize: CGSize { UIScreen.main.bounds.size }
    
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
    
    func setCorner(_ type: CornerType) { self.layer.cornerRadius = type.rawValue }
    
    func setBorder(_ color: UIColor = .border, border: CGFloat = 1) {
        self.layer.borderWidth = border
        self.layer.borderColor = color.cgColor
    }
    
    func addDashedBorder(color: UIColor = .label, cornerRadius: CGFloat = 16) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineDashPattern = [4, 4] // 6 uzun chiziq, 4 bo‘shliq
        shapeLayer.lineWidth = 1
        shapeLayer.frame = self.bounds
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath

        // Avval eski borderni o‘chirish (agar bor bo‘lsa)
        self.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }

        self.layer.addSublayer(shapeLayer)
    }
    
    func setCornerRadiusiPhoneXorLater(_ cornerRadius: CGFloat) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let safeAreaInsets = keyWindow.safeAreaInsets

        if safeAreaInsets.top > 20 || safeAreaInsets.bottom > 0 {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        } else {
            self.layer.cornerRadius = 0
        }
    }
    
    func setBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func addGradientBackground() {
        let gradientView = GradientView()
        
        insertSubview(gradientView, at: 0)
        gradientView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

enum CornerType: CGFloat {
    case small = 8
    case regular = 12
    case medium = 16
    case big = 24
}
