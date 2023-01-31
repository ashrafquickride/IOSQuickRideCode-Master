//
//  OutstationTaxiInfoTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 01/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutstationTaxiInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    
    
    func facilitiesUI(data: String, imageUrl: String?) {
        infoLabel.text = data.replace( target: "\\u20B9", withString: " ₹")
        if let imageUrl = imageUrl, imageUrl != "" {
            ImageCache.getInstance().setImageToView(imageView: infoImageView, imageUrl: imageUrl , placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        }else {
            infoImageView.image = UIImage(named: "arrow_right")
        }
    }
    func updateUIForInterCityRules(data: String){
        if data == Strings.cancel_policy {
            let firstString = Strings.for_cancel_policy_out_station
            let lastString = Strings.cancel_policy
            let stringValue = firstString + lastString
            let finalString = NSMutableAttributedString(string: stringValue)
            finalString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0,length:firstString.count))
            finalString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x007AFF), range: NSRange(location:firstString.count,length:lastString.count))
            self.infoLabel.attributedText = finalString
        }else{
            infoLabel.text = data
        }
    }
}
