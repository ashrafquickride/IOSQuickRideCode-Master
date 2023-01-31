//
//  ChatConversationDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import MessageUI

protocol ContactRefreshListener {
    func refershContacts()
}

class ChatConversationDialogue : UIViewController,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource,ConversationReceiver, chatClearDelegate, ReceiveLocationDelegate,MFMailComposeViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var SendButton: UIButton!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatMessageTextView: UITextView!
    
    @IBOutlet weak var sendView: UIView!
    
    @IBOutlet weak var callingTipLbl: UILabel!
    
    @IBOutlet weak var callingTipLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendMessageViewHieghtConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commonMsgsCollectionView: UICollectionView!
    
    @IBOutlet weak var commonMsgsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var callButton: CustomUIButton!
    @IBOutlet weak var centralChatButton: CustomUIButton!
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var unreadChatView: QuickRideCardView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCompanyNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var shareLocationIcon: UIButton!
    @IBOutlet weak var userVerificationImage: UIImageView!
    
    var isKeyBoardVisible = false
    var keyboardHeight : CGFloat = 0.0
    var chatHistory : [ConversationMessage] = [ConversationMessage]()
    var userId: Double?
    var listener : ContactRefreshListener?
    var isRideStarted = false
    var commonMsgs : [String]?
    var isFromQuickShare = false
    var isFromTaxipool = false
    private var conversationChatVM = ConversationChatViewModel()
    private var hideDefaultMessages = false
    var isFromCentralChat = false
    
    func initializeDataBeforePresentingView(ride: Ride?, userId: Double,isRideStarted : Bool,listener : ContactRefreshListener?){
        AppDelegate.getAppDelegate().log.debug("\(userId)")
        self.userId = userId
        self.isRideStarted = isRideStarted
        conversationChatVM = ConversationChatViewModel(ride: ride)
        self.listener = listener
    }
    
    
    override func viewDidLoad(){
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        ConversationCache.currentChatUserId = userId!
        observeNotifications()
        ConversationCache.getInstance().resetUnreadMessageCountOfUser(sourceId: userId!)
        QuickRideProgressSpinner.startSpinner()
        conversationChatVM.getUserbasicInfo(userId: userId ?? 0)
        setUpUI()
        if UserDataCache.getInstance()?.getUserRecentRideType() == Ride.RIDER_RIDE{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDER_CHAT_INITIATED, params: ["userId": QRSessionManager.getInstance()?.getUserId(),"chatInitiatedWith" : userId], uniqueField: User.FLD_USER_ID)
        }else{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PASSENGER_CHAT_INITIATED, params: ["userId": userId], uniqueField: User.FLD_USER_ID)
        }
     }
    
    private func setUpUI() {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.disableSendSMSForCompanyCode{
            sendView.isHidden = true
            sendMessageViewHieghtConstraint.constant = 0
            callButton.isHidden = true
        }else{
            sendView.isHidden = false
            sendMessageViewHieghtConstraint.constant = 60
            callButton.isHidden = false
        }
        if isFromQuickShare || hideDefaultMessages || isFromTaxipool{
            commonMsgsCollectionView.isHidden = true
            commonMsgsCollectionViewHeightConstraint.constant = 0
        }else{
            commonMsgsCollectionView.isHidden = false
            commonMsgsCollectionViewHeightConstraint.constant = 90
        }
     }
    
    private func checkCallOptionIsAvailableOrNot(){
        var callSupport = true
        if UserProfile.SUPPORT_CALL_ALWAYS == conversationChatVM.userBasicInfo?.callSupport{
            callSupport = true
        }else if UserProfile.SUPPORT_CALL_AFTER_JOINED == conversationChatVM.userBasicInfo?.callSupport{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: userId))
            if (contact != nil && contact!.contactType == Contact.RIDE_PARTNER) || RideValidationUtils.checkUserJoinedInUpCommingRide(userId: userId ?? 0){
                callSupport = true
            }else{
                callSupport = false
            }
        }else{
            callSupport = false
        }
        if callSupport{
           callButton.isHidden = false
        }else{
            let callImage = UIImage(named: "icon_call")
            let tintedImage = callImage?.withRenderingMode(.alwaysTemplate)
            callButton.setImage(tintedImage, for: .normal)
            callButton.tintColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    func continueToInitialization(){
        if !self.isRideStarted{
            callingTipLbl.isHidden = true
            callingTipLblHeightConstraint.constant = 10
        }else{
            callingTipLbl.isHidden = false
            callingTipLblHeightConstraint.constant = 34
            callingTipLbl.text = String(format: Strings.calling_tip_text, arguments: [conversationChatVM.userBasicInfo?.name ?? ""])
        }
        self.commonMsgsCollectionView.delegate = self
        self.commonMsgsCollectionView.dataSource = self
        commonMsgs = conversationChatVM.getChatSuggestions(userId: userId)
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        self.chatTableView.estimatedRowHeight = 80
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.setNeedsLayout()
        self.chatTableView.layoutIfNeeded()
        self.chatTableView.contentInset = UIEdgeInsets(top: 0,left:  0,bottom:  0,right:  0)
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ChatConversationDialogue.handleSwipes(_:))))
        checkAndCreateConversationObject()
        if chatHistory.isEmpty == false{
            for index in chatHistory.reversed() {
                if (index.destId != userId && index.msgStatus != ConversationMessage.MSG_STATUS_READ) {
                    let messageAckSenderTask = MessageAckSenderTask(conversationMessage: index, status: ConversationMessage.MSG_STATUS_READ)
                    messageAckSenderTask.publishMessage()
                    break
                }
            }
        }
        self.chatHistory.sort(by: { $0.time! < $1.time!})
        if Thread.isMainThread == true{
            chatTableView.reloadData()
            setEditData()
        }else{
            DispatchQueue.main.sync(){
                self.chatTableView.reloadData()
                self.setEditData()
            }
        }
       
    }
    
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible {
            chatMessageTextView.endEditing(true)
            self.resignFirstResponder()
        }
    }
    
    func setEditData(){
        AppDelegate.getAppDelegate().log.debug("")
        self.chatMessageTextView.text =  Strings.type_your_message
        chatMessageTextView.textColor = Colors.chatMsgTextColor
        chatMessageTextView.delegate = self
        shareLocationIcon.isHidden = false
        SendButton.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        
        ConversationCache.getInstance().addParticularConversationListener(number: userId!, conversationReceiver: self)
        ConversationCache.getInstance().getPendingMessagesOfUser(destId: Double((QRSessionManager.getInstance()?.getUserId())!)!, sourceId: userId!){
        }
        chatTableView.reloadData()
        chatTableView.scrollToBottom(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(ChatConversationDialogue.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatConversationDialogue.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        ConversationCache.getInstance().removeParticularConversationListener(number: userId!)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
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
            return
        }
        if chatMessageTextView.text.isEmpty{
            shareLocationIcon.isHidden = false
            SendButton.isHidden = true
        }else{
            shareLocationIcon.isHidden = true
            SendButton.isHidden = false
        }
        isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 0
        self.view.layoutIfNeeded()
        if isFromQuickShare || isFromTaxipool{
            commonMsgsCollectionView.isHidden = true
            commonMsgsCollectionViewHeightConstraint.constant = 0
        }else{
            commonMsgsCollectionView.isHidden = false
            commonMsgsCollectionViewHeightConstraint.constant = 90
        }
    }
  
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageTextView.text == nil || chatMessageTextView.text.isEmpty == true || chatMessageTextView.text ==  Strings.type_your_message{
            
            chatMessageTextView.text = ""
            chatMessageTextView.textColor = Colors.chatMsgTextColor
            shareLocationIcon.isHidden = false
            SendButton.isHidden = true
        }else{
            shareLocationIcon.isHidden = true
            SendButton.isHidden = false
        }
        commonMsgsCollectionView.isHidden = true
        commonMsgsCollectionViewHeightConstraint.constant = 0
        addDoneButton(textView: textView)
        return true
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
        if(chatMessageTextView.text.isEmpty == true){
            shareLocationIcon.isHidden = false
            SendButton.isHidden = true
            resignFirstResponder()
        }else if chatMessageTextView.text.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0{
            shareLocationIcon.isHidden = false
            SendButton.isHidden = true
        }else{
            chatMessageTextView.textColor = Colors.chatMsgTextColor
            shareLocationIcon.isHidden = true
            SendButton.isHidden = false
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if chatMessageTextView.text.isEmpty == true {
            self.chatMessageTextView.text =  Strings.type_your_message
        }
        chatMessageTextView.endEditing(true)
        resignFirstResponder()

    }
    
    func checkAndCreateConversationObject(){
        AppDelegate.getAppDelegate().log.debug("")
        guard let userBasicInfo = conversationChatVM.userBasicInfo else{
            return
        }
        let conversation = ConversationCache.getInstance().getConversationObject(userBasicInfo: userBasicInfo)
        chatHistory = conversation.messages
        let lastMessage = conversation.messages.last
        if lastMessage?.sourceApplication == ConversationMessage.SOURCE_APPLICATION_P2P{
            hideDefaultMessages = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("")
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView delegate and data source
    func numberOfSections(in tableView: UITableView) -> Int {
        AppDelegate.getAppDelegate().log.debug("")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppDelegate.getAppDelegate().log.debug("\(section)")
        return chatHistory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
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
    
    
    
    func sendData(message : String, location : Location?){
        AppDelegate.getAppDelegate().log.debug("")
        
        if QRReachability.isConnectedToNetwork() == false{
            chatMessageTextView.endEditing(true)
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
        conversationMessage.destId = userId
        conversationMessage.sourceId = Double((QRSessionManager.getInstance()?.getUserId())!)
        conversationMessage.msgStatus = ConversationMessage.MSG_STATUS_NEW
        conversationMessage.msgType = ConversationMessage.MSG_TYPE_NEW
        conversationMessage.time = Double(StringUtils.getStringFromDouble(decimalNumber : NSDate().timeIntervalSince1970*1000))
        if isFromQuickShare{
            conversationMessage.sourceApplication = ConversationMessage.SOURCE_APPLICATION_P2P
        }
        
        if location != nil
        {
            conversationMessage.address = location!.completeAddress
            conversationMessage.latitude = location!.latitude
            conversationMessage.longitude = location!.longitude
        }
        return conversationMessage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return commonMsgs!.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
            let cell : CommonMsgsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CommonMsgsCollectionViewCell
            if commonMsgs!.endIndex <= indexPath.row{
                return cell
            }
            cell.messageLbl.text = commonMsgs![indexPath.row]
        cell.msgView.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        cell.msgView.layer.shadowRadius = 3
        cell.msgView.layer.shadowOffset = CGSize(width: 0,height: 1)
        cell.msgView.layer.shadowOpacity = 1
            ViewCustomizationUtils.addBorderToView(view: cell.msgView, borderWidth: 1, color: UIColor(netHex: 0xE5E5E5))
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CommonMsgsCollectionViewCell
                sendData(message: cell.messageLbl.text!, location: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let label = UILabel(frame: CGRect.zero)
            label.text = commonMsgs![indexPath.item]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 25, height: 40)
    }
    func addSentMessageToAdapter(conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        guard let userBasicInfo = conversationChatVM.userBasicInfo else { return }
        chatMessageTextView.text = ""
        let conversation = ConversationCache.getInstance().getConversationObject(userBasicInfo: userBasicInfo)
        if conversation.messages.isEmpty{
            ConversationCache.getInstance().storeNewContact(userId: userBasicInfo.userId!)
        }
        conversation.messages.append(conversationMessage)
        chatHistory.append(conversationMessage)
        ConversationCachePersistenceHelper.addPersonalChatMessage(conversationMessage: conversationMessage, phone: userId!)
        
        var height = self.chatTableView.frame.size.height+100
        if isKeyBoardVisible == true{
            height = height + keyboardHeight
        }
        refreshChatMessageTableView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    func receiveConversationMessage(conversationMessage conversation: ConversationMessage) {
        AppDelegate.getAppDelegate().log.debug("\(conversation)")
        
        chatHistory.append(conversation)
        
        refreshChatMessageTableView()
        if  (Double)((QRSessionManager.getInstance()?.getUserId())!)! == conversation.destId!{
            let messageAckSenderTask = MessageAckSenderTask(conversationMessage: conversation, status: ConversationMessage.MSG_STATUS_READ)
            messageAckSenderTask.publishMessage()
        }
    }
    
    func receiveConversationMessageStatus(statusMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(statusMessage)")
        if conversationChatVM.userBasicInfo != nil{
            checkAndCreateConversationObject()
            if Thread.isMainThread == true{
                self.chatHistory.sort(by: { $0.time! < $1.time!})
                chatTableView.reloadData()
            }else{
                DispatchQueue.main.sync(){
                    self.chatHistory.sort(by: { $0.time! < $1.time!})
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    func refreshChatMessageTableView()
    {
        AppDelegate.getAppDelegate().log.debug("")
        if Thread.isMainThread == true{
            self.chatHistory.sort(by: { $0.time! < $1.time!})
            chatTableView.reloadData()
            chatTableView.scrollToBottom(animated: true)
        }else{
            DispatchQueue.main.sync(){
                self.chatHistory.sort(by: { $0.time! < $1.time!})
                self.chatTableView.reloadData()
                self.chatTableView.scrollToBottom(animated: true)
            }
        }
        
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        sendData(message: chatMessageTextView.text, location: nil)
        shareLocationIcon.isHidden = false
        SendButton.isHidden = true
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        guard let userBasicInfo = conversationChatVM.userBasicInfo else { return }
        var callSupport = true
        if UserProfile.SUPPORT_CALL_ALWAYS == userBasicInfo.callSupport{
            callSupport = true
        }else if UserProfile.SUPPORT_CALL_AFTER_JOINED == userBasicInfo.callSupport{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: userId))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                callSupport = true
            }else{
              callSupport = false
            }
        }else{
            callSupport = false
        }
        let chatAlertController = ConversationChatAlertController(viewController: self, presentConatctUserBasicInfo : userBasicInfo, supportCall : callSupport)
        chatAlertController.profileAlertAction()
        chatAlertController.reportToUserAction()
        if chatHistory.count >= 1{
            chatAlertController.clearChatAction(delegate: self)
        }
        chatAlertController.addRemoveAlertAction()
        chatAlertController.showAlertController()
    }
    func clearConversation() {
        chatHistory.removeAll()
        self.chatTableView.reloadData()
    }
    
    @IBAction func callOptionTapped(_ sender: Any){
        guard let userBasicInfo = conversationChatVM.userBasicInfo else { return }
        if let callDisableMsg = getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
        AppDelegate.getAppDelegate().log.debug("Calling")
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: userId),refId: Strings.CHAT, name: userBasicInfo.name ?? "", targetViewController: self)
    }
    
    private func getErrorMessageForCall() -> String?{
        if UserProfile.SUPPORT_CALL_NEVER == conversationChatVM.userBasicInfo?.callSupport{
            return Strings.no_call_please_msg
        }else if UserProfile.SUPPORT_CALL_AFTER_JOINED == conversationChatVM.userBasicInfo?.callSupport{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: userId))
            if (contact != nil && contact!.contactType != Contact.RIDE_PARTNER) && !RideValidationUtils.checkUserJoinedInUpCommingRide(userId: userId ?? 0){
                return Strings.call_joined_partner_msg
            }
        }
        return nil
    }
    
    @IBAction func shareLocationTapped(_ sender: Any){
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectLocationFromMap = storyboard.instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location :nil, locationType: ChangeLocationViewController.ORIGIN, actnBtnTitle: Strings.send_location, isFromEditRoute: false, dropLocation: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }
    
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        
        AppDelegate.getAppDelegate().log.debug("")
        self.sendData(message : "Location : " + "\(String(describing: location.completeAddress!))",location: location)
    }

    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("")
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    private func observeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(userBasicInfoReceived), name: .userBasicInfoReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToGetUserBasicInfo), name: .failedToGetUserBasicInfo, object: nil)
    }
    
    @objc func userBasicInfoReceived(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        showUserProfileInformation()
        continueToInitialization()
        checkCallOptionIsAvailableOrNot()
    }
    
    @objc func failedToGetUserBasicInfo(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseError = notification.userInfo?["responseObject"] as? ResponseError
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
    }
    
    private func showUserProfileInformation(){
        userNameLabel.text = conversationChatVM.userBasicInfo?.name
        userCompanyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: conversationChatVM.userBasicInfo?.profileVerificationData, companyName: conversationChatVM.userBasicInfo?.companyName?.capitalized)
        userImageView.isHidden = false
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: conversationChatVM.userBasicInfo?.imageURI, gender: conversationChatVM.userBasicInfo?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        userVerificationImage.isHidden = false
        userVerificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: conversationChatVM.userBasicInfo?.profileVerificationData)
        if isFromCentralChat{
            centralChatButton.isHidden = true
            unreadChatView.isHidden = true
        }else{
            centralChatButton.isHidden = false
            let unreadCount = MessageUtils.getUnreadCountOfChat()
            if unreadCount > 0{
                unreadChatView.isHidden = false
                chatCountLabel.text = String(unreadCount)
            }else{
                unreadChatView.isHidden = true
            }
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: userId),isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(), rideVehicle: nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        ConversationCache.currentChatUserId = nil
        self.listener?.refershContacts()
    }
    
    @IBAction func centralChatButtonTapped(_ sender: Any) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CentralChatViewController") as! CentralChatViewController
        self.navigationController?.pushViewController(centralChatViewController, animated: false)
    }
}
extension UITableView {
    
    func scrollToBottom(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            let point = CGPoint(x: 0, y: self.contentSize.height + self.contentInset.bottom - self.frame.height)
            if point.y >= 0 {
                self.setContentOffset(point, animated: animated)
            }
        }
    }
}
