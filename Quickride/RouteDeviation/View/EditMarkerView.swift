//
//  EditMarkerView.swift
//  Quickride
//
//  Created by Vinutha on 23/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EditMarkerView: UIView {

    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var anchorImageView: UIImageView!
    @IBOutlet weak var editImageView: UIImageView!
    
    func initializeView(title: String, imageName: String?){
        titleLabel.text = title
        if imageName != nil {
            editImageView.isHidden = false
            editImageView.image = UIImage(named: imageName!)
        } else {
            editImageView.isHidden = true
        }
        ViewCustomizationUtils.addCornerRadiusToThreeCorners(view: InfoView, cornerRadius: 2, corners: [.topLeft, .topRight, .bottomLeft])
        anchorImageView.image = anchorImageView.image!.withRenderingMode(.alwaysTemplate)
        anchorImageView.tintColor = UIColor.white
        
    }

}
