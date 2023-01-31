//
//  AccountUtils.swift
//  Quickride
//
//  Created by iDisha on 24/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import SimplZeroClick
import ObjectMapper
import LoginWithAmazon
import PWAINSilentPayiOSSDK

class AccountUtils: AuthorizeSuccessDelegate{

    var linkExternalWalletReceiver: linkExternalWalletReciever?
    var PGTController : PGTransactionViewController!
    var topBar : UIView?
    var GPaySuportedUPIId = ["okaxis","okicici","oksbi","okhdfc"]

    func addLinkWalletSuggestionAlert(title : String?,message : String?,viewController: UIViewController?, linkExternalWalletReciever: linkExternalWalletReciever?){

        UserDataCache.LINK_WALLET_DIALOGUE_DISPLAY_STATUS = true
        let linkWalletSuggestionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LinkWalletSuggestionViewController") as! LinkWalletSuggestionViewController
        linkWalletSuggestionViewController.initializeView(titleString: title, message: message) { (result, walletType) in
            if result == Strings.link_caps{
                if walletType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM{
                    if title == Strings.redeem_title{
                        linkExternalWalletReciever?(false, walletType)
                    }
                    else{
                        self.linkRequestedWallet(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM, linkExternalWalletReceiver: linkExternalWalletReciever)
                    }
                }else if walletType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW{
                    if title == Strings.redeem_title{
                        linkExternalWalletReciever?(false, walletType)
                    }
                    else{
                        self.linkRequestedWallet(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_TMW, linkExternalWalletReceiver: linkExternalWalletReciever)
                    }
                }else{
                    self.linkRequestedWallet(walletType: walletType!, linkExternalWalletReceiver: linkExternalWalletReciever)
                }
            }else{
                linkExternalWalletReciever?(false, nil)
            }
        }
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: linkWalletSuggestionViewController, animated: false)
    }

    func openWalletLinkingController(walletType : String, linkExternalWalletReciever: linkExternalWalletReciever?){
        let linkWalletViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LinkWalletViewController") as! LinkWalletViewController
        linkWalletViewController.initializeDataBeforePresenting(walletType: walletType, linkExternalWalletReciever: linkExternalWalletReciever)
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkWalletViewController)
    }



    func showPaymentDrawer(handler: linkedWalletActionCompletionHandler?){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: nil) {(data) in
            if let handler = handler {
                handler(data)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }

    func showLinkedWalletBalanceInsufficientAlert(handler: linkedWalletActionCompletionHandler?){
        let linkedWalletBalanceInsufficientAlertVC = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LinkedWalletBalanceInsufficientAlertViewController") as! LinkedWalletBalanceInsufficientAlertViewController
        linkedWalletBalanceInsufficientAlertVC.initializeView(titleString: Strings.linked_wallet_insufficient_balance) { [weak self] (result) in
            if result == Strings.change_paymet_mode{
                self?.showPaymentDrawer(handler: nil)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletBalanceInsufficientAlertVC)
    }

    func lazyPayRequestOTP(linkExternalWalletReceiver : linkExternalWalletReciever?){
        let user = UserDataCache.getInstance()?.currentUser
        if user != nil && user!.contactNo != nil{
            let mobileNumber = StringUtils.getStringFromDouble(decimalNumber: user!.contactNo!)
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.linkLazyPayAccountToQR(phone: QRSessionManager.getInstance()!.getUserId(), mobileNo: mobileNumber, viewController: nil) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.handleLinkWalletSuccessResponse(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY, mobileNo: mobileNumber, linkWalletResponse : nil,linkExternalWalletReceiver: { (walletAdded, walletType) in
                        linkExternalWalletReceiver?(walletAdded, nil)
                    })
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
            }
        }
    }

    func handleLinkWalletSuccessResponse(walletType : String, mobileNo: String, linkWalletResponse : LinkWalletResponse?,linkExternalWalletReceiver : linkExternalWalletReciever?){
        let OTPValidationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPValidationViewController") as! OTPValidationViewController
        OTPValidationViewController.initializeDataBeforePresenting(phoneNo: mobileNo, walletType: walletType,linkWalletResponse:linkWalletResponse, linkExternalWalletReceiver: { (walletAdded, walletType) in
            linkExternalWalletReceiver?(walletAdded, nil)
        }, otpId: nil)
        AccountPaymentViewController.OTPValidationViewController = OTPValidationViewController
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: OTPValidationViewController, animated: false, completion: nil)
    }

    func checkSimplSdkApprovalStatus(viewController: UIViewController?, linkExternalWalletReceiver : linkExternalWalletReciever?){

        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let email = userProfile?.email == nil ?
            userProfile?.emailForCommunication == nil ? "" : userProfile?.emailForCommunication
            : userProfile?.email


        var params :[String : Any] = [:]
        if let profileVerificationData = userProfile?.profileVerificationData{
          params["email_verification_status"] = String(profileVerificationData.emailVerified)
          params["govt_id_verified"] = String(profileVerificationData.persIDVerified)
        }
        params["first_name"] = userProfile?.userName
        params["employer_name"] = userProfile?.companyName

        if let homeLocation = UserDataCache.getInstance()?.getHomeLocation(){
            params["user_location_origin"] = String(homeLocation.latitude!) + "," + String(homeLocation.longitude!)
        }

        if let officeLocation = UserDataCache.getInstance()?.getOfficeLocation(){
            params["user_location_destination"] = String(officeLocation.latitude!) + "," + String(officeLocation.longitude!)
        }

        if let numberOfRidesAsRider = userProfile?.numberOfRidesAsRider,let numberOfRidesAsPassenger = userProfile?.numberOfRidesAsPassenger{
            params["successful_txn_count"] = String(numberOfRidesAsRider+numberOfRidesAsPassenger)
        }

        let user = GSUser(phoneNumber: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo), email: email!)
        user.headerParams = params

        QuickRideProgressSpinner.startSpinner()
        GSManager.shared().checkApproval(for: user) { (approved, firstTransaction, text, error) in
            QuickRideProgressSpinner.stopSpinner()
            if error != nil {

                MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: true, message1: error!.localizedDescription, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, msgWithLinkText: "", isActionButtonRequired: true, viewController: nil) { (text) in
                }

            }else if approved{
                self.generateSimplSdkToken(viewController: viewController, linkExternalWalletReceiver: { (walletAdded, walletType) in
                    linkExternalWalletReceiver?(walletAdded, nil)
                })
            }else{
                MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.simpl_approval_failure_error, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, msgWithLinkText: "", isActionButtonRequired: true, viewController: nil){ (text) in
                }
            }
        }
    }
    func generateSimplSdkToken(viewController: UIViewController?,linkExternalWalletReceiver : linkExternalWalletReciever?){
        let user = GSUser(phoneNumber: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo), email: "")
        GSManager.shared().generateToken(for: user) { (jsonResponse, error) in
            if error != nil {
                MessageDisplay.displayAlert(messageString: error!.localizedDescription, viewController: viewController, handler: nil)
            } else {
                let data = jsonResponse!["data"] as! [AnyHashable: Any]
                self.linkSimplWallet(token: data["zero_click_token"] as! String, viewController: viewController, linkExternalWalletReceiver: { (walletAdded, walletType) in
                    linkExternalWalletReceiver?(walletAdded, nil)
                })
            }
        }
    }
    func linkSimplWallet(token : String, viewController: UIViewController?, linkExternalWalletReceiver : linkExternalWalletReciever?){
        AccountRestClient.linkSIMPLAccountToQR(userId: (UserDataCache.getInstance()?.currentUser?.phoneNumber)!, simplToken: token , viewController: viewController, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                linkExternalWalletReceiver?(true, nil)
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }

    func checkAmazonPayAuthorizeCallAndLink(linkExternalWalletReceiver: linkExternalWalletReciever?){
        self.linkExternalWalletReceiver = linkExternalWalletReceiver
        let amazonPay = AmazonPayAuthorizeCallbackHandler()
        amazonPay.delegate = self
        AmazonAuthKey.sharedInstance = nil
        let request:APayAuthorizeRequest =
            APayAuthorizeRequest.build({(builder) in
                builder?.withCodeChallenge(AmazonAuthKey.getInstance().codeChallenge)
            } )
        AmazonPay.sharedInstance()?.authorize(request, apayAuthorizeCallback: amazonPay)
    }

    func authorizationSuccess(response: APayAuthorizationResponse) {

        if response.status == AmazonPayResponse.auth_status_granted{

            QuickRideProgressSpinner.startSpinner()

            AccountRestClient.linkAmazonPayWallet(userId: QRSessionManager.getInstance()!.getUserId(), codeVerifier: AmazonAuthKey.getInstance().codeVerifier, authCode: response.authCode, clientId: response.clientId, redirectUri: response.redirectUri, viewController: nil) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                    UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                    UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                    self.linkExternalWalletReceiver?(true, nil)
                    AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
            }
        }
    }

    func showActivatedAlert(walletType: String){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: String(format: Strings.link_wallet_success_msg, arguments: [walletType]), isFromLinkedWallet: true, handler: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: animationAlertController)
        animationAlertController.view!.layoutIfNeeded()
    }
    func checkAvailableRechargeWalletsValidOrNot(linkWallets: [String]) -> [String]{
        var tempWallets = [String]()
        for walletType in linkWallets{
            switch walletType{
            case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
                tempWallets.append(walletType)
            default: break
            }
        }
        return tempWallets
    }

    func checkAvailableRedemptionWalletsValidOrNot(linkWallets: [String]) -> [String]{
        var tempWallets = [String]()
        for walletType in linkWallets{
            switch walletType{
            case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
                tempWallets.append(walletType)
            default: break
            }
        }
        return tempWallets
    }

    func openUPIWalletLinkingViewController(type: String, linkExternalWalletReceiver : linkExternalWalletReciever?){

        let upiWalletLinkingViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UPIWalletLinkingViewController") as! UPIWalletLinkingViewController
        upiWalletLinkingViewController.initializeDataBeforePresenting(type: type, linkExternalWalletReceiver: linkExternalWalletReceiver)
        ViewControllerUtils.addSubView(viewControllerToDisplay: upiWalletLinkingViewController)
    }

    func checkAvailableUPIWalletValidOrNot(linkWallets: [String]) -> [String]{
        var tempWallets = [String]()
        for walletType in linkWallets{
            switch walletType{
            case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
                tempWallets.append(walletType)
            case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
                tempWallets.append(walletType)
            default: break
            }
        }
        return tempWallets
    }

    func generateOrderIDWithPrefix () -> String{
        AppDelegate.getAppDelegate().log.debug("generateOrderIDWithPrefix()")
        return QRSessionManager.getInstance()!.getUserId()+DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)!

    }

    func rechargeThroughPayTm(amount : Double,delegate : PGTransactionDelegate,custId : String,orderId : String) {
        let mc : PGMerchantConfiguration = PGMerchantConfiguration.default()
        let type :ServerType?
        let orderDict = NSMutableDictionary()
        if AppConfiguration.useProductionServerForPG{
            mc.checksumGenerationURL = AppConfiguration.checksumGenerationURL
            mc.checksumValidationURL = AppConfiguration.checksumValidationURL
            orderDict["MID"] = AppConfiguration.merchantId
            orderDict["WEBSITE"] = AppConfiguration.companyWebsite
            orderDict["INDUSTRY_TYPE_ID"] = AppConfiguration.industryTypeId
            type = eServerTypeProduction
        }else{
            mc.checksumGenerationURL = AppConfiguration.test_checksumGenerationURL
            mc.checksumValidationURL = AppConfiguration.test_checksumValidationURL
            orderDict["MID"] = AppConfiguration.test_merchantId
            orderDict["WEBSITE"] = AppConfiguration.test_companyWebsite
            orderDict["INDUSTRY_TYPE_ID"] = AppConfiguration.test_industryTypeId
            type = eServerTypeStaging
        }
        orderDict["CHANNEL_ID"] = AppConfiguration.channelId

        orderDict["TXN_AMOUNT"] = amount
        orderDict["ORDER_ID"] = orderId
        orderDict["REQUEST_TYPE"] = AppConfiguration.requestType
        orderDict["CUST_ID"] = custId

        let order : PGOrder = PGOrder(params: orderDict as [NSObject : AnyObject])

        let txnController = PGTransactionViewController(transactionFor: order)
        txnController?.serverType = type!
        txnController?.merchant = mc
        txnController?.delegate = delegate
        showPaytmController(controller: txnController!)
    }

    func showPaytmController(controller : PGTransactionViewController){
        AppDelegate.getAppDelegate().log.debug("showController()")

        topBar = UIView(frame: CGRect(x: 0, y: 20, width: ViewControllerUtils.getCenterViewController().view.frame.width, height: 44))
        topBar!.backgroundColor = UIColor.white
        let buttonBack : UIButton = UIButton(frame: CGRect(x: 0, y: 5, width: 30, height: 30))
        buttonBack.setImage(UIImage(named: "back"), for: UIControl.State.normal)
        buttonBack.addTarget(self, action: #selector(AccountUtils.btnBack(_:)), for: UIControl.Event.touchUpInside)
        topBar!.addSubview(buttonBack)

        controller.cancelButton = buttonBack

        ViewControllerUtils.getCenterViewController().navigationController?.view.addSubview(topBar!)
        PGTController = controller
        if ViewControllerUtils.getCenterViewController().navigationController != nil{
            ViewControllerUtils.getCenterViewController().navigationController?.pushViewController(controller, animated: false)
        }else{
            ViewControllerUtils.getCenterViewController().present(controller, animated: false, completion: { () -> Void in
            })
        }
    }

    func removeController(controller : PGTransactionViewController){
        AppDelegate.getAppDelegate().log.debug("removeController()")
        if ViewControllerUtils.getCenterViewController().navigationController != nil{
            ViewControllerUtils.getCenterViewController().navigationController?.popViewController(animated: false)
        }else{
            controller.dismiss(animated: false, completion: { () -> Void in
            })
        }
        topBar?.removeFromSuperview()
    }

    @objc func btnBack(_ sender: AnyObject){
        AppDelegate.getAppDelegate().log.debug("btnBack()")
        MessageDisplay.displayErrorAlertWithAction(title: Strings.oops, isDismissViewRequired : false, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: { (result) in
            if Strings.yes_caps == result{
                self.PGTController.navigationController?.popViewController(animated: false)
                self.topBar?.removeFromSuperview()
            }
        })
    }
    func showLinkedWalletExpiredAlert(viewController: UIViewController,linkExternalWalletReceiver : linkExternalWalletReciever?){
        let linkedWalletBalanceInsufficientAlertVC = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LinkedWalletBalanceInsufficientAlertViewController") as! LinkedWalletBalanceInsufficientAlertViewController
        linkedWalletBalanceInsufficientAlertVC.initializeView(titleString: Strings.wallet_expired){ (result) in
            if result == Strings.relink_caps{
                if let linkedWallet  = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
                    self.linkRequestedWallet(walletType: linkedWallet.type!, linkExternalWalletReceiver: linkExternalWalletReceiver)
                }
            }else if result == Strings.change_paymet_mode{
                self.showPaymentDrawer(handler: nil)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletBalanceInsufficientAlertVC)
    }
    func linkRequestedWallet(walletType: String, linkExternalWalletReceiver : linkExternalWalletReciever?){

        let linkWalletViewController = UIStoryboard(name: StoryBoardIdentifiers.accountsb_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LinkWalletViewController") as! LinkWalletViewController
        linkWalletViewController.initializeDataBeforePresenting(walletType: walletType, linkExternalWalletReciever: linkExternalWalletReceiver)
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkWalletViewController)

    }
    func checkAvailableRedemptionOptionsValidOrNot() -> [String]{
        var tempRedemptionOptions = [String]()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        guard let availableOptions = clientConfiguration.availableRedemptionOptions else {
            return tempRedemptionOptions
        }
        for option in availableOptions{
            switch option{
            case RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_HP_CARD:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_PAYTM:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_TMW:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_SODEXO:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_HP_PAY:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_IOCL:
                tempRedemptionOptions.append(option)
            case RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER:
                tempRedemptionOptions.append(option)
            default: break
            }
        }
        return tempRedemptionOptions
    }

    func checkAvailableRechargeOptionsValidOrNot() -> [String]{
        var tempRechargeOptions = [String]()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        guard let availableOptions = clientConfiguration.availableRechargeOptions else {
            return tempRechargeOptions
        }
        for option in availableOptions{
            switch option{
            case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM:
                tempRechargeOptions.append(option)
            case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_AMAZON_PAY:
                tempRechargeOptions.append(option)
            case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_FREECHARGE:
                tempRechargeOptions.append(option)
            default: break
            }
        }
        return tempRechargeOptions
    }

    func updateDefaultLinkedWallet(linkedWallet: LinkedWallet, viewController: UIViewController?, listener: LinkedWalletUpdateDelegate?){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateDefaultLinkedWallet(userId: QRSessionManager.getInstance()!.getUserId(), type: linkedWallet.type, viewController: viewController) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UserDataCache.getInstance()?.updateUserDefaultLinkedWallet(linkedWallet: linkedWallet)
                listener?.linkedWalletInfoChanged()
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    func removeLinkedWallet(linkedWallet: LinkedWallet,showError: Bool, viewController: UIViewController?, handler: linkedWalletActionCompletionHandler?){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.removeLinkedWalletOfUser(userId: QRSessionManager.getInstance()!.getUserId(), type: linkedWallet.type, viewController: viewController) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()?.deleteLinkedWallet(linkedWallet: linkedWallet)
                UserCoreDataHelper.deleteLinkedWallet(linkedWallet:linkedWallet)
                handler?(.success)
            }else{
                if showError {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
                handler?(.failed)
            }
        }
    }
    func isValidGpayUPIId(upiId: String) -> Bool{
        if GPaySuportedUPIId.contains(upiId){
            return true
        }
        return false
    }



    func checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: UIViewController?,foundNoSupportedWallet: Bool = false, handler: linkedWalletActionCompletionHandler?) {
        guard let allLinkedWallets = UserDataCache.getInstance()?.linkedWallets,allLinkedWallets.count > 0 else {
            if foundNoSupportedWallet {
                handler?(.addPayment)
            }else{
                handler?(.success)
            }
            return
        }
        var unsupported : [LinkedWallet] = []
        for linkedWallet in allLinkedWallets {
            if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_ANDROID || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_PHONEPE_ANDROID {
                unsupported.append(linkedWallet)
            }
        }
        if unsupported.count <= 0 {
            handler?(.success)
            return
        }
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        for wallet in unsupported {
            group.enter()
            queue.async {
                self.removeLinkedWallet(linkedWallet: wallet,showError: false, viewController: viewController, handler: {(result) in
                    group.leave()
                })
            }
        }
        group.notify(queue: queue) {
            handler?(.success)
        }
    }

 func checkEligibilityForLazypay(linkExternalWalletReceiver: linkExternalWalletReciever?){
          QuickRideProgressSpinner.startSpinner()
          AccountRestClient.getLazyPayDisplayEligibility(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo), viewController: nil) { (responseObject, error) in
              QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS"{
                    self.lazyPayRequestOTP(linkExternalWalletReceiver: linkExternalWalletReceiver)
                }else{
                    if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"]),responseError.errorCode == ServerErrorCodes.NOT_ELIGIBLE_FOR_LAZY_PAY_ERROR{
                        MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.lazypay_approval_failure_error, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, msgWithLinkText: "", isActionButtonRequired: true, viewController: nil){ (text) in
                        }
                    }else{
                       ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                    }
                }
            }else{
               ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
          }
      }
    func showPaymentConfirmationView(paymentInfo: [String: Any], rideId: Double?, handler: paymentActionCompletionHandler?) {
        let upiPaymentInitiationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "UPIPaymentConfirmationViewController") as! UPIPaymentInitiationViewController
        upiPaymentInitiationViewController.initializeData(paymentInfo: paymentInfo, rideId: rideId, actionCompletionHandler: handler)
        ViewControllerUtils.addSubView(viewControllerToDisplay: upiPaymentInitiationViewController)
    }
}
