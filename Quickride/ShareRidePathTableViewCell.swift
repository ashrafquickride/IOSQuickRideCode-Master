//
//  ShareRidePathTableViewCell.swift
//  Quickride
//
//  Created by HK on 09/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ShareRidePathTableViewCell: UITableViewCell {
    
    private var ride: Ride?
    
    func initialiseRidePath(ride: Ride?){
        self.ride = ride
    }
    
    @IBAction func copyLinkButtonTapped(_ sender: Any) {
        let shareRidePath = ShareRidePath(viewController: parentViewController ?? ViewControllerUtils.getCenterViewController(), rideId: getRideId())
        shareRidePath.prepareRideTrackCoreURL(handler: { (url) -> Void in
            UIPasteboard.general.string = url
            UIApplication.shared.keyWindow?.makeToast( Strings.ride_path_link_copied)
        })
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let shareRidePath = ShareRidePath(viewController: parentViewController ?? ViewControllerUtils.getCenterViewController(), rideId: getRideId())
        shareRidePath.showShareOptions()
    }
    
    private func getRideId() -> String{
        var rideId: String
        if self.ride?.rideType == Ride.RIDER_RIDE{
            rideId = StringUtils.getStringFromDouble(decimalNumber : self.ride?.rideId)
        }else{
            rideId =  StringUtils.getStringFromDouble(decimalNumber : (self.ride as! PassengerRide).riderRideId)
        }
        return rideId
    }
}
