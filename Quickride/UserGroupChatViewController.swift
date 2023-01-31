//
//  UserGroupChatViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 3/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

class UserGroupChatViewController : UIViewController,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Outlets
    @IBOutlet weak var chatMessageText: UITextView!
    
    @IBOutlet weak var tblGroupChat: UITableView!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatTextMessageView: UIView!
    
    @IBOutlet weak var sendMessageViewHiehtConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var groupNameLabel: QRHeaderLabel!
    
    @IBOutlet weak var groupMembersLabel: UILabel!
    
    @IBOutlet weak var groupInfoView: UIStackView!
    
    @IBOutlet weak var commonMsgsCollectionView: UICollectionView!

    @IBOutlet weak var commonMsgCVHeight: NSLayoutConstraint!
    
    //MARK: Propertise
    var group : Group?
    var chatMessageArray = [GroupConversationMessage]()
    let cellSpacingHeight: CGFloat = 5
    var isKeyBoardVisible = false
    var commonMsgs = ["Who is going today?","Thanks for the ride"];

    func initializeDataBeforePresenting(group : Group){
        self.group = group
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UserGroupChatCache.getInstance()?.addUserGroupChatListener(groupId: group!.id, listener: self)
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.tblGroupChat.estimatedRowHeight = 80
        self.tblGroupChat.rowHeight = UITableView.automaticDimension
        self.tblGroupChat.setNeedsLayout()
        self.tblGroupChat.layoutIfNeeded()
        self.tblGroupChat.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(UserGroupChatViewController.handleSwipes(_:))))
        self.commonMsgsCollectionView.delegate = self
        self.commonMsgsCollectionView.dataSource = self
        self.groupNameLabel.text = self.group!.name
        self.groupMembersLabel.text = "\(self.group!.members.count) Memebers"
        let clientconfiguration = ConfigurationCache.getObjectClientConfiguration()
        if clientconfiguration.disableSendSMSForCompanyCode{
            chatTextMessageView.isHidden = true
            sendMessageViewHiehtConstraint.constant = 0
        }else{
            chatTextMessageView.isHidden = false
            sendMessageViewHiehtConstraint.constant = 62
        }
        UserGroupChatCache.getInstance()?.resetUnreadMessageOfGroup(groupId: group!.id)
        if Thread.isMainThread == true{
            setEditData()
        }else{
            DispatchQueue.main.sync(){
                self.setEditData()
            }
        }
        chatMessageArray = UserGroupChatCache.getInstance()!.getMessagesOfAGroup(groupId: group!.id)
        self.chatMessageArray.sort(by: { $0.time < $1.time})
        self.tblGroupChat.delegate = self
        self.tblGroupChat.dataSource = self
        self.tblGroupChat.reloadData()
        self.tblGroupChat.scrollToBottom(animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(UserGroupChatViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserGroupChatViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        groupInfoView.isUserInteractionEnabled = true
        groupInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupViewTapped(_:))))
    }
    @objc func groupViewTapped(_ gesture: UITapGestureRecognizer){
        let groupInformationViewController =  UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupInformationViewController") as! GroupInformationViewController
        groupInformationViewController.initializeDataBeforePresenting(group: self.group)
        self.navigationController?.pushViewController(groupInformationViewController, animated: false)
        
    }
    
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible {
            chatMessageText.endEditing(true)
            self.resignFirstResponder()
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            self.bottomSpaceConstraint.constant =  keyBoardSize.height
        }
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        sendMessageButton.isEnabled = false
        bottomSpaceConstraint.constant = 0
        commonMsgCVHeight.constant = 0
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.bottomSpaceConstraint.constant ==  0{
            self.bottomSpaceConstraint.constant =  280
        }
        commonMsgCVHeight.constant = 0
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageText.text.isEmpty == true {
            self.chatMessageText.text =  Strings.type_your_message
        }
        chatMessageText.endEditing(true)
        resignFirstResponder()
        if self.bottomSpaceConstraint.constant >  0{
            self.bottomSpaceConstraint.constant =  0
        }
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageText.text == nil || chatMessageText.text.isEmpty == true || chatMessageText.text == Strings.type_your_message{
            chatMessageText.text = ""
            chatMessageText.textColor = Colors.chatMsgTextColor
            sendMessageButton.isEnabled = false
        }else{
            sendMessageButton.isEnabled = true
        }
        addDoneButton(textView: textView)
        return true
    }
    
    func setEditData(){
        AppDelegate.getAppDelegate().log.debug("")
        self.chatMessageText.text = Strings.type_your_message
        chatMessageText.textColor = Colors.chatMsgTextColor
        chatMessageText.delegate = self
        sendMessageButton.isEnabled = false
    }
    func addDoneButton(textView: UITextView){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textView.inputAccessoryView = keyToolBar
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if(chatMessageText.text.isEmpty == true){
            sendMessageButton.isEnabled = false
            resignFirstResponder()
        }else if chatMessageText.text.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0{
            sendMessageButton.isEnabled = false
            commonMsgsCollectionView.isHidden = false
            commonMsgCVHeight.constant = 50
        }else{
            sendMessageButton.isEnabled = true
            commonMsgsCollectionView.isHidden = true
            commonMsgCVHeight.constant = 0
            
        }
    }
    
    // MARK: - TableView delegate and data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatMessage = chatMessageArray[indexPath.row]
        if  chatMessage.senderId != UserDataCache.getInstance()?.currentUser?.phoneNumber{
            let cell : UserGroupChatReceiveTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellReceive", for: indexPath) as! UserGroupChatReceiveTableViewCell
            cell.initailseChatData(chatMessage: chatMessage)
            return cell
        }else{
            let cell : UserGroupChatSenderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellSender", for: indexPath) as! UserGroupChatSenderTableViewCell
            cell.initializeChatData(chatMessage: chatMessage)
            return cell
        }
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        sendData(messageText: chatMessageText.text)
        self.chatMessageText.text = ""
        sendMessageButton.isEnabled = false
    }
    @IBAction func btnBackTapped(_ sender: Any) {
        NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_USER_GRP_CHAT, groupValue: StringUtils.getStringFromDouble(decimalNumber: group!.id))
        UserGroupChatCache.getInstance()?.removeUserGroupChatListener(groupId: group!.id)
        self.navigationController?.popViewController(animated: false)
        NotificationCenter.default.removeObserver(self)
    }
   
    
    func sendData(messageText: String){
        let user = UserDataCache.getInstance()?.currentUser
        if user == nil{
            return
        }
        AppDelegate.getAppDelegate().log.debug("")
        
        if QRReachability.isConnectedToNetwork() == false{
            chatMessageText.endEditing(false)
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
        }else{
            if MessageUtils.isMessageAllowedToDisplay(message: messageText, latitude: 0, longitude: 0){
                let message  = GroupConversationMessage(groupId: group!.id, senderId: user!.phoneNumber, senderName: user!.userName, message: messageText, time: NSDate().getTimeStamp())
                UserGroupChatCache.getInstance()?.addMessage(message: message)
                newChatMessageRecieved(newMessage: message)
                let jsondata : String = Mapper().toJSONString(message , prettyPrint: true)!
                let topicName = GroupConversationMessageMQTTListener.USER_GROUP_CHAT_TOPIC+StringUtils.getStringFromDouble(decimalNumber: group!.id)
                EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.publishMessage( topicName : topicName, mqttMessage: jsondata)
                GroupRestClient.sendGroupConversationMessage(message: message, viewController: self, handler: { (responseObject, error) in
                })
            }else{
                UIApplication.shared.keyWindow?.makeToast( "This message can't be send")
            }
           
        }
    }
}
//MARK: GroupConversationListener
extension UserGroupChatViewController: GroupConversationListener{
    func newChatMessageRecieved(newMessage: GroupConversationMessage) {
        AppDelegate.getAppDelegate().log.debug("\(newMessage)")
        chatMessageArray.append(newMessage)
        self.chatMessageArray.sort(by: { $0.time < $1.time})
        if Thread.isMainThread == true{
            tblGroupChat.reloadData()
            tblGroupChat.scrollToBottom(animated: true)
        }else{
            DispatchQueue.main.sync(){
                self.tblGroupChat.reloadData()
                self.tblGroupChat.scrollToBottom(animated: true)
            }
        }
    }
    
}
extension UserGroupChatViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
            let cell : CommonMsgsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CommonMsgsCollectionViewCell
            if commonMsgs.endIndex <= indexPath.row{
                return cell
            }
            cell.messageLbl.text = commonMsgs[indexPath.row]
        cell.msgView.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        cell.msgView.layer.shadowRadius = 3
        cell.msgView.layer.shadowOffset = CGSize(width: 0,height: 1)
        cell.msgView.layer.shadowOpacity = 1
            ViewCustomizationUtils.addBorderToView(view: cell.msgView, borderWidth: 1, color: UIColor(netHex: 0xE5E5E5))
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = commonMsgs[indexPath.row]
        sendData(messageText: message)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let label = UILabel(frame: CGRect.zero)
            label.text = commonMsgs[indexPath.item]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 25, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return commonMsgs.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
