//
//  RedeemPointsViewController.swift
//  Quickride
//
//  Created by Halesh on 07/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import TransitionButton

class RedeemPointsViewController: UIViewController,UITextFieldDelegate{

    //MARK: Outlets
    @IBOutlet weak var pointsTextField: UITextField!

    @IBOutlet weak var redeemOptionsTableView: UITableView!

    @IBOutlet weak var redeemOptionsTableViewHightConstraint: NSLayoutConstraint!

    @IBOutlet weak var redeemButton: TransitionButton!
    
    @IBOutlet weak var backButton: CustomUIButton!

    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!

    //MARK: Propertise
    private var redeemPointsViewModel = RedeemPointsViewModel()


    func initializeView(redeemOptions: [String],userAccount: Account,linkWalletReceiver: LinkWalletReceiver){
       redeemPointsViewModel.redeemOptions = redeemOptions
       redeemPointsViewModel.userAccount = userAccount
       redeemPointsViewModel.linkWalletReceiver = linkWalletReceiver
    }

    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
    }
    override func viewWillAppear(_ animated: Bool) {
        getPreferredFuelCompanyAndCardStatus()
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK: Methods
    private func setUpUi(){
        redeemOptionsTableViewHightConstraint.constant = CGFloat((redeemPointsViewModel.redeemOptions.count)*80)
        backButton.changeBackgroundColorBasedOnSelection()
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        pointsTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        continueActnColorChange()
    }

    func getPreferredFuelCompanyAndCardStatus(){
        guard let userId = QRSessionManager.getInstance()?.getUserId() else { return }
        redeemPointsViewModel.preferredFuelCardsAndStatus(userId: userId, viewController: self, delegate: self)
    }

    @IBAction func redeemButtonTapped(_ sender: TransitionButton) {
        pointsTextField.endEditing(true)
        if NumberUtils.validateTextFieldForSpecialCharacters(textField: pointsTextField , viewController: self){
            return
        }
        let points = pointsTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if let pointsFromTextField = points,let redeemPoints = Int(pointsFromTextField){
            redeemPointsViewModel.redeemablePoints = redeemPoints
        }else{
            MessageDisplay.displayAlert( messageString: Strings.amount_should_valid,viewController: self,handler: nil)
            return
        }
        if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil && !UserDataCache.LINK_WALLET_DIALOGUE_DISPLAY_STATUS && redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] != RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            AccountUtils().addLinkWalletSuggestionAlert(title: Strings.redeem_title, message: nil, viewController: self) { (walletAdded, walletType) in
                if walletAdded == true, let wallet = walletType{
                    self.redeemPointsViewModel.linkWalletReceiver!.linkWallet(walletType: wallet)
                }else if walletType != nil{
                    self.encashConfirmation(encashType: walletType!)
                }else{
                    self.encashPoints()
                }
            }
        }else{
            encashPoints()
        }
    }
    private func encashPoints() {
        AppDelegate.getAppDelegate().log.debug("encashPoints()")
        if redeemPointsViewModel.redeemablePoints <= 0{
            MessageDisplay.displayAlert( messageString : Strings.invalid_amount_redemption,viewController: self,handler: nil)
            return
        }
        if redeemPointsViewModel.redeemablePoints > Int(redeemPointsViewModel.userAccount!.earnedPoints) + Int(redeemPointsViewModel.userAccount?.purchasedPoints ?? 0) {
            MessageDisplay.displayAlert( messageString : Strings.encash_error_msgexceedbal,viewController: self,handler: nil)
            return
        }
        #if MYRIDE
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if  encashAmountEntered! < clientConfiguration!.minimumEncashableAmountForPayTm {
            let alertMsg =  Strings.min_encashable_points_msg + " " + String(clientConfiguration.minimumEncashableAmountForPayTm)
            MessageDisplay.displayAlert(messageString : alertMsg, viewController: self,handler: nil)
            return
        } else if encashInformation != nil && encashAmountEntered! > self.encashInformation!.redeemablePoints{
            MessageDisplay.displayAlert(messageString: Strings.more_than_encashable_points_msg_part1, viewController: self,handler: nil)
            return
        }else{
            var params = [String : String]()
            params[Account.FLD_ACCOUNT_ID] = self.userId
            params[Account.POINTS] = self.txtEncashPrice.text!
            params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_PEACH
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.postEncashRequest(body : params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
                self.handleEncashResponse(responseObject: responseObject, error: error)
            })
        }
        #else
        if redeemPointsViewModel.redeemablePoints > (redeemPointsViewModel.encashInformation.redeemablePoints + Int(redeemPointsViewModel.userAccount?.purchasedPoints ?? 0)){
            MessageDisplay.displayAlert(messageString: Strings.more_than_encashable_points_msg_part1, viewController: self,handler: nil)
            return
        }else{
            redeemPointsViewModel.rechargedPoints = redeemPointsViewModel.redeemablePoints - Int(redeemPointsViewModel.userAccount?.earnedPoints ?? 0)
            getTheRechargeAmount()
        }
        #endif
    }

    private func getTheRechargeAmount(){
        if redeemPointsViewModel.rechargedPoints > 0 && redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] != RedemptionRequest.REDEMPTION_TYPE_PAYTM && redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] != RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL && redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] != RedemptionRequest.REDEMPTION_TYPE_TMW && redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] != RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY{
            let rechargedAmountRedemedChargesDialouge = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RechargedAmountRedemedChargesDialouge") as! RechargedAmountRedemedChargesDialouge
            rechargedAmountRedemedChargesDialouge.initializeDataBeforePresentingView(rechargedAmount: redeemPointsViewModel.rechargedPoints, redemedPoints: String(redeemPointsViewModel.redeemablePoints),viewController: self, handler: { (result) in
                if result == Strings.confirm_caps{
                    if self.redeemPointsViewModel.redeemOptions[self.redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
                        self.encashThroughSodexoCard()
                    }else{
                        self.encashThroughPetroCard()
                    }
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rechargedAmountRedemedChargesDialouge)
        }else if redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] ==  RedemptionRequest.REDEMPTION_TYPE_PAYTM || redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL || redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_TMW || redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY{
            encashConfirmation(encashType: redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow])
        }else if redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            encashThroughSodexoCard()
        }else{
            self.encashThroughPetroCard()
        }
    }

    private func encashConfirmation(encashType: String){
        guard let phoneNumber = QRSessionManager.getInstance()?.getCurrentSession().contactNo else { return }
        let encashConfirmationViewController : EncashConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EncashConfirmationViewController") as! EncashConfirmationViewController
        encashConfirmationViewController.initializeDataBeforePresentingView(amount: String(redeemPointsViewModel.redeemablePoints),accountPhoneNo:phoneNumber ,redemptionOptionReceiver : self,encashType: encashType, rechargedPoints: redeemPointsViewModel.rechargedPoints)
        ViewControllerUtils.addSubView(viewControllerToDisplay: encashConfirmationViewController)
    }

    private func encashThroughPetroCard(){
        if redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD && redeemPointsViewModel.shellStatus == FuelCardRegistration.OPEN{
            let firstEncashVC = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "FirstEncashmentViewController") as! FirstEncashmentViewController
            firstEncashVC.initializeDataBeforePresentingView(preferredFuelCompany: redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow]) {(cardRegistered) in
                if cardRegistered{
                    self.redeemPointsViewModel.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: nil)
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: firstEncashVC)
        }else if redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow] == RedemptionRequest.REDEMPTION_TYPE_HP_CARD && redeemPointsViewModel.hpStatus == FuelCardRegistration.OPEN{
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.hp_fuel_card, aboutText: Strings.about_hp, stepsTitle: Strings.hp_steps_title, stepsText: Strings.hp_steps, contact: Strings.hp_contact_no, email: Strings.hp_email, fuelCardRegistrationReceiver: { (cardRegistered) in
                if cardRegistered{
                    let fuelCardRegistration = FuelCardRegistration(userId: ((QRSessionManager.getInstance()?.getUserId())!), preferredFuelCompany: self.redeemPointsViewModel.redeemOptions[self.redeemPointsViewModel.selectedRow], cardStatus: FuelCardRegistration.ACTIVE)
                    self.redeemPointsViewModel.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: fuelCardRegistration)
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }else{
            continueRedeemThroughPetroCard(fuelCardRegistration: nil)
        }
    }

    private func continueRedeemThroughPetroCard(fuelCardRegistration: FuelCardRegistration?){
        guard let userId = QRSessionManager.getInstance()?.getUserId() else { return }
        redeemPointsViewModel.redeemThroughShellAndHP(userId: userId, points: redeemPointsViewModel.redeemablePoints, redemptionType: redeemPointsViewModel.redeemOptions[redeemPointsViewModel.selectedRow], preferredFuelCompany: fuelCardRegistration?.preferredFuelCompany, cardStatus: fuelCardRegistration?.cardStatus, rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
    }

    private func encashThroughSodexoCard(){
        if redeemPointsViewModel.sodexoStatus == FuelCardRegistration.PENDING{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.sodexo_pending_msg, message2: nil, positiveActnTitle: Strings.cantact_support, negativeActionTitle : Strings.ok_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if result == Strings.cantact_support{
                    let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
                    sodexoRegistrationViewController.initializeView(cardStatus: self.redeemPointsViewModel.sodexoStatus, fuelCardRegistrationReceiver: {(completionStatus , error) in

                    })
                    ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
                }
            })
        }else if redeemPointsViewModel.sodexoStatus == FuelCardRegistration.ACTIVE{
            guard let userId = QRSessionManager.getInstance()?.getUserId() else { return }
            redeemPointsViewModel.redeemThroughSodexo(userId: userId, points: redeemPointsViewModel.redeemablePoints, redemptionType: RedemptionRequest.REDEMPTION_TYPE_SODEXO,rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
        }else if redeemPointsViewModel.sodexoStatus == FuelCardRegistration.OPEN{
            let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
            sodexoRegistrationViewController.initializeView(cardStatus: self.redeemPointsViewModel.sodexoStatus, fuelCardRegistrationReceiver: {(completionStatus , error) in

            })
            ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
        }else{
            getPreferredFuelCompanyAndCardStatus()
        }
    }

    private func checkAndMoveToProfile(){
        if QRSessionManager.getInstance() == nil{
            return
        }
        if let userProfileObject = UserDataCache.getInstance()?.getUserProfile(userId: QRSessionManager.getInstance()!.getUserId()){
            if userProfileObject.companyName == nil || userProfileObject.email == nil{
                let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
                self.navigationController?.pushViewController(vc, animated: false)
            }
            else{
                let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
                vc.initializeDataBeforePresentingView(profileId: QRSessionManager.getInstance()!.getUserId(), isRiderProfile: UserRole.None, rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView: false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }

    private func selectRedeemOptionBasedOnEncashType(){
        #if MYRIDE
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        txtEncashPrice.placeholder = Strings.points_redeem + String(clientConfiguration.minimumEncashableAmount) + " )"
        #else
        #endif
    }
//MARK: KeyBoard and TextField Methods
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        pointsTextField.delegate = self
        resignFirstResponder()
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton()
        continueActnColorChange()
        #if WERIDE
        ScrollViewUtils.scrollToPoint(scrollViewEncash, point: CGPoint(x: 0, y: 200))
        #else
        #endif
    }

    @objc func textFieldDidChange(textField : UITextField){
        continueActnColorChange()
        pointsTextField.becomeFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
        continueActnColorChange()
    }

    func addDoneButton(){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        pointsTextField.inputAccessoryView = keyToolBar
    }

    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if redeemPointsViewModel.isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        redeemPointsViewModel.isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceConstraint.constant = keyBoardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if redeemPointsViewModel.isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        redeemPointsViewModel.isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 0
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == pointsTextField{
            threshold = 6
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }

    private func continueActnColorChange(){
        if pointsTextField.text != nil && !pointsTextField.text!.isEmpty{
            CustomExtensionUtility.changeBtnColor(sender: redeemButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            redeemButton.isUserInteractionEnabled = true
        } else {
            CustomExtensionUtility.changeBtnColor(sender: redeemButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            redeemButton.isUserInteractionEnabled = false
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK:UITableViewDataSource
extension RedeemPointsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        redeemPointsViewModel.redeemOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! RedemptionOptionsTableViewCell

        if redeemPointsViewModel.redeemOptions.endIndex <= indexPath.row{
            return cell
        }
        var fuelCardStatus : String?
        switch redeemPointsViewModel.redeemOptions[indexPath.row] {
        case RedemptionRequest.REDEMPTION_TYPE_HP_CARD:
            fuelCardStatus = redeemPointsViewModel.hpStatus
        case RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD:
            fuelCardStatus = redeemPointsViewModel.shellStatus
        case RedemptionRequest.REDEMPTION_TYPE_SODEXO:
            fuelCardStatus = redeemPointsViewModel.sodexoStatus
        default:
            break
        }
        cell.initializeView(option: redeemPointsViewModel.redeemOptions[indexPath.row], selectedRow: redeemPointsViewModel.selectedRow, index : indexPath.row,cardStatus: fuelCardStatus, viewController: self)
        return cell
    }
}

//MARK:UITableViewDelegate
extension RedeemPointsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 25, y: 10, width: tableView.frame.size.width, height: 35))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 25, y: 10, width: tableView.frame.size.width - 10, height: 25))
        headerLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        headerLabel.text = Strings.select_Redemption_method.uppercased()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        headerView.addSubview(headerLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if redeemPointsViewModel.redeemOptions.endIndex <= indexPath.row{
            return
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? RedemptionOptionsTableViewCell{
            selectedCell.encashOptionSelectionImage.image = UIImage(named: "selected")
        }
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(item: redeemPointsViewModel.selectedRow, section: 0)) as? RedemptionOptionsTableViewCell{
            if redeemPointsViewModel.selectedRow != indexPath.row{
                prevSelectedCell.encashOptionSelectionImage.image = UIImage(named: "unselected")
            }
        }
        redeemPointsViewModel.selectedRow = indexPath.row
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
}

