//
//  LoadingBar.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class LoadingBar: BaseView {
    let bar = UIView()
    var barLeft: NSLayoutConstraint?
    
    override func setView() {
        backgroundColor = .systemBlue.withAlphaComponent(0.2)
        snp.makeConstraints { $0.height.equalTo(4) }
        layer.cornerRadius = 2
        addSubview(bar)
        bar.backgroundColor = .systemBlue
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 100).isActive = true
        barLeft = bar.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        barLeft?.isActive = true
        bar.layer.cornerRadius = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.startConstraintAnimation()
        }
    }
    
    func startConstraintAnimation() {
        barLeft?.constant = (isPhone ? screenSize.width : (cellWidth + 20)) - 132
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse]) { self.layoutIfNeeded() }
    }
}

