//
//  InviteContactsAndGroupViewController.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI
class InviteContactsAndGroupViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var inviteReferLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var requestSentInfoView: UIView!
    
    //MARK: Variables
    private var viewModel = InviteContactsAndGroupViewModel()
    
    func initailizeView(ride: Ride?,taxiRide: TaxiRidePassenger?){
        viewModel = InviteContactsAndGroupViewModel(ride: ride,taxiRide: taxiRide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        viewModel.getAllRidePartners()
        viewModel.fetchPhoneBookContacts(viewController: self)
        viewModel.getAllJoinedGroups()
        contactsTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNsNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUi(){
        contactsTableView.estimatedRowHeight = 70
        contactsTableView.rowHeight = UITableView.automaticDimension
        searchBar.delegate = self
        backButton.changeBackgroundColorBasedOnSelection()
        shareImage.image = shareImage.image?.withRenderingMode(.alwaysTemplate)
        shareImage.tintColor = .white
        contactsTableView.register(UINib(nibName: "FetchingContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "FetchingContactsTableViewCell")
        contactsTableView.register(UINib(nibName: "contactPermissionTableViewCell", bundle: nil), forCellReuseIdentifier: "contactPermissionTableViewCell")
        if let _ = viewModel.ride{
            bottomView.isHidden = false
            bottomView.addShadow()
            if let afterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let afterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                inviteReferLabel.text = String(format: Strings.invite_users_get_point, arguments: [String(afterVerification + afterFirstRide)])
            }
        }else{
            bottomView.isHidden = true
        }
    }
    
    private func confirmNsNotification(){
        //Ride partner
        NotificationCenter.default.addObserver(self, selector: #selector(inviteRidePartnerContactTapped(_:)), name: .inviteRidePartnerContactTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inviteContactSuccess(_:)), name: .inviteContactSuccess, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(inviteContactfailed(_:)), name: .inviteContactfailed, object: viewModel)
        
        //PhoneBook contacts
        NotificationCenter.default.addObserver(self, selector: #selector(contactPermission(_:)), name: .contactPermission, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactInviteTapped(_:)), name: .contactInviteTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactsFetchingFailed(_:)), name: .contactsFetchingFailed, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(noContactsToDisplay(_:)), name: .noContactsToDisplay, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(contactsLoaded(_:)), name: .contactsLoaded, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(contactInviteResponse(_:)), name: .contactInviteResponse, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelRideInvitationSuccess(_:)), name: .cancelRideInvitationSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelRideInvitationFailed(_:)), name: .cancelRideInvitationFailed, object: nil)
    }
    
    //MARK: RidePartenrs
    @objc func inviteRidePartnerContactTapped(_ notification : NSNotification){
        if let rideObj = viewModel.ride, rideObj.rideType == Ride.PASSENGER_RIDE && (rideObj as! PassengerRide).riderRideId != 0{
            let error = ResponseError(errorCode: 2631,userMessage: Strings.already_join_ride)
            MessageDisplay.displayAlert(messageString: error.userMessage!, viewController: self, handler: { (result) in
            })
            return
        }
        
        guard let index = notification.userInfo?["index"] as? Int, index < viewModel.searchedRidePartners.count else { return }
        continueInvite(contact: viewModel.searchedRidePartners[index], paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "") {
            
            responseObject, error in
            self.handleErrorResponse(contact: self.viewModel.searchedRidePartners[index], responseObject: responseObject, error: error)
        }
    }
    
    private func handleErrorResponse(contact: Contact,responseObject: NSDictionary?, error: NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
            QuickRideProgressSpinner.stopSpinner()
            let result = RestResponseParser<ContactInviteResponse>().parse(responseObject: responseObject, error: error)
            guard let error = result.1 else{ return }
            if error.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error.extraInfo, !extraInfo.isEmpty{
                if extraInfo["PaymentLinkData"] != nil {
                    self.handlePaymentFailureResponse(contact: contact, error: error)
                }else {
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.viewModel.ride?.rideId, handler: nil)
                }
            }else if RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == error.errorCode ||
                        RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == error.errorCode ||
                        RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == error.errorCode ||
                        RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == error.errorCode ||
                        RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == error.errorCode{
                self.handlePaymentFailureResponse(contact: contact, error: error)
            }else{
                UIApplication.shared.keyWindow?.makeToast( "\(Strings.invite_failed) , \(error.userMessage!)")
            }
        }
    }
    
    func handlePaymentFailureResponse(contact: Contact, error: ResponseError){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet == nil {
            showPaymentDrawer(contact: contact)
        }else if error.errorCode == RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR  {
            showPaymentDrawer(contact: contact)
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            displayAddMoneyView(errorMessage: error.userMessage ?? "")
        }
    }
    
    func displayAddMoneyView(errorMessage: String){
        let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        addMoneyViewController.initializeView(errorMsg: errorMessage){ (result) in
            if result == .changePayment {
                self.showPaymentDrawer(contact: nil)
            }
        }
        addMoneyViewController.modalPresentationStyle = .overFullScreen
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: addMoneyViewController, animated: true, completion: nil)
    }
    
    func showPaymentDrawer(contact: Contact?){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .ccdcSelected {
                guard let contact = contact else { return }
                self.continueInvite(contact: contact, paymentType: TaxiRidePassenger.PAYMENT_MODE_PAYMENT_LINK) { responseObject,error in
                    if (responseObject!["result"] as! String == "FAILURE"){
                        let result = RestResponseParser<ResponseError>().parse(responseObject: responseObject, error: error)
                        if let responseError = result.1{
                            self.displayWebView(responseError: responseError)
                        }
                    }
                }
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func displayWebView(responseError: ResponseError){
        let extraInfo = responseError.extraInfo
        let controlName = self.convertToDictionary(text: extraInfo?["PaymentLinkData"] as! String)
        if let linkUrl = controlName?["paymentLink"], let successURL = controlName?["redirectionUrl"] {
            let queryItems1 = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps1 = URLComponents(string :  linkUrl as! String)
            urlcomps1?.queryItems = [queryItems1]
            
            let queryItems2 = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps2 = URLComponents(string :  successURL as! String)
            urlcomps2?.queryItems = [queryItems2]
            if urlcomps1?.url != nil {
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: "Payment", url: urlcomps1?.url, actionComplitionHandler: nil)
                webViewController.successUrl = urlcomps2?.url
                self.navigationController?.pushViewController(webViewController, animated: false)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    @objc func inviteContactSuccess(_ notification : NSNotification){
        QuickRideProgressSpinner.stopSpinner()
        contactsTableView.reloadData()
        if viewModel.ride?.rideType == Ride.PASSENGER_RIDE {
            requestSentInfoView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self.requestSentInfoView.isHidden = true
            })
        }
    }
    
    @objc func inviteContactfailed(_ notification : NSNotification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["NSDictionary"] as? NSDictionary
        let error = notification.userInfo?["NSError"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc func contactInviteResponse(_ notification : NSNotification){
       QuickRideProgressSpinner.stopSpinner()
       let responseError = notification.userInfo?["responseError"] as? ResponseError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: nil, viewController: self)
    }
    
    //MARK: PhonebookContacts
    @objc func contactPermission(_ notification : NSNotification){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        contactsTableView.reloadData()
    }
    
    @objc func contactInviteTapped(_ notification : NSNotification){
        if let rideObj = viewModel.ride,rideObj.rideType == Ride.PASSENGER_RIDE && (rideObj as! PassengerRide).riderRideId != 0{
            let error = ResponseError(errorCode: 2631,userMessage: Strings.already_join_ride)
            MessageDisplay.displayAlert(messageString: error.userMessage!, viewController: self, handler: { (result) in
            })
            return
        }
        guard let index = notification.userInfo?["index"] as? Int else { return }
        let contact = viewModel.searchedPhoneBookContacts[index]
        if let userId = contact.contactId, userId != "0" {
            continueInvite(contact: self.viewModel.searchedPhoneBookContacts[index], paymentType: UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? "") { responseObject, error in
                self.handleErrorResponse(contact: self.viewModel.searchedPhoneBookContacts[index], responseObject: responseObject, error: error)
            }
        }else{
            guard let taxiRide = viewModel.taxiRide else {
                return
            }
            JoinMyRide().getDeepLinkURLForTaxiPool(rideId: StringUtils.getStringFromDouble(decimalNumber:taxiRide.id), riderId: QRSessionManager.getInstance()?.getUserId() ?? "", from: taxiRide.startAddress ?? "", to: taxiRide.endAddress ?? "", startTime: taxiRide.pickupTimeMs ?? 0) {[weak self] message in
                guard let self = self else {
                    return
                }
                self.sendSMS(phoneNumber: StringUtils.getStringFromDouble(decimalNumber: contact.contactNo), message: message, viewController: self)
            }
            
        }
        
    }
    
    private func continueInvite(contact: Contact, paymentType: String, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        viewModel.accountUtils = AccountUtils()
        viewModel.accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: self, handler: {(result) in
            if result == .success {
                QuickRideProgressSpinner.startSpinner()
                self.viewModel.inviteContacts(contact: contact, viewController: self,paymentType: paymentType){responseObject,error in
                    QuickRideProgressSpinner.stopSpinner()
                    complitionHandler(responseObject,error)
                }
            }else if result == .addPayment {
                self.showPaymentDrawer(contact: contact)
            }
        })
    }
    
    @objc func cancelRideInvitationFailed(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc func cancelRideInvitationSuccess(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        contactsTableView.reloadData()
    }
     func sendSMS(phoneNumber:String?, message : String,viewController : UIViewController){

        let messageViewConrtoller = MFMessageComposeViewController()

        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            if phoneNumber != nil{
                messageViewConrtoller.recipients = [phoneNumber!]
            }
            messageViewConrtoller.messageComposeDelegate = viewController
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: messageViewConrtoller, animated: false, completion: nil)
        }
    }
    
    @objc func contactsFetchingFailed(_ notification : NSNotification){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.contact_sync_failed, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil,linkButtonText: nil, viewController: self, handler: { (result) in
        })
        contactsTableView.reloadData()
    }
    @objc func noContactsToDisplay(_ notification : NSNotification){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.no_contacts_found_to_display, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil,linkButtonText: nil, viewController: self, handler: { (result) in
        })
        contactsTableView.reloadData()
    }
    
    @objc func contactsLoaded(_ notification : NSNotification){
        contactsTableView.reloadData()
    }
    
    @IBAction func inviteYourPalTapped(_ sender: UIButton) {
        JoinMyRide().prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber: viewModel.ride?.rideId), riderId: StringUtils.getStringFromDouble(decimalNumber: viewModel.ride?.userId), from: viewModel.ride?.startAddress ?? "", to: viewModel.ride?.endAddress ?? "", startTime: viewModel.ride?.startTime ?? 0, vehicleType: (viewModel.ride as? RiderRide)?.vehicleType ?? "", viewController: self,isFromTaxiPool: false)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func removeRequestSentViewTapped(_ sender: Any) {
        requestSentInfoView.isHidden = true
    }
}
//MARK: UITableViewDataSource
extension InviteContactsAndGroupViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return viewModel.getRidePartnerNoOfRows()
        }else if section == 1{
            if let _ = viewModel.ride{ //only for carpool
                return viewModel.getGroupsNoOfRows()
            }else{
                return 0
            }
        }else{
            return viewModel.getPhonebookContactsNoOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RidePartnerTableViewCell", for: indexPath as IndexPath) as! RidePartnerTableViewCell
            cell.inviteButton.tag = indexPath.row
            cell.menuButton.tag = indexPath.row
            cell.initializeRidePartner(contact: viewModel.searchedRidePartners[indexPath.row], rideId: viewModel.ride?.rideId ?? 0, rideType: viewModel.ride?.rideType ?? "", viewController: self)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteGroupsTableViewCell", for: indexPath as IndexPath) as! InviteGroupsTableViewCell
            cell.inviteButton.tag = indexPath.row
            cell.initializeGroup(group: viewModel.searchedUserGroups[indexPath.row], ride: viewModel.ride!, delegate: self, viewController: self)
            return cell
        }else{
            if !viewModel.isContactsLoaded{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FetchingContactsTableViewCell", for: indexPath as IndexPath) as! FetchingContactsTableViewCell
                cell.selectionStyle = .none
                return cell
            }else if viewModel.isUserDisableContactPermission{
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactPermissionTableViewCell", for: indexPath as IndexPath) as! contactPermissionTableViewCell
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneBookContactTableViewCell", for: indexPath as IndexPath) as! PhoneBookContactTableViewCell
                cell.inviteButton.tag = indexPath.row
                cell.initailizePhoneBookContact(contact: viewModel.searchedPhoneBookContacts[indexPath.row], rideId: viewModel.ride?.rideId ?? 0)
                cell.selectionStyle = .none
                return cell
            }
            
        }
    }
}
//MARK: UITableViewDelegate
extension InviteContactsAndGroupViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && !viewModel.searchedRidePartners.isEmpty{
            return 35
        }else if let _ = viewModel.ride, section == 1 && !viewModel.searchedUserGroups.isEmpty{
            return 60
        }else if section == 2 && !viewModel.searchedPhoneBookContacts.isEmpty{
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.frame.size.width, height: 60))
        let deviderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 14))
        deviderView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 30, width: tableView.frame.size.width - 10, height: 35))
        headerLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        if section == 0{
            let headerViewFirst = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            headerViewFirst.backgroundColor = UIColor.white
            let headerLabelFirst = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width - 10, height: 35))
            headerLabelFirst.textColor = UIColor.black.withAlphaComponent(0.4)
            headerLabelFirst.font = UIFont.boldSystemFont(ofSize: 16.0)
            headerLabelFirst.text = Strings.ride_partners_contact.uppercased()
            headerViewFirst.addSubview(headerLabelFirst)
            return headerViewFirst
        }else if section == 1{
            headerLabel.text = Strings.groups.uppercased()
            headerView.addSubview(deviderView)
        }else{
            headerLabel.text = Strings.contacts.uppercased()
            headerView.addSubview(deviderView)
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 0 && viewModel.searchedRidePartners.count > 5 && !viewModel.isRequiredToShowAllRidePartners){
            return 50
        }else if let _ = viewModel.ride, section == 1 && viewModel.searchedUserGroups.count > 2 && !viewModel.isRequiredToShowAllGroups{
            return 50
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.frame.size.width, height: 50))
        headerView.backgroundColor = .white
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 15, width: tableView.frame.size.width - 10, height: 25))
        headerLabel.textColor = UIColor(netHex: 0x007AFF)
        headerLabel.font = UIFont.systemFont(ofSize: 14.0)
        if section == 0{
            headerLabel.text = Strings.all_ride_partners
            headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allRidePartnerTapped(_:))))
        }else if section == 1{
            headerLabel.text = Strings.all_groups
            headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allGroupsTapped(_:))))
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    @objc func allRidePartnerTapped(_ gestureRecognizer: UITapGestureRecognizer){
        viewModel.isRequiredToShowAllRidePartners = true
        contactsTableView.reloadData()
    }
    
    @objc func allGroupsTapped(_ gestureRecognizer: UITapGestureRecognizer){
        viewModel.isRequiredToShowAllGroups = true
        contactsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if viewModel.searchedUserGroups.endIndex <= indexPath.row{
                return
            }
            let userGroup = viewModel.searchedUserGroups[indexPath.row]
            let userGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.groups_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteUserGroupsViewController") as! InviteUserGroupsViewController
            userGroupViewController.initializeDataBeforePresenting(group: userGroup,rideId: viewModel.ride?.rideId, rideType: viewModel.ride?.rideType)
            self.navigationController?.pushViewController(userGroupViewController, animated: false)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
//OnGroupInviteListener
extension InviteContactsAndGroupViewController: OnGroupInviteListener{
    func groupInviteCompleted() {
        contactsTableView.reloadData()
        UIApplication.shared.keyWindow?.makeToast( Strings.invite_groups)
    }
}
//MARK: UISearchBarDelegate
extension InviteContactsAndGroupViewController: UISearchBarDelegate{
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
        viewModel.searchedPhoneBookContacts.removeAll()
        viewModel.searchedUserGroups.removeAll()
        viewModel.searchedRidePartners.removeAll()
        if searchText.isEmpty == true{
            viewModel.searchedRidePartners = viewModel.ridePartners
            viewModel.searchedUserGroups = viewModel.userGroups
            viewModel.searchedPhoneBookContacts = viewModel.phoneBookContacts
            contactsTableView.reloadData()
        }else{
            for contact in viewModel.ridePartners{
                if contact.contactName.localizedCaseInsensitiveContains(searchText){
                    viewModel.searchedRidePartners.append(contact)
                }
            }
            for group in viewModel.userGroups{
                if group.name!.localizedCaseInsensitiveContains(searchText){
                    viewModel.searchedUserGroups.append(group)
                }
            }
            for contact in viewModel.phoneBookContacts{
                if contact.contactName.localizedCaseInsensitiveContains(searchText){
                    viewModel.searchedPhoneBookContacts.append(contact)
                }
            }
            contactsTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
}

