//
//  InviteUserGroupsViewController.swift
//  Quickride
//
//  Created by rakesh on 3/19/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class InviteUserGroupsViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,GrpMemberSelectionDelegate,OnGroupMemberInviteListener{

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLbl: UILabel!
     @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var groupTypeLbl: UILabel!
    @IBOutlet weak var groupCategoryLbl: UILabel!
    @IBOutlet weak var grpLocationLbl: UILabel!
    @IBOutlet weak var groupURLLbl: UILabel!
    @IBOutlet weak var grpURLHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var grpLocationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var grpMembersTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    @IBOutlet weak var inviteBtn: UIButton!
    
    @IBOutlet weak var selectAllView: UIView!
    
    var group : Group?
    var groupMembers : [GroupMember] = [GroupMember]()
    var allUsersSelected = true
    var selectedUsers : [Int : Bool] = [Int : Bool]()
    var rideId : Double?
    var rideType : String?
    
    
    func initializeDataBeforePresenting(group : Group,rideId :Double?,rideType : String?){
        self.group = group
        self.rideId = rideId
        self.rideType = rideType
    }
  override func viewDidLoad() {
    
      self.navigationController?.isNavigationBarHidden = false
       self.automaticallyAdjustsScrollViewInsets = false
       groupNameLbl.text = group!.name
       groupDescriptionLabel.text = group!.description
        groupTypeLbl.text = group!.type
        groupCategoryLbl.text = group!.category
        if group!.imageURI != nil{
            ImageCache.getInstance().setImageToView(imageView: self.groupImageView, imageUrl: group!.imageURI!, placeHolderImg: UIImage(named: "new_group_icon"),imageSize: ImageCache.DIMENTION_LARGE)
        }else{
            self.groupImageView.image = UIImage(named: "new_group_icon")
        }
                if group!.address != nil && group!.address?.isEmpty == false{
            grpLocationLbl.text = group!.address!
            grpLocationHeightConstraint.constant = 65
        }else{
            grpLocationHeightConstraint.constant = 0
        }
        if group!.url != nil && group!.url?.isEmpty == false{
            groupURLLbl.text = group!.url!
             grpURLHeightConstraint.constant = 65
        }else{
            grpURLHeightConstraint.constant = 0
        }
        
        grpMembersTableView.delegate = self
        grpMembersTableView.dataSource = self
     
        if group!.creatorId == Double(QRSessionManager.getInstance()!.getUserId())! || group!.currentUserStatus == GroupMember.MEMBER_STATUS_CONFIRMED{
            grpMembersTableView.isHidden = false
        }else{
            grpMembersTableView.isHidden = true
        }
        initialiseGroupMembers()
        if self.groupMembers.isEmpty{
          inviteBtn.isHidden = true
        }else{
          inviteBtn.isHidden = false
        }
    
       if allUsersSelected{
         selectAllBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
       }else{
         selectAllBtn.setImage(UIImage(named: "tick_icon"), for: .normal)
       }
       selectAllView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteUserGroupsViewController.selectAllViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: selectAllBtn, cornerRadius: 3)
        inviteBtn.setTitleColor(Colors.profileJoinColor, for: .normal)
    
    }
    
    func initialiseGroupMembers()
    {
        
        let fetchedGrpMembers = group!.members
  
        self.groupMembers = group!.removeCurrentUserAndPendingMembers()
            self.grpMembersTableView.delegate = self
            self.grpMembersTableView.dataSource = self
            self.grpMembersTableView.reloadData()
            self.adjustHeightOfTableView()
      
  }
    
    func groupsMemberSelectedAtIndex(row: Int, group: GroupMember) {
        AppDelegate.getAppDelegate().log.debug("\(row) \(group)")
        self.selectedUsers[row] = true
    }
    func groupsMemberUnSelectedAtIndex(row: Int, group: GroupMember) {
        AppDelegate.getAppDelegate().log.debug("\(row) \(group)")
        self.selectedUsers[row] = false
        if allUsersSelected
        {
            self.allUsersSelected = false
            selectAllBtn.setImage(UIImage(named : "tick_icon") , for: .normal)
        }
    }

    func adjustHeightOfTableView(){
        
        tableViewHeightConstraint.constant = grpMembersTableView.contentSize.height + 20
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : GroupMembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupMembersTableViewCell", for: indexPath) as! GroupMembersTableViewCell
        if self.groupMembers.endIndex <= indexPath.row{
            return cell
        }
        let groupMember = self.groupMembers[indexPath.row]
        cell.groupMemberName.text = groupMember.userName
        cell.groupMemberImageView.image = nil
        ImageCache.getInstance().setImageToView(imageView: cell.groupMemberImageView, imageUrl: groupMember.imageURI, gender: groupMember.gender!,imageSize: ImageCache.DIMENTION_TINY)

        cell.initializeMemberView(groupMember: groupMember, row: indexPath.row)
        cell.initializeMultipleSelection(groupSelectionDelegate: self, isSelected: selectedUsers[indexPath.row])
        if allUsersSelected{
            cell.selectAllUsers()
        }else{
            cell.deselectAllUsers()
        }
       
      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let groupMember = groupMembers[indexPath.row]
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        self.navigateToProfileDisplay(groupMember: groupMember)
        
    }
  
    func navigateToProfileDisplay(groupMember : GroupMember){
        
        let profileDisplayView  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayView.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: groupMember.userId), isRiderProfile : RideManagementUtils.getUserRoleBasedOnRide() ,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayView, animated: false)
    }
        

    @objc func selectAllViewTapped(_ gesture : UITapGestureRecognizer){
       self.setImageToSelectAllBtn()
    }
    
    @IBAction func selectAllBtnClicked(_ sender: Any) {
     self.setImageToSelectAllBtn()
   }
   func setImageToSelectAllBtn(){
        if allUsersSelected
        {
            self.allUsersSelected = false
            selectAllBtn.setImage(UIImage(named: "tick_icon"), for: .normal)
            self.grpMembersTableView.reloadData()
            
        }else{
            self.allUsersSelected = true
            selectAllBtn.setImage(UIImage(named: "group_tick_icon"), for: .normal)
            self.grpMembersTableView.reloadData()
        }
    }
    @IBAction func inviteBtnClicked(_ sender: Any) {
        
        var selectedGroupMembers = [Double]()
        if groupMembers.isEmpty
        {
            return
        }
        for index in 0...groupMembers.count-1{
            if selectedUsers[index] == true{
                selectedGroupMembers.append(groupMembers[index].userId)
            }
        }
        if(selectedGroupMembers.count == 0)
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.select_atleast_one)
            return
        }
        
        if selectedGroupMembers.isEmpty == false
        {
            if rideId != nil && rideType != nil
            {

                InviteUserGroups.inviteSelectedUserOfGroupTask(rideId: rideId!, rideType: rideType!, userIds: selectedGroupMembers, groupId: group!.id, receiver: self, viewController: self)
                
            }
        }
    
    
    }
    @IBAction func backBtnTapped(_ sender: Any) {
      self.navigationController?.popViewController(animated: false)
    }
    
    func groupMembersInviteCompleted() {
        UIApplication.shared.keyWindow?.makeToast( Strings.invite_group_members)
        self.navigationController?.popViewController(animated: false)
    }
    
    
    
}