//MARK:RedeemPointsViewModelDelegate
extension RedeemPointsViewController: RedeemPointsViewModelDelegate{
    func handelSuccussResponse() {
        UserDataCache.getInstance()?.refreshAccountInformationInCache()
        FaceBookEventsLoggingUtils.logAmountDebitEvent(amount: Double(redeemPointsViewModel.redeemablePoints), currency: "INR")
        if RedemptionRequest.REDEMPTION_TYPE_TMW == redeemPointsViewModel.redemptionRequest?.type || RedemptionRequest.REDEMPTION_TYPE_PEACH == redeemPointsViewModel.redemptionRequest?.type || RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY == redeemPointsViewModel.redemptionRequest?.type{
            let tmwEncashSuccessViewController : TMWEncashSuccessViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWEncashSuccessViewController") as! TMWEncashSuccessViewController
            var message : String?
            guard let contactNo = redeemPointsViewModel.redeemOptionAccountNo else { return }
            if RedemptionRequest.REDEMPTION_TYPE_PEACH == redeemPointsViewModel.redemptionRequest?.type{
                message = String(format: Strings.redemption_success_peach, arguments: [String(redeemPointsViewModel.redeemablePoints)])
            }else if RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY == redeemPointsViewModel.redemptionRequest?.type{
                message = String(format: Strings.amazon_pay_encash_success, arguments: [String(redeemPointsViewModel.redeemablePoints),contactNo])
            }else{
                message = String(format: Strings.tmw_encash_success, arguments: [String(redeemPointsViewModel.redeemablePoints),contactNo])
            }
            tmwEncashSuccessViewController.initializeMessage(message: message!)
            self.navigationController?.view.addSubview(tmwEncashSuccessViewController.view)
            self.navigationController?.addChild(tmwEncashSuccessViewController)
        }else{
            if SharedPreferenceHelper.getDontShowReferMessage() == false{
                let dontShowAgainAlertDialouge = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "DontShowAgainAlertDialouge") as! DontShowAgainAlertDialouge
                dontShowAgainAlertDialouge.initializeDataBeforePersentingView(titlemsg:  "\(redeemPointsViewModel.redeemablePoints) \(Strings.points_encashed)", message: redeemPointsViewModel.getMessageOnEncashmentSuccess()+"\n"+Strings.redemption_sucess_msg, viewController: self, positiveActnTitle: Strings.refer, negativeActionTitle: Strings.later_caps, handler: { (result, checkBoxSelected) in
                    SharedPreferenceHelper.setDontShowReferMessage(status: checkBoxSelected)
                    if Strings.refer == result{
                        let shareEarnVC = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.shareEarnViewController)
                        self.navigationController?.pushViewController(shareEarnVC, animated: false)
                    }

                })
                ViewControllerUtils.addSubView(viewControllerToDisplay: dontShowAgainAlertDialouge)

            }else{
                MessageDisplay.displayErrorAlertWithAction(title : "\(redeemPointsViewModel.redeemablePoints) \(Strings.points_encashed)", isDismissViewRequired : false, message1: redeemPointsViewModel.getMessageOnEncashmentSuccess(), message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil, linkButtonText: nil, viewController: self, handler: { (result) in

                })
            }
        }
        pointsTextField.text = ""
        selectRedeemOptionBasedOnEncashType()
    }

    func handleFailureResponse() {
        let configuration = ConfigurationCache.getObjectClientConfiguration()
        MessageDisplay.displayErrorAlertWithAction(title: Strings.redemption_limit_alert, isDismissViewRequired: true, message1: String(format: Strings.min_redemption_for_unverified_user_alert, arguments: [String(configuration.minEncashableAmountForNonVerifiedUser), String(100)]), message2: nil, positiveActnTitle: Strings.verify_now_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler:{ (result) in
            if Strings.verify_now_caps == result{
                self.checkAndMoveToProfile()
            }
        })
    }

    func startAnimation() {
        redeemButton.startAnimation()
    }

    func stopAnimation() {
       redeemButton.stopAnimation()
    }
}

