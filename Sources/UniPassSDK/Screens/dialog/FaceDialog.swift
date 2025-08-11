//
//  FaceUpdateDialog.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class FaceDialog: BaseDialog<FaceView> {
    
    var completion: ((UIImage) -> ())?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dialog.cameraView.appear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dialog.cameraView.appear = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dialog.completion = { [weak self] image in
            self?.dismiss(animated: true)
            guard let image else { return }
            self?.completion?(image)
        }
    }
}
