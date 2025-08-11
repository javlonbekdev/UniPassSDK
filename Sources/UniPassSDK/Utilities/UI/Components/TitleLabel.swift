//
//  TitleLabel.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class TitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = .systemFont(ofSize: 15, weight: .semibold)
        self.numberOfLines = 0
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.6
    }
    
    required init?(coder: NSCoder) { nil }
}


class SubtitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = .systemFont(ofSize: 15)
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) { nil }
}
