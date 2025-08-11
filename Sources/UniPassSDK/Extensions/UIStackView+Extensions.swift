//
//  UIStackView+Extensions.swift
//  Unipass
//
//  Created by Javlonbek Dev on 15/07/25.
//

import UIKit

extension UIStackView {
    
    /// Bir nechta view'larni bir vaqtda stackView'ga qo'shish
    /// - Parameter views: Qo'shilishi kerak bo'lgan view'lar
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
    
    /// Array ko'rinishida view'larni qo'shish
    /// - Parameter views: View'lar array'i
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
    
    /// Bir nechta view'larni olib tashlash
    /// - Parameter views: Olib tashlanishi kerak bo'lgan view'lar
    func removeArrangedSubviews(_ views: UIView...) {
        views.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    /// Barcha arranged subview'larni olib tashlash
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
