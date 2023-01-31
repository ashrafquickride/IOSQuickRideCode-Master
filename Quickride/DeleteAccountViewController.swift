//
//  DeleteAccountViewController.swift
//  Quickride
//
//  Created by Quick Ride on 8/30/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

//import Foundation
//import BottomPopup
//import UIKit
//import ObjectMapper
//
//enum DeleteAction {
//    case suspend
//    case delete
//}
//class DeleteAccountViewController : BottomPopupViewController {
//
//    @IBOutlet weak var deleteButton: UIButton!
//
//    @IBOutlet weak var descriptionLabel: UILabel!
//
//    var handler: (DeleteAction) -> Void = {
//        (action: DeleteAction) -> Void in
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        updatePopupHeight(to: 290)
//        descriptionLabel.isUserInteractionEnabled = true
//        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DeleteAccountViewController.suspendAction(_:))))
//        ViewCustomizationUtils.addCornerRadiusToView(view: deleteButton, cornerRadius: 15)
//        ViewCustomizationUtils.addBorderToView(view: deleteButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
//        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: self.view, cornerRadius: 20, corner1: .topRight, corner2: .topLeft)
//    }
//
//    @IBAction func deleteAction(_ sender: Any) {
//        dismiss(animated: false)
//        handler(.delete)
//    }
//
//    @objc func suspendAction(_ sender: UITapGestureRecognizer)  {
//        dismiss(animated: false)
//        handler(.suspend)
//    }
//
//}
