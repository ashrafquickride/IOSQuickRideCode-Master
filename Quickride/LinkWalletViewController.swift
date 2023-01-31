//
//  LinkPaytmWalletViewController.swift
//  Quickride
//
//  Created by rakesh on 10/1/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class LinkWalletViewController : UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var mainContantView: UIView!
    @IBOutlet weak var bottomHeightCon: NSLayoutConstraint!
    @IBOutlet weak var linkingWalletTableView: UITableView!
    @IBOutlet weak var linkedWalletTableViewHeightCon: NSLayoutConstraint!
    var isrequiredtoshowworkView = false
    private var isKeyBoardVisible = false
    var walletType : String?
    var cellNumber: String?
    var upiNumber: String?
    var tableViewHeight = 0.0
    var messageList = [String]()
    var linkExternalWalletReciever : linkExternalWalletReciever?
    func initializeDataBeforePresenting(walletType : String,linkExternalWalletReciever : linkExternalWalletReciever?){
        self.linkExternalWalletReciever = linkExternalWalletReciever
        self.walletType = walletType
        descriptionForWalletType(walletType: walletType)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: mainContantView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        linkingWalletTableView.dataSource = self
        linkingWalletTableView.rowHeight = UITableView.automaticDimension
        linkingWalletTableView.register(UINib(nibName: "CommonWalletImageTableViewCell", bundle: nil), forCellReuseIdentifier: "CommonWalletImageTableViewCell")
        linkingWalletTableView.register(UINib(nibName: "EnterNumberTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterNumberTableViewCell")
        linkingWalletTableView.register(UINib(nibName: "OtherPaymentMethodsTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherPaymentMethodsTableViewCell")
        linkingWalletTableView.register(UINib(nibName: "CreateAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateAccountTableViewCell")
        linkingWalletTableView.register(UINib(nibName: "SignUpAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "SignUpAccountTableViewCell")
        linkingWalletTableView.register(UINib(nibName: "CommonButtonTableviewCell", bundle: nil), forCellReuseIdentifier: "CommonButtonTableviewCell")
        linkingWalletTableView.register(UINib(nibName: "UpiWalletTableViewCell", bundle: nil), forCellReuseIdentifier: "UpiWalletTableViewCell")
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LinkWalletViewController.backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        updateUIBasedOnTapping(isrequiredtoshowView: false)
    
    }
    
    func updateUIBasedOnTapping(isrequiredtoshowView: Bool){
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY {
            linkedWalletTableViewHeightCon.constant = 320
            self.isrequiredtoshowworkView = true
        } else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL {
            linkedWalletTableViewHeightCon.constant = 320
            self.isrequiredtoshowworkView = true
        }else if  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            linkedWalletTableViewHeightCon.constant = 280
            self.isrequiredtoshowworkView = true
        } else {
            self.isrequiredtoshowworkView = isrequiredtoshowView
            setTableViewHeight(sectionHeight: 0)
            self.linkingWalletTableView.reloadData()
        }
    }
    
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomHeightCon.constant = keyBoardSize.height
        
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomHeightCon.constant = 0
    }
    
    
    func linkUpiWallet(){
        QuickRideProgressSpinner.startSpinner()
        guard let upiNumber = upiNumber else { return }
        AccountRestClient.linkUPIWallet(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", mobileNo: UserDataCache.getInstance()?.currentUser?.contactNo, email: UserDataCache.getInstance()?.getLoggedInUserProfile()?.emailForCommunication, vpaAddress: upiNumber, type: walletType, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReciever?(true, nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                var type = linkedWallet!.type
                if linkedWallet!.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
                    type = Strings.gpay
                }
                AccountUtils().showActivatedAlert(walletType: type!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
        
    }
    
    
    func linkPaytmWallet(){
        QuickRideProgressSpinner.startSpinner()
        guard let cellNumber = cellNumber else { return }
        AccountRestClient.linkPaytmAccountToQR(phone: cellNumber, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                let linkWalletResponse = Mapper<LinkWalletResponse>().map(JSONObject: responseObject!["resultData"])
                
                self.handleLinkWalletSuccessResponse(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM, linkWalletResponse : linkWalletResponse!, otpId: nil)
                
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            
        }
    }
    
    
    
    func handleLinkWalletSuccessResponse(walletType : String,linkWalletResponse : LinkWalletResponse?,otpId: String?){
        let OTPValidationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPValidationViewController") as! OTPValidationViewController
        guard let cellNumber = cellNumber else {
            return
        }
        
        OTPValidationViewController.initializeDataBeforePresenting(phoneNo: cellNumber, walletType: walletType,linkWalletResponse:linkWalletResponse, linkExternalWalletReceiver: self.linkExternalWalletReciever, otpId: otpId)
        AccountPaymentViewController.OTPValidationViewController = OTPValidationViewController
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: OTPValidationViewController, animated: false, completion: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    
    
    
    func linkTMWWallet(){
        
        QuickRideProgressSpinner.startSpinner()
        guard let cellNumber = cellNumber else {
            return
        }
        AccountRestClient.linkTMWAccountToQR(phone: cellNumber, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil{
                if responseObject!["result"] as! String == "SUCCESS"{
                    
                    let linkWalletResponse = Mapper<LinkWalletResponse>().map(JSONObject: responseObject!["resultData"])
                    
                    self.handleLinkWalletSuccessResponse(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_TMW, linkWalletResponse: linkWalletResponse!, otpId: nil)
                    
                }else{
                    let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    if errorResponse?.errorCode == RideValidationUtils.TMW_WALLET_NOT_PRESENT{
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: errorResponse!.userMessage, message2: nil, positiveActnTitle: Strings.register_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: { (actionText) in
                            if actionText == Strings.register_caps{
                                
                                self.openTMWRegistrationController()
                                
                            }
                        })
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                    
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            
        }
    }
    
    
    
    
    func linkFrechargeWallet(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.linkFrechargeWallet(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: cellNumber ?? " ", viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let freechargeResponse = Mapper<FreechargeResponse>().map(JSONObject: responseObject!["resultData"])
                self.handleLinkWalletSuccessResponse(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE, linkWalletResponse : nil, otpId: freechargeResponse?.otpId)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            
        }
    }
    
    private func setTableViewHeight(sectionHeight: CGFloat){
        tableViewHeight = Double(messageList.count * 70)
        if messageList.count > 0 {
            tableViewHeight = tableViewHeight + 100
        }
        if isrequiredtoshowworkView == true {
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM {
                tableViewHeight = tableViewHeight + 130
            }
            if  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
                tableViewHeight = tableViewHeight + 157
            }
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK {
                tableViewHeight = tableViewHeight + 125
            }
            
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE {
                tableViewHeight = tableViewHeight + 125
            }
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE {
                tableViewHeight = tableViewHeight + 157
            }
        }
        if (CGFloat(tableViewHeight) + sectionHeight) > 570 {
            linkedWalletTableViewHeightCon.constant = 345
        } else{
            linkedWalletTableViewHeightCon.constant = CGFloat(tableViewHeight) + 10 + sectionHeight
        }
    }
    
    func linkMobikwikWallet(){
        QuickRideProgressSpinner.startSpinner()
        guard let cellNumber = cellNumber else { return }
        AccountRestClient.linkMobikwikWallet(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: cellNumber, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.handleLinkWalletSuccessResponse(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK, linkWalletResponse : nil, otpId: nil)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    func openTMWRegistrationController(){
        let tmwRegistrationController : TMWRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWRegistrationViewController") as! TMWRegistrationViewController
        ViewControllerUtils.getCenterViewController().view.addSubview(tmwRegistrationController.view)
        ViewControllerUtils.getCenterViewController().addChild(tmwRegistrationController)
    }
    
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    func hiddingAndUnhiddingWorkViewCell() {
        if !isrequiredtoshowworkView {
            updateUIBasedOnTapping(isrequiredtoshowView: true)
            
        } else {
            updateUIBasedOnTapping(isrequiredtoshowView: false)
        }
    }
    
    
    func descriptionForWalletType(walletType: String){
        switch walletType{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            messageList = [String(format: Strings.paylater_and_paytm_payment_info1, arguments: [Strings.paytm_wallet]), Strings.paylater_and_paytm_payment_info2, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            messageList = [Strings.wallet_cc_dc_payment_info, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            messageList = [String(format: Strings.paylater_and_paytm_payment_info1, arguments: [Strings.simpl_Wallet]), Strings.paylater_and_paytm_payment_info2, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            messageList = [String(format: Strings.paylater_and_paytm_payment_info1, arguments: [Strings.lazyPay_wallet]), Strings.paylater_and_paytm_payment_info2, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            messageList = [Strings.wallet_cc_dc_payment_info, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            messageList = [Strings.wallet_cc_dc_payment_info, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            messageList = [String(format: Strings.paylater_and_paytm_payment_info1, arguments: [Strings.upi]), Strings.upi_payment_info2, Strings.upi_payment_info3,Strings.upi_payment_info4]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            messageList = [Strings.wallet_cc_dc_payment_info, Strings.amount_will_refund_if_ride_cancelled]
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            messageList = [String(format: Strings.paylater_and_paytm_payment_info1, arguments: [Strings.gpay]), Strings.upi_payment_info2, Strings.upi_payment_info3,Strings.upi_payment_info4]
        default:
            messageList = ["",""]
        }
    }
    
    func openRegistrationController(url:String, title: String){
        let urlcomps = URLComponents(string : url )
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: title, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    func setUpWorkViewCell(indexPath: IndexPath)-> UITableViewCell {
        
        let cell = linkingWalletTableView.dequeueReusableCell(withIdentifier: "SignUpAccountTableViewCell", for: indexPath) as! SignUpAccountTableViewCell
        cell.descriptionLabel.text = messageList[indexPath.row]
        return cell
    }
    
}
    //MARK:TAbleViewDataSource
extension LinkWalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY || walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL ||  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
                return 0
            } else {
                return 1
            }
        case 2:
            return 1
        case 3:
            if isrequiredtoshowworkView {
                return messageList.count
            } else {
                return 0
            }
        case 4 :
            
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE {
                return 0
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonWalletImageTableViewCell", for: indexPath) as! CommonWalletImageTableViewCell
            cell.intialiseDataForImg(walletType: walletType ?? "")
            return cell
        case 1:
            if self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE ||  self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpiWalletTableViewCell", for: indexPath) as! UpiWalletTableViewCell
                cell.intialiseDataForNumber(walletType: walletType ?? "") { phoneNumber,ispressed in
                    self.upiNumber = phoneNumber
                    if ispressed == true {
                        self.linkUpiWallet()
                    }
                }
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnterNumberTableViewCell", for: indexPath) as! EnterNumberTableViewCell
                cell.intialiseDataForNumber() { phoneNumber,ispressed in
                    self.cellNumber = phoneNumber
                    if ispressed == true {
                        if self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
                            self.linkPaytmWallet()
                        }
                        else if self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_TMW{
                            self.linkTMWWallet()
                        }
                        else if self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
                            self.linkMobikwikWallet()
                        }else if self.walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
                            self.linkFrechargeWallet()
                        }
                    }
                }
                let user = UserDataCache.getInstance()?.currentUser
                if user != nil && user!.contactNo != nil{
                    cell.phoneNumberField.text = StringUtils.getStringFromDouble(decimalNumber: user!.contactNo!)
                }
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountTableViewCell", for: indexPath) as! CreateAccountTableViewCell
            cell.nameOfBtn.setTitle("How it works", for: .normal)
            if  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY || walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL ||  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
                cell.nameOfBtn.setTitleColor(UIColor(netHex: 0x000000), for: .normal)
            } else {
                cell.nameOfBtn.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            }
            cell.intialiseDataForNumber(walletType: walletType ?? ""){ isTapped in
                if isTapped {
                    self.hiddingAndUnhiddingWorkViewCell()
                }
            }
            return cell
        case 3:
            return  setUpWorkViewCell(indexPath: indexPath)
        case 4:
            if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE ||  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPaymentMethodsTableViewCell", for: indexPath) as! OtherPaymentMethodsTableViewCell
                cell.seperatorView.isHidden = true
                cell.titlelabel.text = "*For your ride payments through UPI, the transaction needs to be approved from your respective UPI apps."
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonButtonTableviewCell", for: indexPath) as! CommonButtonTableviewCell
                if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
                    let attributedTitle = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                    attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x007AFF)
                                                                                             ]))
                    cell.commonBtn.contentHorizontalAlignment = .left
                    cell.commonBtn.setAttributedTitle(attributedTitle, for: .normal)
                }
                else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL || walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY ||  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
                    cell.commonBtn.setTitle("LINK".uppercased(), for: .normal)
                    cell.commonBtn.backgroundColor = UIColor(netHex: 0x00B557)
                    cell.commonBtn.setTitleColor(UIColor(netHex: 0xFFFFFF), for: .normal)
                    cell.commonBtn.layer.cornerRadius = 10
                    cell.commonBtn.titleLabel?.textAlignment = .center
                    cell.commonBtn.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 16)
                }
                    cell.intialiseDataForNumber(walletType: walletType ?? ""){ isTapped in
                        if isTapped {
                            switch self.walletType {
                            case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
                                AccountUtils().checkSimplSdkApprovalStatus(viewController: self, linkExternalWalletReceiver: self.linkExternalWalletReciever)
                            case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
                                AccountUtils().checkEligibilityForLazypay(linkExternalWalletReceiver: self.linkExternalWalletReciever)
                            case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
                                self.view.removeFromSuperview()
                                self.removeFromParent()
                                self.openRegistrationController(url: AppConfiguration.PAYTM_REGISTRATION_LINK, title: Strings.paytm)
                            case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
                                self.view.removeFromSuperview()
                                self.removeFromParent()
                                self.openRegistrationController(url: AppConfiguration.TMW_REDIRECTION_URL, title: Strings.tmw)
                            default:
                                AccountUtils().checkAmazonPayAuthorizeCallAndLink (linkExternalWalletReceiver: self.linkExternalWalletReciever)
                                self.view.removeFromSuperview()
                                self.removeFromParent()
                                
                            }
                        }
                    }
                return cell
            }
        default :
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
            
        }
    }
}
