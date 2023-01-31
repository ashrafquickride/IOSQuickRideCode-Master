//
//  RidePathGroupMemberCell.swift
//  Quickride
//
//  Created by QuickRideMac on 7/4/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol GroupMemberSelectionDelegate{
    func groupsMemberSelectedAtIndex(row :Int, group : UserRouteGroupMember)
    func groupsMemberUnSelectedAtIndex(row : Int, group : UserRouteGroupMember)
}
class RidePathGroupMemberCell: UITableViewCell {
    
    @IBOutlet weak var memberImageView: UIImageView!
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var verificationStatusImageView: UIImageView!
    
    @IBOutlet weak var companyNameText: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
        
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var raingBar: RatingBar!
    
    var groupSelectionDelegate : GroupMemberSelectionDelegate?
    var groupMember : UserRouteGroupMember?
    var userSelected = false
    var row : Int?

    func initializeViews(groupMember : UserRouteGroupMember, row: Int)
    {
        self.groupMember = groupMember
        self.row  = row
        self.memberName.text = groupMember.userName
        setUserImage(gender: groupMember.gender!, imageURI: groupMember.imageURI)
        setRatingAndNoOfReviews(userInfo: groupMember)
        setVerificationStatusDetails(userInfo: groupMember)
    }
    func setUserImage(gender : String,imageURI : String?)
    {
        self.memberImageView.image = nil
         ImageCache.getInstance().setImageToView(imageView: memberImageView, imageUrl: imageURI, gender: gender,imageSize: ImageCache.DIMENTION_TINY)

    }
    func setRatingAndNoOfReviews(userInfo : UserRouteGroupMember)
    {
        if(Int(userInfo.rating!) < 1)
        {
            self.ratingView.isHidden = true
        }
        else
        {
            self.ratingView.isHidden = false
            self.raingBar.numStars = 1
            self.raingBar.rating = 5
            self.ratingLabel.text = StringUtils.getStringFromDouble(decimalNumber: userInfo.rating!)
            if(userInfo.noOfReviews! <= 0)
            {
                self.ratingLabel.text = StringUtils.getStringFromDouble(decimalNumber: userInfo.rating!)
            }
            else
            {
                self.ratingLabel.text = StringUtils.getStringFromDouble(decimalNumber: userInfo.rating!) + "(" + String(userInfo.noOfReviews!) + ")"
            }
        }
    }
    
    func setVerificationStatusDetails(userInfo : UserRouteGroupMember)
    {
        companyNameText.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userInfo.profileVerificationData, companyName: userInfo.companyName?.capitalized)
        if companyNameText.text == Strings.not_verified {
            companyNameText.textColor = UIColor.black
        }else{
            companyNameText.textColor = UIColor(netHex: 0x24A647)
        }
        verificationStatusImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userInfo.profileVerificationData)
    }
    func initializeMultipleSelection(groupSelectionDelegate : GroupMemberSelectionDelegate,isSelected : Bool?){
        if isSelected != nil{
            self.userSelected = isSelected!
        }else{
            self.userSelected = false
        }
        self.groupSelectionDelegate = groupSelectionDelegate
        self.memberImageView.isUserInteractionEnabled = true
        setGroupImage()
        self.memberImageView.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(RidePathGroupMemberCell.tapped(_:))))
    }
    
    func selectAllUsers()
    {
        self.userSelected = true
        self.selectionImage.image = UIImage(named: "group_tick_icon")
        groupSelectionDelegate?.groupsMemberSelectedAtIndex(row: row!, group: self.groupMember!)

    }
    func deselectAllUsers()
    {
        self.userSelected = false
        self.selectionImage.image = nil
        groupSelectionDelegate?.groupsMemberUnSelectedAtIndex(row: row!,group: self.groupMember!)
    }
    func setGroupImage(){
        if userSelected == true{
            self.selectionImage.image = UIImage(named: "group_tick_icon")
        }else
        {
            self.selectionImage.image = nil
        }
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer) {
        userSelected = !userSelected
        userImageTapped()
    }
    func userImageTapped(){
        if (userSelected) {
            UIImageView.transition(with: memberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            groupSelectionDelegate?.groupsMemberSelectedAtIndex(row: row!, group: self.groupMember!)
        } else {
            UIImageView.transition(with: memberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            groupSelectionDelegate?.groupsMemberUnSelectedAtIndex(row: row!,group: self.groupMember!)
        }
    }

}
