//
//  UserRouteGroupCreationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/14/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit
import Alamofire
import GoogleMaps

class UserRouteGroupCreationViewController : UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource, UserRouteGroupJoinReceiver, ReceiveLocationDelegate, OnGroupInviteListener, GroupMemberSelectionDelegate {
    
    @IBOutlet weak var navigationTitle: UINavigationItem!

    @IBOutlet weak var topActnBtn: UIButton!

    @IBOutlet weak var editGroupImage: UIButton!
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var fromLocationText: UILabel!
    
    @IBOutlet weak var toLocationText: UILabel!
    
    @IBOutlet weak var swapImageView: UIImageView!

    @IBOutlet weak var createGroup: UIButton!
    
    @IBOutlet weak var createGroupTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createGrpBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var groupMembersTableView: UITableView!
    
    @IBOutlet weak var groupMembersView: UIView!
    
    @IBOutlet weak var groupMembersViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var groupMembersTableViewBottomSpaceConstraint: NSLayoutConstraint!
    
    var isKeyBoardVisible = false
    var fromLocation : Location?
    var toLocation : Location?
    var isPicChanged = false
    var allUsersSelected = true
    var groupMembers : [UserRouteGroupMember] = [UserRouteGroupMember]()
    var presentedFromSearchGroupView = false
    private var existedUserRouteGroups : [UserRouteGroup]?
    
    var enableJoinOption : Bool = false
    var isDisplayMode : Bool = false
    var isFromRideView : Bool = false
    var createdUserRouteGroup : UserRouteGroup?
    var selectedUserRouteGroup : UserRouteGroup?
    var isRemoveOptionApplicableForPic = false

    var callPhoneNumber : String?
    var rideType : String?
    var rideId : Double?
    var selectedUsers : [Int : Bool] = [Int : Bool]()

