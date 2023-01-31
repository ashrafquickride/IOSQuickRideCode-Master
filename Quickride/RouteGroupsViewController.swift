//
//  RouteGroupsViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 6/29/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit
import GoogleMaps

class RouteGroupsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UserRouteGroupJoinReceiver, SuggestedGroupsReceiver {
    
    @IBOutlet weak var noGroupsView: UIView!
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    @IBOutlet weak var searchGroupBtn: UIButton!
    
    
    @IBOutlet weak var searchGroupButtonForNoGroupsView: UIButton!
    var homeLocation : UserFavouriteLocation?
    var officeLocation : UserFavouriteLocation?
    var myGroups : [UserRouteGroup] = [UserRouteGroup]()
    var suggestedGroups : [UserRouteGroup] = [UserRouteGroup]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        initialiseHomeAndOfficeLocations()
        initialiseGroups()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        AppDelegate.getAppDelegate().log.debug("")
            return 2
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0{
                return myGroups.count
            }else{
                return suggestedGroups.count
            }
     }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if  indexPath.section == 0{
            return 51
        }else{
            return 110
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 30
    }

    func tableView(_
        tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && myGroups.count > 0{
            return Strings.my_route_group
        }
        else if section == 1 && suggestedGroups.count > 0{
            return Strings.recommended_route_groups
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.section == 0{
            let cell : MyGroupsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Joined Group Cell", for: indexPath as IndexPath) as! MyGroupsTableViewCell
            if self.myGroups.endIndex <= indexPath.row{
                return cell
            }
            let myGroup  = self.myGroups[indexPath.row]
            cell.myGroupName.text = myGroup.groupName
            cell.settingsBtn.tag = indexPath.row
            
            if myGroup.imageURI != nil{
                    ImageCache.getInstance().setImageToView(imageView: cell.myGroupImage, imageUrl: myGroup.imageURI!, placeHolderImg: UIImage(named:"group_new_small"),imageSize: ImageCache.DIMENTION_TINY)
            }
            else{
                cell.myGroupImage.image = UIImage(named:"group_new_small")
            }
            return cell
        }
        else
        {
            let cell : SuggestedGroupsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Suggested Group Cell", for: indexPath as IndexPath) as! SuggestedGroupsTableViewCell
            if self.suggestedGroups.endIndex <= indexPath.row{
                return cell
            }
            let recommendedGroup  = self.suggestedGroups[indexPath.row]
            
            cell.fromLocationLabel.text = recommendedGroup.fromLocationAddress
            cell.toLocationLabel.text = recommendedGroup.toLocationAddress
            cell.groupNameLbel.text = recommendedGroup.groupName
            cell.noOfMembers.text = String(format: Strings.members, arguments: [String(recommendedGroup.memberCount!)])
            cell.joinBtn.tag = indexPath.row
            if(recommendedGroup.imageURI != nil)
            {
                ImageCache.getInstance().setImageToView(imageView: cell.groupImage, imageUrl: recommendedGroup.imageURI!, placeHolderImg: UIImage(named:"group_new_small"),imageSize: ImageCache.DIMENTION_TINY)
            }
            else
            {
                cell.groupImage.image = UIImage(named: "group_new_small")
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  indexPath.section == 0{
            if self.myGroups.endIndex <= indexPath.row{
                return
            }
            let joinedGroup = self.myGroups[indexPath.row]
            let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
            userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup: joinedGroup, enableJoinOption: false, isDisplayMode: true, isFromRideView: false, fromLocation: nil, toLocation: nil, rideId: nil, rideType: nil)
            self.navigationController?.pushViewController(userRouteGroupCreateVC, animated: false)
        }
        else
        {
            if self.suggestedGroups.endIndex <= indexPath.row{
                return
            }
            let recommendedGroup = self.suggestedGroups[indexPath.row]
            let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
            userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup: recommendedGroup, enableJoinOption: true, isDisplayMode: true, isFromRideView: false, fromLocation: nil, toLocation: nil, rideId: nil, rideType: nil)
            self.navigationController?.pushViewController(userRouteGroupCreateVC, animated: false)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    @IBAction func joinedGroupSettingTapped(_ sender: Any) {
        
        let joinedGroup = self.myGroups[(sender as AnyObject).tag]
        
        let alertController : GroupViewAndExitAlertController = GroupViewAndExitAlertController(viewController: self) { (result) -> Void in
            if result == Strings.EXIT{
                GroupExitTask.userRouteGroupExitingTask(userRouteGroup: joinedGroup, userId: QRSessionManager.getInstance()!.getUserId(), viewController: self, completionHandler: { (error) -> Void in
                    if error == nil{
                        self.handleUserExitFromTheGroup(userRouteGroup: joinedGroup)
                    }
                })
            }
            else if result == Strings.VIEW
            {
                let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
                userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup: joinedGroup, enableJoinOption: false, isDisplayMode: true, isFromRideView: false, fromLocation: nil, toLocation: nil, rideId: nil, rideType: nil)
                self.navigationController?.pushViewController(userRouteGroupCreateVC, animated: false)
            }
        }
        alertController.viewAlertAction()
        alertController.exitAlertAction()
        alertController.addRemoveAlertAction()
        alertController.showAlertController()
    }
    
    func handleUserExitFromTheGroup(userRouteGroup : UserRouteGroup)
    {
        self.myGroups = UserDataCache.getInstance()!.getUserRouteGroups()
        if(!checkForTheSuggestedGroupPossibility(userRouteGroup: userRouteGroup))
        {
            if(myGroups.isEmpty)
            {
                noGroupsView.isHidden = false
                self.groupsTableView.isHidden = true
                return
            }
            self.groupsTableView.reloadData()
            return
        }
        suggestedGroups.append(userRouteGroup)
        self.groupsTableView.reloadData()
    }
    @IBAction func searchGroupClicked(_ sender: Any) {
        let userRouteGroupSearchViewController  = UIStoryboard(name : StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupSearchViewController") as! UserRouteGroupSearchViewController
        if(homeLocation != nil)
        {
            userRouteGroupSearchViewController.fromLocation = getLocationFromFavouriteLocation(userFavouriteLocation: homeLocation!)
        }
        if(officeLocation != nil)
        {
            userRouteGroupSearchViewController.toLocation = getLocationFromFavouriteLocation(userFavouriteLocation: officeLocation!)
        }
        self.navigationController?.pushViewController(userRouteGroupSearchViewController, animated: false)
    }

    func initialiseGroups()
    {
        initialiseJoinedGroups()
        initialiseSuggestedGroups()
    }
    
    func initialiseJoinedGroups()
    {
        self.myGroups = UserDataCache.getInstance()!.getUserRouteGroups()
        if !myGroups.isEmpty
        {
            noGroupsView.isHidden = true
            groupsTableView.isHidden = false
            self.groupsTableView.reloadData()
        }
    }
    func initialiseSuggestedGroups()
    {
        if (homeLocation != nil || officeLocation != nil)
        {
            var homeLoc,ofcLoc : Location?
            
            if(homeLocation != nil)
            {
                homeLoc = getLocationFromFavouriteLocation(userFavouriteLocation: homeLocation!)!
            }
            else{
                homeLoc = Location()
            }
            if(officeLocation != nil)
            {
                ofcLoc = getLocationFromFavouriteLocation(userFavouriteLocation: officeLocation!)!
            }
            else
            {
                ofcLoc = Location()
            }
            
            if(homeLoc != nil || ofcLoc != nil)
            {
                SuggestedGroupsGettingTask.suggestedUserRouteGroupsGettingTask(homeLoc: homeLoc!, ofcLoc: ofcLoc!, receiver: self, viewController: self)
            }
        }
        else
        {
            if myGroups.isEmpty
            {
                noGroupsView.isHidden = false
                groupsTableView.isHidden = true
            }
        }
    }

    func getLocationFromFavouriteLocation(userFavouriteLocation : UserFavouriteLocation) -> Location?
    {
        let location : Location = Location()
        location.completeAddress = userFavouriteLocation.address
        location.shortAddress = userFavouriteLocation.address
        location.latitude = userFavouriteLocation.latitude!
        location.longitude = userFavouriteLocation.longitude!
        return location
    }
    func receivedSuggestedGroups(suggestedRidePathGroups : [UserRouteGroup]?)
    {
            if(suggestedRidePathGroups != nil && !suggestedRidePathGroups!.isEmpty)
            {
                self.noGroupsView.isHidden = true
                var finalSuggested : [UserRouteGroup]?
                if(suggestedRidePathGroups != nil && !suggestedRidePathGroups!.isEmpty)
                {
                    if !self.myGroups.isEmpty
                    {
                        finalSuggested = GroupsUtil.filterMyGroupsAndSuggestedGroups(suggestedRidePathGroups: suggestedRidePathGroups!, myGroups: self.myGroups)
                    }
                    else
                    {
                        finalSuggested = suggestedRidePathGroups
                    }
                }
                if (finalSuggested != nil && !finalSuggested!.isEmpty)
                {
                    self.groupsTableView.isHidden = false
                    self.suggestedGroups = finalSuggested!
                    self.groupsTableView.reloadData()
                }
            }
            else
            {
                if self.myGroups.isEmpty
                {
                    self.noGroupsView.isHidden = false
                    self.groupsTableView.isHidden = true
                }
                else
                {
                    self.noGroupsView.isHidden = true
                    self.groupsTableView.isHidden = false
                }
            }
    }
    func checkForTheSuggestedGroupPossibility(userRouteGroup : UserRouteGroup) -> Bool
    {
        if(homeLocation == nil && officeLocation == nil)
        {
            return false
        }
        else if(homeLocation != nil)
        {
            return GroupsUtil.isApplicableForSuggesting(userRouteGroup: userRouteGroup,fromLatitude: homeLocation!.latitude!,fromLongitude: homeLocation!.longitude!,toLatitude: 0,toLongitude: 0);
        }
        else if(officeLocation != nil)
        {
            return GroupsUtil.isApplicableForSuggesting(userRouteGroup: userRouteGroup,fromLatitude: 0,fromLongitude: 0,toLatitude: officeLocation!.latitude!,toLongitude: officeLocation!.longitude!)
        }
        return false
    }
    
    func initialiseHomeAndOfficeLocations() {
        let favLocations = UserDataCache.getInstance()?.getFavoriteLocations()
        if favLocations!.isEmpty == true{
            homeLocation = nil
            officeLocation = nil
        } else {
            retrieveHomeAndOfficeLocationsFromFavourites(favLocations: favLocations!)
        }
    }
    func retrieveHomeAndOfficeLocationsFromFavourites(favLocations :[UserFavouriteLocation])
    {
        AppDelegate.getAppDelegate().log.debug("")
        for favLocation in favLocations{
            if GroupsUtil.checkWhetherHomeLocation(locationNmae: favLocation.name!)
            {
                self.homeLocation = favLocation
            }
            else if GroupsUtil.checkWhetherOfficeLocation(locationNmae: favLocation.name!)
            {
                self.officeLocation = favLocation
            }
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func joinBtnTapped(_ sender: Any) {
        if suggestedGroups.count <= (sender as AnyObject).tag{
            return
        }
        let suggestedGroup = suggestedGroups[(sender as AnyObject).tag]
        UserRouteGroupJoin.groupJoin(foundGroup: suggestedGroup, receiver : self)
    }
    func joinedRidePathGroup(joinedGroup : UserRouteGroup)
    {
        self.myGroups = UserDataCache.getInstance()!.getUserRouteGroups()

        for index in 0...suggestedGroups.count - 1{
            if joinedGroup.id == suggestedGroups[index].id
            {
                suggestedGroups.remove(at: index)
                break
            }
        }
        groupsTableView.isHidden = false
        self.groupsTableView.reloadData()
    }
    func userJoinedThisGroupAlready()
    {
        UIApplication.shared.keyWindow?.makeToast( Strings.user_joined_group)
    }
}
