//
//  PlacedOrderTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PlacedOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var updatedDate: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    
    func initialisePlacedProduct(){
        
    }
    
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        
        
    }
    
}
