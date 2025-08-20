//
//  FaceUpdateDialog.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit
import SnapKit

open class FaceDialog: UIViewController {
    open var subview = FaceView()
    
    open var completion: ((UIImage) -> ())?
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subview.cameraView.startTimer()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        subview.cameraView.stopTimer()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = UIScreen.main.bounds.size
        
        view.addSubview(subview)
        subview.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        subview.completion = { [weak self] image in
            self?.dismiss(animated: true)
            guard let image else { return }
            self?.completion?(image)
        }
    }
}
