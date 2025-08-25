//
//  File.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 25/08/25.
//

import UIKit
import SnapKit
import Combine

open class UniPassViewController: UIViewController {
    
    // MARK: - Properties
    var model: GenerateTokenResponse?
    private let viewModel = UniPassViewModel()
    private let activity = CustomActivityView()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.1)
        setupUI()
        setupBindings()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentFaceDialog()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activity.isHidden = true
    }
    
    private func setupBindings() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleViewState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.activity.isHidden = !isLoading
                if isLoading {
                    self?.activity.startAnimating()
                } else {
                    self?.activity.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentFaceDialog() {
        print("present start")
        let dialog = FaceDialog()
        dialog.modalPresentationStyle = .fullScreen
        dialog.completion = { [weak self] image in
            guard let self = self else { return }
            self.viewModel.login(with: image, model: self.model)
        }
        present(dialog, animated: true)
        print("present end")
    }
    
    // MARK: - State Handling
    private func handleViewState(_ state: UniPassViewState) {
        switch state {
        case .idle:
            break
            
        case .loading:
            break // Loading UI allaqachon isLoading orqali handle qilinadi
            
        case .success(let response):
            handleSuccessResponse(response)
        case .error(let errorMessage):
            handleError(errorMessage)
        }
    }
    
    private func handleSuccessResponse(_ response: VerifyIdentityResponse) {
        // Bu yerda muvaffaqiyatli javob bilan ishlash
        print("✅ Tasdiqlash muvaffaqiyatli:")
        print("Request ID: \(response.requestId)")
        print("Result Token: \(response.resultToken)")
        print("Description: \(response.description)")
        
        // Success UI yoki keyingi ekranga o'tish
        showSuccessAlert(message: response.description) {
            // Bu yerda keyingi ekranga o'tish yoki boshqa amallar
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleError(_ errorMessage: String) {
        print("❌ Xatolik: \(errorMessage)")
        
        showErrorAlert(message: errorMessage) {
            // Xatolik bo'lganda qayta urinish yoki orqaga qaytish
            self.viewModel.resetState()
            self.presentFaceDialog()
        }
    }
    
    // MARK: - Alert Methods
    private func showSuccessAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Muvaffaqiyat",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Xatolik",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Qayta urinish", style: .default) { _ in
            completion()
        })
        
        alert.addAction(UIAlertAction(title: "Bekor qilish", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Deinit
    deinit {
        cancellables.removeAll()
    }
}
