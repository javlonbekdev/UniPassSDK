//
//  UITextField+Extensions.swift
//  Unipass
//
//  Created by Javlonbek Dev on 17/07/25.
//

import UIKit
import Combine

extension UITextField {
    
    var textBinding: String {
        get { text ?? "" }
        set { text = newValue }
    }
    
    // Publisher for text changes
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .prepend(self.text ?? "")
            .eraseToAnyPublisher()
    }
}
