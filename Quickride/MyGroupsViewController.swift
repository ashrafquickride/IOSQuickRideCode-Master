//
//  MyGroupsViewController.swift
//  Quickride
//
//  Created by rakesh on 3/8/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

class MyGroupsViewController : UIViewController, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{

@IBOutlet weak var groupsTableView: UITableView!
@IBOutlet weak var noGroupsView: UIView!
@IBOutlet weak var groupsSearchBar: UISearchBar!

    
var groupsList : [Group] = [Group]()
var groupsListForRecommGrps : [Group] = [Group]()
var sections = [Strings.user_groups,Strings.recommended_user_groups]
var isFromSearchView = false
    
override func viewDidLoad() {
    super.viewDidLoad()
    groupsSearchBar.delegate = self
    self.groupsList = UserDataCache.getInstance()!.getAllJoinedGroups()
}

    override func viewWillAppear(_ animated: Bool) {
        self.initializeView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return Strings.recommended_user_groups
            }
        case 1:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return Strings.user_groups
            }
        default: return nil
        }
      return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
         return self.groupsListForRecommGrps.count
        }else{
         return self.groupsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
              let cell : GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath as IndexPath) as! GroupTableViewCell
            if self.groupsListForRecommGrps.endIndex <= indexPath.row{
                return cell
            }
            let group = groupsListForRecommGrps[indexPath.row]
            cell.groupName.text = group.name
            cell.noOfMembersLabel.text = String(format: Strings.members, arguments: [String(group.members.count)])
            if group.imageURI != nil{
                ImageCache.getInstance().setImageToView(imageView: cell.groupImage, imageUrl: group.imageURI!, placeHolderImg: UIImage(named:"group_circle"),imageSize: ImageCache.DIMENTION_TINY)
            }else{
                cell.groupImage.image = UIImage(named:"group_circle")
            }
            cell.joinStatusLabel.isHidden = true
            cell.joinStatusLblWidthConstraint.constant = 0
            return cell
        }else{
            let cell : GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath as IndexPath) as! GroupTableViewCell
            if self.groupsList.endIndex <= indexPath.row{
                return cell
            }
            let joinedGroup = self.groupsList[indexPath.row]
            cell.groupName.text = joinedGroup.name
            if joinedGroup.imageURI != nil{
                 ImageCache.getInstance().setImageToView(imageView: cell.groupImage, imageUrl: joinedGroup.imageURI!, placeHolderImg: UIImage(named:"group_circle"),imageSize: ImageCache.DIMENTION_TINY)
            }else{
                cell.groupImage.image = UIImage(named:"group_circle")
            }
            cell.noOfMembersLabel.text = String(format: Strings.members, arguments: [String(joinedGroup.getConfirmedMembersOfAGroup().count)])
            if joinedGroup.creatorId == Double(QRSessionManager.getInstance()!.getUserId())!{
                 cell.joinStatusLabel.isHidden = true
                 cell.joinStatusLblWidthConstraint.constant = 0
            }else if joinedGroup.currentUserStatus == GroupMember.MEMBER_STATUS_CONFIRMED{
                 cell.joinStatusLabel.isHidden = true
                 cell.joinStatusLblWidthConstraint.constant = 0
            }else{
                cell.joinStatusLabel.isHidden = false
                cell.joinStatusLblWidthConstraint.constant = 120
                cell.joinStatusLabel.text = Strings.request_pending
                cell.joinStatusLabel.textColor = UIColor.red
                cell.joinStatusLabel.textAlignment = .center
            }
          
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if self.groupsListForRecommGrps.endIndex <= indexPath.row{
                return
            }
            let selectedGroup = groupsListForRecommGrps[indexPath.row]
            if selectedGroup == nil {
                return
            }
            let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
            groupInformationViewController.initializeDataBeforePresenting(group: selectedGroup)
            self.navigationController?.pushViewController(groupInformationViewController, animated: false)
        }else{
            if self.groupsList.endIndex <= indexPath.row{
                return
            }
            let selectedGroup  = self.groupsList[indexPath.row]
            if selectedGroup == nil {
                return
            }
            let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
            groupInformationViewController.initializeDataBeforePresenting(group: selectedGroup)
            self.navigationController?.pushViewController(groupInformationViewController, animated: false)
        }
       tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
   
    func getGroups(searchText : String?){
    
        GroupRestClient.getGroupsForSearch(groupNameSearchIdentifier: searchText, viewController: self,handler:{ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let groups = Mapper<Group>().mapArray(JSONObject: responseObject!["resultData"])
                let filteredGroups = self.filterFetchedGroups(groups: groups!)
                self.groupsListForRecommGrps = filteredGroups
                if self.groupsList.isEmpty && self.groupsListForRecommGrps.isEmpty
                {
                    self.noGroupsView.isHidden = false
                    self.groupsTableView.isHidden = true
                }
                else{
                    self.noGroupsView.isHidden = true
                    self.groupsTableView.isHidden = false
                    self.groupsTableView.delegate = self
                    self.groupsTableView.dataSource = self
                    self.groupsTableView.reloadData()
                }
            }
        })
    }

   
    @IBAction func AddGroupBtnTapped(_ sender: Any) {
        let createGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        self.navigationController?.pushViewController(createGroupViewController, animated: false)
    }
 
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.showsCancelButton = true
        groupsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        groupsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func filterFetchedGroups(groups : [Group]) -> [Group]{
    
        var filteredGrps = [Group]()
        for fetchedGroup in groups {
            var isExistingGrp = false
            
            for userGroup in groupsList{
                if fetchedGroup.id == userGroup.id{
                   isExistingGrp = true
                   break
                }
            }
            if !isExistingGrp{
               filteredGrps.append(fetchedGroup)
            }
        }
     return filteredGrps
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
      if searchText.isEmpty{
          groupsTableView.delegate = nil
          groupsTableView.dataSource = nil
           groupsList = UserDataCache.getInstance()!.getAllJoinedGroups()
            self.getGroups(searchText: nil)
        }else{
            
            if searchText.count % 3 == 0{
                groupsTableView.delegate = nil
                groupsTableView.dataSource = nil
                groupsList.removeAll()
                groupsListForRecommGrps.removeAll()
                self.getGroups(searchText: searchText)
                for group in UserDataCache.getInstance()!.getAllJoinedGroups(){
                    if group.name!.localizedCaseInsensitiveContains(searchText){
                        groupsList.append(group)
                    }
                }
                groupsTableView.delegate = self
                groupsTableView.dataSource = self
                groupsTableView.reloadData()
            }
           
        }
   
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked() \(searchBar)")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func initializeView(){
        
        groupsTableView.delegate = nil
        groupsTableView.dataSource = nil
        self.groupsList = UserDataCache.getInstance()!.getAllJoinedGroups()
        groupsList.sort(by: { $0.lastRefreshedTime.compare($1.lastRefreshedTime as Date) == ComparisonResult.orderedDescending })
        getGroups(searchText: nil)
    }

    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
