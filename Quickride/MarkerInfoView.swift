//
//  MarkerInfoView.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MarkerInfoView: UIView {
    
    @IBOutlet weak var placePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fromAndToInfo: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    func initializeViews(rideParticipant : RideParticipant){
        AppDelegate.getAppDelegate().log.debug("initializeViews()")
        ViewCustomizationUtils.addBorderToView(view: infoView, borderWidth: 1, color: UIColor.black)
        ViewCustomizationUtils.addCornerRadiusToView(view: infoView, cornerRadius: CGFloat(5))
        ImageCache.getInstance().setImageToView(imageView: placePhoto, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_TINY)
        nameLabel.text = rideParticipant.name
      if rideParticipant.startAddress != nil && rideParticipant.endAddress != nil{
        fromAndToInfo.text = "\(rideParticipant.startAddress!) \(Strings.to) \(rideParticipant.endAddress!)"
      }
      
    }    
}
