//
//  Button.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit
import SnapKit

class Button: UIButton {
    var customType: UIButtonType = .fill
    var textColor: UIColor = .label
    var backColor: UIColor = .systemBackground
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) { nil }
    
    func setCustom(_ string: String, _ type: UIButtonType = .fill, fontSize: CGFloat = 17) {
        configuration = .bordered()
        configuration?.imagePadding = 12
        configuration?.imagePlacement = .trailing
        configuration?.attributedTitle = .init(
            string, attributes: .init([
                .font: UIFont.systemFont(ofSize: fontSize),
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ])
        )
        setConfig(type)
    }
    
    func setConfig(_ type: UIButtonType = .fill) {
        customType = type
        switch type {
        case .fill:
            textColor = .white
            configuration?.baseBackgroundColor = .systemBlue
        case .bordered(let color):
            backColor = color
            textColor = color
            configuration?.baseBackgroundColor = .clear
            setCorner(.small)
            setBorder(color)
        case .borderless:
            textColor = .systemBlue
            configuration?.baseBackgroundColor = .clear
        case .gray:
            textColor = .label
            configuration?.baseBackgroundColor = .systemBackground
        }
        configuration?.attributedTitle?.mergeAttributes(.init([.foregroundColor: textColor]))
    }
    
    override var isHighlighted: Bool { didSet {
        configuration?.attributedTitle?.mergeAttributes(.init([.foregroundColor: textColor.withAlphaComponent(isHighlighted ? 0.5 : 1)]))
        if customType == .bordered(color: backColor) {
            setBorder(backColor.withAlphaComponent(isHighlighted ? 0.5 : 1))
        }
    }}
    
    func setView() {
        snp.makeConstraints { $0.height.equalTo(50) }
    }
}

enum UIButtonType: Equatable {
    case fill, bordered(color: UIColor), borderless, gray
}
