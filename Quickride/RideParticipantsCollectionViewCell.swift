//
//  RideParticipantsCollectionView.swift
//  Quickride
//
//  Created by Halesh on 11/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RideParticipantsCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var participantImageView: UIImageView!
    
    @IBOutlet weak var participantNameLbl: UILabel!
    
    @IBOutlet weak var unReadMsgCountLbl: UILabel!
    
    @IBOutlet weak var unReadMsgView: UIView!
    
    @IBOutlet weak var rideModeratorImageView: UIImageView!
    
    func initializeParticipantsCellData(rideParticipant: RideParticipant, index: Int,unreadMsg: Int?){
        participantNameLbl.text = rideParticipant.name
        participantNameLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        participantImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: rideParticipant.gender!)
        ImageCache.getInstance().setImageToView(imageView: self.participantImageView, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_TINY)
        ViewCustomizationUtils.addBorderToView(view: participantImageView, borderWidth: 0, color: UIColor.white)
        if unreadMsg != nil && unreadMsg! > 0 {
            unReadMsgView.isHidden = false
            unReadMsgCountLbl.text = String(unreadMsg!)
            ViewCustomizationUtils.addBorderToView(view: unReadMsgView, borderWidth: 2, color: .white)
        }else{
            unReadMsgView.isHidden = true
        }
        if let userId = QRSessionManager.getInstance()?.getUserId(), rideParticipant.userId == Double(userId) {
            if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences(), ridePreference.rideModerationEnabled, rideParticipant.status == Ride.RIDE_STATUS_STARTED {
                rideModeratorImageView.isHidden = false
            } else {
                rideModeratorImageView.isHidden = true
            }
        } else {
            if rideParticipant.rideModerationEnabled, rideParticipant.status == Ride.RIDE_STATUS_STARTED {
                rideModeratorImageView.isHidden = false
            } else {
                rideModeratorImageView.isHidden = true
            }
        }
        
    }
    
}
