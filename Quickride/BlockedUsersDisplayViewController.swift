//
//  BlockedUsersDisplayViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 1/6/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
    import Foundation
    import UIKit
    import ObjectMapper
    
    class BlockedUsersDisplayViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UserUnBlockReceiver, UserBlockReceiver, ContactSelectionReceiver
    {
        @IBOutlet weak var blockUserBtn: UIButton!
        
        @IBOutlet weak var noBlockedUsersView: UIView!
        
        @IBOutlet weak var blockedUsersTableView: UITableView!
        var blockedUserList  : [BlockedUser] = [BlockedUser]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
           
          
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        override func viewWillAppear(_ animated: Bool) {
            AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
            if self.navigationController != nil{
                AppDelegate.getAppDelegate().log.debug("navigation bar displayed")
                self.navigationController!.isNavigationBarHidden = false
            }
            blockedUserList = UserDataCache.getInstance()!.getAllBlockedUsers()
            if blockedUserList.isEmpty
            {
                self.noBlockedUsersView.isHidden = false
                self.blockedUsersTableView.isHidden = true
            }else{
              self.noBlockedUsersView.isHidden = true
              self.blockedUsersTableView.isHidden = false
              blockedUsersTableView.delegate = self
              blockedUsersTableView.dataSource = self
              blockedUsersTableView.reloadData()
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell : BlockedUsersCell = tableView.dequeueReusableCell(withIdentifier: "BlockedUsersCell", for: indexPath as IndexPath) as! BlockedUsersCell
            if self.blockedUserList.endIndex <= indexPath.row{
                return cell
            }
            let blockedUser  = self.blockedUserList[indexPath.row]
            cell.blockedUserImageView.image = nil
            cell.blockedUserName.text = blockedUser.name
            ImageCache.getInstance().setImageToView(imageView: cell.blockedUserImageView, imageUrl: blockedUser.imageUri, gender: blockedUser.gender!,imageSize: ImageCache.DIMENTION_TINY)

            
            cell.initializeViews(blockedUserList: self.blockedUserList, index: indexPath.row)
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            AppDelegate.getAppDelegate().log.debug("")
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.blockedUserList.count
        }
        
        func displayBlockedUserPopUpMenu(blockedUser : BlockedUser)
        {
            let alertController : BlockAlertController = BlockAlertController(viewController: self) { (result) -> Void in
                if result == Strings.unblock{
                  UserUnBlockTask.unBlockUser(phoneNumber: blockedUser.blockedUserId!,viewController : self,receiver : self)
                }
            }
            alertController.unblockAlertAction()
            alertController.cancelAlertAction()
            
            alertController.showAlertController()
        }
        @IBAction func blockUserBtnTapped(_ sender: Any) {
            
           let conversationContactsViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ConversationContactSelectViewController") as! ConversationContactSelectViewController

            conversationContactsViewController.initializeDataBeforePresentingView(requireConversationContacts: false, requireRidePartners: true, isNavBarRequired: true,moveToContacts : true,receiver: self)
            self.navigationController?.pushViewController(conversationContactsViewController, animated: false)
        }
        @IBAction func backBtnTapped(_ sender: Any) {
            if self.navigationController == nil{
                self.dismiss(animated: false, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        }
        
        @IBAction func menuBtnTapped(_ sender: Any) {
            let contact = self.blockedUserList[(sender as AnyObject).tag]
  
            displayBlockedUserPopUpMenu(blockedUser: contact)
        }
        
        func userUnBlocked()
        {
            self.initializeView()
        }
        
        func contactSelected(contact : Contact)
        {
            var blockedReason = [String]()
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            for feedackMsg in clientConfiguration.etiquetteList{
                blockedReason.append(feedackMsg.feedbackMsg!)
            }
            let textViewAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "TextViewAlertController") as! TextViewAlertController
            textViewAlertController.initializeDataBeforePresentingView(title: Strings.confirm_block + " " + contact.contactName + " ?", positiveBtnTitle: Strings.no_caps, negativeBtnTitle: Strings.yes_caps, placeHolder: Strings.placeholder_reason, textAlignment: NSTextAlignment.left, isCapitalTextRequired: false, isDropDownRequired: true, dropDownReasons: blockedReason, existingMessage: nil,viewController: self, handler: { (text, result) in
                if Strings.yes_caps == result
                {
                    let reason = text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if reason!.count == 0{
                        MessageDisplay.displayAlert(messageString: Strings.suspend_reason,  viewController: self,handler: nil)
                        self.contactSelected(contact : contact)
                        return
                    }
                    UserBlockTask.blockUser(phoneNumber: Double(contact.contactId!)!, viewController : self, receiver : self, isContactNumber: false, reason: text)
                }
            })
            self.navigationController?.view.addSubview(textViewAlertController.view!)
            self.navigationController?.addChild(textViewAlertController)
        }
        func userBlocked()
        {
            self.navigationController?.popViewController(animated: false)
            self.initializeView()
        }
        func initializeView()
        {
           self.blockedUserList = UserDataCache.getInstance()!.getAllBlockedUsers()
            blockedUsersTableView.delegate = nil
            blockedUsersTableView.dataSource = nil
            if(self.blockedUserList.isEmpty)
            {
                self.noBlockedUsersView.isHidden = false
                self.blockedUsersTableView.isHidden = true
            }
            else{
                self.noBlockedUsersView.isHidden = true
                self.blockedUsersTableView.isHidden = false
                blockedUsersTableView.delegate = self
                blockedUsersTableView.dataSource = self
                self.blockedUsersTableView.reloadData()
            }
        }
        
        func userBlockingFailed(responseError : ResponseError)
        {
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self,handler: nil)
        }

    }
