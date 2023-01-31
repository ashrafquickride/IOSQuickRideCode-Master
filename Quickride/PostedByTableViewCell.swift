//
//  PostedByTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PostedByTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var profileView: QuickRideCardView!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var ratingStarImage: UIImageView!
    
    var userId: Double?
    
    func initialiseProfileView(userId: Double?,userName: String?,companyName: String?,userImgUri: String?,gender: String?,profileVerificationData: ProfileVerificationData?,rating: Int,noOfReviews: Int,cardTitle: String){
        cardTitleLabel.text = cardTitle.uppercased()
        self.userId = userId
        nameLabel.text = userName?.capitalized
        if let cmpName = companyName{
           companyNameLabel.text = cmpName
        }else{
            companyNameLabel.text = " -"
        }
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: userImgUri, gender: gender ?? "" , imageSize: ImageCache.DIMENTION_TINY)
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: profileVerificationData)
        if rating > 0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingStarImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(rating) + "(\(String(noOfReviews)))"
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
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToProfile(_:))))
    }
    
    @objc func goToProfile(_ sender :UITapGestureRecognizer){
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: userId) ,isRiderProfile: UserRole.Rider,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.parentViewController?.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
}
