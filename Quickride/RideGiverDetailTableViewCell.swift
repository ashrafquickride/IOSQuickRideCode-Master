//
//  RideGiverDetailTableViewCell.swift
//  Quickride
//
//  Created by HK on 25/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideGiverDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var usersImage: UIImageView!
    @IBOutlet weak var favImageView: CircularImageView!
    @IBOutlet weak var addFavoriteBtn: UIButton!
    
    //Rating/auto match/feedback
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var addcomplimentBtn: UIButton!
    @IBOutlet weak var addcomplementView: UIView!
    @IBOutlet weak var ratingView: UIView!
    
    private var delegate: UserDetailsTableViewCellDelegate?
    private var rideBillingDetails: RideBillingDetails?
    private var ratingButtonArray = [UIButton]()
    private var isFeedbackLoaded = false
    private var ratingDelegate: BillRatingTableViewCellDelegate?
    private var rating = 0
    private var alreadyGivenRating = 0
    
    func initialiseRideGiver(riderDetails: RideParticipant?,rideBillingDetails: RideBillingDetails?,userFeedback: UserFeedback?,isFeedbackLoaded: Bool,delegate: UserDetailsTableViewCellDelegate,ratingDelegate: BillRatingTableViewCellDelegate){
        self.rideBillingDetails = rideBillingDetails
        self.delegate = delegate
        self.ratingDelegate = ratingDelegate
        self.isFeedbackLoaded = isFeedbackLoaded
        if QRSessionManager.getInstance()!.getUserId() == String(rideBillingDetails?.fromUserId ?? 0) {
            userNameLabel.text = rideBillingDetails?.toUserName?.capitalized
            if let riderData = riderDetails {
                ImageCache.getInstance().setImageToView(imageView: usersImage, imageUrl: riderData.imageURI, gender: riderData.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            }else{
                usersImage.image = UIImage(named: "default_contact")
            }
        }
        
        if UserDataCache.getInstance()?.isFavouritePartner(userId: Double(rideBillingDetails?.toUserId ?? 0)) ?? false {
            addFavoriteBtn.isHidden = true
            favImageView.isHidden = false
        }else{
            addFavoriteBtn.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: addFavoriteBtn, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
            favImageView.isHidden = true
        }
        //Rating/feedback
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        if isFeedbackLoaded{
            ratingView.isHidden = false
            if let givenRating = userFeedback?.rating{
                alreadyGivenRating = Int(givenRating)
                setGivenRating(selectedRating: Int(givenRating))
            }
        }else{
            ratingView.isHidden = true
        }
    }
    
    func setGivenRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
    }
    
    
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if alreadyGivenRating != 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.you_have_already_given_feedback)
            for (_,data) in ratingButtonArray.enumerated() {
                data.isUserInteractionEnabled = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                for (_,data) in self.ratingButtonArray.enumerated() {
                    data.isUserInteractionEnabled = true
                }
            }
            return
        }
        rating = sender.tag + 1
        handleFeedbackButton(givenRate: sender.tag + 1)
    }

    
    private func handleFeedbackButton(givenRate: Int){
        ratingDelegate?.moveToRatingScreen(rating: givenRate)
    }
    
    @IBAction func addcomplimentButtonTappedTapped(_ sender: UIButton) {
        ratingDelegate?.moveToRatingScreen(rating: rating)
    }
    @IBAction func addFavBtnPressed(_ sender: UIButton) {
        delegate?.addOrRemoveFavoritePartner(userId: Double(rideBillingDetails?.toUserId ?? 0) , status: 1)
    }
    
    @IBAction func removeFavoriteButtonPressed(_ sender: UIButton) {
        delegate?.addOrRemoveFavoritePartner(userId: Double(rideBillingDetails?.toUserId ?? 0), status: 0)
    }
}
