//
//  NearByOptionView.swift
//  Quickride
//
//  Created by QuickRideMac on 14/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
class NearByOptionView: UIView {
  
  
  
  @IBOutlet var viewWidth: NSLayoutConstraint!
  @IBOutlet weak var fromLocationLabel: UILabel!
  
  @IBOutlet weak var backGroundView: UIView!
  @IBOutlet weak var toLocationLabel: UILabel!
  
  @IBOutlet weak var userName: UILabel!
  
  @IBOutlet var pickupTime: UILabel!
  
  
  func initializeDataAndViews(nearByRideOption : NearByRideOption){
    
    ViewCustomizationUtils.addCornerRadiusToView(view: backGroundView, cornerRadius: 5.0)
    fromLocationLabel.text = nearByRideOption.fromLocation
    toLocationLabel.text = nearByRideOption.toLocation
    userName.text = nearByRideOption.userName
    pickupTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: nearByRideOption.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    if UIApplication.shared.keyWindow != nil{
      viewWidth.constant = UIApplication.shared.keyWindow!.frame.width - 100
    }
    
  }
  func initialiseDataAndViews(matchedUser : MatchedUser){
    ViewCustomizationUtils.addCornerRadiusToView(view: backGroundView, cornerRadius: 5.0)
    fromLocationLabel.text = matchedUser.fromLocationAddress
    toLocationLabel.text = matchedUser.toLocationAddress
    userName.text = matchedUser.name
    pickupTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    if UIApplication.shared.keyWindow != nil{
      viewWidth.constant = UIApplication.shared.keyWindow!.frame.width*0.8
    }
    
  }
}
