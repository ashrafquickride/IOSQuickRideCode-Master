//
//  RouteGroupMemberCell.swift
//  Quickride
//
//  Created by Admin on 24/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RouteGroupMemberCell : UITableViewCell{
    

    @IBOutlet weak var memberImageView: UIImageView!
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var verificationStatusImageView: UIImageView!
    
    @IBOutlet weak var companyNameLbl: UILabel!
    
    @IBOutlet weak var ratingLbl: UILabel!
    
    @IBOutlet weak var requestBtn: UIButton!
    
    
    @IBOutlet weak var ratingImageView: UIImageView!
    
    var groupMemberSelectionDelegate : GroupMemberSelectionDelegate?
    var groupMember : UserRouteGroupMember?
    var row : Int?
    var userSelected = false
    
    func initializeViews(groupMember : UserRouteGroupMember, row: Int)
    {
        self.groupMember = groupMember
        self.row  = row
        self.memberName.text = groupMember.userName
        self.requestBtn.tag = row
        ViewCustomizationUtils.addCornerRadiusToView(view: self.requestBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: self.requestBtn, borderWidth: 1.0, color: UIColor(netHex: 0x00B557))
        setUserImage()
        setRatingAndNoOfReviews(userInfo: groupMember)
        setVerificationStatusDetails(userInfo: groupMember)
    }
    
    func setUserImage()
    {
        if userSelected{
            self.memberImageView.image = UIImage(named: "rider_select")
        }else{
           ImageCache.getInstance().setImageToView(imageView: self.memberImageView, imageUrl: self.groupMember!.imageURI, gender: self.groupMember!.gender!,imageSize: ImageCache.DIMENTION_TINY)
        }
   }
    
    func setVerificationStatusDetails(userInfo : UserRouteGroupMember)
    {
        companyNameLbl.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userInfo.profileVerificationData, companyName: userInfo.companyName?.capitalized)
        if companyNameLbl.text == Strings.not_verified {
            companyNameLbl.textColor = UIColor.black
        }else{
            companyNameLbl.textColor = UIColor(netHex: 0x24A647)
        }
        verificationStatusImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userInfo.profileVerificationData)
    }
    
    
    func setRatingAndNoOfReviews(userInfo : UserRouteGroupMember)
    {
        if(Int(userInfo.rating!) < 1)
        {
            self.ratingLbl.isHidden = true
            self.ratingImageView.isHidden = true
        }
        else
        {
            self.ratingLbl.isHidden = false
            self.ratingImageView.isHidden = false
            self.ratingLbl.text = String(userInfo.rating!)

        }
    }
    
    func initializeMultipleSelection(groupMemberSelectionDelegate : GroupMemberSelectionDelegate,isSelected : Bool?){
        if isSelected != nil{
            self.userSelected = isSelected!
        }else{
            self.userSelected = false
        }
        self.groupMemberSelectionDelegate = groupMemberSelectionDelegate
        self.memberImageView.isUserInteractionEnabled = true
        setUserImage()
        self.memberImageView.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(RidePathGroupMemberCell.tapped(_:))))
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer) {
        userSelected = !userSelected
        userImageTapped()
    }
    func userImageTapped(){
        if (userSelected) {
            UIImageView.transition(with: memberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setUserImage()
            groupMemberSelectionDelegate?.groupsMemberSelectedAtIndex(row: row!, group: self.groupMember!)
        } else {
            UIImageView.transition(with: memberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setUserImage()
            groupMemberSelectionDelegate?.groupsMemberUnSelectedAtIndex(row: row!,group: self.groupMember!)
        }
    }
    
}
