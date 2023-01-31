//
//  MyRidesTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 21/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyRidesTableViewCell: UITableViewCell {
  
  @IBOutlet weak var iboIcon: UIImageView!
    
  @IBOutlet weak var iboFromLocation: UILabel!
    
  @IBOutlet weak var iboToLocation: UILabel!
    
  @IBOutlet weak var iboTimeStamp: UILabel!
    
  @IBOutlet weak var iboStatus: UILabel!

  @IBOutlet weak var iboOptionsButton: UIButton!
    
  @IBOutlet weak var rideActionButton: UIButton!
  
  @IBOutlet weak var rideActionImage: UIImageView!
    

    @IBOutlet weak var backGroundView: UIView!
    
  // Not in WeRide
  
  @IBOutlet weak var iboCount: UILabel!
  
  @IBOutlet weak var iboStatusBg: UIView!

  @IBOutlet weak var freezeIcon: UIImageView!
    
    
    @IBOutlet weak var dayDateMonthView: UIView!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
