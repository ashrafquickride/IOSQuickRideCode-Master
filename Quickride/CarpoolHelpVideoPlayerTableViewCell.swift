//
//  CarpoolHelpVideoPlayerTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 25/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CarpoolHelpVideoPlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoDescriptionLbl: UILabel!
    @IBOutlet weak var videoPlayerTimeLbl: UILabel!
    @IBOutlet weak var videoPlayerImageView: UIImageView!
 
    
    static let CARPOOL_VIDEOS: [String] = ["nMU9UzmU3eY", "H3iTw-ItEe0", "vet2rwz3Smo"]
    
  
    func setTitleAndContentBasedOnCategory(value: Int?){
        switch value {
        case 0:
            videoDescriptionLbl.text = Strings.carpool_description_for_message1
            videoPlayerImageView.image = UIImage(named: "carpool_img_2")
            videoPlayerTimeLbl.text = "30 Sec"
        case 1:
            videoDescriptionLbl.text = Strings.carpool_description_for_message2
            videoPlayerImageView.image = UIImage(named: "carpool_img_3")
            videoPlayerTimeLbl.text = "30 Sec"
        case 2:
            videoDescriptionLbl.text = Strings.carpool_description_for_message3
            videoPlayerImageView.image = UIImage(named: "carpool_img_1")
            videoPlayerTimeLbl.text = "30 Sec"
        default:
            break
        }
    }
    
}
