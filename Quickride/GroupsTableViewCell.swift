//
//  GroupsTableViewCell.swift
//  Quickride
//
//  Created by rakesh on 3/8/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol UserGroupSelectionDelegate{
    func groupsSelectedAtIndex(row :Int, group : Group)
    func groupsUnSelectedAtIndex(row : Int, group : Group)
}

class GroupTableViewCell : UITableViewCell{
    

    @IBOutlet weak var groupImage: UIImageView!
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var noOfMembersLabel: UILabel!
    
    @IBOutlet weak var joinStatusLabel: UILabel!

  
    @IBOutlet weak var joinStatusLblWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var groupCategoryLbl: UILabel!
    @IBOutlet weak var inviteBtn: UIButton!
   
    var userGroup : Group?
    var row : Int?
    var userGroupSelectionDelegate : UserGroupSelectionDelegate?
    var userSelected = false
    
    func initializeViews(userGroup : Group,row : Int){
        self.userGroup = userGroup
        self.row = row
        ViewCustomizationUtils.addCornerRadiusToView(view: inviteBtn, cornerRadius: 3.0)
        ViewCustomizationUtils.addBorderToView(view: inviteBtn, borderWidth: 1.0, color: Colors.inviteActionBtnTextColor)
    }
    
    func initializeMultipleSelection(userGroupSelectionDelegate : UserGroupSelectionDelegate,isSelected : Bool?){
        if isSelected != nil{
            self.userSelected = isSelected!
        }else{
            self.userSelected = false
        }
        self.userGroupSelectionDelegate = userGroupSelectionDelegate
        self.groupImage.isUserInteractionEnabled = true
        setGroupImage()
        self.groupImage.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(GroupTableViewCell.tapped(_:))))
        
    }
   
    func setGroupImage(){
        if userSelected == true{
            self.groupImage.image = UIImage(named: "rider_select")
        }else if(userGroup?.imageURI != nil && !userGroup!.imageURI!.isEmpty)
        {
            ImageCache.getInstance().setImageToView(imageView: self.groupImage, imageUrl: userGroup!.imageURI!, placeHolderImg: UIImage(named: "group_big"),imageSize: ImageCache.DIMENTION_SMALL)
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
            userGroupSelectionDelegate?.groupsSelectedAtIndex(row: row!, group: userGroup!)
        } else {
            UIImageView.transition(with: groupImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            userGroupSelectionDelegate?.groupsUnSelectedAtIndex(row: row!, group:  userGroup!)
        }
    }


}
