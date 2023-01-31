//
//  RiderBillTableViewCell.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RiderBillTableViewCell: UITableViewCell {
    
  @IBOutlet weak var imgPassengerPic: UIImageView!
    
  @IBOutlet weak var lblPassengerName: UILabel!
    
  @IBOutlet weak var lblTotalFare: UILabel!
    
  @IBOutlet weak var billOptionsButton: CustomUIButton!
    
  @IBOutlet weak var billPendingStatusView: UIView!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
    
    func initializeViews(rideParticipant : RideParticipant?,viewController : UIViewController){
    }
}
