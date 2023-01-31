//
//  GroupInformationViewController.swift
//  Quickride
//
//  Created by rakesh on 3/10/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class GroupInformationViewController : UIViewController, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,GroupMemberDelegate,GroupNameUpdateDelegate,GroupDescriptionUpdateDelegate{
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var membersCount: UILabel!
    @IBOutlet weak var groupDescription: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var exitGroupButton: UIButton!
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var groupDescriptionView: UIView!
    @IBOutlet weak var groupNameView: UIView!
    @IBOutlet weak var groupInfoLabel: UILabel!
    @IBOutlet weak var joinButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitBtnSeparatorView: UIView!
    @IBOutlet weak var exitBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var changeGrpNameImage: UIImageView!
    @IBOutlet weak var changeGrpDescImage: UIImageView!
    
    @IBOutlet weak var groupTypeLabel: UILabel!
    @IBOutlet weak var groupCategoryLabel: UILabel!
    @IBOutlet weak var groupLocationLabel: UILabel!
    
    @IBOutlet weak var groupChatBtn: UIButton!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var joinBtnTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var changeGrpImageBtn: UIButton!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var locationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addMemberView: UIView!
    @IBOutlet weak var addMemberViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addMemberTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var JoinGrpMemberCount: UIView!
    
    @IBOutlet weak var memberCountView: UIView!
    
    @IBOutlet weak var joinGrpMemberCountLbl: UILabel!
    
    
    @IBOutlet weak var joingrpMemberCountHeightConstraint: NSLayoutConstraint!
    
    
    
    private var  modelLessDialogue: ModelLessDialogue?

    var group : Group?
    var groupMembers : [GroupMember] = [GroupMember]()
    
    var isRemoveOptionApplicableForPic = false
    var isPicChanged = false
    
    func initializeDataBeforePresenting(group : Group?){
        self.group = group
    }
    
    override func viewDidLoad() {
        definesPresentationContext = true
        self.automaticallyAdjustsScrollViewInsets = false
        initializeGroupInformationView()
       if group!.currentUserStatus != nil{
            if group!.lastRefreshedTime.timeIntervalSince1970 - NSDate().timeIntervalSince1970 >= 15*60{
                refreshTheGroupOfUser()
            }
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    func initializeGroupInformationView() {
        self.navigationItem.title = group!.name
        ViewCustomizationUtils.addCornerRadiusToView(view: changeGrpImageBtn, cornerRadius: changeGrpImageBtn.bounds.size.width/2.0)
        editImageView.image = editImageView.image!.withRenderingMode(.alwaysTemplate)
        editImageView.tintColor = UIColor.white
        groupName.text = group!.name
        if group!.imageURI != nil{
            ImageCache.getInstance().setImageToView(imageView: self.groupImage, imageUrl: group!.imageURI!, placeHolderImg: UIImage(named: "new_group_icon"),imageSize: ImageCache.DIMENTION_LARGE)
        }else{
             self.groupImage.image = UIImage(named: "new_group_icon")
        }
        membersCount.text = String(format: Strings.members, arguments: [String(describing: group!.getConfirmedMembersOfAGroup().count)])
        groupDescription.text = group!.description
        groupTypeLabel.text = group!.type
        groupCategoryLabel.text = group!.category
        joinGrpMemberCountLbl.text = String(format: Strings.members, arguments: [String(describing: group!.getConfirmedMembersOfAGroup().count)])
        if group!.address != nil && group!.address?.isEmpty == false{
            
            groupLocationLabel.text = group!.address!
            locationView.isHidden = false
            locationViewHeightConstraint.constant = 65
            
        }else{
            locationView.isHidden = true
            locationViewHeightConstraint.constant = 0
        }
       
        groupLocationLabel.isUserInteractionEnabled = true
        groupLocationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupInformationViewController.openMapsUrl(_:))))
        addMemberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupInformationViewController.addGrpMemberViewTapped(_:))))
        if group!.creatorId == Double(QRSessionManager.getInstance()!.getUserId()){
            groupNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupInformationViewController.editGroupNameViewTapped(_:))))
            groupDescriptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupInformationViewController.editGroupDescriptionViewTapped(_:))))
        }
        self.adjustConstraintsBasedOnRole(group: group)
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        ViewCustomizationUtils.addCornerRadiusToView(view: joinButton, cornerRadius: 5.0)
        if let createdTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: group!.creationTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy), group!.creatorId == Double(QRSessionManager.getInstance()!.getUserId()){
         groupInfoLabel.text = String(format: Strings.created_by, arguments: [String(describing: createdTime)])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if group!.currentUserStatus != nil{
            initialiseGroupMembers()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    func refreshTheGroupOfUser(){
        GroupRestClient.getGroupOfUser(groupId: group!.id, viewController: self,handler:  { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let group = Mapper<Group>().map(JSONObject: responseObject!["resultData"])
                group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: group!)
                self.group = group
                self.initializeGroupInformationView()
                if group!.currentUserStatus != nil{
                    self.initialiseGroupMembers()
                }
            }
        })
    }
    
    
    func adjustConstraintsBasedOnRole(group : Group?){
        
        if group?.creatorId == Double(QRSessionManager.getInstance()!.getUserId())! && group!.currentUserStatus != nil{
            joinButton.isHidden = true
            joinButtonHeightConstraint.constant = 0
            groupMembersTableView.isHidden = false
            addMemberView.isHidden = false
            addMemberViewHeightConstraint.constant = 50
            JoinGrpMemberCount.isHidden = true
            joingrpMemberCountHeightConstraint.constant = 0
            tableViewBottomSpaceConstraint.constant = 0
            tableViewHeightConstraint.constant = 250
            groupInfoLabel.isHidden = false
            joinBtnTopSpaceConstraint.constant = 0
            addMemberTopSpaceConstraint.constant = 0
            memberCountView.isHidden = false
            changeGrpImageBtn.isHidden = false
            groupChatBtn.isHidden = false
            editImageView.isHidden = false
            changeGrpNameImage.isHidden = false
            changeGrpDescImage.isHidden = false
        }else if group?.currentUserStatus == nil || group!.creatorId != Double(QRSessionManager.getInstance()!.getUserId())! && group!.currentUserStatus == GroupMember.MEMBER_STATUS_PENDING{
            joinButton.isHidden = false
            joinButtonHeightConstraint.constant = 40
            exitGroupButton.isHidden = true
            groupMembersTableView.isHidden = true
            addMemberView.isHidden = true
            addMemberViewHeightConstraint.constant = 0
            exitBtnSeparatorView.isHidden = true
            exitBtnHeightConstraint.constant = 0
            tableViewBottomSpaceConstraint.constant = 0
            tableViewHeightConstraint.constant = 0
            groupInfoLabel.isHidden = true
            joinBtnTopSpaceConstraint.constant = 10
            addMemberTopSpaceConstraint.constant = 10
            memberCountView.isHidden = true
            changeGrpImageBtn.isHidden = true
            groupChatBtn.isHidden = true
             editImageView.isHidden = true
            JoinGrpMemberCount.isHidden = false
            joingrpMemberCountHeightConstraint.constant = 50
            changeGrpNameImage.isHidden = true
            changeGrpDescImage.isHidden = true
        }else{
            joinButton.isHidden = true
            joinButtonHeightConstraint.constant = 0
            exitGroupButton.isHidden = false
            groupMembersTableView.isHidden = false
            addMemberView.isHidden = true
            addMemberViewHeightConstraint.constant = 0
            exitBtnSeparatorView.isHidden = false
            exitBtnHeightConstraint.constant = 25
            tableViewBottomSpaceConstraint.constant = 10
            tableViewHeightConstraint.constant = 250
            groupInfoLabel.isHidden = false
            joinBtnTopSpaceConstraint.constant = 0
            addMemberTopSpaceConstraint.constant = 10
            memberCountView.isHidden = false
            changeGrpImageBtn.isHidden = true
            groupChatBtn.isHidden = false
            JoinGrpMemberCount.isHidden = true
             editImageView.isHidden = true
            joingrpMemberCountHeightConstraint.constant = 0
            changeGrpNameImage.isHidden = true
            changeGrpDescImage.isHidden = true
        }
    }
    
    @objc func addGrpMemberViewTapped(_ sender : UITapGestureRecognizer){
        let addGroupMembersViewController = UIStoryboard(name: "Groups", bundle: nil).instantiateViewController(withIdentifier: "AddGroupMembersViewController") as! AddGroupMembersViewController
        addGroupMembersViewController.initializeDataBeforePresenting(group: group, delegate: self)
        self.navigationController?.pushViewController(addGroupMembersViewController, animated: false)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
    }
    
   func hideExitBtnBasedOnGrpMembersCount() {
        if group!.members.count > 1{
            exitGroupButton.isHidden = true
            exitBtnSeparatorView.isHidden = true
            exitBtnHeightConstraint.constant = 0
        }else{
            exitGroupButton.isHidden = false
            exitBtnSeparatorView.isHidden = false
            exitBtnHeightConstraint.constant = 25
        }
    }
    
    func initialiseGroupMembers()
    {
        
        self.groupMembers = group!.members
        if !self.groupMembers.isEmpty{
            self.groupMembersTableView.delegate = self
            self.groupMembersTableView.dataSource = self
            self.groupMembersTableView.reloadData()
            self.adjustHeightOfTableView()
            if group!.creatorId == Double(QRSessionManager.getInstance()!.getUserId()){
                hideExitBtnBasedOnGrpMembersCount()
            }
        }
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
        ImageCache.getInstance().setImageToView(imageView: cell.groupMemberImageView, imageUrl: groupMember.imageURI, gender: groupMember.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
        cell.menuBtn.tag = indexPath.row
        
        if group!.creatorId == Double(QRSessionManager.getInstance()!.getUserId())!{
            
            if groupMember.type == GroupMember.MEMBER_TYPE_ADMIN{
                cell.groupMemberRole.text = GroupMember.MEMBER_TYPE_ADMIN
                cell.groupMemberRole.isHidden = false
                cell.groupMemberRole.textAlignment = .right
                cell.groupMemberRoleWidthConstraint.constant = 93
                cell.menuBtn.isHidden = true
            }else{
                if groupMember.status == GroupMember.MEMBER_STATUS_PENDING{
                    cell.groupMemberRole.isHidden = false
                    cell.groupMemberRoleWidthConstraint.constant = 93
                    cell.menuBtn.isHidden = false
                    cell.groupMemberRole.textAlignment = .left
                    cell.groupMemberRole.textColor = UIColor.red
                    cell.groupMemberRole.text = GroupMember.MEMBER_STATUS_PENDING
                  
                }else{
                    cell.groupMemberRole.isHidden = true
                    cell.groupMemberRoleWidthConstraint.constant = 0
                    cell.menuBtn.isHidden = false
                }
                
            }
            
        }else{
            if groupMember.type == GroupMember.MEMBER_TYPE_ADMIN{
                cell.groupMemberRole.text = GroupMember.MEMBER_TYPE_ADMIN
                cell.groupMemberRole.isHidden = false
                cell.groupMemberRole.textAlignment = .right
                cell.groupMemberRoleWidthConstraint.constant = 93
            }else{
                if groupMember.status == GroupMember.MEMBER_STATUS_PENDING{
                    cell.groupMemberRole.isHidden = false
                    cell.groupMemberRoleWidthConstraint.constant = 93
                    cell.menuBtn.isHidden = false
                    cell.groupMemberRole.textAlignment = .left
                    cell.groupMemberRole.textColor = UIColor.red
                    cell.groupMemberRole.text = GroupMember.MEMBER_STATUS_PENDING
                    
                }else{
                    cell.groupMemberRole.isHidden = true
                    cell.groupMemberRoleWidthConstraint.constant = 0
                }
            }
            cell.menuBtn.isHidden = true
        }
        
        cell.initializeViews(group: group!, groupMember: groupMember, viewController: self, delegate: self)
        return cell
    }
    
    func adjustHeightOfTableView(){
        
        tableViewHeightConstraint.constant = groupMembersTableView.contentSize.height + 20
    }
    
    
    
    func groupMemberDeleted(group : Group) {
        self.initialiseGroupMembers()
        membersCount.text = String(format: Strings.members, arguments: [String(describing: group.getConfirmedMembersOfAGroup().count)])
    }
    
    func groupMemberAdded(group : Group) {
        self.initialiseGroupMembers()
         membersCount.text = String(format: Strings.members, arguments: [String(describing: group.getConfirmedMembersOfAGroup().count)])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let groupMember = groupMembers[indexPath.row]
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        self.navigateToProfileDisplay(groupMember: groupMember)
        
    }
    
    func navigateToProfileDisplay(groupMember : GroupMember){
        
        let profileDisplayView  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayView.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: groupMember.userId), isRiderProfile : RideManagementUtils.getUserRoleBasedOnRide(),rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayView, animated: false)
    }
    
    @objc func openMapsUrl(_ sender : UITapGestureRecognizer){
        let url = NSURL(string: "https://maps.google.com/?daddr=\(String(describing: group!.latitude)),\(String(describing: group!.longitude))&directionsmode=driving")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    @IBAction func chatBtnClicked(_ sender: Any) {
        
        let groupChatViewController = UIStoryboard(name: "ConversationChat", bundle: nil).instantiateViewController(withIdentifier: "UserGroupChatViewController") as! UserGroupChatViewController
        groupChatViewController.initializeDataBeforePresenting(group: group!)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: groupChatViewController, animated: false)
    }
    
    @objc func editGroupNameViewTapped(_ gesture : UITapGestureRecognizer){
        
        let editGroupNameViewController  = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard,bundle: nil).instantiateViewController(withIdentifier: "EditGroupNameViewController") as! EditGroupNameViewController
        editGroupNameViewController.initializeDataBeforePresenting(group: group!, delegate: self)
        self.navigationController?.view.addSubview(editGroupNameViewController.view)
        self.navigationController?.addChild(editGroupNameViewController)
        editGroupNameViewController.view.layoutIfNeeded()
    
    }
    
    @objc func editGroupDescriptionViewTapped(_ gesture : UITapGestureRecognizer){
        let editGroupDescViewController  = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard,bundle: nil).instantiateViewController(withIdentifier: "EditGroupDescriptionViewController") as! EditGroupDescriptionViewController
        editGroupDescViewController.initializeDataBeforePresenting(group: group!, delegate: self)
        self.navigationController?.view.addSubview(editGroupDescViewController.view)
        self.navigationController?.addChild(editGroupDescViewController)
        editGroupDescViewController.view.layoutIfNeeded()
    }
   
    
    
    @IBAction func changeGrpImageBtnClicked(_ sender: Any) {
        handleGroupImageChange(sender as! UIButton)
        
    }
    
    
    
    func handleGroupImageChange(_ sender: UIButton){
        if (self.group?.imageURI != nil && self.group?.imageURI?.isEmpty  == false) {
            isRemoveOptionApplicableForPic = true
        }
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self, delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    func checkAndSaveGroupImage(){
        AppDelegate.getAppDelegate().log.debug("")
        if isPicChanged{
            var imageURI : String?
            QuickRideProgressSpinner.startSpinner()
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: groupImage.image!),targetViewController: self) { (responseObject, error) in
              QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    imageURI = responseObject!["resultData"]! as? String
                    self.group?.imageURI = imageURI
                    ImageCache.getInstance().storeImageToCache(imageUrl: imageURI!, image: self.groupImage.image!)
                    self.updateGroup(group: self.group!)
                }
                else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
    }
    
    
    @IBAction func joinBtnClicked(_ sender: Any) {
        if group!.category == Group.USER_GROUP_CATEGORY_CORPORATE{
            let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
            if userProfile!.verificationStatus == 0{
                displayEmailUnverifiedDialogue()
            }else if group!.companyCode == userProfile!.companyCode{
                addMemberToGroup()
            }else{
                requestMembershipToGroup()
            }
        }else if group!.type == Group.USER_GROUP_TYPE_PRIVATE{
            requestMembershipToGroup()
        }else{
            addMemberToGroup()
        }
    }
    
    func requestMembershipToGroup(){
        group!.currentUserStatus = GroupMember.MEMBER_STATUS_PENDING
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.requestMembershipToGroup(group: group!, viewController: self,handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let groupMember = Mapper<GroupMember>().map(JSONObject: responseObject!["resultData"])
                self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: self.group!)
                UserDataCache.getInstance()!.addMemberToGrp(groupId: groupMember!.groupId, groupMember: groupMember!)
                self.navigateToGroupsDisplay()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
        
    }
    
    func addMemberToGroup(){
        group!.currentUserStatus = GroupMember.MEMBER_STATUS_CONFIRMED
        let groupMember = GroupMember(userId: Double(QRSessionManager.getInstance()!.getUserId())!, groupId: group!.id, groupName: group!.name!, type: group!.type, status: group!.currentUserStatus!)
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.addMembersToGroup(groupMember: groupMember, viewController: self,handler:{ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let groupMember = Mapper<GroupMember>().map(JSONObject: responseObject!["resultData"])
                self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()?.addOrUpdateGroup(newGroup: self.group!)
                UserDataCache.getInstance()!.addMemberToGrp(groupId: groupMember!.groupId, groupMember: groupMember!)
                self.navigationController?.popViewController(animated: false)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func displayEmailUnverifiedDialogue(){
        modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
        modelLessDialogue?.initializeViews(message: Strings.corporate_req_verification, actionText: Strings.verify_now)
        modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditing(_:))))
        modelLessDialogue?.isUserInteractionEnabled = true
        modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
        self.view.addSubview(modelLessDialogue!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.removeModelLessDialogue()
        }
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func profileEditing(_ recognizer: UITapGestureRecognizer) {
        let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func navigateToGroupsDisplay(){
        var myGroupsViewController : UIViewController?
        if self.navigationController != nil{
            for viewController in self.navigationController!.viewControllers{
                if viewController.isKind(of: MyGroupsViewController.classForCoder()){
                    myGroupsViewController = viewController
                }
            }
        }
        if myGroupsViewController == nil{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.navigationController?.popToViewController(myGroupsViewController!, animated: false)
        }
    }
    
    func groupNameUpdated(updatedGroup : Group) {
        
        self.groupName.text = updatedGroup.name
    }
    
    func groupDescriptionUpdated(updatedGroup: Group) {
        self.groupDescription.text = updatedGroup.description
    }
    
    
    
    
    
    @IBAction func exitBtnClicked(_ sender: Any) {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.exit_grp, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.deleteMemberFromGroup()
            }
        })
    }
    
    
    func deleteMemberFromGroup(){
        
        let currentUserId = Double(QRSessionManager.getInstance()!.getUserId())!
        let groupMember = GroupMember(userId: currentUserId, groupId: group!.id, groupName: group!.name!, type: group!.type, status: group!.currentUserStatus!)
        
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.deleteGroupMember(groupId: group!.id, memberId: currentUserId, viewController: self,handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                UserDataCache.getInstance()!.deleteMemberFromGroup(groupId: self.group!.id, groupMember: groupMember)
                UserDataCache.getInstance()!.deleteGroupFromList(groupId: self.group!.id)
                self.navigateToGroupsDisplay()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func updateGroup(group : Group){
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.updateGroup(group: group, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( "Group Updated")
                self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: self.group!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
}
extension GroupInformationViewController: UIImagePickerControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if image != nil{
            self.isPicChanged = isUpdated
            self.isRemoveOptionApplicableForPic = true
            self.groupImage.image = ImageUtils.RBResizeImage(image: image!, targetSize: CGSize(width: 540, height: 540))
            self.checkAndSaveGroupImage()
        }
        else{
            self.isPicChanged = isUpdated
            self.group?.imageURI = nil
            self.groupImage.image = UIImage(named: "new_group_icon")
            self.isRemoveOptionApplicableForPic = false
            self.updateGroup(group: self.group!)
        }
    }
}
