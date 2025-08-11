//
//  LoginView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 15/07/25.
//

import UIKit

class LoginView: BaseView {
    
    // MARK: - UI Components
    private let gradientBackground = GradientView()
    private var containerView = UIView()
    private var stackView = UIStackView()
    private var logoImageView = UIImageView()
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    var segmentedControl = UISegmentedControl(items: ["Pasport seriya", "JShShIR"])
    var field = CustomTextField()
    var birthField = CustomTextField()
    var pinflLabel = UILabel()
    var birthDate = UIDatePicker()
    var loginButton = UIButton(type: .system)
    private var termTextView = UITextView()
    
    // MARK: - Initialization
    override func setView() {
        addGradientBackground()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubviews(stackView, birthDate)
        
        // StackView'ga elementlarni qo'shish
        stackView.addArrangedSubviews(logoImageView, titleLabel, subtitleLabel, segmentedControl, field, birthField, pinflLabel, loginButton, termTextView)
        
        setUIView()
        setupConstraints()
    }
    
    private func setUIView() {
        // Container view
        containerView.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowRadius = 20
        
        // Stack view
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Logo image view
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        
        // Title label
        titleLabel.text = "Dasturga kirish"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        // Subtitle label
        subtitleLabel.text = "Dasturdan foydalanish uchun ma'lumotlaringizni kiriting!"
        [subtitleLabel, pinflLabel].forEach {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .systemGray
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        
        // Passport text field
        field.placeholder = "AA000000"
        field.autocorrectionType = .no
        
        birthDate.datePickerMode = .date
        birthField.keyboardType = .numberPad
        pinflLabel.isHidden = true
        pinflLabel.text = "JShShIR ni pasportingizdagi rasmingizni pastidagi uzun matndan olishingiz mumkin bo'ladi"
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2000, month: 1, day: 1)
        if let defaultDate = calendar.date(from: dateComponents) {
            birthDate.date = defaultDate
            birthField.placeholder = "01.01.2000"
        }
        
        // Login button
        loginButton.setTitle("Kirish", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 12
        
        setupTermsTextView()
    }
    
    private func setupTermsTextView() {
        termTextView.isEditable = false
        termTextView.isScrollEnabled = false
        termTextView.backgroundColor = .clear
        termTextView.textAlignment = .center
        termTextView.font = .systemFont(ofSize: 12)
        
        // Chiziqlarni olib tashlash
        termTextView.textContainer.lineFragmentPadding = 0
        termTextView.textContainerInset = UIEdgeInsets.zero
        termTextView.contentInset = UIEdgeInsets.zero
        termTextView.scrollIndicatorInsets = UIEdgeInsets.zero
        termTextView.showsVerticalScrollIndicator = false
        termTextView.showsHorizontalScrollIndicator = false
        
        // Agar hali ham chiziq ko'rinsa
        termTextView.layer.borderWidth = 0
        termTextView.layer.borderColor = UIColor.clear.cgColor
        
        let text = "Tizimga kirish orqali siz bizning shartlarimizga va maxfiylik siyosatimizga rozilik bildirasiz."
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.label,
            range: NSRange(location: 0, length: text.count)
        )
        
        if let range = text.range(of: "shartlarimiz") {
            attributedString.addAttribute(.link, value: "https://apple.com", range: NSRange(range, in: text))
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(range, in: text))
        }
        
        if let range = text.range(of: "maxfiylik siyosatimiz") {
            attributedString.addAttribute(.link, value: "https://google.com", range: NSRange(range, in: text))
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(range, in: text))
        }
        
        termTextView.attributedText = attributedString
        termTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(32)
        }
        
        birthDate.snp.makeConstraints {
            $0.trailing.equalTo(birthField).inset(6)
            $0.centerY.equalTo(birthField)
        }
        
        pinflLabel.snp.makeConstraints { $0.height.equalTo(50) }
        
        // Specific height constraints
        logoImageView.snp.makeConstraints { $0.height.equalTo(50) }
        segmentedControl.snp.makeConstraints { $0.height.equalTo(44) }
        
        [field, loginButton].forEach { $0.snp.makeConstraints { $0.height.equalTo(50) } }
        
        // StackView spacing'larini sozlash
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.setCustomSpacing(32, after: subtitleLabel)
        stackView.setCustomSpacing(16, after: field)
    }
}
