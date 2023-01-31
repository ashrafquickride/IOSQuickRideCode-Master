//
//  GroupMembersTableViewCell.swift
//  Quickride
//
//  Created by rakesh on 3/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol GroupMemberDelegate{
    func groupMemberAdded(group : Group)
    func groupMemberDeleted(group : Group)
}

protocol GrpMemberSelectionDelegate {
    func groupsMemberSelectedAtIndex(row :Int, group : GroupMember)
    func groupsMemberUnSelectedAtIndex(row : Int, group : GroupMember)
}
class GroupMembersTableViewCell : UITableViewCell{
    

    @IBOutlet weak var groupMemberImageView: UIImageView!
    @IBOutlet weak var groupMemberName: UILabel!
    @IBOutlet weak var groupMemberRole: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var selectedUserImage: UIImageView!
    
    @IBOutlet weak var groupMemberRoleWidthConstraint: NSLayoutConstraint!
    
    var group : Group?
    var groupMember : GroupMember?
    var viewController : UIViewController?
    var delegate : GroupMemberDelegate?
    var grpMemberSelectionDelegate : GrpMemberSelectionDelegate?
    var userSelected = false
    var row : Int?
    
    func initializeViews(group : Group,groupMember : GroupMember,viewController : UIViewController,delegate : GroupMemberDelegate?){
        self.viewController = viewController
        self.group = group
        self.groupMember = groupMember
        self.delegate = delegate
    }
    
    func initializeMemberView(groupMember : GroupMember,row: Int){
        self.groupMember = groupMember
        self.row = row
    }
    
    func initializeMultipleSelection(groupSelectionDelegate : GrpMemberSelectionDelegate,isSelected : Bool?){
        
        if isSelected != nil{
            self.userSelected = isSelected!
        }else{
            self.userSelected = false
        }
        self.grpMemberSelectionDelegate = groupSelectionDelegate
        self.groupMemberImageView.isUserInteractionEnabled = true
        setGroupImage()
        self.groupMemberImageView.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(GroupMembersTableViewCell.tapped(_:))))
    }
    func setGroupImage(){
        if userSelected == true{
            self.selectedUserImage.image = UIImage(named: "group_tick_icon")
        }else
        {
            self.selectedUserImage.image = nil
        }
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer) {
        userSelected = !userSelected
        userImageTapped()
    }
    
    func selectAllUsers()
    {
        self.userSelected = true
        self.selectedUserImage.image = UIImage(named: "group_tick_icon")
        grpMemberSelectionDelegate?.groupsMemberSelectedAtIndex(row: row!, group: self.groupMember!)
        
    }
    func deselectAllUsers()
    {
        self.userSelected = false
        self.selectedUserImage.image = nil
        grpMemberSelectionDelegate?.groupsMemberUnSelectedAtIndex(row: row!,group: self.groupMember!)
    }
    func userImageTapped(){
        if (userSelected) {
            UIImageView.transition(with: groupMemberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            grpMemberSelectionDelegate?.groupsMemberSelectedAtIndex(row: row!, group: self.groupMember!)
        } else {
            UIImageView.transition(with: groupMemberImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setGroupImage()
            grpMemberSelectionDelegate?.groupsMemberUnSelectedAtIndex(row: row!,group: self.groupMember!)
        }
    }

    @IBAction func menuBtnTapped(_ sender: Any) {
    
        let alertController : GroupsViewAlertController = GroupsViewAlertController(viewController: self.viewController!) { (result) in
            if result == Strings.delete_member{
                self.deleteGroupMember()
            }else if result == Strings.confirm{
                self.addMemberToGroup()
            }else if result == Strings.REJECT{
                self.rejectGroupMember()
            }
        }
        if groupMember?.status == GroupMember.MEMBER_STATUS_PENDING{
          alertController.confirmMembershipToGrpAlertAction()
          alertController.rejectMembershipToGrpAlertAction()
        }else{
          alertController.deleteGroupMemberAlertAction()
        }
        alertController.cancelAlertAction()
        alertController.showAlertController()
    
    
    
    }
    func deleteGroupMember(){
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.deleteGroupMember(groupId: group!.id, memberId: groupMember!.userId , viewController: self.viewController,handler:  { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
             if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.deleteMemberFromGroup(groupId: self.group!.id, groupMember: self.groupMember!)
                self.delegate?.groupMemberDeleted(group: self.group!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }

        })
    }
    
    func addMemberToGroup(){
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.addMembersToGroup(groupMember: groupMember!, viewController: self.viewController,handler :{ (responseObject, error) in
         QuickRideProgressSpinner.stopSpinner()
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                
                let groupMember = Mapper<GroupMember>().map(JSONObject: responseObject!["resultData"])
                  self.group!.lastRefreshedTime = NSDate()
            UserDataCache.getInstance()!.updateUserGroupMember(groupMember: groupMember!)
            self.delegate?.groupMemberAdded(group: self.group!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
      })
    }

    func rejectGroupMember(){
       QuickRideProgressSpinner.startSpinner()
        GroupRestClient.rejectGroupMembership(groupMember: groupMember!, viewController: self.viewController,handler:{ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                 self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.deleteMemberFromGroup(groupId: self.groupMember!.groupId, groupMember: self.groupMember!)
                self.delegate?.groupMemberDeleted(group: self.group!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
}