    override func viewDidLoad()
    {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        definesPresentationContext = true
        self.navigationController?.isNavigationBarHidden = false
        groupNameTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(UserRouteGroupCreationViewController.keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserRouteGroupCreationViewController.keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.automaticallyAdjustsScrollViewInsets = false
        createGroup.backgroundColor = Colors.mainButtonColor
        getExistedUserRouteGroups()
        if(isDisplayMode)
        {
            createFromAndToLocationData()
        }
        if isDisplayMode || isFromRideView || enableJoinOption
        {
            initialiseGroupMembers()
        }
        initialiseViews()
        ViewCustomizationUtils.addCornerRadiusToView(view: createGroup, cornerRadius: 4)
        ViewCustomizationUtils.addCornerRadiusToView(view: selectAllBtn, cornerRadius: 3)
        swapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserRouteGroupCreationViewController.swapLocations(_:))))
    }
    
    func initializeDataBeforePresenting(selectedUserRouteGroup : UserRouteGroup?, enableJoinOption : Bool, isDisplayMode : Bool, isFromRideView : Bool, fromLocation : Location?, toLocation : Location?, rideId : Double?, rideType : String?){
        self.selectedUserRouteGroup = selectedUserRouteGroup
        self.enableJoinOption = enableJoinOption
        self.isDisplayMode = isDisplayMode
        self.isFromRideView = isFromRideView
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
    
    @objc func ridePathGroupJoin(_ gesture : UITapGestureRecognizer)
    {
        UserRouteGroupJoin.groupJoin(foundGroup: selectedUserRouteGroup!, receiver : self)
    }
    func joinedRidePathGroup(joinedGroup : UserRouteGroup)
    {
        self.navigationController?.popViewController(animated: false)
    }
    func userJoinedThisGroupAlready()
    {
        UIApplication.shared.keyWindow?.makeToast( Strings.user_joined_group)
    }

    @objc func sendInvite(_ gesture : UITapGestureRecognizer)
    {
        var selectedGroupMembers = [Double]()
        if groupMembers.isEmpty
        {
            return
        }
        for index in 0...groupMembers.count-1{
            if selectedUsers[index] == true{
                selectedGroupMembers.append(groupMembers[index].userId!)
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
        InviteRideGroups.inviteSelectedUserOfGroupTask(rideId: rideId!, rideType: rideType!, userIds: selectedGroupMembers, groupId: selectedUserRouteGroup!.id!, receiver: self, viewController: self)

            }
        }
    }
    func groupInviteCompleted()
    {
        UIApplication.shared.keyWindow?.makeToast( Strings.invite_sent_group_member)
    }
    func groupsMemberSelectedAtIndex(row: Int, group: UserRouteGroupMember) {
        AppDelegate.getAppDelegate().log.debug("\(row) \(group)")
        self.selectedUsers[row] = true
    }
    func groupsMemberUnSelectedAtIndex(row: Int, group: UserRouteGroupMember) {
        AppDelegate.getAppDelegate().log.debug("\(row) \(group)")
        self.selectedUsers[row] = false
        if allUsersSelected
        {
            self.allUsersSelected = false
            selectAllBtn.setTitleColor(Colors.inviteActionBtnTextColor, for: .normal)
            selectAllBtn.backgroundColor = UIColor.white
        }
    }

    @objc func swapLocations(_ gesture : UITapGestureRecognizer)
    {
        let tempLocation = fromLocation
        fromLocation = toLocation
        toLocation = tempLocation
        
        if fromLocation == nil{
            fromLocationText.text = Strings.from_location_hint
            fromLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationText.font = fromLocationText.font.withSize(12)
        }else{
            fromLocationText.text = fromLocation!.shortAddress
            fromLocationText.textColor = Colors.locationTextColor
            fromLocationText.font = fromLocationText.font.withSize(15)
        }
        if toLocation == nil{
            toLocationText.text = Strings.to_location_hint_create
            toLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationText.font = toLocationText.font.withSize(12)
        }else{
            toLocationText.text = toLocation!.shortAddress
            toLocationText.textColor = Colors.locationTextColor
            toLocationText.font = toLocationText.font.withSize(15)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : RidePathGroupMemberCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RidePathGroupMemberCell
        if self.groupMembers.endIndex <= indexPath.row{
            return cell
        }
        let groupMember = groupMembers[indexPath.row]
        
        cell.initializeViews(groupMember: groupMember, row: indexPath.row)
        if isFromRideView
        {
            cell.initializeMultipleSelection(groupSelectionDelegate: self, isSelected: selectedUsers[indexPath.row])
        }
        if isFromRideView && allUsersSelected
        {
            cell.selectAllUsers()
        }
        else
        {
            cell.deselectAllUsers()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return groupMembers.count
    }
    func customizeActions()
    {
        if enableJoinOption
        {
            topActnBtn.isHidden = false
            topActnBtn.setTitle(Strings.join, for: .normal)
            self.topActnBtn.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(UserRouteGroupCreationViewController.ridePathGroupJoin(_:))))
        }
        if isFromRideView && !groupMembers.isEmpty
        {
            topActnBtn.isHidden = false
            topActnBtn.setTitle(Strings.invite, for: .normal)
            topActnBtn.setTitleColor(Colors.profileJoinColor, for: .normal)
            self.topActnBtn.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(UserRouteGroupCreationViewController.sendInvite(_:))))
            selectAllBtn.isHidden = false
            selectAllBtn.backgroundColor = Colors.inviteActionBtnTextColor
            selectAllBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    func initialiseViews()
    {
        if(isDisplayMode)
        {
            navigationTitle.title = Strings.view_group
            self.groupNameTextField.isUserInteractionEnabled = false
            self.groupNameTextField.placeholder = ""
            self.createGroup.isHidden = true
            self.groupMembersView.isHidden = false
            self.swapImageView.isHidden = true
            self.fromLocationText.text = selectedUserRouteGroup?.fromLocationAddress
            self.toLocationText.text = selectedUserRouteGroup?.toLocationAddress
            self.groupNameTextField.text = selectedUserRouteGroup?.groupName
            setGroupImage()
            editGroupImage.isHidden = true
            adjustHeightofViewForDisplayMode()
        }
        else
        {
            self.groupNameTextField.contentVerticalAlignment = .bottom
            self.groupNameTextField.placeholder = "Group(StartLocation-To-EndLocation)"
            navigationTitle.title = Strings.create_group
        }

        if(fromLocation != nil)
        {
            fromLocationText.text = fromLocation!.shortAddress
        }
        else
        {
            fromLocationText.text = Strings.from_location_hint
            fromLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationText.font = fromLocationText.font.withSize(12)
        }
        if(toLocation != nil)
        {
            toLocationText.text = toLocation!.shortAddress
        }
        else
        {
            toLocationText.text = Strings.to_location_hint_create
            toLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationText.font = toLocationText.font.withSize(12)
        }
        if(!isDisplayMode)
        {
            self.groupMembersView.isHidden = true
            self.fromLocationText.isUserInteractionEnabled = true
            self.toLocationText.isUserInteractionEnabled = true
            self.fromLocationText.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(UserRouteGroupCreationViewController.fromLocationTapped(_:))))
            self.toLocationText.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(UserRouteGroupCreationViewController.toLocationTapped(_:))))
            editGroupImage.isHidden = false
        }
    }
    
    func setGroupImage()
    {
        if(selectedUserRouteGroup?.imageURI != nil && !selectedUserRouteGroup!.imageURI!.isEmpty)
        {
            ImageCache.getInstance().setImageToView(imageView: self.groupImageView, imageUrl: selectedUserRouteGroup!.imageURI!, placeHolderImg: UIImage(named: "group_new_small"),imageSize: ImageCache.DIMENTION_SMALL)
        }
        else
        {
            groupImageView.image = UIImage(named: "group_new_small")
        }
    }
    func adjustHeightofViewForDisplayMode()
    {
        createGroupTopSpaceConstraint.constant = 0
        createGrpBtnHeightConstraint.constant = 0
     }
    @objc func fromLocationTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let changeLocationVC: ChangeLocationViewController = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.ORIGIN, currentSelectedLocation: nil, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    @objc func toLocationTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let changeLocationVC: ChangeLocationViewController = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.DESTINATION, currentSelectedLocation: nil, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    func receiveSelectedLocation(location: Location, requestLocationType: String) {AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
    }
    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            self.fromLocation = location
            fromLocationText.text = location.shortAddress
            fromLocationText.textColor = Colors.locationTextColor
            fromLocationText.font = fromLocationText.font.withSize(15)

        }else{
            self.toLocation = location
            toLocationText.text = location.shortAddress
            toLocationText.textColor = Colors.locationTextColor
            toLocationText.font = toLocationText.font.withSize(15)
        }
    }
    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("")
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            self.fromLocation = nil
            fromLocationText.text = Strings.from_location_hint
            fromLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationText.font = fromLocationText.font.withSize(12)
        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            self.toLocation = nil
            toLocationText.text = Strings.to_location_hint_create
            toLocationText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationText.font = toLocationText.font.withSize(12)
        }
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
                    self.topActnBtn.isHidden = true
                    self.selectAllBtn.isHidden = true
                    self.groupMembersView.isHidden = true
                }
                else
                {
                    self.groupMembers = members!
                    self.groupMembersTableView.delegate = self
                    self.groupMembersTableView.dataSource = self
                    self.groupMembersTableView.reloadData()
                    self.adjustHeightOfTableView()
                }
                self.customizeActions()
            }
            else
            {
                self.topActnBtn.isHidden = true
                self.selectAllBtn.isHidden = true
                self.groupMembersView.isHidden = true
            }
        })
    }
    func adjustHeightOfTableView()
    {
        groupMembersViewHeightConstraint.constant = groupMembersViewHeightConstraint.constant - groupMembersTableView.frame.size.height
        groupMembersTableView.frame = CGRect(x: groupMembersTableView.frame.origin.x, y: groupMembersTableView.frame.origin.y, width: groupMembersTableView.frame.size.width, height: groupMembersTableView.contentSize.height)
        groupMembersViewHeightConstraint.constant = groupMembersViewHeightConstraint.constant + groupMembersTableView.contentSize.height
    }
    func removeCurrentUserFromGroupIfRequired(members : [UserRouteGroupMember]) -> [UserRouteGroupMember]
    {
        if(!isFromRideView)
        {
            return members;
        }
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

    func getExistedUserRouteGroups()
    {
        let userRouteGroups = UserDataCache.getInstance()?.getUserRouteGroups()
        if userRouteGroups != nil
        {
            existedUserRouteGroups = userRouteGroups
        }
    }
 
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func addNewGroup(_ sender: Any) {
        
        if(validateAllDetails())
        {
            self.createdUserRouteGroup = UserRouteGroup(groupName: groupNameTextField.text!,  creatorId:Double(QRSessionManager.getInstance()!.getUserId())!, fromLocationAddress:fromLocation!.shortAddress!, toLocationAddress:toLocation!.shortAddress!, fromLocationLatitude:fromLocation!.latitude, fromLocationLongitude:fromLocation!.longitude, toLocationLatitude:toLocation!.latitude, toLocationLongitude:toLocation!.longitude,  memberCount:1, appName: AppConfiguration.APP_NAME)
            checkAndSaveUserImage()
        }
    }
    
    func validateAllDetails() -> Bool
    {
        if(fromLocation == nil || fromLocationText.text!.isEmpty )
        {
            MessageDisplay.displayAlert(messageString: Strings.from_location,viewController: self,handler: nil)
            return false
        }
        else if(toLocation == nil || toLocationText.text!.isEmpty )
        {
            MessageDisplay.displayAlert(messageString: Strings.to_location,viewController: self,handler: nil)
            return false
        }
        else if(checkForDuplicateFromAndToLocation())
        {
            MessageDisplay.displayAlert(messageString: Strings.group_join_already,viewController: self,handler: nil)
                return false;
        }
        else if(groupNameTextField.text == nil || groupNameTextField.text!.isEmpty )
        {
            MessageDisplay.displayAlert(messageString: Strings.group_name,viewController: self,handler: nil)
            return false;
        }
        else if(checkGroupNameExistedAlready(givenGroupName: groupNameTextField.text!))
        {
            MessageDisplay.displayAlert(messageString: Strings.group_join,viewController: self,handler: nil)
            return false
        }
        return true
    }

    func checkForDuplicateFromAndToLocation() -> Bool
    {
        if(existedUserRouteGroups != nil)
        {
            for ridePathGroup in existedUserRouteGroups!
            {
                if ((fromLocation?.shortAddress == ridePathGroup.fromLocationAddress && toLocation?.shortAddress == ridePathGroup.toLocationAddress) ||
                   (fromLocation?.latitude == ridePathGroup.fromLocationLatitude && fromLocation?.longitude == ridePathGroup.fromLocationLongitude) && (toLocation?.latitude == ridePathGroup.toLocationLatitude && toLocation?.longitude == ridePathGroup.toLocationLongitude))
                {
                    return true
                }
                else
                {
                    continue;
                }
            }
        }
        return false
    }
    func checkGroupNameExistedAlready(givenGroupName : String) -> Bool
    {
        if(existedUserRouteGroups != nil)
        {
            for ridePathGroup in existedUserRouteGroups!
            {
                if(givenGroupName == ridePathGroup.groupName)
                {
                    return true
                }
                else
                {
                    continue
                }
            }
        }
        return false
    }
    func saveUserRouteGroup()
    {
        QuickRideProgressSpinner.startSpinner()
        UserRouteGroupServicesClient.createNewGroup(body: createdUserRouteGroup!.getParams(), targetViewController: self, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let ridePathGroup = Mapper<UserRouteGroup>().map(JSONObject: responseObject!["resultData"])
                let userDataCache  : UserDataCache? = UserDataCache.getInstance()
                if(userDataCache != nil)
                {
                    userDataCache!.addUserRidePathGroup(ridePathGroup: ridePathGroup!)
                }
                self.navigateToGroupsDisplay()
            }
            else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
            }
        })
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
    
    @IBAction func editImageTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        handleProfileImageChange(sender as! UIButton)
    }
    
    func handleProfileImageChange(_ sender: UIButton){
        if (self.createdUserRouteGroup?.imageURI != nil && self.createdUserRouteGroup?.imageURI!.isEmpty == false) {
            isRemoveOptionApplicableForPic = true
        }
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self, delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }

    func checkAndSaveUserImage(){
        AppDelegate.getAppDelegate().log.debug("")
        if isPicChanged  {
            var imageURI : String?
            let image = ImageUtils.RBResizeImage(image: groupImageView.image!, targetSize: CGSize(width: 120, height: 120))
            QuickRideProgressSpinner.startSpinner()
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image),targetViewController: self) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    imageURI = responseObject!["resultData"]! as? String
                    self.createdUserRouteGroup?.imageURI = imageURI
                    self.saveUserRouteGroup()
                }
                else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
        else{
             self.saveUserRouteGroup()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.groupNameTextField.resignFirstResponder()
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == groupNameTextField{
            threshold = 30
        }else{
            return true
        }
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 250))
    }

    @IBAction func selectAllButtonClicked(_ sender: UIButton) {
        
        if allUsersSelected
        {
            self.allUsersSelected = false
            selectAllBtn.setTitleColor(Colors.inviteActionBtnTextColor, for: .normal)
            selectAllBtn.backgroundColor = UIColor.white
            self.groupMembersTableView.reloadData()

        }else{
            self.allUsersSelected = true
            selectAllBtn.backgroundColor = Colors.inviteActionBtnTextColor
            selectAllBtn.setTitleColor(UIColor.white, for: .normal)
            self.groupMembersTableView.reloadData()
        }
    }
    
    @objc func keyBoardWillShow(_ notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
            isKeyBoardVisible = true
            groupMembersTableViewBottomSpaceConstraint.constant = 150
    }
    @objc func keyBoardWillHide(_
        notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        groupMembersTableViewBottomSpaceConstraint.constant = 10
    }
}
extension UserRouteGroupCreationViewController: UIImagePickerControllerDelegate{
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
            self.groupImageView.image = image!.circle
            self.isRemoveOptionApplicableForPic = true
        }else{
            self.isPicChanged = isUpdated
            self.createdUserRouteGroup?.imageURI = nil
            self.groupImageView.image = UIImage(named: "group_new_big")
        }
    }
}