//MARK:RedemptionOptionReceiver
extension RedeemPointsViewController: RedemptionOptionReceiver{
    func redemptionOptionReceived(payTmAccountId : String, encashType : String){
        redeemPointsViewModel.redeemOptionAccountNo = payTmAccountId
        guard let userId = QRSessionManager.getInstance()?.getUserId() else { return }
        switch encashType {
        case EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM:
                AccountUtils().openWalletLinkingController(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM) { (walletAdded, walletType) in
                    if walletAdded == true{
                        self.redeemPointsViewModel.linkWalletReceiver?.linkWallet(walletType: encashType)
                    }
                }
        case EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW:
                AccountUtils().openWalletLinkingController(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_TMW) { (walletAdded, walletType) in
                    if walletAdded == true{
                        self.redeemPointsViewModel.linkWalletReceiver?.linkWallet(walletType: encashType)
                    }
                }
        case RedemptionRequest.REDEMPTION_TYPE_PAYTM:
            redeemPointsViewModel.redeemThroughSelectedOption(userId: userId, points:  redeemPointsViewModel.redeemablePoints, redemptionType: RedemptionRequest.REDEMPTION_TYPE_PAYTM, redeemOptionAccountNo: payTmAccountId, rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
        case RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL:
            redeemPointsViewModel.redeemThroughSelectedOption(userId: userId, points:  redeemPointsViewModel.redeemablePoints, redemptionType: RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL, redeemOptionAccountNo: payTmAccountId, rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
        case RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY:
            redeemPointsViewModel.redeemThroughSelectedOption(userId: userId, points: redeemPointsViewModel.redeemablePoints, redemptionType: RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY, redeemOptionAccountNo: payTmAccountId, rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
        case RedemptionRequest.REDEMPTION_TYPE_TMW:
            redeemPointsViewModel.redeemThroughSelectedOption(userId: userId, points: redeemPointsViewModel.redeemablePoints, redemptionType: RedemptionRequest.REDEMPTION_TYPE_TMW, redeemOptionAccountNo: payTmAccountId, rechargedPoints: redeemPointsViewModel.rechargedPoints, viewController: self, delegate: self)
        default:
            break
        }
    }
}

//MARK:RedemptionOptionReceiver
extension RedeemPointsViewController: GetFuelCardsAndStatus{
    func handaleSuccussResponse() {
        redeemOptionsTableView.reloadData()
    }
}
