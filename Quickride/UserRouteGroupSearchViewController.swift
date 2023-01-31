//
//  UserRouteGroupSearchViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/16/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit


class UserRouteGroupSearchViewController : UIViewController, UITableViewDelegate,UITableViewDataSource, ReceiveLocationDelegate, UserRouteGroupJoinReceiver, SuggestedGroupsReceiver {
    
    @IBOutlet weak var fromLocationEditText: UILabel!
    
    @IBOutlet weak var toLocationEditText: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var noGroupsFoundView: UIView!
    
    @IBOutlet weak var swapImageView: UIImageView!
    
    @IBOutlet weak var recommendedGroupsView: UIView!
    
    @IBOutlet weak var recommendedGroupsTableView: UITableView!
    
    @IBOutlet weak var createGroupBtn: UIButton!
    
    @IBOutlet weak var recommendedGroupsHeightConstraint: NSLayoutConstraint!
    
    var existedUserRouteGroups : [UserRouteGroup]?
    
    var foundGroups : [UserRouteGroup] = [UserRouteGroup]()
    var finalSuggested : [UserRouteGroup] = [UserRouteGroup]()
    
    var fromLocation : Location?
    var toLocation : Location?
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        searchButton.backgroundColor = Colors.mainButtonColor
        initializeFromAndToLocations()
        swapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserRouteGroupSearchViewController.swapLocations(_:))))
        fromLocationEditText.isUserInteractionEnabled = true
        toLocationEditText.isUserInteractionEnabled = true
        fromLocationEditText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserRouteGroupSearchViewController.fromLocationTapped(_:))))
        toLocationEditText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserRouteGroupSearchViewController.toLocationTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: searchButton, cornerRadius: 4.0)

        getExistedUserRouteGroups()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
    }

    func initializeFromAndToLocations()
    {
        if self.fromLocation != nil
        {
            self.fromLocationEditText.text = fromLocation!.shortAddress
        }
        else
        {
            fromLocationEditText.text = Strings.from_location_hint
            fromLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationEditText.font = fromLocationEditText.font.withSize(12)
        }
        if self.toLocation != nil
        {
            self.toLocationEditText.text = toLocation!.shortAddress
        }
        else
        {
            toLocationEditText.text = Strings.to_location_hint
            toLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationEditText.font = toLocationEditText.font.withSize(12)
        }
    }
    @objc func swapLocations(_ gesture : UITapGestureRecognizer) {
        
        let tempLocation = fromLocation
        fromLocation = toLocation
        toLocation = tempLocation
        
        if fromLocation == nil{
            fromLocationEditText.text = Strings.from_location_hint
            fromLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationEditText.font = fromLocationEditText.font.withSize(12)
        }else{
            fromLocationEditText.text = fromLocation!.shortAddress
            fromLocationEditText.textColor = Colors.locationTextColor
            fromLocationEditText.font = fromLocationEditText.font.withSize(15)
        }
        if toLocation == nil{
            toLocationEditText.text = Strings.to_location_hint
            toLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationEditText.font = toLocationEditText.font.withSize(12)
        }else{
            toLocationEditText.text = toLocation!.shortAddress
            toLocationEditText.textColor = Colors.locationTextColor
            toLocationEditText.font = toLocationEditText.font.withSize(15)
        }
    }
    func getExistedUserRouteGroups()
    {
        let userRouteGroups = UserDataCache.getInstance()?.getUserRouteGroups()
        if userRouteGroups != nil{
            existedUserRouteGroups = userRouteGroups
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.foundGroups.count
        }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SuggestedGroupsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SuggestedGroupsTableViewCell
        if self.foundGroups.endIndex <= indexPath.row{
            return cell
        }
        let foundGroup  = self.foundGroups[indexPath.row]

        cell.fromLocationLabel.text = foundGroup.fromLocationAddress
        cell.toLocationLabel.text = foundGroup.toLocationAddress
        cell.groupNameLbel.text = foundGroup.groupName
        cell.noOfMembers.text = String(format: Strings.members, arguments: [String(foundGroup.memberCount!)])
        cell.joinBtn.tag = indexPath.row
        if foundGroup.imageURI != nil
        {
            ImageCache.getInstance().setImageToView(imageView: cell.groupImage, imageUrl: foundGroup.imageURI!, placeHolderImg: UIImage(named: "group_new_small"),imageSize: ImageCache.DIMENTION_TINY)
        }
        else
        {
            cell.groupImage.image = UIImage(named: "group_new_small")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.foundGroups.endIndex <= indexPath.row{
            return
        }
        let recommendedGroup = self.foundGroups[indexPath.row]
        let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
         userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup: recommendedGroup, enableJoinOption: true, isDisplayMode: true, isFromRideView: false, fromLocation: nil, toLocation: nil, rideId: nil, rideType: nil)
        
        self.navigationController?.pushViewController(userRouteGroupCreateVC, animated: false)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    @IBAction func createGroupBtnTapped(_ sender: Any) {
        let userRouteGroupCreateVC : UserRouteGroupCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserRouteGroupCreationViewController") as! UserRouteGroupCreationViewController
        userRouteGroupCreateVC.initializeDataBeforePresenting(selectedUserRouteGroup: nil, enableJoinOption: false, isDisplayMode: false, isFromRideView: false, fromLocation: fromLocation, toLocation: toLocation, rideId: nil, rideType: nil)
        self.navigationController?.pushViewController(userRouteGroupCreateVC, animated: false)
    }
    
    func receiveSelectedLocation(location: Location, requestLocationType: String) {AppDelegate.getAppDelegate().log.debug("")
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
    }
    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            self.fromLocation = location
            fromLocationEditText.text = location.shortAddress
            fromLocationEditText.textColor = Colors.locationTextColor
            fromLocationEditText.font = fromLocationEditText.font.withSize(15)
        }else{
            self.toLocation = location
            toLocationEditText.text = location.shortAddress
            toLocationEditText.textColor = Colors.locationTextColor
            toLocationEditText.font = toLocationEditText.font.withSize(15)
        }
    }

    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("")
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            self.fromLocation = nil
            fromLocationEditText.text = Strings.from_location_hint
            fromLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            fromLocationEditText.font = fromLocationEditText.font.withSize(12)
        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            self.toLocation = nil
            toLocationEditText.text = Strings.to_location_hint
            toLocationEditText.textColor = Colors.locationTextColor.withAlphaComponent(0.6)
            toLocationEditText.font = toLocationEditText.font.withSize(12)
        }
        if self.fromLocation == nil && self.toLocation == nil
        {
            self.recommendedGroupsView.isHidden = true
        }
    }

    @IBAction func searchBtnTapped(_ sender: Any) {
        if (fromLocation == nil && toLocation == nil) || (fromLocationEditText.text!.isEmpty && toLocationEditText.text!.isEmpty)
        {
            MessageDisplay.displayAlert(messageString: Strings.enter_from_to,  viewController: self,handler: nil)
        }
        else
        {
            SuggestedGroupsGettingTask.suggestedUserRouteGroupsGettingTask(homeLoc: fromLocation, ofcLoc: toLocation, receiver: self, viewController: self)
        }
    }
    func receivedSuggestedGroups(suggestedRidePathGroups : [UserRouteGroup]?)
    {
            if(self.existedUserRouteGroups != nil && !self.existedUserRouteGroups!.isEmpty)
            {
                self.finalSuggested = GroupsUtil.filterMyGroupsAndSuggestedGroups(suggestedRidePathGroups: suggestedRidePathGroups!,myGroups: self.existedUserRouteGroups!)
            }
            else
            {
                self.finalSuggested = suggestedRidePathGroups!
            }
            if (!self.finalSuggested.isEmpty)
            {
                self.recommendedGroupsView.isHidden = false
                self.foundGroups = self.finalSuggested
                self.noGroupsFoundView.isHidden = true
                self.createGroupBtn.isHidden = false
                self.recommendedGroupsTableView.reloadData()
                self.adjustHeightOfTableView()
            }
            else if(self.finalSuggested.isEmpty)
            {
                self.noGroupsFoundView.isHidden = false
            }
            else
            {
                self.noGroupsFoundView.isHidden = false
                self.recommendedGroupsView.isHidden = true
            }
    }
    @objc func fromLocationTapped(_ gesture : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let changeLocationVC: ChangeLocationViewController = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.ORIGIN, currentSelectedLocation: fromLocation, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)

    }
    @objc func toLocationTapped(_ gesture : UITapGestureRecognizer) {

        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let changeLocationVC: ChangeLocationViewController = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.DESTINATION, currentSelectedLocation: toLocation, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    @IBAction func joinBtnTapped(_ sender: Any) {
        UserRouteGroupJoin.groupJoin(foundGroup: self.foundGroups[(sender as AnyObject).tag], receiver : self)
    }
    func joinedRidePathGroup(joinedGroup : UserRouteGroup)
    {
        self.navigationController?.popViewController(animated: false)
    }
    func userJoinedThisGroupAlready()
    {
        UIApplication.shared.keyWindow?.makeToast( Strings.user_joined_group)
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func adjustHeightOfTableView()
    {
        recommendedGroupsHeightConstraint.constant = recommendedGroupsHeightConstraint.constant - recommendedGroupsTableView.frame.size.height
        recommendedGroupsTableView.frame = CGRect(x: recommendedGroupsTableView.frame.origin.x, y: recommendedGroupsTableView.frame.origin.y, width: recommendedGroupsTableView.frame.size.width, height: recommendedGroupsTableView.contentSize.height)
        recommendedGroupsHeightConstraint.constant = recommendedGroupsHeightConstraint.constant + recommendedGroupsTableView.contentSize.height
    }
}
