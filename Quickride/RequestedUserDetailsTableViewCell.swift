//
//  RequestedUserDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestedUserDetailsTableViewCell: UITableViewCell {

   //MARK: Outltes
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStarImage: UIImageView!
    
    private var order: Order?
    func initialiseOrder(order: Order){
        self.order = order
        userNameLabel.text = order.borrowerInfo?.name
        if let companyName = order.borrowerInfo?.companyName{
            companyNameLabel.text = companyName
        }else{
           companyNameLabel.text = "-"
        }
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  order.borrowerInfo?.imageURI, gender:  order.borrowerInfo?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData:  order.borrowerInfo?.profileVerificationData)
        if  Int(order.borrowerInfo?.rating ?? 0) > 0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingStarImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(order.borrowerInfo?.rating ?? 0) + "(\(String( order.borrowerInfo?.noOfReviews ?? 0)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            ratingStarImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 2.0
            ratingLabel.layer.masksToBounds = true
        }
        updatedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: order.productOrder?.creationDateInMs ?? 0, timeFormat: DateUtils.DATE_FORMAT_D_MM)
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: order?.borrowerInfo?.userId) ,isRiderProfile: UserRole.Rider,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.parentViewController?.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
}
