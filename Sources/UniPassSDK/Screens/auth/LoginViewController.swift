//
//  LoginViewController.swift
//  Unipass
//
//  Created by Javlonbek Dev on 15/07/25.
//

import UIKit
import SnapKit
import Combine

class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    private let subview = LoginView()
//    private let viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        setupBindings()
        setUpAcivityIndicator()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(subview)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTap)))
        subview.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        subview.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        subview.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        subview.birthDate.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
//    private func setupBindings() {
//        bindActivityStatus(
//            publisher: viewModel.$activity,
//            cancellables: &cancellables
//        )
//        
//        viewModel.$isLoginSuccessful
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] success in
//                if success {
//                    self?.handleLoginSuccess()
//                }
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$selectedSegment
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] index in
//                guard let self = self else { return }
//                self.subview.field.placeholder = index == 0 ? "AA000000" : "JShShIR (14 raqam)"
//                [self.subview.birthField, self.subview.birthDate].forEach { $0.isHidden = index == 1 }
//                self.subview.pinflLabel.isHidden = index == 0
//                
////                self.subview.field.endEditing(true)
//                self.subview.field.keyboardType = index == 0 && viewModel.field.count < 2 ? .default : .numberPad
//                self.subview.birthField.becomeFirstResponder()
//                self.subview.field.becomeFirstResponder()
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$field
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                self?.subview.field.text = text
//            }
//            .store(in: &cancellables)
//        
//        subview.field.textPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                self?.viewModel.field = text.uppercased()
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$birthField
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                self?.subview.birthField.text = text
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$birthDate
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] date in
//                if self?.subview.birthDate.date != date {
//                    self?.subview.birthDate.date = date
//                }
//            }
//            .store(in: &cancellables)
//        
//        subview.birthField.textPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                self?.viewModel.birthField = text
//            }
//            .store(in: &cancellables)
//    }
    
    @objc func segmentChanged(_ segment: UISegmentedControl) {
//        viewModel.selectedSegment = segment.selectedSegmentIndex
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
//        viewModel.birthDate = datePicker.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
//        if viewModel.isValid {
//            let dialog = FaceDialog()
//            dialog.completion = { [weak self] image in
//                self?.viewModel.login(with: image)
//            }
//            present(dialog, animated: true)
//        } else {
//            subview.field.setError(true)
//            let action = UIAlertAction(title: "OK", style: .default)
//            customAlertView(title: "Xatolik", message: "ma'lumotlarni to'liq kiriting", actions: [action])
//        }
    }
    
    @objc func viewTap() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Xatolik", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoading(_ show: Bool) {
        // Add loading indicator here
        // You can use a third-party library like MBProgressHUD or create custom loader
    }
    
//    private func handleLoginSuccess() {
//        // Navigate to main screen
//        let mainViewController = MainViewController() // Your main screen
//        navigationController?.setViewControllers([mainViewController], animated: true)
//    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
