//
//  BaseDialogView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class BaseDialogView: BaseView {
    var dismiss: (() -> ())?
    let dismissBack = UIButton()
    let back = UIView()
    
    let scroll = UIScrollView()
    let stack = UIStackView()
    
    let indicator = UIView()
//    let dismiss = Button()
    
    func setFull() {
        setBack()
        setScroll()
        setNav()
    }
    
    func setBack() {
        addSubviews(dismissBack, back)
        dismissBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        dismissBack.addTarget(self, action: #selector(dismissTap), for: .touchUpInside)
        back.setCornerRadiusiPhoneXorLater(12)
        back.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            if isPhone {
                $0.left.right.equalToSuperview()
            } else {
                $0.centerX.equalToSuperview()
                $0.width.equalTo(cellWidth + 20)
            }
        }
        back.backgroundColor = .systemBackground
    }
    
    @objc func dismissTap() {
        dismiss?()
    }
    
    func setScroll() {
        back.addSubview(scroll)
        
        scroll.snp.makeConstraints { $0.edges.equalToSuperview() }
        scroll.addSubview(stack)
        scroll.keyboardDismissMode = .interactive
        
        stack.snp.makeConstraints { $0.top.bottom.equalToSuperview().inset(40); $0.leading.trailing.equalTo(back).inset(16) }
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
    }
    
    func setNav() {
        back.addSubviews(indicator/*, dismiss*/)
        
        indicator.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(6)
        }
        indicator.layer.cornerRadius = 3
        indicator.backgroundColor = .systemBackground
    }
}
