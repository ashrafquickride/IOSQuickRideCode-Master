//
//  InviteByContactTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InviteByContactTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var user1Image: UIImageView!
    @IBOutlet weak var user2Image: UIImageView!
    @IBOutlet weak var user3image: UIImageView!
    @IBOutlet weak var inviteContactsLabel: UILabel!
    @IBOutlet weak var contactImagesView: UIView!
    @IBOutlet weak var shareRideUrlView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    
    private var ride: Ride?
    private var viewContoller: UIViewController?
    private var isFromLiveride = false
    private var taxiRide: TaxiRidePassenger?
    func initializeInviteByContactView(ride: Ride?,isFromLiveride: Bool,viewContoller: UIViewController,taxiRide: TaxiRidePassenger?){
        self.ride = ride
        self.taxiRide = taxiRide
        self.viewContoller = viewContoller
        if ride?.rideType == Ride.RIDER_RIDE || taxiRide != nil{
            shareRideUrlView.isHidden = false
        }else{
            shareRideUrlView.isHidden = true
        }
        let ridePartnerContacts = sortRidePartnersBasedOnRecentRole()
        if !ridePartnerContacts.isEmpty{
            showContacts(ridePartnerContacts: ridePartnerContacts)
        }else{
            user1Image.backgroundColor = UIColor(netHex: 0xDBD8BF)
            user1Image.contentMode = .center
            user2Image.backgroundColor = UIColor(netHex: 0xDFB6B6)
            user2Image.contentMode = .center
            user3image.backgroundColor = UIColor(netHex: 0xBAD7E1)
            user3image.contentMode = .center
            inviteContactsLabel.text = "Commuting is fun with like minded people"
        }
        if isFromLiveride{
            topSeparatorView.isHidden = true
        }else{
            topSeparatorView.isHidden = false
        }
    }
    
    private func showContacts(ridePartnerContacts: [Contact]){
        if ridePartnerContacts.count == 1{
            ImageCache.getInstance().setImageToView(imageView: user1Image, imageUrl: ridePartnerContacts[0].contactImageURI, gender: ridePartnerContacts[0].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            user2Image.backgroundColor = UIColor(netHex: 0xDBD8BF)
            user2Image.contentMode = .center
            user3image.backgroundColor = UIColor(netHex: 0xDFB6B6)
            user3image.contentMode = .center
            let userNames = ridePartnerContacts[0].contactName
            inviteContactsLabel.text = "\(userNames) and phonebook contacts"
        }else if ridePartnerContacts.count == 2{
            ImageCache.getInstance().setImageToView(imageView: user1Image, imageUrl: ridePartnerContacts[0].contactImageURI, gender: ridePartnerContacts[0].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            ImageCache.getInstance().setImageToView(imageView: user2Image, imageUrl: ridePartnerContacts[1].contactImageURI, gender: ridePartnerContacts[1].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            user3image.backgroundColor = UIColor(netHex: 0xBAD7E1)
            user3image.contentMode = .center
            let userNames = ridePartnerContacts[0].contactName + ", " + ridePartnerContacts[1].contactName
            inviteContactsLabel.text = "\(userNames) and phonebook contacts"
        }else{
            ImageCache.getInstance().setImageToView(imageView: user1Image, imageUrl: ridePartnerContacts[0].contactImageURI, gender: ridePartnerContacts[0].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            ImageCache.getInstance().setImageToView(imageView: user2Image, imageUrl: ridePartnerContacts[1].contactImageURI, gender: ridePartnerContacts[1].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            ImageCache.getInstance().setImageToView(imageView: user3image, imageUrl: ridePartnerContacts[2].contactImageURI, gender: ridePartnerContacts[2].contactGender ,imageSize: ImageCache.DIMENTION_TINY)
            let userNames = ridePartnerContacts[0].contactName + ", " + ridePartnerContacts[1].contactName + ", " + ridePartnerContacts[2].contactName
            if ridePartnerContacts.count > 3{
                inviteContactsLabel.text = "\(userNames) and \(ridePartnerContacts.count - 3) more"
            }else{
                inviteContactsLabel.text = "\(userNames)"
            }
        }
    }
    
    @IBAction func inviteContactTapped(_ sender: UIButton) {
        let inviteContactsAndGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteContactsAndGroupViewController") as! InviteContactsAndGroupViewController
        inviteContactsAndGroupViewController.initailizeView(ride: ride,taxiRide: taxiRide)
        viewContoller?.navigationController?.pushViewController(inviteContactsAndGroupViewController, animated: true)
    }
    
    @IBAction func shareRideInviteTapped(_ sender: Any) {
        if let taxiRidePassenger = taxiRide{
            JoinMyRide().prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber:taxiRidePassenger.id), riderId: QRSessionManager.getInstance()?.getUserId() ?? "",from: taxiRidePassenger.startAddress ?? "", to: taxiRidePassenger.endAddress ?? "",startTime: taxiRidePassenger.pickupTimeMs ?? 0,vehicleType: "", viewController: parentViewController,isFromTaxiPool: true)
        }else{
            guard let ride = ride,let userId = QRSessionManager.getInstance()?.getUserId(), let vehicleType = (ride as? RiderRide)?.vehicleType else { return }
            let joinMyRide =  JoinMyRide()
            joinMyRide.prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber: ride.rideId), riderId: userId,from: ride.startAddress, to: ride.endAddress,startTime: ride.startTime,vehicleType: vehicleType, viewController: parentViewController,isFromTaxiPool: false)
        }
    }
    
    private func sortRidePartnersBasedOnRecentRole() -> [Contact]{
        var rideType = ""
        if ride?.rideType == Ride.RIDER_RIDE{
            rideType = Ride.PASSENGER_RIDE
        }else{
            rideType = Ride.RIDER_RIDE
        }
        var ridePartners = ContactUtils.getRidePartnerContacts().filter { $0.defaultRole == rideType}
        let sameRolePartner = ContactUtils.getRidePartnerContacts().filter { $0.defaultRole != rideType}
        ridePartners.append(contentsOf: sameRolePartner)
        return ridePartners
    }
}
