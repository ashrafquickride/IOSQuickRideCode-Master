//
//  MenuTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    
    func configureForMenu(menuItem : MenuItem){
        menuImageView.image = menuItem.menuImage
        menuLabel.text = menuItem.menuLabel
  }
    
}
