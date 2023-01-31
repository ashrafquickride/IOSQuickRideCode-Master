//
//  TaxipoolInviteUserDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxipoolInviteUserDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var taxiFareLabel: UILabel!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var rejectButton: QRCustomButton!
    @IBOutlet weak var acceptButton: QRCustomButton!
    @IBOutlet weak var joinButton: QRCustomButton!
    private var viewModel = TaxipoolInviteDetailsViewModel()
    
    func showInvitedUserInfo(viewModel: TaxipoolInviteDetailsViewModel){
        self.viewModel = viewModel
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: viewModel.taxiInvite?.invitingUserImageURI ?? "", gender: viewModel.taxiInvite?.invitingUserGender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = viewModel.taxiInvite?.invitingUserName
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: viewModel.invitedUserDetails?.profileVerificationData, companyName: viewModel.invitedUserDetails?.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if (viewModel.invitedUserDetails?.rating ?? 0) > 0.0{
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(viewModel.invitedUserDetails?.rating ?? 0) + "(\(String(viewModel.invitedUserDetails?.rating ?? 0)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingShowingLabelHeightConstraints.constant = 15.0
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            starImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 8.0
            ratingLabel.layer.masksToBounds = true
        }
        verificationImage.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: viewModel.invitedUserDetails?.profileVerificationData)
        pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(viewModel.taxiInvite?.pickupTimeMs ?? 0), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        var taxiFare: Double?
        if (viewModel.matchedTaxiRideGroup?.joinedPassengers.count ?? 0) > 1{
            taxiFare = viewModel.matchedTaxiRideGroup?.minPoints
        }else{
            taxiFare = viewModel.matchedTaxiRideGroup?.maxPoints
        }
        taxiFareLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiFare)])
        if viewModel.isFromJoinMyRide{
            joinButton.isHidden = false
            rejectButton.isHidden = true
            acceptButton.isHidden = true
        }else{
            joinButton.isHidden = true
            rejectButton.isHidden = false
            acceptButton.isHidden = false
        }
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        AppUtilConnect.callNumber(receiverId: String(viewModel.taxiInvite?.invitingUserId ?? 0), refId: "", name: viewModel.taxiInvite?.invitingUserName ?? "", targetViewController: parentViewController ?? ViewControllerUtils.getCenterViewController())
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        guard let userId = viewModel.taxiInvite?.invitingUserId else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.isFromTaxipool = true
        chatViewController.initializeDataBeforePresentingView(ride: nil, userId: Double(userId), isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        viewModel.acceptTaxipoolInvite { [weak self](taxiPassengerId) in
            if let id = taxiPassengerId{
                let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
                taxiLiveRide.initializeDataBeforePresenting(rideId: id)
                self?.parentViewController?.navigationController?.popToRootViewController(animated: false)
                ViewControllerUtils.displayViewController(currentViewController: self?.parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
            }
        }
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        viewModel.rejectTaxipoolInvite { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject == nil && error == nil{
                self.parentViewController?.navigationController?.popViewController(animated: false)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    @IBAction func whatTaxipoolTapped(_ sender: Any) {
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolHowItWorkViewController") as! TaxipoolHowItWorkViewController
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
    }
    
    @IBAction func join(_ sender: Any) {
        guard let matchedTaxiRideGroup = viewModel.matchedTaxiRideGroup else { return }
        let taxipoolLocationSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolLocationSelectionViewController") as! TaxipoolLocationSelectionViewController
        taxipoolLocationSelectionViewController.showLocation(matchedTaxiRideGroup: matchedTaxiRideGroup) { [weak self] matchedTaxiRideGroup in
            self?.viewModel.matchedTaxiRideGroup = matchedTaxiRideGroup
            self?.viewModel.acceptTaxipoolInvite(complitionHandler: { (taxiPassengerId) in
                if let id = taxiPassengerId{
                    self?.parentViewController?.navigationController?.popToRootViewController(animated: false)
                    let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
                    taxiLiveRide.initializeDataBeforePresenting(rideId: id)
                    ViewControllerUtils.displayViewController(currentViewController: self?.parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
                }
            })
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxipoolLocationSelectionViewController)
    }
}
