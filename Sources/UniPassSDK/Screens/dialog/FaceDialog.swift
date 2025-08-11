//
//  FaceUpdateDialog.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

open class FaceDialog: UIViewController {
    let dialog = FaceView()
    
    var completion: ((UIImage) -> ())?
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dialog.cameraView.appear = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dialog.cameraView.appear = false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        dialog.completion = { [weak self] image in
            self?.dismiss(animated: true)
            guard let image else { return }
            self?.completion?(image)
        }
    }
}
