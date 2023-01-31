//
//  BlockedUsersCell.swift
//  Quickride
//
//  Created by QuickRideMac on 1/6/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class BlockedUsersCell : UITableViewCell
{
    @IBOutlet weak var userDetailsView: UIView!
    
    @IBOutlet weak var blockedUserName: UILabel!
    
    @IBOutlet weak var blockedUserImageView: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    var blockedUserList = [BlockedUser]()
    var index : Int?

    func initializeViews(blockedUserList : [BlockedUser], index : Int)
    {
        self.blockedUserList = blockedUserList
        self.index = index
        self.userDetailsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BlockedUsersCell.navigateToProfile(_:))))
    }
    @objc func navigateToProfile(_ gesture: UITapGestureRecognizer){
        
        let blockedUser  = self.blockedUserList[index!]
        UserDataCache.getInstance()?.getUserBasicInfo(userId: blockedUser.blockedUserId!, handler: { (userBasicInfo, responseError, error) in
            if userBasicInfo != nil{
                
                let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
                profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: blockedUser.blockedUserId),isRiderProfile: UserRole.None ,rideVehicle : nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
                ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
            }
          
        })
  
    }
}

