//
//  MatchingTaxipoolTableViewCell.swift
//  Quickride
//
//  Created by HK on 10/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MatchingTaxipoolTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var quickRideCardView: QuickRideCardView!
    
    private var taxiMatchedGroup: MatchedTaxiRideGroup?
    private var ride: Ride?
    
    func showMatchedTaxiUserInfo(taxiMatchedGroup: MatchedTaxiRideGroup,ride: Ride){
        self.taxiMatchedGroup = taxiMatchedGroup
        self.ride = ride
        if taxiMatchedGroup.joinedPassengers.count > 1{
            priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiMatchedGroup.minPoints)])
        }else{
            priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiMatchedGroup.maxPoints)])
        }
        pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiMatchedGroup.pickupTimeMs), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        if let matchedUser = taxiMatchedGroup.joinedPassengers.first{
            userNameLabel.text = "Join taxi with \(matchedUser.userName ?? "")"
            ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: matchedUser.imageURI, gender: matchedUser.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        }
        self.quickRideCardView.isUserInteractionEnabled = true
        self.quickRideCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userCardTapped(_:))))
        
    }
    @objc
    private func userCardTapped(_ selector: UITapGestureRecognizer){
        moveToTaxiDetailView()
    }
    
    @IBAction func howItWorksTapped(_ sender: Any) {
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolHowItWorkViewController") as! TaxipoolHowItWorkViewController
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
    }
    
    @IBAction func joinButtonTapped(_ sender: Any){
        moveToTaxiDetailView()
    }
    
    func getTaxiPoolMatchedUser(matchedTaxiRideGroup: MatchedTaxiRideGroup) -> TaxiRidePassenger?{
        return matchedTaxiRideGroup.joinedPassengers.first
    }
    
    private func moveToTaxiDetailView(){
        guard let matchedTaxiRideGroup = taxiMatchedGroup,let taxiRide = getTaxiPoolMatchedUser(matchedTaxiRideGroup: matchedTaxiRideGroup) else { return }
        let userProfile = UserDataCache.getInstance()?.userProfile
        let taxipoolInvite = TaxiPoolInvite(taxiRideGroupId: matchedTaxiRideGroup.taxiRideGroupId, invitingUserId: Int(taxiRide.userId!), invitingRideId: Int(taxiRide.id!), invitingRideType: TaxiPoolInvite.TAXI, invitedUserId: Int(UserDataCache.getInstance()?.userId ?? "") ?? 0, invitedRideId: Int(self.ride!.rideId), invitedRideType: TaxiPoolInvite.TAXI,invitingUserName: taxiRide.userName,invitedUserName: userProfile?.userName ,invitingUserImageURI: taxiRide.imageURI ,invitedUserImageURI: userProfile?.imageURI ,invitingUserGender: taxiRide.gender ,invitedUserGender: userProfile?.gender ,fromLat: matchedTaxiRideGroup.startLat, fromLng: matchedTaxiRideGroup.startLng, toLat: matchedTaxiRideGroup.endLat, toLng: matchedTaxiRideGroup.endLng, distance: matchedTaxiRideGroup.distance, pickupTimeMs: matchedTaxiRideGroup.pickupTimeMs, overviewPolyLine: matchedTaxiRideGroup.routePolyline ?? "",minFare: matchedTaxiRideGroup.minPoints,maxFare: matchedTaxiRideGroup.maxPoints)
        let taxipoolInviteDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolInviteDetailsViewController") as! TaxipoolInviteDetailsViewController
        taxipoolInviteDetailsViewController.showReceivedTaxipoolInvite(taxipoolInvite: taxipoolInvite, matchedTaxiRideGroup: matchedTaxiRideGroup,isFromJoinMyRide: true)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: taxipoolInviteDetailsViewController, animated: false)
    }
    
}
