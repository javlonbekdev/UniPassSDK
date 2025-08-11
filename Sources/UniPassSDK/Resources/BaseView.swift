//
//  BaseView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    func setView() {}
    
    var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var hasHomeButton: Bool {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            _ = windowScene.windows.first { window in
                let bottomSafeArea = window.safeAreaInsets.bottom
                return bottomSafeArea == 0
            }
        }
        return false  // Default to "Has Home Button" if window is unavailable
    }
    
    required init?(coder: NSCoder) { nil }
    
    @objc func refresh() {}
}
