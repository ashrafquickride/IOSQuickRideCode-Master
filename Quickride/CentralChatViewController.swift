//
//  CentralChatViewController.swift
//  Quickride
//
//  Created by Halesh on 18/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CentralChatViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var navigationView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var backButton: CustomUIButton!
    
    @IBOutlet weak var searchButton: CustomUIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newContactButton: UIButton!
    
    @IBOutlet weak var noChatsView: UIView!
    
    
    //MARK: Propertise
    private var centralChatViewModel = CentralChatViewModel()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        backButton.changeBackgroundColorBasedOnSelection()
        searchButton.changeBackgroundColorBasedOnSelection()
    }
    override func viewWillAppear(_ animated: Bool) {
        ImageUtils.setTintedIcon(origImage: UIImage(named: "ic_chat")!, imageView: newContactButton.imageView!, color: UIColor.white)
        loadAllCentralChats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func loadAllCentralChats(){
        centralChatViewModel.getAllAvailableChatsToShowInCentralChat(groupChatListener: self, personalChatListener: self, userGroupChatListner: self)
        if centralChatViewModel.centralChatList.isEmpty{
            tableView.isHidden = true
            noChatsView.isHidden = false
        }else{
            tableView.isHidden = false
            noChatsView.isHidden = true
            sortCentralChats()
        }
    }
    
    private func sortCentralChats(){
        var activeCentralChats = [CentralChat]()
        var inActiveCentralChats = [CentralChat]()
        centralChatViewModel.centralChatSearchedList.removeAll()
        for centralChat in centralChatViewModel.centralChatList{
            if centralChat.lastUpdateTime != nil{
                activeCentralChats.append(centralChat)
            }else{
                inActiveCentralChats.append(centralChat)
            }
        }
        activeCentralChats.sort(by: { $0.lastUpdateTime! > $1.lastUpdateTime!})
        centralChatViewModel.centralChatSearchedList.append(contentsOf: activeCentralChats)
        centralChatViewModel.centralChatSearchedList.append(contentsOf: inActiveCentralChats)
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func newContactTapped(_ sender: Any) {
        let chatSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.conversationContactsViewController) as! ConversationSegmentedViewController
        chatSelectionViewController.isFromCentralChat = true
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: chatSelectionViewController, animated: false)
    }
    
    @IBAction func startSharingRideTapped(_ sender: Any) {
        centralChatViewModel.removeListeners()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchBar.isHidden = false
        searchBar.showsCancelButton = true
        navigationView.isHidden = true
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        centralChatViewModel.removeListeners()
        self.navigationController?.popViewController(animated: false)
        
    }
}
//MARK: UITableViewDataSource
extension CentralChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return centralChatViewModel.centralChatSearchedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "CentralChatTableViewCell", for: indexPath) as! CentralChatTableViewCell
        if centralChatViewModel.centralChatSearchedList.endIndex <= indexPath.row{
            return cell
        }
        let chat = centralChatViewModel.centralChatSearchedList[indexPath.row]
        var gender: String?
        if chat.chatType == CentralChat.PERSONAL_CHAT{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : chat.uniqueId))
            gender = contact?.contactGender
        }
        cell.initializeChatCell(centralChat: chat, contactGender: gender)
        return cell
    }
}

//MARK: UITableViewDelegate
extension CentralChatViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let chat = centralChatViewModel.centralChatSearchedList[indexPath.row]
        if chat.chatType == CentralChat.PERSONAL_CHAT{
            moveToPersonalChatController(uniqueId: chat.uniqueId)
        }else if chat.chatType == CentralChat.USER_GROUP_CHAT{
            moveToUserGroupChatController(uniqueId: chat.uniqueId)
        }else if chat.chatType == CentralChat.RIDE_JOIN_GROUP_CHAT{
            moveToRideJoinGroupChatController(uniqueId: chat.uniqueId)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(netHex: 0xe9e9e9)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
    
    private func moveToPersonalChatController(uniqueId: Double?){
        let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatConversationDialogue.isFromCentralChat = true
        chatConversationDialogue.initializeDataBeforePresentingView(ride: nil,  userId: uniqueId ?? 0, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: chatConversationDialogue, animated: false)
    }
    
    private func moveToRideJoinGroupChatController(uniqueId: Double?){
        guard let riderRideId = uniqueId else { return }
        let groupChatViewController  = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
        groupChatViewController.initailizeGroupChatView(riderRideID: riderRideId, isFromCentralChat: true)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: groupChatViewController, animated: false)
    }
    
    private func moveToUserGroupChatController(uniqueId: Double?){
        guard let groupToPass = UserDataCache.getInstance()?.getGroupWithGroupId(groupId: uniqueId) else { return }
        let userGroupChatViewController = UIStoryboard(name: "ConversationChat", bundle: nil).instantiateViewController(withIdentifier: "UserGroupChatViewController") as! UserGroupChatViewController
        userGroupChatViewController.initializeDataBeforePresenting(group: groupToPass)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: userGroupChatViewController, animated: false)
    }
}

//MARK: UISearchBarDelegate
extension CentralChatViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        centralChatViewModel.centralChatSearchedList.removeAll()
        if searchText.isEmpty == true{
            centralChatViewModel.centralChatSearchedList = centralChatViewModel.centralChatList
        }else{
            for chat in centralChatViewModel.centralChatList{
                if chat.name!.localizedCaseInsensitiveContains(searchText){
                    centralChatViewModel.centralChatSearchedList.append(chat)
                }
            }
        }
        if centralChatViewModel.centralChatSearchedList.isEmpty == true && centralChatViewModel.centralChatSearchedList.isEmpty == true{
            noChatsView.isHidden = false
            tableView.isHidden = true
        }else{
            noChatsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        dismissSearchbar()
    }
    
    func dismissSearchbar(){
        searchBar.isHidden = true
        navigationView.isHidden = false
        centralChatViewModel.centralChatSearchedList.removeAll()
        centralChatViewModel.centralChatSearchedList = centralChatViewModel.centralChatList
        sortCentralChats()
        tableView.reloadData()
    }
}
//MARK: GroupChatMessageListener
extension CentralChatViewController: GroupChatMessageListener{
    func newChatMessageRecieved(newMessage: GroupChatMessage) {
        RidesGroupChatCache.getInstance()?.putUnreadMessageFlagOfARide(rideId: newMessage.rideId)
        centralChatViewModel.updatePerticularRideJoinGroupInCentralChat(newMessage: newMessage)
        sortCentralChats()
    }
    
    func chatMessagesInitializedFromSever() {}
    
    func handleException() {}
}

//MARK: ConversationReceiver
extension CentralChatViewController: ConversationReceiver{
    func receiveConversationMessage(conversationMessage: ConversationMessage) {
        guard let sourceId = conversationMessage.sourceId else { return }
        ConversationCache.getInstance().putUnreadMessageFlagOfUser(sourceId: sourceId)
        centralChatViewModel.updatePerticularContactInCentralChat(conversationMessage: conversationMessage)
        sortCentralChats()
    }
    
    func receiveConversationMessageStatus(statusMessage: ConversationMessage) {}
}
//MARK: GroupConversationListener
extension CentralChatViewController: GroupConversationListener{
    func newChatMessageRecieved(newMessage: GroupConversationMessage) {
        UserGroupChatCache.getInstance()?.putUnreadMessageFlagOfAGroup(groupId: newMessage.groupId)
        centralChatViewModel.upadtePerticularUserGroupInCentralChat(newMessage: newMessage)
        sortCentralChats()
    }
}
