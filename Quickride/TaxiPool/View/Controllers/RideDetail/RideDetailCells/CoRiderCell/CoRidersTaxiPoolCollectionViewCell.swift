//
//  CoRidersTaxiPoolCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 5/18/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class CoRidersTaxiPoolCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rideProfileImageView: CircularImageView!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    
    func initialiseCurrentUser(){
        statusView.isHidden = true
        let userProfile = UserDataCache.getInstance()?.userProfile
        ImageCache.getInstance().setImageToView(imageView: rideProfileImageView, imageUrl: userProfile?.imageURI, gender: userProfile?.gender ?? "",imageSize: ImageCache.DIMENTION_SMALL)
        riderNameLabel.isHidden = false
        riderNameLabel.text = "You"
    }
    
    func initialiseCoRiderUserInfo(taxiRidePassengerBasicInfo: TaxiRidePassengerBasicInfo?){
        statusView.isHidden = true
        ImageCache.getInstance().setImageToView(imageView: rideProfileImageView, imageUrl: taxiRidePassengerBasicInfo?.imageURI, gender: taxiRidePassengerBasicInfo?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        riderNameLabel.isHidden = false
        riderNameLabel.text = taxiRidePassengerBasicInfo?.userName
    }
    
    func initialiseEmptyUser(){
        statusView.isHidden = true
        rideProfileImageView.image = UIImage(named: "user_circle_solid")
        riderNameLabel.isHidden = true
    }
    
    func initialiseTaxipoolInvite(taxiInvite: TaxiPoolInvite){
        ImageCache.getInstance().setImageToView(imageView: rideProfileImageView, imageUrl: taxiInvite.invitedUserImageURI, gender: taxiInvite.invitedUserGender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        riderNameLabel.isHidden = false
        riderNameLabel.text = taxiInvite.invitedUserName
        setImageViewBasedOnInvitationStatus(status: taxiInvite.status?.uppercased() ?? "")
    }
    
    private func setImageViewBasedOnInvitationStatus(status : String){
        AppDelegate.getAppDelegate().log.debug(status)
        statusView.isHidden = false
        switch status {
        case TaxiPoolInvite.TAXI_INVITE_STATUS_RECEIVED:
            statusImageView.image = UIImage(named:"delivered_icon")
        case TaxiPoolInvite.TAXI_INVITE_STATUS_OPEN:
            statusImageView.image = UIImage(named:"sent_icon")
        case TaxiPoolInvite.TAXI_INVITE_STATUS_READ:
            statusImageView.image = UIImage(named:"double_tick_green")
        default:
            statusImageView.image = UIImage(named:"sent_icon")
            break
        }
    }
}
