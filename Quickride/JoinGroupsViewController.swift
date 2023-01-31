//
//  JoinGroupsViewController.swift
//  Quickride
//
//  Created by rakesh on 3/14/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class JoinGroupsViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    
    @IBOutlet weak var groupsSearchBar: UISearchBar!
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var noGroupsView: UIView!
    
    var groupList = [Group]()
    var searchText : String?
    
    override func viewDidLoad() {
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        getGroups(searchText: searchText)
        groupsSearchBar.delegate = self
   }
    
    func getGroups(searchText : String?){
       QuickRideProgressSpinner.startSpinner()
        GroupRestClient.getGroupsForSearch(groupNameSearchIdentifier: searchText, viewController: self,handler:{ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
            let groups = Mapper<Group>().mapArray(JSONObject: responseObject!["resultData"])
             self.groupList = groups!
             self.initializeViews()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self)
            }
        })
    }
   
    func initializeViews(){
        
        groupsTableView.delegate = nil
        groupsTableView.dataSource = nil
        
        if self.groupList.isEmpty{
          groupsTableView.isHidden = true
          noGroupsView.isHidden = false
          groupsTableView.delegate = self
          groupsTableView.dataSource = self
          groupsTableView.reloadData()
        }else{
           groupsTableView.isHidden = false
           noGroupsView.isHidden = true
           groupsTableView.delegate = self
           groupsTableView.dataSource = self
           groupsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let group = groupList[indexPath.row]
             let cell : GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath as IndexPath) as! GroupTableViewCell
            cell.groupName.text = group.name
            cell.noOfMembersLabel.text = String(format: Strings.members, arguments: [String(group.members.count)])
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedGroup  = self.groupList[indexPath.row]
       
        let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
        groupInformationViewController.initializeDataBeforePresenting(group: selectedGroup, isFromJoinGroupView: true)
        self.navigationController?.pushViewController(groupInformationViewController, animated: false)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count >= 3{
            self.getGroups(searchText: searchText)
        }else if searchText.isEmpty{
            self.getGroups(searchText: nil)
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
    
    @IBAction func addGrpBtnTapped(_ sender: Any) {
    self.openGroupCreationPage()
    
    }
    func openGroupCreationPage(){
        let createGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        self.navigationController?.pushViewController(createGroupViewController, animated: false)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    
    
}
