//
//  CustomerInfoTableViewCell.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CustomerInfoTableViewCell: UITableViewCell{
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func set(content: CustomerSupportElement, isExpanded: Bool){
        self.infoLabel.text = content.title
        if content.message == nil || content.message?.isEmpty == true
        {
            self.arrowImage.isHidden = true
            self.descriptionLabel.isHidden = true
            return
        }
        self.arrowImage.isHidden = false
        if isExpanded{
            self.descriptionLabel.isHidden = false
            self.descriptionLabel.text = content.message
            self.arrowImage.image = UIImage(named: "icon_upward")
        }
        else{
            self.descriptionLabel.isHidden = true
            self.descriptionLabel.text = ""
            self.arrowImage.image = UIImage(named: "icon_downward")
        }
        let origImage = self.arrowImage.image
        let tintedImage = origImage!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.arrowImage.image = tintedImage
        self.arrowImage.tintColor = UIColor.black
    }
}
