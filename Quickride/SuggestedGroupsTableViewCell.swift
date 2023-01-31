//
//  SuggestedGroupsTableViewCell.swift
//  Quickride
//
//  Created by QuickRideMac on 12/28/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

protocol GroupSelectionDelegate{
    func groupsSelectedAtIndex(row :Int, group : UserRouteGroup)
    func groupsUnSelectedAtIndex(row : Int, group : UserRouteGroup)
}

class SuggestedGroupsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupImage: UIImageView!
    
    @IBOutlet weak var groupNameLbel: UILabel!
    
    @IBOutlet weak var fromLocationLabel: UILabel!
    
    @IBOutlet weak var toLocationLabel: UILabel!
    
    @IBOutlet weak var noOfMembers: UILabel!
    
    @IBOutlet weak var joinBtn: UIButton!
    
    @IBOutlet weak var inviteBtn: UIButton!
    
    var userGroup : UserRouteGroup?
    var groupSelectionDelegate : GroupSelectionDelegate?
    var userSelected = false
    var row : Int?

    func initializeViews(userGroup : UserRouteGroup, row: Int){
        
        self.fromLocationLabel.text = userGroup.fromLocationAddress
        self.toLocationLabel.text = userGroup.toLocationAddress
        self.groupNameLbel.text = userGroup.groupName
        self.noOfMembers.text = String(format: Strings.members, arguments: [String(userGroup.memberCount!)])
        self.userGroup = userGroup
        self.row = row
        ViewCustomizationUtils.addCornerRadiusToView(view: inviteBtn, cornerRadius: 3.0)
        ViewCustomizationUtils.addBorderToView(view: inviteBtn, borderWidth: 1.0, color: Colors.inviteActionBtnTextColor)
    }

    func initializeMultipleSelection(groupSelectionDelegate : GroupSelectionDelegate,isSelected : Bool?){
        if isSelected != nil{
            self.userSelected = isSelected!
        }else{
            self.userSelected = false
        }
        self.groupSelectionDelegate = groupSelectionDelegate
        self.groupImage.isUserInteractionEnabled = true
        setGroupImage()
        self.groupImage.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(SuggestedGroupsTableViewCell.tapped(_:))))
        
    }
    func setGroupImage(){
        if userSelected == true{
            self.groupImage.image = UIImage(named: "rider_select")
        }else if(userGroup?.imageURI != nil && !userGroup!.imageURI!.isEmpty)
        {
            ImageCache.getInstance().setImageToView(imageView: groupImage, imageUrl: userGroup!.imageURI!,placeHolderImg: UIImage(named: "group_big"),imageSize: ImageCache.DIMENTION_TINY)
        }
        else
        {
            self.groupImage.image = UIImage(named: "group_big")
        }
    }

    @objc func tapped(_ sender:UITapGestureRecognizer) {
        userSelected = !userSelected
        userImageTapped()
    }
    func userImageTapped(){
        if (userSelected) {
            UIImageView.transition(with: groupImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            groupSelectionDelegate?.groupsSelectedAtIndex(row: row!, group: userGroup!)
        } else {
            UIImageView.transition(with: groupImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            groupSelectionDelegate?.groupsUnSelectedAtIndex(row: row!,group: userGroup!)
        }
    }

}
