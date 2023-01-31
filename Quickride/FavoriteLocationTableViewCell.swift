//
//  FavoriteLocationTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FavoriteLocationTableViewCell: UITableViewCell {
  
    @IBOutlet weak var locationLabelWidthConstraint: NSLayoutConstraint!
    
  @IBOutlet weak var iboLocationLabel: UILabel!
  @IBOutlet weak var iboLocationAddress: UILabel!
  @IBOutlet weak var menuOption: UIButton!
    
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
