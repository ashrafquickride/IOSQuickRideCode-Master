//
//  UserRouteGroupInfoViewController.swift
//  Quickride
//
//  Created by Admin on 22/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRouteGroupInfoViewController : UIViewController, UITableViewDelegate,UITableViewDataSource,OnGroupInviteListener,GroupMemberSelectionDelegate{
  
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var groupMembersCountLbl: UILabel!
    
    @IBOutlet weak var groupMembersTableView: UITableView!
    
    @IBOutlet weak var inviteAllBtn: UIButton!
    
    @IBOutlet weak var inviteBtn: UIButton!
    
    var fromLocation : Location?
    var toLocation : Location?
    var groupMembers : [UserRouteGroupMember] = [UserRouteGroupMember]()
    var selectedUserRouteGroup : UserRouteGroup?
    var rideType : String?
    var rideId : Double?
    var selectedUsers : [Int : Bool] = [Int : Bool]()
    
    override func viewDidLoad() {
        createFromAndToLocationData()
        initialiseGroupMembers()
        initializeViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: inviteAllBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: inviteAllBtn, borderWidth: 1.0, color: UIColor(netHex: 0x00B500))
        ViewCustomizationUtils.addCornerRadiusToView(view: inviteBtn, cornerRadius: 7.0)
        inviteBtn.addShadow()
    }
    func initializeDataBeforePresenting(selectedUserRouteGroup : UserRouteGroup?,fromLocation : Location?, toLocation : Location?, rideId : Double?, rideType : String?){
        self.selectedUserRouteGroup = selectedUserRouteGroup
        self.fromLocation = fromLocation
        self.toLocation = toLocation
        self.rideId = rideId
        self.rideType = rideType
    }
    
    func createFromAndToLocationData()
    {
        AppDelegate.getAppDelegate().log.debug("")
        fromLocation = Location()
        fromLocation!.completeAddress = selectedUserRouteGroup!.fromLocationAddress
        fromLocation!.shortAddress = selectedUserRouteGroup!.fromLocationAddress
        fromLocation!.latitude = selectedUserRouteGroup!.fromLocationLatitude!
        fromLocation!.longitude = selectedUserRouteGroup!.fromLocationLongitude!
        
        toLocation = Location()
        toLocation!.completeAddress = selectedUserRouteGroup!.toLocationAddress
        toLocation!.shortAddress = selectedUserRouteGroup!.toLocationAddress
        toLocation!.latitude = selectedUserRouteGroup!.toLocationLatitude!
        toLocation!.longitude = selectedUserRouteGroup!.toLocationLongitude!
    }
    
    func initialiseGroupMembers()
    {
        QuickRideProgressSpinner.startSpinner()
        UserRouteGroupServicesClient.getAllMembersOfAGroup(groupId: selectedUserRouteGroup!.id!, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                
                var members = Mapper<UserRouteGroupMember>().mapArray(JSONObject: responseObject!["resultData"])
                members = self.removeCurrentUserFromGroupIfRequired(members: members!)
                
                if (members == nil || members!.isEmpty)
                {
                    self.groupMembersTableView.isHidden = true
                }
                else
                {
                    self.groupMembers = members!
                    self.groupMembersCountLbl.text = String(format: Strings.members, arguments: [String(self.groupMembers.count)])
                    self.groupMembersTableView.delegate = self
                    self.groupMembersTableView.dataSource = self
                    self.groupMembersTableView.reloadData()
                }
            }
            else
            {
                self.groupMembersTableView.isHidden = true
            }
        })
    }
    
    func removeCurrentUserFromGroupIfRequired(members : [UserRouteGroupMember]) -> [UserRouteGroupMember]
    {
        var userRouteGroupMembers  : [UserRouteGroupMember] = [UserRouteGroupMember]()
        let userId : Double = Double(QRSessionManager.getInstance()!.getUserId())!
        for member in members
        {
            if(userId != member.userId)
            {
                userRouteGroupMembers.append(member)
            }
        }
        return userRouteGroupMembers;
    }
    
    
    func initializeViews(){
        self.fromLabel.text = selectedUserRouteGroup?.fromLocationAddress
        self.toLabel.text = selectedUserRouteGroup?.toLocationAddress
        self.groupName.text = selectedUserRouteGroup?.groupName
        setGroupImage()
    }
    
    func setGroupImage()
    {
        if(selectedUserRouteGroup?.imageURI != nil && !selectedUserRouteGroup!.imageURI!.isEmpty)
        {
           ImageCache.getInstance().setImageToView(imageView: self.groupImageView, imageUrl: selectedUserRouteGroup!.imageURI!, placeHolderImg: UIImage(named: "group_big"),imageSize: ImageCache.DIMENTION_TINY)
         }
        else
        {
            groupImageView.image = UIImage(named: "group_big")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteGroupMemberCell", for: indexPath) as! RouteGroupMemberCell
        if self.groupMembers.endIndex <= indexPath.row{
            return cell
        }
        let groupMember = groupMembers[indexPath.row]
        cell.initializeViews(groupMember: groupMember, row: indexPath.row)
        cell.initializeMultipleSelection(groupMemberSelectionDelegate: self, isSelected: selectedUsers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.groupMembers.endIndex <= indexPath.row{
            return
        }
        let groupMember = groupMembers[indexPath.row]
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
        if(QRSessionManager.getInstance()!.getUserId() == StringUtils.getStringFromDouble(decimalNumber: groupMember.userId!)){
            return
        }
        navigateToProfileDisplay(groupMember: groupMember)
    }
    
    func navigateToProfileDisplay(groupMember : UserRouteGroupMember)
    {
        
        let profileDisplayView  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayView.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: groupMember.userId!), isRiderProfile : RideManagementUtils.getUserRoleBasedOnRide() ,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayView, animated: false)
    }
    
    func navigateToGroupsDisplay(){
        var routeGroupsViewController : UIViewController?
        if self.navigationController != nil{
            for viewController in self.navigationController!.viewControllers{
                if viewController.isKind(of: RouteGroupsViewController.classForCoder()){
                    routeGroupsViewController = viewController
                }
            }
        }
        if routeGroupsViewController == nil{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.navigationController?.popToViewController(routeGroupsViewController!, animated: false)
        }
    }
    
    @IBAction func inviteAllBtnClicked(_ sender: Any) {
    
        inviteGroupMembers(groupMembers: groupMembers)
        
    }
    
    
    func inviteGroupMembers(groupMembers : [UserRouteGroupMember]){
        var selectedGroupMembers = [Double]()
        if groupMembers.isEmpty
        {
            return
        }
        for index in 0...groupMembers.count-1{
            selectedGroupMembers.append(groupMembers[index].userId!)
        }
        
        if rideId != nil && rideType != nil
        {
            InviteRideGroups.inviteSelectedUserOfGroupTask(rideId: rideId!, rideType: rideType!, userIds: selectedGroupMembers, groupId: selectedUserRouteGroup!.id!, receiver: self, viewController: self)
            
        }
    }
    
    
    
    func groupInviteCompleted() {
        UIApplication.shared.keyWindow?.makeToast( Strings.invite_sent_group_member)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func requestBtnClicked(_ sender: UIButton) {
        
        if groupMembers.count <= sender.tag{
            return
        }
        let groupMember = groupMembers[sender.tag]
        inviteGroupMembers(groupMembers: [groupMember])
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func groupsMemberSelectedAtIndex(row: Int, group: UserRouteGroupMember) {
        self.selectedUsers[row] = true
        validateAndDisplayInviteBtn()
    }
    
    func groupsMemberUnSelectedAtIndex(row: Int, group: UserRouteGroupMember) {
        self.selectedUsers[row] = false
        validateAndDisplayInviteBtn()
    }
    
    func validateAndDisplayInviteBtn(){
        
        if selectedUsers.values.contains(true){
            inviteBtn.isHidden = false
            if rideType == Ride.RIDER_RIDE{
                self.inviteBtn.setTitle("Invite", for: .normal)
            }else{
                self.inviteBtn.setTitle("Request", for: .normal)
            }
        }else{
            inviteBtn.isHidden = true
        }
        
    }
    
    @IBAction func inviteBtnClicked(_ sender: Any) {
        
        var selectedGroupMembers = [UserRouteGroupMember]()
        
        for index in 0...groupMembers.count-1{
            if selectedUsers[index] == true{
                selectedGroupMembers.append(groupMembers[index])
            }
        }
        
        if selectedGroupMembers.isEmpty == false
        {
            inviteGroupMembers(groupMembers: selectedGroupMembers)
        }
    }
    
    
    
}
