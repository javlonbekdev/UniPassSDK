//
//  FaceView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

open class FaceView: UIView {
    var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    var dismiss: (() -> ())?
    let dismissBack = UIButton()
    let back = UIView()
    
    open var scroll = UIScrollView()
    let stack = UIStackView()
    
    let indicator = UIView()
    
    var completion: ((UIImage?) -> ())?
    
    let title = TitleLabel()
    let instruction = IconLabelView()
    let loadingBar = LoadingBar()
    let distanceFace = IconLabelView()
    let headStatus = IconLabelView()
    let takePrivateData = UILabel()
    let extraView = UIView()
    let cameraView = FaceCameraView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setFull() {
        setBack()
        setScroll()
        setNav()
    }
    
    func setBack() {
        addSubviews(dismissBack, back)
        dismissBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        dismissBack.addTarget(self, action: #selector(dismissTap), for: .touchUpInside)
        back.setCornerRadiusiPhoneXorLater(12)
        back.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            if isPhone {
                $0.left.right.equalToSuperview()
            } else {
                $0.centerX.equalToSuperview()
                $0.width.equalTo(cellWidth + 20)
            }
        }
        back.backgroundColor = .systemBackground
    }
    
    @objc func dismissTap() {
        dismiss?()
    }
    
    func setScroll() {
        back.addSubview(scroll)
        
        scroll.snp.makeConstraints { $0.edges.equalToSuperview() }
        scroll.addSubview(stack)
        scroll.keyboardDismissMode = .interactive
        
        stack.snp.makeConstraints { $0.top.bottom.equalToSuperview().inset(40); $0.leading.trailing.equalTo(back).inset(16) }
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
    }
    
    func setNav() {
        back.addSubviews(indicator/*, dismiss*/)
        
        indicator.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(6)
        }
        indicator.layer.cornerRadius = 3
        indicator.backgroundColor = .systemBackground
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
