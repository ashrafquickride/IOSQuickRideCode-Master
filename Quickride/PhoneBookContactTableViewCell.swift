//
//  PhoneBookContactTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PhoneBookContactTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var appIconImage: UIImageView!
    @IBOutlet weak var contactFirstLaterLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var inviteButtonHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var earnPointsLabel: UILabel!
    @IBOutlet weak var requestSentView: UIView!
    
    func initailizePhoneBookContact(contact: Contact,rideId: Double){
        contactNameLabel.text = contact.contactName
        contactNumberLabel.text = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
        if contact.status == ContactRegistrationStatus.NOT_REGISTERED{
            inviteButton.setTitle(Strings.refer_now, for: .normal)
            appIconImage.isHidden = true
            if let afterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let afterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                earnPointsLabel.text = String(format: Strings.earn_points, arguments: [String(afterVerification + afterFirstRide)])
            }
            inviteButtonHieghtConstraint.constant = -8
        }else{
            inviteButton.setTitle(Strings.invite.uppercased(), for: .normal)
            appIconImage.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: appIconImage, borderWidth: 1, color: UIColor.white)
            inviteButtonHieghtConstraint.constant = 0
        }
        contactFirstLaterLabel.text = String(contact.contactName.prefix(1))
        let invitedContacts = SharedPreferenceHelper.getInvitedPhoneBookContacts(rideId: rideId)
        if invitedContacts.contains(contact.contactId ?? ""){
            inviteButton.isHidden = true
            requestSentView.isHidden = false
            earnPointsLabel.isHidden = true
        }else{
           inviteButton.isHidden = false
            requestSentView.isHidden = true
            earnPointsLabel.isHidden = false
        }
    }
    
    @IBAction func inviteOrReferNowButtonTapped(_ sender: UIButton) {
        var userInfo = [String : Any]()
        userInfo["index"] = sender.tag
        NotificationCenter.default.post(name: .contactInviteTapped, object: nil, userInfo: userInfo)
    }
}
