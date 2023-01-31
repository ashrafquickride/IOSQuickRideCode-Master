//
//  UserGroupChatSelectionViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 3/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class UserGroupChatSelectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
     var topViewController : ConversationSegmentedViewController?
    var groups = [Group]()
    var searchedGroups = [Group]()
    
    
    @IBOutlet weak var searchText: UISearchBar!
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    @IBOutlet weak var noGroupsView: UIView!
    
    
    private var modelLessDialogue: ModelLessDialogue?

    override func viewDidLoad() {
        
        if UserDataCache.getInstance()?.joinedGroups != nil{
            groups = UserDataCache.getInstance()!.joinedGroups
        }
        
        if groups.isEmpty{
            self.groupsTableView.isHidden = true
            self.noGroupsView.isHidden = false
        }else{
            self.groupsTableView.isHidden = false
            self.noGroupsView.isHidden = true
            self.reArrangeTheGroupsList(groupsList: groups)
        }
        searchText.delegate = self
    }
    
    func searchForGroups( searchText: String) {
        groupsTableView.delegate = nil
        groupsTableView.dataSource = nil
        
        searchedGroups.removeAll()
        if searchText.isEmpty == true{
            searchedGroups = groups
        }else{
            for group in groups{
                if group.name!.starts(with: searchText){
                    searchedGroups.append(group)
                }
            }
        }
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        
        if searchedGroups.isEmpty == true{
            noGroupsView.isHidden = false
            groupsTableView.isHidden = true
        }else{
            noGroupsView.isHidden = true
            groupsTableView.isHidden = false
            self.groupsTableView.reloadData()
        }
    }
    
    @IBAction func createGroupClicked(_ sender: Any) {
        
        let myGroupsViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyGroupsViewController") as! MyGroupsViewController
        self.navigationController?.pushViewController(myGroupsViewController, animated: false)
    }
    
    func reArrangeTheGroupsList(groupsList : [Group])
    {
        groups.removeAll()
        searchedGroups.removeAll()
        
        var lastMessages =  [GroupConversationMessage]()
        var groupsWithOutMessages = [Group]()
        for group in groupsList {
            let lastConversationMessage = UserGroupChatCache.getInstance()?.getLastMessageOfGroup(groupId: group.id)
            if lastConversationMessage != nil{
                lastMessages.append(lastConversationMessage!)
            }else{
                groupsWithOutMessages.append(group)
            }
        }
        lastMessages.sort(by: { $0.time > $1.time})
        self.groupsTableView.delegate = nil
        self.groupsTableView.dataSource = nil
        for message in lastMessages {
            for group in groupsList{
                if message.groupId == group.id{
                    groups.append(group)
                    break
                }
            }
        }
        self.groups.append(contentsOf: groupsWithOutMessages)
        self.searchedGroups = self.groups
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
        self.groupsTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refershGroups()
    }
    func refershGroups() {
        groups = UserDataCache.getInstance()!.joinedGroups
            if groups.isEmpty{
                self.groupsTableView.isHidden = true
                self.noGroupsView.isHidden = false
            }else{
                self.groupsTableView.isHidden = false
                self.noGroupsView.isHidden = true
                self.reArrangeTheGroupsList(groupsList: groups)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        groupsTableView.delegate = nil
        groupsTableView.dataSource = nil
        searchedGroups.removeAll()
        for group in groups{
            if group.name!.starts(with: searchText){
               searchedGroups.append(group)
            }
        }
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupsTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserGroupChatConversationCell", for: indexPath) as! UserGroupChatConversationCell
        if indexPath.row >= searchedGroups.count{
            return cell
        }
        let group = searchedGroups[indexPath.row]
        cell.userImageButton.tag = indexPath.row
        
        
        if group.imageURI != nil{
            cell.groupIcon.image = nil
            ImageCache.getInstance().setImageToView(imageView: cell.groupIcon, imageUrl: group.imageURI!, placeHolderImg: UIImage(named: "group_circle"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            cell.groupIcon.image = UIImage(named : "group_circle")
        }
        cell.groupName.text = group.name
        let lastMessage = UserGroupChatCache.getInstance()?.getLastMessageOfGroup(groupId: group.id)
        if lastMessage == nil{
            cell.lastMessage.text = nil
            cell.unreadMessagesView.isHidden = true
        }else{
            cell.lastMessage.text = lastMessage!.message
            
            let unReadMessageCount = UserGroupChatCache.getInstance()?.getUnreadMessageCountOfGroup(groupId: group.id)
            
            if unReadMessageCount == 0{
                cell.lastMessage.textColor = UIColor.black.withAlphaComponent(0.5)
                cell.unreadMessagesView.isHidden = true
            }else{
                cell.lastMessage.textColor = UIColor.black
                cell.unreadMessagesView.isHidden = false
                cell.unreadMessagesCount.text = String(describing: unReadMessageCount!)
                cell.unreadMessagesView.layer.cornerRadius = cell.unreadMessagesView.bounds.size.width/2.0
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchText.endEditing(false)
        if indexPath.row >= searchedGroups.count{
            return
        }
        let group = searchedGroups[indexPath.row]
        if UserDataCache.getInstance()!.getLoggedInUserProfile()?.numberOfRidesAsRider == 0{
            if RideManagementUtils.getUserQualifiedToDisplayContact(){
                moveToGroupChatView(group: group)
            }
            else{
                modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
                modelLessDialogue?.initializeViews(message: Strings.no_balance_reacharge_toast, actionText: Strings.link_caps)
                modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(payMentVC(_:))))
                modelLessDialogue?.isUserInteractionEnabled = true
                modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
                self.view.addSubview(modelLessDialogue!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.removeModelLessDialogue()
                }
            }
        }
        else{
            moveToGroupChatView(group: group)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func payMentVC(_ recognizer: UITapGestureRecognizer) {
        removeModelLessDialogue()
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }
    func moveToGroupChatView(group: Group){
        let groupChatViewController = UIStoryboard(name: "ConversationChat", bundle: nil).instantiateViewController(withIdentifier: "UserGroupChatViewController") as! UserGroupChatViewController
        groupChatViewController.initializeDataBeforePresenting(group: group)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: groupChatViewController, animated: false)
    }
    
    @IBAction func createGroupTapped(_ sender: Any) {
        
        let createGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        self.navigationController?.pushViewController(createGroupViewController, animated: false)
        
    }
    @IBAction func editGroupButtonTapped(_ sender: UIButton) {
        let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
        let selectedGroup = searchedGroups[sender.tag]
        groupInformationViewController.initializeDataBeforePresenting(group: selectedGroup)
        self.navigationController?.pushViewController(groupInformationViewController, animated: false)
    }
}
