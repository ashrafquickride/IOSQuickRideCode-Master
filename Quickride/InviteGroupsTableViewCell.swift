//
//  InviteGroupsTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 04/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InviteGroupsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var requestSentView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    
    private var group: Group?
    private var viewController: UIViewController?
    private var delegate: OnGroupInviteListener?
    private var ride: Ride?
    
    func initializeGroup(group: Group,ride: Ride,delegate: OnGroupInviteListener,viewController: UIViewController){
        self.group = group
        self.delegate = delegate
        self.viewController = viewController
        self.ride = ride
        groupNameLabel.text = group.name
        memberCountLabel.text = String(format: Strings.number_of_riders, arguments: [String(group.getConfirmedMembersOfAGroup().count)])
        if group.imageURI != nil && !group.imageURI!.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: groupImage, imageUrl: group.imageURI!, placeHolderImg: UIImage(named: "group_circle"),imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            groupImage.image = UIImage(named: "group_circle")
        }
        let invitedGroups = SharedPreferenceHelper.getInvitedGroupsIds(rideId: ride.rideId)
        if invitedGroups.contains(group.id){
            inviteButton.isHidden = true
            requestSentView.isHidden = false
        }else{
            inviteButton.isHidden = false
            requestSentView.isHidden = true
        }
    }
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        InviteUserGroups.inviteUserGroupstask(selectedGroups: [(group ?? Group())], rideId: ride?.rideId ?? 0, rideType: ride?.rideType ?? "", receiver: delegate!, viewController: viewController!)
    }
}
