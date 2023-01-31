//
//  MatchingRequestTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MatchingRequestTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    private var availableRequest = AvailableRequest()
    func initialiseMatchingRequest(availableRequest: AvailableRequest){
        self.availableRequest = availableRequest
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: availableRequest.imageURI, gender: availableRequest.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        userNameLabel.text = availableRequest.name?.capitalized
        requestedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: availableRequest.requestedTime, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        var distance = availableRequest.distance
        distanceLabel.text = QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2))
        if let companyName = availableRequest.companyName{
            companyNameLabel.text = companyName.capitalized
        }else{
            companyNameLabel.text = "-"
        }
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: availableRequest.profileVerificationData)
        if availableRequest.rating > 0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(availableRequest.rating) + "(\(String(availableRequest.noOfReviews)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            ratingImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 2.0
            ratingLabel.layer.masksToBounds = true
        }
    }
    @IBAction func requestTapped(_ sender: Any) {
        let requirementRequestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequirementRequestDetailsViewController") as! RequirementRequestDetailsViewController
        requirementRequestDetailsViewController.initialiseRequiremnet(availableRequest: availableRequest)
        parentViewController?.navigationController?.pushViewController(requirementRequestDetailsViewController, animated: false)
    }
}
