//
//  FaceView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

class FaceView: BaseDialogView {
    var completion: ((UIImage?) -> ())?
    
    let title = TitleLabel()
    let instruction = IconLabelView()
    let loadingBar = LoadingBar()
    let distanceFace = IconLabelView()
    let headStatus = IconLabelView()
    let takePrivateData = UILabel()
    let extraView = UIView()
    let cameraView = FaceCameraView()
    
    override func setView() {
        setFull()
        stack.alignment = .fill
        stack.addArrangedSubviews(title, instruction, loadingBar, distanceFace, headStatus, takePrivateData, extraView)
        title.textAlignment = .center
        title.text = "identity_detail_title".text
        
        instruction.title.text = "please_follow_the_instruction".text
        instruction.image.image = UIImage(named: "follow.signs")
        
        takePrivateData.text = "personal_data_retrieval".text
        setUpdate(0, .normal)
        
        extraView.addSubview(cameraView)
        cameraView.snp.makeConstraints { $0.centerX.top.bottom.equalToSuperview() }
        cameraView.update = { self.setUpdate($0, $1) }
    }
    
    func notFace() {
        distanceFace.title.text = "please_look_straight_at_the_camera".text
        distanceFace.image.image = UIImage(named: "eye.tracking")
        
        headStatus.title.text = "don_t_rotate_your_head".text
        headStatus.image.image = UIImage(named: "face.smiling")
        
        [distanceFace, headStatus].forEach { $0.color = .systemRed }
    }
    
    func setUpdate(_ distance: Double, _ status: HeadStatus) {
        distanceFace.title.text = "please_look_straight_at_the_camera".text
        distanceFace.image.image = UIImage(named: "eye.tracking")
        
        headStatus.title.text = "don_t_rotate_your_head".text
        headStatus.image.image = UIImage(named: "face.smiling")
        
        [distanceFace, headStatus].forEach { $0.color = .systemRed }
        
        guard let _ = cameraView.cropImage else { return }
        
        if distance < 0.03 {
            distanceFace.title.text = "move_closer_to_the_camera".text
            distanceFace.image.image = UIImage(named: "face.down")
        } else if distance > 0.2 {
            distanceFace.title.text = "move_away_from_the_camera".text
            distanceFace.image.image = UIImage(named: "face.up")
        } else {
            distanceFace.title.text = "face_is_at_the_right_distance_hold_still_and_blink".text
            distanceFace.color = .systemGreen
            distanceFace.image.image = UIImage(named: "checkmark")
        }
        
        switch status {
        case .upDown:
            headStatus.title.text = "face_is_not_straight_don_t_face_downwards_or_upwards".text
            headStatus.image.image = UIImage(named: "face.nod")
        case .leftRight:
            headStatus.title.text = "face_is_not_straight_don_t_face_sideways".text
            headStatus.image.image = UIImage(named: "face.right")
        case .rotate:
            headStatus.title.text = "face_is_not_straight_don_t_tilt_your_head".text
            headStatus.image.image = UIImage(named: "face.shake")
        case .normal:
            headStatus.title.text = "face_is_straight_hold_still".text
            headStatus.color = .systemGreen
            headStatus.image.image = .checkmark
        }
        
        if distanceFace.color == .systemGreen && headStatus.color == .systemGreen {
            completion?(cameraView.photo)
        }
    }
}

enum HeadStatus { case upDown, leftRight, rotate, normal }
