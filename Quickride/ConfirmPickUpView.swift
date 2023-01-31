//
//  ConfirmPickUpView.swift
//  Quickride
//
//  Created by Vinutha on 09/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

enum ConfirmPickupType{
    case Add
    case Edit
    case None
}

class ConfirmPickUpView: UIView {
    
    @IBOutlet weak var confirmPickupView: UIView!
    @IBOutlet weak var confirmPickupButton: UIButton!
    @IBOutlet weak var notchImageView: UIImageView!
    @IBOutlet weak var pickupImageView: UIImageView!
    
    func initializeDataAndViews(confirmPickupType: ConfirmPickupType){
        ViewCustomizationUtils.addCornerRadiusToThreeCorners(view: confirmPickupView, cornerRadius: 5, corners: [.topLeft, .topRight, .bottomLeft])
        confirmPickupView.isHidden = false
        notchImageView.isHidden = false
        notchImageView.image = notchImageView.image!.withRenderingMode(.alwaysTemplate)
        notchImageView.tintColor = Colors.editRouteBtnColor
        if confirmPickupType == ConfirmPickupType.Add {
            confirmPickupButton.setImage(nil, for: .normal)
            confirmPickupButton.setTitle("Confirm pick-up", for: .normal)
            pickupImageView.image = UIImage(named: "green")
        } else if confirmPickupType == ConfirmPickupType.Edit {
            confirmPickupView.isHidden = true
            notchImageView.isHidden = true
            pickupImageView.image = UIImage(named: "edit_pickup_green")
        } else {
            confirmPickupView.isHidden = true
            notchImageView.isHidden = true
            pickupImageView.image = UIImage(named: "green")
        }
    }
}
