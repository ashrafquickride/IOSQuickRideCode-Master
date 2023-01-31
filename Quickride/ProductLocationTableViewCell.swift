//
//  ProductLocationTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 14/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductLocationTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var defaultlocationButton: UIButton!
    @IBOutlet weak var defaultLocationLabel: UILabel!
    @IBOutlet weak var otherLocationButton: UIButton!
    @IBOutlet weak var otherLocationLabel: UILabel!
    
    private var product: Product?
    
    func initialiseLocations(product: Product){
        self.product = product
    }
    
    @IBAction func defaultLocationEdit(_ sender: Any) {
        
    }
    
    @IBAction func otherLocationEdit(_ sender: Any) {
        
    }
}
