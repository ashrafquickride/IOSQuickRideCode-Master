//
//  SearchProductTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SearchProductTableViewCell: UITableViewCell{
    
    //MARK: Outlets
    @IBOutlet weak var searchLabel: UILabel!
    func initialiseList(productTitle: String){
        searchLabel.text = productTitle
    }
}
