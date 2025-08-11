//
//  BaseViewController.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 08/08/25.
//
import UIKit


class BaseViewController: UIViewController {
    var activity: CustomActivityView? = CustomActivityView()
    
    func setUpAcivityIndicator() {
        guard let activity else { return }
        view.addSubview(activity)
        activity.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func customAlertView(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}
