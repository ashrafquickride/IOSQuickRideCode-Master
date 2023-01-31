//
//  SortRideMatchTableViewCell.swift
//  Quickride
//
//  Created by QuickRideMac on 1/26/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SortRideMatchTableViewCell: UITableViewCell{
    
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var sortOptionTitle: UILabel!
    
    func initializeViews(optionTitle: String,imageSelected : Bool){
        sortOptionTitle.text = optionTitle
        if imageSelected{
            selectionImage.image = UIImage(named: "ic_radio_button_checked")
            sortOptionTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            sortOptionTitle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        }else{
            selectionImage.image = UIImage(named: "radio_button_1")
            sortOptionTitle.font = UIFont(name: "HelveticaNeue", size: 14)
            sortOptionTitle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        }
    }
}
