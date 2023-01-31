//
//  ProductPostedByProfileTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class ProductPostedByProfileTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var profileView: QuickRideCardView!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var ratingStarImage: UIImageView!
    
    private var availableProduct: AvailableProduct?
    func initialiseProfileView(availableProduct: AvailableProduct){
        self.availableProduct = availableProduct
        nameLabel.text = availableProduct.userName
        if let companyName = availableProduct.companyName{
            companyNameLabel.text = companyName
        }else{
           companyNameLabel.text = " -"
        }
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: availableProduct.userImgUri, gender: availableProduct.gender ?? "", imageSize: ImageCache.DIMENTION_TINY)
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: availableProduct.profileVerificationData)
        if availableProduct.rating > 0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingStarImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(availableProduct.rating) + "(\(String(availableProduct.noOfReviews)))"
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
        profileDisplayViewController.isFromQuickShare = true
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: String(availableProduct?.userId ?? 0) ,isRiderProfile: UserRole.Rider,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.parentViewController?.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
    @IBAction func reportProfileTapped(_ sender: Any) {
        let userProfile = UserDataCache.getInstance()?.userProfile
        var subject = ""
        if let ownerName = availableProduct?.userName,let ownerId = availableProduct?.userId, let userName = userProfile?.userName,let userId = UserDataCache.getInstance()?.userId, let listingId = availableProduct?.productListingId{
            subject = userName + "(\(userId)))" + "-" + "found something wrong with " + (ownerName) + "'s " + "(\(ownerId))" + "product(\(listingId)) :"
        }
        HelpUtils.sendEmailToSupportWithSubject(delegate: self, viewController: parentViewController!, messageBody: nil, image: getScreenShot(), listOfIssueTypes: Strings.list_of_product_report_types, subject: subject, reciepients: nil)
    }
    private func getScreenShot() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: parentViewController?.view.frame.width ?? 414,height: parentViewController?.view.frame.height ?? 400 ), false, 0);
        window?.drawHierarchy(in: window?.bounds ?? CGRect(), afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}
//MARK: MFMailComposeViewControllerDelegate
extension ProductPostedByProfileTableViewCell: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
