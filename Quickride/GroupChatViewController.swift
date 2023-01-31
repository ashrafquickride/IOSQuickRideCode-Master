
//
//  GroupChatViewController.swift
//  Quickride
//
//  Created by Anki on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import MessageUI

class GroupChatViewController: UIViewController,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,GroupChatMessageListener,RideParticipantsListener,UICollectionViewDelegateFlowLayout,ReceiveLocationDelegate,chatClearDelegate,ConversationReceiver,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var chatMessageText: UITextView!
    
    @IBOutlet weak var tblGroupChat: UITableView!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: UIView!
    
    @IBOutlet weak var messageTextViewHieghtConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideParticipantsCollectionView: UICollectionView!
    
    @IBOutlet weak var commonMsgsCollectionView: UICollectionView!
    
    @IBOutlet weak var commonMsgsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var groupChatIcon: UIImageView!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var allUserTextLbl: UILabel!
    
    @IBOutlet weak var groupUnreadMsgView: UIView!
    
    @IBOutlet weak var groupUnreadMsgLbl: UILabel!
        
    @IBOutlet weak var backButton: CustomUIButton!
    
    @IBOutlet weak var callButton: CustomUIButton!
    
    @IBOutlet weak var rideComplitionView: UIView!
    @IBOutlet weak var unreadCountView: QuickRideCardView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var centralChatButton: CustomUIButton!
    @IBOutlet weak var shareLocButton: UIButton!
    
    var currentRiderRideID : Double=0
    var chatMessageArray = [GroupChatMessage]()
    var chatHistory = [ConversationMessage]()
    var rideParticipants :[RideParticipant] = [RideParticipant]()
    var isKeyBoardVisible = false
    var commonMsgs = [String]()
    var presentConatctUserBasicInfo : UserBasicInfo?
    var selectedParticipant = -1
    var unreadMessages = [Double: Int]()
    var groupUnreadMsg = 0
    private var isFromCentralChat = false
    
    func initailizeGroupChatView(riderRideID: Double,isFromCentralChat: Bool){
        self.currentRiderRideID = riderRideID
        self.isFromCentralChat = isFromCentralChat
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        backButton.changeBackgroundColorBasedOnSelection()
        callButton.changeBackgroundColorBasedOnSelection()
        RidesGroupChatCache.getInstance()?.addRideGroupChatListener(rideId: currentRiderRideID, listener: self)
        getRideParticipantImage(currentRideId: currentRiderRideID)
        if selectedParticipant == -1{
            menuButton.isHidden = true
            callButton.isHidden = true
            chatTableView.isHidden = true
        }else{
            menuButton.isHidden = false
            checkCallOptionIsAvailableOrNot()
            chatTableView.isHidden = false
        }
        QuickRideProgressSpinner.stopSpinner()
    }
    
    private func checkCallOptionIsAvailableOrNot(){
        var callSupport = true
        if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_ALWAYS {
            callSupport = true
        }else if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : self.presentConatctUserBasicInfo?.userId))
            if (contact != nil && contact!.contactType == Contact.RIDE_PARTNER) || RideValidationUtils.checkUserJoinedInUpCommingRide(userId: presentConatctUserBasicInfo?.userId ?? 0){
                callSupport = true
            }else{
                callSupport = false
            }
        }else{
            callSupport = false
        }
        if callSupport{
            callButton.isHidden = false
            callButton.tintColor = .black
        }else{
            callButton.isHidden = false
            let callImage = UIImage(named: "icon_call")
            let tintedImage = callImage?.withRenderingMode(.alwaysTemplate)
            callButton.setImage(tintedImage, for: .normal)
            callButton.tintColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        var clientconfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientconfiguration == nil{
            clientconfiguration = ClientConfigurtion()
        }
        if clientconfiguration!.disableSendSMSForCompanyCode{
            messageTextView.isHidden = true
            messageTextViewHieghtConstraint.constant = 0
        }else{
            messageTextView.isHidden = false
            messageTextViewHieghtConstraint.constant = 57
        }
        self.tblGroupChat.estimatedRowHeight = 80
        self.tblGroupChat.rowHeight = UITableView.automaticDimension
        self.chatTableView.estimatedRowHeight = 80
        self.chatTableView.rowHeight = UITableView.automaticDimension
        
        self.tblGroupChat.setNeedsLayout()
        self.tblGroupChat.layoutIfNeeded()
        self.chatTableView.setNeedsLayout()
        self.chatTableView.layoutIfNeeded()
        self.tblGroupChat.delegate = self
        self.tblGroupChat.dataSource = self
        self.rideParticipantsCollectionView.delegate = self
        self.rideParticipantsCollectionView.dataSource = self
        self.commonMsgsCollectionView.delegate = self
        self.commonMsgsCollectionView.dataSource = self
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GroupChatViewController.handleSwipes(_:))))
        groupChatIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupChatViewController.groupChatIconTapped(_:))))
        ViewCustomizationUtils.addBorderToView(view: groupChatIcon, borderWidth: 4, color: UIColor(netHex: 0x333333))
        allUserTextLbl.textColor = UIColor(netHex: 0x333333)
        titleLabel.text = Strings.group_chat
        groupUnreadMsgView.isHidden = true
        ViewCustomizationUtils.addBorderToView(view: groupUnreadMsgView, borderWidth: 2, color: UIColor.white)
        RidesGroupChatCache.getInstance()?.resetUnreadMessageCountOfARide(rideId: currentRiderRideID)
        showCentralChatIcon()
        if Thread.isMainThread == true{
            setEditData()
        }else{
            DispatchQueue.main.sync(){
                self.setEditData()
            }
        }
        
    }
    private func showCentralChatIcon(){
        if isFromCentralChat{
            centralChatButton.isHidden = true
            unreadCountView.isHidden = true
        }else{
            centralChatButton.isHidden = false
            let unReadCount = MessageUtils.getUnreadCountOfChat()
            if unReadCount > 0{
                unreadCountView.isHidden = false
                unreadCountLabel.text = String(unReadCount)
            }else{
                unreadCountView.isHidden = true
            }
        }
    }
    private func showDefaultMessageDependingUponRideStatus(riderRideStatus: String?,currentUserStatus: String?, rideType: String?){
        if rideType == Ride.RIDER_RIDE{
            if currentUserStatus == Ride.RIDE_STATUS_SCHEDULED{
              commonMsgs = Strings.rider_groupChat_before_start
            }else if currentUserStatus == Ride.RIDE_STATUS_STARTED{
              commonMsgs = Strings.rider_groupChat_after_start
            }else if currentUserStatus == Ride.RIDE_STATUS_COMPLETED{
                rideComplitionView.isHidden = false
                commonMsgsCollectionView.isHidden = true
                commonMsgsCollectionViewHeightConstraint.constant = 0
            }else{
                commonMsgs = Strings.common_msg_for_group_chat
            }
        }else{
            if riderRideStatus == Ride.RIDE_STATUS_SCHEDULED{
               commonMsgs = Strings.passenger_groupChat_before_start
            }else if riderRideStatus == Ride.RIDE_STATUS_STARTED && currentUserStatus == Ride.RIDE_STATUS_SCHEDULED{
               commonMsgs = Strings.passenger_groupChat_started_butNotPicUp
            }else if riderRideStatus == Ride.RIDE_STATUS_STARTED && currentUserStatus == Ride.RIDE_STATUS_STARTED{
                commonMsgs = Strings.passenger_groupChat_inTheCar
            }else if currentUserStatus == Ride.RIDE_STATUS_COMPLETED{
                rideComplitionView.isHidden = false
                commonMsgsCollectionView.isHidden = true
                commonMsgsCollectionViewHeightConstraint.constant = 0
            }else{
                commonMsgs = Strings.common_msg_for_group_chat
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        if chatMessageText.text.isEmpty{
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
        }else{
            sendMessageButton.isHidden = false
            shareLocButton.isHidden = true
        }
        bottomSpaceConstraint.constant = 0
        self.view.layoutIfNeeded()
        commonMsgsCollectionView.isHidden = false
        commonMsgsCollectionViewHeightConstraint.constant = 90
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupChatViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupChatViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
   
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageText.text.isEmpty == true {
            self.chatMessageText.text =  Strings.type_your_message
        }
        chatMessageText.endEditing(true)
        resignFirstResponder()
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageText.text == nil || chatMessageText.text.isEmpty == true || chatMessageText.text == Strings.type_your_message{
            chatMessageText.text = ""
            chatMessageText.textColor = Colors.chatMsgTextColor
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
        }else{
            sendMessageButton.isHidden = false
            shareLocButton.isHidden = true
        }
        commonMsgsCollectionView.isHidden = true
        commonMsgsCollectionViewHeightConstraint.constant = 0
        addDoneButton(textView: textView)
        return true
    }
    
    func setEditData(){
        AppDelegate.getAppDelegate().log.debug("")
        self.chatMessageText.text = Strings.type_your_message
        chatMessageText.textColor = Colors.chatMsgTextColor
        chatMessageText.delegate = self
        sendMessageButton.isHidden = true
        shareLocButton.isHidden = false
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
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
            resignFirstResponder()
        }else if chatMessageText.text.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0{
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
        }else{
            sendMessageButton.isHidden = false
            shareLocButton.isHidden = true
        }
    }
    func getRideParticipantImage(currentRideId : Double){
        AppDelegate.getAppDelegate().log.debug("")
        QuickRideProgressSpinner.startSpinner()
        MyActiveRidesCache.getInstance(userId: QRSessionManager.getInstance()?.getUserId())!.getRideParicipants(riderRideId: currentRideId,rideParticipantsListener: self)
    }
    
    func getRideParticipants(rideParticipants : [RideParticipant]){
        AppDelegate.getAppDelegate().log.debug("\(rideParticipants)")
        QuickRideProgressSpinner.stopSpinner()
        var filteredRideParticipants = [RideParticipant]()
        var rideType: String?
        var riderRideStatus: String?
        var currentUserRideStatus: String?
        for rideParticipant in rideParticipants{
            if rideParticipant.userId == Double(QRSessionManager.getInstance()!.getUserId()){
                if rideParticipant.rider{
                    rideType = Ride.RIDER_RIDE
                    currentUserRideStatus = rideParticipant.status
                }else{
                    rideType = Ride.PASSENGER_RIDE
                    currentUserRideStatus = rideParticipant.status
                }
                continue
            }
            filteredRideParticipants.append(rideParticipant)
            if rideParticipant.rider{
                riderRideStatus = rideParticipant.status
            }else{
                riderRideStatus = rideParticipant.status
            }
        }
        self.rideParticipants = filteredRideParticipants
        for rideParticipant in self.rideParticipants{
            ConversationCache.getInstance().addParticularConversationListener(number: rideParticipant.userId, conversationReceiver: self)
        }
        rideParticipantsCollectionView.reloadData()
        if RidesGroupChatCache.getInstance() != nil{
            if let messages =  RidesGroupChatCache.getInstance()!.getGroupChatMessagesOfARide(rideId: currentRiderRideID){
                chatMessageArray = messages
                self.chatMessageArray.sort(by: { $0.chatTime < $1.chatTime})
                if chatMessageArray.isEmpty == false{
                    self.tblGroupChat.delegate = self
                    self.tblGroupChat.dataSource = self
                    tblGroupChat.reloadData()
                    tblGroupChat.scrollToBottom(animated: true)
                }
            }else{
                RidesGroupChatCache.getInstance()?.loadGroupChatMessagesOfARide(rideId: currentRiderRideID)
            }
        }
        showDefaultMessageDependingUponRideStatus(riderRideStatus: riderRideStatus, currentUserStatus: currentUserRideStatus, rideType: rideType)
    }
   
    func onFailure(responseObject: NSDictionary?, error: NSError?) {
        AppDelegate.getAppDelegate().log.debug("")
        QuickRideProgressSpinner.stopSpinner()
        if RidesGroupChatCache.getInstance() != nil{
            
            if let messages = RidesGroupChatCache.getInstance()!.getGroupChatMessagesOfARide(rideId: currentRiderRideID){
                chatMessageArray = messages
                self.chatMessageArray.sort(by: { $0.chatTime < $1.chatTime})
                if(!chatMessageArray.isEmpty){
                    tblGroupChat.reloadData()
                    tblGroupChat.scrollToBottom(animated: true)
                }
            }else{
                RidesGroupChatCache.getInstance()?.loadGroupChatMessagesOfARide(rideId: currentRiderRideID)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("")
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblGroupChat{
            if section == 0{
                return 1
            }else{
                return chatMessageArray.count
            }
        }else{
            if section == 0{
                return 1
            }else{
                return chatHistory.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblGroupChat{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellText", for: indexPath)
                return cell
            }else{
                AppDelegate.getAppDelegate().log.debug("message :"+self.chatMessageArray[indexPath.row].toJSONString()!)
                let phone = String(chatMessageArray[indexPath.row].phonenumber)
                if  ("\(phone)".components(separatedBy: ".")[0]) != QRSessionManager.sharedInstance?.getUserId(){
                    let cell : ChatTableViewReceiveCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewReceiveCell
                    if chatMessageArray.endIndex <= indexPath.row{
                        return cell
                    }
                    var hideImageAndName = false
                    if indexPath.row != 0 && chatMessageArray[indexPath.row].phonenumber == chatMessageArray[indexPath.row - 1].phonenumber{
                        hideImageAndName = true
                    }
                    cell.initializeReceivedCellData(rideParticipants: rideParticipants, groupChatMessage: chatMessageArray[indexPath.row],viewController: self,isImageHideRequire: hideImageAndName)
                    return cell
                }
                else {
                    let cell : ChatTableViewSenderCell = tableView.dequeueReusableCell(withIdentifier: "CellSender", for: indexPath) as! ChatTableViewSenderCell
                    if chatMessageArray.endIndex <= indexPath.row{
                        return cell
                    }
                    cell.initializeSenderCellData(groupChatMessage: chatMessageArray[indexPath.row],view: self.view)
                    
                    return cell
                }
            }
        }else{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellTextPersonal", for: indexPath)
                return cell
            }else{
                let conversationMessage = chatHistory[indexPath.row]
                let phone = String(conversationMessage.sourceId!)
                if  ("\(phone)".components(separatedBy: ".")[0]) != QRSessionManager.sharedInstance?.getUserId(){
                    let cell =  tableView.dequeueReusableCell(withIdentifier: "PersonalChatTableViewReceiveCell", for: indexPath) as! PersonalChatTableViewReceiveCell
                    if chatHistory.endIndex <= indexPath.row{
                        return cell
                    }
                    cell.initializeReceivedData(conversationMessage: conversationMessage, viewController: self)
                    return cell
                }else{
                    let cell : PersonalChatTableViewSenderCell = tableView.dequeueReusableCell(withIdentifier: "PersonalChatTableViewSenderCell", for: indexPath) as! PersonalChatTableViewSenderCell
                    if chatHistory.endIndex <= indexPath.row{
                        return cell
                    }
                    cell.initializePersonalSenderCellData(conversationMessage: conversationMessage, view: self.view)
                    return cell
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    
    func showingUnreadMsgcountForRideParticipant(senderId: Double){
        var count = unreadMessages[senderId]
        if count == nil {
           count = 0
        }
        unreadMessages[senderId] = count! + 1
        rideParticipantsCollectionView.reloadData()
    }
    func newChatMessageRecieved(newMessage: GroupChatMessage) {
        AppDelegate.getAppDelegate().log.debug("\(newMessage)")
        chatMessageArray.append(newMessage)
        if selectedParticipant != -1 {
            groupUnreadMsg += 1
            groupUnreadMsgView.isHidden = false
            groupUnreadMsgLbl.text = String(groupUnreadMsg)
        }else{
            groupUnreadMsg = 0
            groupUnreadMsgView.isHidden = true
            self.chatMessageArray.sort(by: { $0.chatTime < $1.chatTime})
            if Thread.isMainThread == true{
                tblGroupChat.reloadData()
                tblGroupChat.scrollToBottom(animated: true)
            }else{
                DispatchQueue.main.sync(){
                    self.tblGroupChat.reloadData()
                    tblGroupChat.scrollToBottom(animated: true)
                }
            }
        }
    }
    func receiveConversationMessage( conversationMessage conversation: ConversationMessage) {
        AppDelegate.getAppDelegate().log.debug("\(conversation)")
        if selectedParticipant == -1 || presentConatctUserBasicInfo!.userId != conversation.sourceId{
            showingUnreadMsgcountForRideParticipant(senderId: conversation.sourceId!)
        }else{
            chatHistory.append(conversation)
            refreshChatMessageTableView()
            let messageAckSenderTask = MessageAckSenderTask(conversationMessage: conversation, status:ConversationMessage.MSG_STATUS_READ)
            messageAckSenderTask.publishMessage()
        }
        
    }
    func receiveConversationMessageStatus(statusMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(statusMessage)")
        if selectedParticipant != -1 && statusMessage.destId == presentConatctUserBasicInfo!.userId{
            checkAndCreateConversationObject()
            refreshChatMessageTableView()
        }
    }
    func checkAndCreateConversationObject(){
        AppDelegate.getAppDelegate().log.debug("")
           let conversation = ConversationCache.getInstance().getConversationObject(userBasicInfo: presentConatctUserBasicInfo!)
            chatHistory = conversation.messages
    }
    func sendData(message : String, location : Location?){
        AppDelegate.getAppDelegate().log.debug("")
        
        if QRReachability.isConnectedToNetwork() == false{
            chatMessageText.endEditing(true)
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
        }else{
            let conversationMessage = createConvMessage(message : message,location: location)
            addSentMessageToAdapter(conversationMessage: conversationMessage)
            ConversationMessageSendingTask(viewController: self, conversationMessage: conversationMessage).publishMessage()
        }
    }
    func createConvMessage(message : String, location : Location?) -> ConversationMessage{
        AppDelegate.getAppDelegate().log.debug("")
        let conversationMessage = ConversationMessage()
        conversationMessage.message = message
        conversationMessage.destId = presentConatctUserBasicInfo?.userId
        conversationMessage.sourceId = Double((QRSessionManager.getInstance()?.getUserId())!)
        conversationMessage.msgStatus = ConversationMessage.MSG_STATUS_NEW
        conversationMessage.msgType = ConversationMessage.MSG_TYPE_NEW
        conversationMessage.time = Double(StringUtils.getStringFromDouble(decimalNumber : NSDate().timeIntervalSince1970*1000))
        if location != nil
        {
            conversationMessage.address = location!.completeAddress
            conversationMessage.latitude = location!.latitude
            conversationMessage.longitude = location!.longitude
        }
        return conversationMessage
    }
    func addSentMessageToAdapter(conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        chatMessageText.text = ""
        
        let conversation = ConversationCache.getInstance().getConversationObject(userBasicInfo : presentConatctUserBasicInfo!)
        if conversation.messages.isEmpty{
            ConversationCache.getInstance().storeNewContact(userId: conversationMessage.sourceId!)
        }
        conversation.messages.append(conversationMessage)
        
        chatHistory.append(conversationMessage)
        ConversationCachePersistenceHelper.addPersonalChatMessage(conversationMessage: conversationMessage, phone: presentConatctUserBasicInfo!.userId!)
        refreshChatMessageTableView()
    }
    func refreshChatMessageTableView()
    {
        AppDelegate.getAppDelegate().log.debug("")
        if Thread.isMainThread == true{
            self.chatHistory.sort(by: { $0.time! < $1.time!})
            chatTableView.reloadData()
            tblGroupChat.scrollToBottom(animated: true)
        }else{
            DispatchQueue.main.sync(){
                self.chatHistory.sort(by: { $0.time! < $1.time!})
                self.chatTableView.reloadData()
                tblGroupChat.scrollToBottom(animated: true)
            }
        }
        
    }
    @IBAction func btnSendTapped(_ sender: Any) {
        if selectedParticipant == -1{
            sendData(text: chatMessageText.text, location: nil)
            self.chatMessageText.text = ""
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
        }else{
            AppDelegate.getAppDelegate().log.debug("")
            sendData(message: chatMessageText.text, location: nil)
            sendMessageButton.isHidden = true
            shareLocButton.isHidden = false
        }
    }
 
    @IBAction func reportBtnClicked(_ sender: Any) {
        
        let screen = UIScreen.main
        
        if let window = UIApplication.shared.keyWindow {
            
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            HelpUtils.sendEmailToSupport(viewController: self, image: image,listOfIssueTypes: Strings.list_of_report_types)
        }
        
    }
    @IBAction func btnBackTapped(_ sender: Any) {
        NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: "GroupChat", groupValue: String(currentRiderRideID))
        RidesGroupChatCache.getInstance()?.removeRideGroupChatListener(rideId: currentRiderRideID)
        for rideParticipant in rideParticipants{               ConversationCache.getInstance().removeParticularConversationListener(number: rideParticipant.userId)
        }
        self.navigationController?.popViewController(animated: false)
        RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = nil
    }
   
    
    
    func sendData(text: String,location : Location?){
        AppDelegate.getAppDelegate().log.debug("")
        let groupChatMessage  = GroupChatMessage()
        groupChatMessage.message = text
        groupChatMessage.chatTime = NSDate().timeIntervalSince1970*1000
        groupChatMessage.userName =  UserDataCache.sharedInstance!.getUserName()
        groupChatMessage.rideId = currentRiderRideID
        groupChatMessage.phonenumber = Double((QRSessionManager.sharedInstance?.getUserId())!)!
        if location != nil{
            groupChatMessage.latitude = location!.latitude
            groupChatMessage.longitude = location!.longitude
            groupChatMessage.address = location!.completeAddress!
        }
        RidesGroupChatCache.singleCacheInstance?.addMessage(groupChatMessage: groupChatMessage, rideId: currentRiderRideID)
        
        newChatMessageRecieved(newMessage: groupChatMessage)
        if QRReachability.isConnectedToNetwork() == false{
            chatMessageText.endEditing(false)
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
        }else{
	    groupChatMessage.uniqueID = QuickRideMessageEntity.GROUP_CHAT_ENTITY + "_" + StringUtils.getStringFromDouble(decimalNumber: groupChatMessage.phonenumber) + "_" + groupChatMessage.uniqueID!
            if MessageUtils.isMessageAllowedToDisplay(message: groupChatMessage.message, latitude: groupChatMessage.latitude, longitude: groupChatMessage.longitude){
                let jsondata : String = Mapper().toJSONString(groupChatMessage , prettyPrint: true)!
                AppDelegate.getAppDelegate().log.debug(jsondata)
                let topicName = RideGroupChatMqttListener.RIDE_GROUP_CHAT_TOPIC+String(currentRiderRideID).components(separatedBy: ".")[0]
                EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.publishMessage( topicName : topicName, mqttMessage: jsondata)
            }
            ChatRestClient.sendGroupChatMessageToOtherParticipantsViaGcm(chatMsg: groupChatMessage, viewController: self, handler: { (responseObject, error) in            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
    
    func handleException() {
    }
    func chatMessagesInitializedFromSever(){
        if let messages = RidesGroupChatCache.getInstance()!.getGroupChatMessagesOfARide(rideId: currentRiderRideID){
            chatMessageArray = messages
            self.chatMessageArray.sort(by: { $0.chatTime < $1.chatTime})
            if(!chatMessageArray.isEmpty){
                self.tblGroupChat.delegate = self
                self.tblGroupChat.dataSource = self
                tblGroupChat.reloadData()
                tblGroupChat.scrollToBottom(animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rideParticipantsCollectionView{
            return rideParticipants.count
        }else{
            return commonMsgs.count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if collectionView == rideParticipantsCollectionView{
            let cell : RideParticipantsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RideParticipantsCollectionViewCell
            let rideParticipant = self.rideParticipants[indexPath.row]
            cell.initializeParticipantsCellData(rideParticipant: rideParticipant,index: indexPath.row,unreadMsg: unreadMessages[rideParticipant.userId])
            if selectedParticipant == indexPath.row{
               ViewCustomizationUtils.addBorderToView(view: cell.participantImageView, borderWidth: 4, color: UIColor(netHex: 0x333333))
            }
            return cell
        }else{
            let cell : CommonMsgsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CommonMsgsCollectionViewCell
            if commonMsgs.endIndex <= indexPath.row{
                return cell
            }
            cell.messageLbl.text = commonMsgs[indexPath.row]
            ViewCustomizationUtils.addBorderToView(view: cell.msgView, borderWidth: 1, color: UIColor(netHex: 0xE5E5E5))
            cell.msgView.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
            cell.msgView.layer.shadowRadius = 3
            cell.msgView.layer.shadowOffset = CGSize(width: 0,height: 1)
            cell.msgView.layer.shadowOpacity = 1
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == rideParticipantsCollectionView{
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? RideParticipantsCollectionViewCell{
                ViewCustomizationUtils.addBorderToView(view: selectedCell.participantImageView, borderWidth: 4, color: UIColor(netHex: 0x333333))
                selectedCell.participantNameLbl.textColor = UIColor(netHex: 0x333333)
                selectedCell.unReadMsgView.isHidden = true
            }
            if let prevSelectedCell = collectionView.cellForItem(at: IndexPath(item: selectedParticipant, section: 0)) as? RideParticipantsCollectionViewCell{
                if selectedParticipant != indexPath.row{
                    ViewCustomizationUtils.addBorderToView(view: prevSelectedCell.participantImageView, borderWidth: 0, color: UIColor.init(netHex: 0xFFFFFF))
                    prevSelectedCell.participantNameLbl.textColor = UIColor.black.withAlphaComponent(0.6)
                }
            }
            
            selectedParticipant = indexPath.row
            let rideParticipant = rideParticipants[indexPath.row]
            presentConatctUserBasicInfo = UserBasicInfo(userId : rideParticipant.userId, gender : rideParticipant.gender,userName : rideParticipant.name!, imageUri: rideParticipant.imageURI, callSupport : rideParticipant.callSupport!)
            checkCallOptionIsAvailableOrNot()
            titleLabel.text = Strings.CHAT
            menuButton.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: groupChatIcon, borderWidth: 0, color: UIColor.init(netHex: 0xffffff))
            allUserTextLbl.textColor = UIColor.black.withAlphaComponent(0.6)
            tblGroupChat.isHidden = true
            chatTableView.isHidden = false
            checkAndCreateConversationObject()
            self.chatTableView.delegate = self
            self.chatTableView.dataSource = self
            self.tblGroupChat.delegate = self
            self.tblGroupChat.dataSource = self
            chatTableView.reloadData()
            tblGroupChat.scrollToBottom(animated: true)
            unreadMessages[rideParticipant.userId] = 0
        }else{
            if selectedParticipant == -1{
                let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CommonMsgsCollectionViewCell
                sendData(text: cell.messageLbl.text!, location: nil)
            }else{
                let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CommonMsgsCollectionViewCell
                sendData(message: cell.messageLbl.text!, location: nil)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == commonMsgsCollectionView{
            let label = UILabel(frame: CGRect.zero)
            label.text = commonMsgs[indexPath.item]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 25, height: 40)
        }else{
            return CGSize(width: (collectionView.bounds.width - 20)/3, height: collectionView.bounds.height)
        }
    }
    
    
    @objc func groupChatIconTapped(_ sender:UISwipeGestureRecognizer){
        ViewCustomizationUtils.addBorderToView(view: groupChatIcon, borderWidth: 4, color: UIColor(netHex: 0x333333))
        selectedParticipant = -1
        chatTableView.isHidden = true
        tblGroupChat.isHidden = false
        menuButton.isHidden = true
        callButton.isHidden = true
        rideParticipantsCollectionView.reloadData()
        tblGroupChat.reloadData()
        tblGroupChat.scrollToBottom(animated: true)
        allUserTextLbl.textColor = UIColor(netHex: 0x333333)
        titleLabel.text = Strings.group_chat
        groupUnreadMsgView.isHidden = true
        groupUnreadMsg = 0
        
    }
    
    @IBAction func currentLocTapped(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Common", bundle: nil)
            let selectLocationFromMap = storyboard.instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location :nil, locationType: ChangeLocationViewController.ORIGIN, actnBtnTitle: Strings.send_location, isFromEditRoute: false, dropLocation: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }
    
    @IBAction func callOptionTapped(_ sender: Any) {
        if let callDisableMsg = getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
       AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: self.presentConatctUserBasicInfo!.userId), refId: Strings.group_chat,name: self.presentConatctUserBasicInfo!.name ?? "", targetViewController: self)
    }
    
    private func getErrorMessageForCall() -> String?{
        if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }else if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : self.presentConatctUserBasicInfo?.userId))
            if (contact != nil && contact!.contactType != Contact.RIDE_PARTNER) && !RideValidationUtils.checkUserJoinedInUpCommingRide(userId: presentConatctUserBasicInfo?.userId ?? 0){
                return Strings.call_joined_partner_msg
            }
        }
        return nil
    }
    
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("")
        if selectedParticipant == -1{
            self.sendData(text : String(describing: location.completeAddress!),location: location)
        }else{
            self.sendData(message : String(describing: location.completeAddress!),location: location)
        }
    }
    
    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("")
    }
    @IBAction func menuButtonTapped(_ sender: Any) {
        var callSupport = true
        if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_ALWAYS {
            callSupport = true
        }else if presentConatctUserBasicInfo!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : self.presentConatctUserBasicInfo?.userId))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                callSupport = true
            }else{
                callSupport = false
            }
        }else{
            callSupport = false
        }
        let chatAlertController = ConversationChatAlertController(viewController: self, presentConatctUserBasicInfo : self.presentConatctUserBasicInfo, supportCall : callSupport)
        chatAlertController.profileAlertAction()
        chatAlertController.reportToUserAction()
        if chatHistory.count >= 1
        {
            chatAlertController.clearChatAction(delegate: self)
            
        }
        chatAlertController.addRemoveAlertAction()
        chatAlertController.showAlertController()
    }
    func clearConversation(){
        chatHistory.removeAll()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.reloadData()
    }
    
    @IBAction func centralChatButtonTapped(_ sender: Any) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CentralChatViewController") as! CentralChatViewController
        self.navigationController?.pushViewController(centralChatViewController, animated: false)
    }
}
