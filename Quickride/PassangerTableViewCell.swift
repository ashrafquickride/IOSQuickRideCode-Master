//
//  PassangerTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 06/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol PassangerTableViewCellDelegate: class {
    func addOrRemoveFavorite(userId: Double,status: Int)
    func refundOrInfoButtonPressed(rideBillingDetails: RideBillingDetails,status: Int)
    func ratingOrexpandPassengerCell(rating: Int,userId: Double,rideId: Double, status: Int)
    func showRideParticipentProfile(index: Int)
}
class PassangerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var favoriteView: CircularImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var removeFromFavorite: UIButton!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var complimentView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var autoMatchView: UIView!
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var leaveFeedBackBtn: UIButton!
    
    //StarBtns
    @IBOutlet weak var oneStarButton: UIButton!
    @IBOutlet weak var twoStarButton: UIButton!
    @IBOutlet weak var threeStarButton: UIButton!
    @IBOutlet weak var fourStarButton: UIButton!
    @IBOutlet weak var fiveStarBtn: UIButton!
    @IBOutlet weak var complimentButton: UIButton!
    @IBOutlet weak var profileViewButton: UIButton!
    
    private var selectedIndexPath: Int?
    
    private var ratingButtonArray = [UIButton]()
    private var selectedIndex = [Int]()
    var tripReport: TripReport?
    var isFromCloseRide = false
    var feedBackList = [UserFeedback]()
    weak var delegate: PassangerTableViewCellDelegate?
    var rating: Int?
    var selectedRating = [Int: Int]()
    var rideBillingDetails: RideBillingDetails?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }
    
    private func setUpUI() {
        ViewCustomizationUtils.addCornerRadiusWithBorderToView(view: favButton, cornerRadius: 5.0, borderWidth: 1.0, color: UIColor(netHex: 0x2196f3))
        ratingButtonArray = [oneStarButton,twoStarButton,threeStarButton,fourStarButton,fiveStarBtn]
        autoMatchView.isHidden = true
        separatorView.isHidden = true
    }
    
    func updatePassangerCellData(rideBillingDetails: RideBillingDetails?,feedBackList: [UserFeedback], isfromCloseRide: Bool,index: Int,rideParticipants: [RideParticipant]?) {
        self.rideBillingDetails = rideBillingDetails
        self.feedBackList = feedBackList
        self.isFromCloseRide = isfromCloseRide
        self.index = index
        if selectedIndex.contains(index) {
            if rating == 3 {
                bottomViewHeightConstraint.constant = 45
                bottomView.isHidden = false
                complimentView.isHidden = true
                leaveFeedBackBtn.isHidden = false
            }else{
                bottomViewHeightConstraint.constant = 45
                bottomView.isHidden = false
                complimentView.isHidden = false
                leaveFeedBackBtn.isHidden = true
            }
        }else{
            bottomViewHeightConstraint.constant = 20
            bottomView.isHidden = true
        }
        userNameLabel.text = rideBillingDetails?.fromUserName
        
        
        profileImageView.image = UIImage(named: "default_contact")
        if let fromUserId = rideBillingDetails?.fromUserId {
            UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: String(fromUserId)) { ( completeProfileObject ,responseError, responseObject ) in
                if let userProfile = completeProfileObject?.userProfile {
                    ImageCache.getInstance().setImageToView(imageView: self.profileImageView, imageUrl: userProfile.imageURI , gender: userProfile.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
                }
            }
        }
        
        if UserDataCache.getInstance()?.isFavouritePartner(userId: Double(rideBillingDetails?.fromUserId ?? 0)) ?? false {
            favoriteView.isHidden = false
            favButton.isHidden = true
        } else {
            favoriteView.isHidden = true
            favButton.isHidden = false
        }
        var isRatingGiven = false
        if !feedBackList.isEmpty {
            for data in feedBackList {
                if Double(rideBillingDetails?.fromUserId ?? 0) == data.feedbacktophonenumber{
                    fillStarForAlreadyComment(rating: Int(data.rating))
                    selectedRating[index] = rating
                    isRatingGiven = true
                }
            }
        }
        if isRatingGiven == false {
            fillStarForAlreadyComment(rating: 0)
        }
    }
    
    func fillStarForAlreadyComment(rating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index <= rating - 1{
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
        
    }
    
    @IBAction func favoriteBtnPressed(_ sender: UIButton) {
        delegate?.addOrRemoveFavorite(userId: Double(rideBillingDetails?.fromUserId ?? 0),status: 1)
    }
    @IBAction func removeFavBtnPressed(_ sender: UIButton) {
        delegate?.addOrRemoveFavorite(userId: Double(rideBillingDetails?.fromUserId ?? 0),status: 0)
    }
    
    @IBAction func starBtnPressed(_ sender: UIButton) {
        if !feedBackList.isEmpty {
            for data in feedBackList {
                if Double(rideBillingDetails?.fromUserId ?? 0) == data.feedbacktophonenumber{
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
            }
        }
        rating = sender.tag+1
        selectedRating[index] = rating
        delegate?.ratingOrexpandPassengerCell(rating: rating ?? 0,userId: Double(rideBillingDetails?.fromUserId ?? 0), rideId: Double(rideBillingDetails?.sourceRefId ?? "") ?? 0, status: 0)
    }
    
    @IBAction func addCompliantBtnPressed(_ sender: UIButton) {
        if selectedIndex.contains(index) {
            let indexToRemove = selectedIndex.index(of: index)
            selectedIndex.remove(at: indexToRemove ?? 0)
        }
    }
    
    
    @IBAction func leaveFeedBackBtnPressed(_ sender: UIButton) {
        if selectedIndex.contains(index) {
            let indexToRemove = selectedIndex.index(of: index)
            selectedIndex.remove(at: indexToRemove ?? 0)
        }
    }
    
    //MARK: Refund
    @IBAction func MoreOptionBtnPressed(_ sender: UIButton) {
        guard let rideBillingDetails = rideBillingDetails else { return }
        delegate?.refundOrInfoButtonPressed(rideBillingDetails: rideBillingDetails, status: 1)
    }
    
    @IBAction func profileViewButtonPressed(_ sender: UIButton) {
        delegate?.showRideParticipentProfile(index: index)
    }
}
