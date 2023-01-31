//
//  ConversationSegmentedViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 3/21/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ConversationSegmentedViewController: UIViewController{
    
    @IBOutlet weak var contactsView: UIView!
    @IBOutlet weak var groupsView: UIView!
    @IBOutlet weak var routeGroupsView: UIView!
    @IBOutlet weak var callHistoryView: UIView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var conversationContactSelectViewController : ConversationContactSelectViewController?
    var userGroupChatSelectionViewController : UserGroupChatSelectionViewController?
    var routeGroupsViewController: RouteGroupsViewController?
    var callHistoryViewController: CallHistoryViewController?
    
    
    var segmentedControllerValue : Int?
    var isFromCentralChat = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsView.isHidden = false
        groupsView.isHidden = true
        callHistoryView.isHidden = true
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        AppDelegate.getAppDelegate().log.debug("prepareForSegue()")
        if segue.identifier == "ConversationContactSelectViewController"{
            conversationContactSelectViewController = segue.destination as? ConversationContactSelectViewController
            conversationContactSelectViewController?.topViewController = self
        }
        else if segue.identifier == "UserGroupChatSelectionViewController"{
            userGroupChatSelectionViewController = segue.destination as? UserGroupChatSelectionViewController
            userGroupChatSelectionViewController?.topViewController = self
        }
        else if segue.identifier == "RouteGroupsViewController"{
            routeGroupsViewController = segue.destination as? RouteGroupsViewController
            userGroupChatSelectionViewController?.topViewController = self
        }
        else if segue.identifier == "CallHistoryViewController" {
            callHistoryViewController = segue.destination as? CallHistoryViewController
        }
        
    }
    func changeTitle(title : String){
        navigationItem.title = title
    }
    
    @IBAction func segmentedControllerAction(_ sender: Any) {
        if segmentedController.selectedSegmentIndex == 0 {
            self.segmentedControllerValue = 0
            contactsView.isHidden = false
            groupsView.isHidden = true
            routeGroupsView.isHidden = true
            callHistoryView.isHidden = true
            changeTitle(title : Strings.select_contact_for_chat)
        }else if segmentedController.selectedSegmentIndex == 1{
            self.segmentedControllerValue = 1
            groupsView.isHidden = false
            contactsView.isHidden = true
            routeGroupsView.isHidden = true
            callHistoryView.isHidden = true
            changeTitle(title : Strings.select_group_for_chat)
        }
        else if segmentedController.selectedSegmentIndex == 2 {
            self.segmentedControllerValue = 2
            groupsView.isHidden = true
            contactsView.isHidden = true
            routeGroupsView.isHidden = false
            callHistoryView.isHidden = true
            changeTitle(title : Strings.my_route_group)
        }
        else if segmentedController.selectedSegmentIndex == 3 {
            self.segmentedControllerValue = 3
            groupsView.isHidden = true
            contactsView.isHidden = true
            routeGroupsView.isHidden = true
            callHistoryView.isHidden = false
            changeTitle(title : Strings.call_history)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
   ConversationCache.getInstance().removeParticularConversationListener(number: Double(QRSessionManager.getInstance()!.getUserId())!)
      self.navigationController?.popViewController(animated: false)
    }
    
}
