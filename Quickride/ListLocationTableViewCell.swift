//
//  ListLocationTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 12/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class ListLocationTableViewCell: UITableViewCell{
  
  @IBOutlet weak var iboIcon: UIImageView!
  @IBOutlet weak var iboTitleLabel: UILabel!
  @IBOutlet weak var iboSubTitleLabel: UILabel!
  @IBOutlet weak var menuBtn: UIButton!
  @IBOutlet weak var menuBtnWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var menuBtnTrailingSpaceConstraint: NSLayoutConstraint!
    
  var coordinates:CLLocationCoordinate2D?
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  
}
