//
//  AddProductSuccessTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 15/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddProductSuccessTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var title: String?
    
    func initailiseSuccessView(isFromAddProduct: Bool,title: String){
        self.title = title
        if isFromAddProduct{
            titleLabel.text = Strings.product_posted_successfully
            infoLabel.text = Strings.product_review_info
        }else{
            titleLabel.text = Strings.item_request_added
            infoLabel.text = Strings.request_review_info
        }
    }
}
