//
//  BaseDialog.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit
import SnapKit

class BaseDialog<sub: BaseDialogView>: BaseViewController {
    var screenSize: CGSize { UIScreen.main.bounds.size }
    
    let dialog = sub()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = screenSize
        dialog.dismiss = { self.dismiss(animated: true) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .clear
        view.addSubview(dialog)
        dialog.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

