//
//  ShareEarnTableViewCell.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/18/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import FirebaseDynamicLinks

class ShareEarnTableViewCell: UITableViewCell {
    

    @IBOutlet weak var offerImageView: UIImageView!

    func initialiseView(image: UIImage){
        offerImageView.image = image
    }
}
