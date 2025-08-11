//
//  IconLabelView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class IconLabelView: BaseView {
    let stack = UIStackView()
    let image = UIImageView()
    let title = UILabel()
    
    var color: UIColor = .label { didSet {
        image.tintColor = color
        title.textColor = color
    }}
    
    override func setView() {
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        stack.spacing = 8
        
        stack.addArrangedSubviews(image, title)
        image.snp.makeConstraints { $0.width.height.equalTo(20) }
        image.tintColor = color
        title.numberOfLines = 0
    }
}
