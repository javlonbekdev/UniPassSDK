//
//  FaceUpdateDialog.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

open class FaceDialog: UIViewController {
    open var subview = FaceView()
    
    open var completion: ((UIImage) -> ())?
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subview.cameraView.appear = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subview.cameraView.appear = false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(subview)
        subview.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        subview.completion = { [weak self] image in
            self?.dismiss(animated: true)
            guard let image else { return }
            self?.completion?(image)
        }
    }
}
