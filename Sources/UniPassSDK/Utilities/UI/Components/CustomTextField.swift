//
//  CustomTextField.swift
//  Unipass
//
//  Created by Javlonbek Dev on 15/07/25.
//

import UIKit

class CustomTextField: UITextField, UITextFieldDelegate {
    
    // MARK: - IBInspectable Properties
    var cornerRadius: CGFloat = 12 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    var leftPadding: CGFloat = 16 {
        didSet {
            updatePadding()
        }
    }
    
    var rightPadding: CGFloat = 16 {
        didSet {
            updatePadding()
        }
    }
    
    var customHeight: CGFloat = 50 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Private Properties
    private var leftPaddingView: UIView?
    private var rightPaddingView: UIView?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Setup Methods
    private func setupTextField() {
        font = .systemFont(ofSize: 13)
        borderStyle = .none
        backgroundColor = .systemBackground
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        returnKeyType = .done
        
        delegate = self
        
        updatePadding()
        
        // Add target for state changes
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    private func updatePadding() {
        // Left padding
        if leftPadding > 0 {
            leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: 0))
            leftView = leftPaddingView
            leftViewMode = .always
        } else {
            leftView = nil
            leftViewMode = .never
        }
        
        // Right padding
        if rightPadding > 0 {
            rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: rightPadding, height: 0))
            rightView = rightPaddingView
            rightViewMode = .always
        } else {
            rightView = nil
            rightViewMode = .never
        }
    }
    
    // MARK: - Overrides
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: customHeight)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        Task { @MainActor in
            setupTextField()
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldDidBeginEditing() {
        animateBorder(color: UIColor.systemBlue, width: 2)
    }
    
    @objc private func textFieldDidEndEditing() {
        animateBorder(color: borderColor, width: borderWidth)
    }
    
    // MARK: - Animation Methods
    private func animateBorder(color: UIColor, width: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = width
        }
    }
    
    // MARK: - Public Methods
    func setError(_ hasError: Bool) {
        let color = hasError ? UIColor.systemRed : borderColor
        animateBorder(color: color, width: borderWidth)
    }
    
    func addLeftIcon(_ icon: UIImage?, size: CGSize = CGSize(width: 24, height: 24)) {
        guard let icon = icon else { return }
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: size.width + leftPadding, height: size.height))
        containerView.addSubview(iconView)
        iconView.center = CGPoint(x: containerView.frame.width - size.width/2, y: containerView.frame.height/2)
        
        leftView = containerView
        leftViewMode = .always
    }
    
    func addRightIcon(_ icon: UIImage?, size: CGSize = CGSize(width: 24, height: 24)) {
        guard let icon = icon else { return }
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: size.width + rightPadding, height: size.height))
        containerView.addSubview(iconView)
        iconView.center = CGPoint(x: size.width/2, y: containerView.frame.height/2)
        
        rightView = containerView
        rightViewMode = .always
    }
}

// MARK: - Convenience Initializers
extension CustomTextField {
    
    convenience init(placeholder: String, height: CGFloat = 50) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.customHeight = height
    }
    
    convenience init(placeholder: String,
                     cornerRadius: CGFloat = 12,
                     borderColor: UIColor = UIColor(white: 0.9, alpha: 1),
                     height: CGFloat = 50) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.customHeight = height
    }
}
