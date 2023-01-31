//
//  EncashPaymentViewController.swift
//  PlacesLookup
//
//  Created by Swagat Kumar Bisoyi on 10/22/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Social

class EncashPaymentViewController: WalletLinkingViewController,UITextFieldDelegate,PayTmRedemptionReceiver, LinkedWalletUpdateDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var scrollViewEncash: UIScrollView!
    
    @IBOutlet weak var labelAvailablePoints: UILabel!
    
    @IBOutlet weak var txtEncashPrice: UITextField!
    
    @IBOutlet var encashButton: UIButton!
    
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var encashButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var enterPointsView: UIView!
    
    @IBOutlet weak var enterPointsHeightContstraint: NSLayoutConstraint!
    
    @IBOutlet weak var encashButtonTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelEarnedPoolPoints: UILabel!
    
    @IBOutlet weak var walletHeadingView: UIView!
    
    @IBOutlet weak var walletHeadingViewHeightContstraint: NSLayoutConstraint!
    
    var encashInformation : EncashInformation?
    var topViewController : PaymentViewController?
    var userAccount : Account?
    var phoneNo : String?
    var userId : String?
    var clientConfiguration :ClientConfigurtion?
    
    static let ENCASH_TYPE_PEACH_PAYMENT = "PEACH"
    static let ENCASH_TYPE_LINKED_PAYTM = "LINKEDPAYTM"
    static let ENCASH_TYPE_LINKED_TMW = "LINKEDTMW"
    private var redemptionRequest : RedemptionRequest?
    private var firstRedemption = false
    private var tmwAccountId : String?
    private var rechargedPoints = 0
    private var isKeyBoardVisible : Bool = false
    private var encashOptions = [String]()
    private var isSelected = [Int : Bool]()
    private var selectedRow: Int?
    private var sodexoStatus : String?
    private var shellStatus : String?
    private var hpStatus : String?
    private var hpPayStatus: String?
    private var IOCLStatus: String?
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        self.encashOptions = AccountUtils().checkAvailableRedemptionOptionsValidOrNot()
        if !self.encashOptions.isEmpty{
            encashButton.isHidden = false
            encashButtonHeightConstraint.constant = 40
            enterPointsView.isHidden = false
            enterPointsHeightContstraint.constant = 40
            tableViewHeightConstraint.constant = CGFloat(self.encashOptions.count*60)
            encashButtonTopSpaceConstraint.constant = 20
            tableViewTopSpaceConstraint.constant = 20
            selectedRow = 0
            tableView.delegate = self
            tableView.dataSource = self
        }else{
            encashButton.isHidden = true
            encashButtonHeightConstraint.constant = 0
            enterPointsView.isHidden = true
            enterPointsHeightContstraint.constant = 0
            tableViewHeightConstraint.constant = 0
            encashButtonTopSpaceConstraint.constant = 0
            tableViewTopSpaceConstraint.constant = 0
        }
        linkedWalletTableView.register(UINib(nibName: "LinkedWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "LinkedWalletXibTableViewCell")
        self.phoneNo = QRSessionManager.getInstance()!.getCurrentSession().contactNo
        self.userId = QRSessionManager.getInstance()!.getUserId()
        clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        txtEncashPrice.delegate = self
        scrollViewEncash.isScrollEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(EncashPaymentViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EncashPaymentViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: encashButton, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.encashButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
           return self.encashOptions.count
        }else if tableView == redemptionLinkWalletTableView{
            return redemptionLinkWalletOptions.count
        }
        else{
           return linkedWallets.count
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! RedemptionOptionsTableViewCell
            
            if encashOptions.endIndex <= indexPath.row{
                return cell
            }
            var fuelCardStatus : String?
            if encashOptions[indexPath.row] == RedemptionRequest.REDEMPTION_TYPE_HP_CARD{
                fuelCardStatus = hpStatus
            }else if encashOptions[indexPath.row] == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
                fuelCardStatus = shellStatus
            }else if encashOptions[indexPath.row] == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
                fuelCardStatus = sodexoStatus
            }else if encashOptions[indexPath.row] == RedemptionRequest.REDEMPTION_TYPE_HP_PAY{
                fuelCardStatus = hpPayStatus
            } else if  encashOptions[indexPath.row] == RedemptionRequest.REDEMPTION_TYPE_IOCL && !SharedPreferenceHelper.getUserRegisteredForIOCL() {
                fuelCardStatus = IOCLStatus
            }
        cell.initializeView(option: encashOptions[indexPath.row], selectedRow: self.selectedRow!, index : indexPath.row,cardStatus: fuelCardStatus, viewController: self)
            return cell
        }else if tableView == redemptionLinkWalletTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: redemptionLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: true, viewController: self,linkWalletReceiver: nil)
            if indexPath.row == redemptionLinkWalletOptions.endIndex - 1{
                cell.separatorView.isHidden = true
            }else{
                cell.separatorView.isHidden = false
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedWalletXibTableViewCell", for: indexPath as  IndexPath) as! LinkedWalletXibTableViewCell
            if linkedWallets.endIndex <= indexPath.row{
                return cell
            }
            cell.initializeDataInCell(linkedWallet: linkedWallets[indexPath.row], showSelectButton: false,viewController: self, listener: self)
            if indexPath.row == linkedWallets.endIndex - 1{
                cell.separatorView.isHidden = true
            }else{
                cell.separatorView.isHidden = false
            }
            return cell
        }
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == self.tableView{
            if encashOptions.endIndex <= indexPath.row{
                return
            }
            if let selectedCell = tableView.cellForRow(at: indexPath) as? RedemptionOptionsTableViewCell{
                selectedCell.encashOptionSelectionImage.image = UIImage(named: "selected")
            }
            if let prevSelectedCell = tableView.cellForRow(at: IndexPath(item: selectedRow!, section: 0)) as? RedemptionOptionsTableViewCell{
                if selectedRow != indexPath.row{
                    prevSelectedCell.encashOptionSelectionImage.image = UIImage(named: "unselected")
                }
            }
            selectedRow = indexPath.row
            tableView.deselectRow(at: indexPath, animated: false)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        refreshAccountInfo()
    }
    
    func refreshAccountInfo() {
        AppDelegate.getAppDelegate().log.debug("refreshAccountInfo()")
        UserDataCache.getInstance()?.getAccountInformation(completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil{
                self.userAccount = responseObject
                let availablePoints: Double?
                if AccountUtils().checkAvailableRechargeOptionsValidOrNot().isEmpty{
                    availablePoints = self.userAccount!.earnedPoints + self.userAccount!.purchasedPoints
                    self.labelAvailablePoints.text = StringUtils.getPointsInDecimal(points: availablePoints!)
                }
                else{
                    availablePoints = self.userAccount!.earnedPoints
                    self.labelAvailablePoints.text = StringUtils.getPointsInDecimal(points: availablePoints!)
                }
                self.handleHidingOfEarnedPointsView(availablePoints: availablePoints!)
            }
        })
       self.getPreferredFuelCompanyAndCardStatus()
        checkCurrentUserIsRegisteredForNEFTBank()
    }
    
    func getPreferredFuelCompanyAndCardStatus(){
        AccountRestClient.getEncashInformation(accountid: self.userId!,targetViewController : self,completionHandler : {
            (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.encashInformation = Mapper<EncashInformation>().map(JSONObject: responseObject!["resultData"])! as EncashInformation
                self.sodexoStatus = FuelCardRegistration.OPEN
                self.shellStatus = FuelCardRegistration.OPEN
                self.hpStatus = FuelCardRegistration.OPEN
                self.hpPayStatus = FuelCardRegistration.OPEN
                self.IOCLStatus = FuelCardRegistration.OPEN
                if self.encashInformation != nil && self.encashInformation!.fuelCardRegistrations != nil{
                    for fuelCardReg in self.encashInformation!.fuelCardRegistrations!{
                        if fuelCardReg.preferredFuelCompany?.uppercased() == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
                            self.sodexoStatus = fuelCardReg.cardStatus
                        }else if fuelCardReg.preferredFuelCompany?.uppercased() == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
                            self.shellStatus = fuelCardReg.cardStatus
                        }else if fuelCardReg.preferredFuelCompany?.uppercased() == RedemptionRequest.REDEMPTION_TYPE_HP_CARD{
                            self.hpStatus = fuelCardReg.cardStatus
                        }else if fuelCardReg.preferredFuelCompany?.uppercased() == RedemptionRequest.REDEMPTION_TYPE_HP_PAY{
                            self.hpPayStatus = fuelCardReg.cardStatus
                            SharedPreferenceHelper.storeHpPayApiCallStatus(status: true)
                        } else if fuelCardReg.preferredFuelCompany?.uppercased() == RedemptionRequest.REDEMPTION_TYPE_IOCL {
                            self.IOCLStatus = fuelCardReg.cardStatus
                            SharedPreferenceHelper.setUserRegisteredForIOCL(status: true)
                        }
                    }
                }
                self.tableView.reloadData()
                self.tableViewHeightConstraint.constant = CGFloat(self.encashOptions.count*60)
            }
            self.checkCurrentUserIsRegisteredForIOCL()
            self.checkCurrentUserIsRegisteredForHPPay()
        })
    }
    
    private func checkCurrentUserIsRegisteredForIOCL() {
        if !SharedPreferenceHelper.getUserRegisteredForIOCL(),let userId = SharedPreferenceHelper.getLoggedInUserId(), let mobileNumber = SharedPreferenceHelper.getLoggedInUserContactNo() {
            AccountRestClient.checkAndRegisterForIOCLFuleCard(firstName: SharedPreferenceHelper.getLoggedInUserName(), lastName: nil, newProfile:  false, userId: userId, mobileNo: mobileNumber) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    SharedPreferenceHelper.setUserRegisteredForIOCL(status: true)
                    if let resultData = responseObject!["resultData"],let fuelCardRegistration = Mapper<FuelCardRegistration>().map(JSONObject: resultData){
                        self.IOCLStatus = fuelCardRegistration.cardStatus
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func checkCurrentUserIsRegisteredForHPPay(){
        if !SharedPreferenceHelper.getHpPayApiCallStatus(){
            AccountRestClient.checkCurrentUserIsHpPayCustomer(userId: QRSessionManager.getInstance()?.getUserId() ?? "", mobileNo: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.currentUser?.contactNo)) { (responseObject, error) in
                SharedPreferenceHelper.storeHpPayApiCallStatus(status: true)
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let resultData = responseObject!["resultData"], let fuelCardRegistration = Mapper<FuelCardRegistration>().map(JSONObject: resultData){
                        self.hpPayStatus = fuelCardRegistration.cardStatus
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    private func checkCurrentUserIsRegisteredForNEFTBank() {
        if !SharedPreferenceHelper.getBankRegistration() {
            AccountRestClient.getBankRegistrationDetails(userId: UserDataCache.getInstance()?.userId ?? "") { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS",responseObject!["resultData"] != nil {
                    SharedPreferenceHelper.setBankRegistration(status: true)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        txtEncashPrice.delegate = self
        resignFirstResponder()
        return false
    }

    override func handleAddWallet(){
        var redemptionLinkWallets = [LinkedWallet]()
        for linkedWallet in linkedWallets{
            if !self.redemptionLinkWalletOptions.isEmpty && redemptionLinkWalletOptions.contains(linkedWallet.type!){
                redemptionLinkWallets.append(linkedWallet)
            }
        }
        if redemptionLinkWallets.isEmpty{
            linkedWallets = redemptionLinkWallets
            linkedWalletTableView.isHidden = true
            linkedWalletTableViewHeightConstraint.constant = 0
        }
        else{
            linkedWallets = redemptionLinkWallets
            linkedWalletTableView.isHidden = false
            linkedWalletTableViewHeightConstraint.constant = CGFloat(redemptionLinkWallets.count * 72)
        }
        linkedWalletTableView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton()
    }
    
    func addDoneButton(){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        txtEncashPrice.inputAccessoryView = keyToolBar
    }
   
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceConstraint.constant = keyBoardSize.height
            
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnEncashTapped(_ sender: Any) {
        if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil && !UserDataCache.LINK_WALLET_DIALOGUE_DISPLAY_STATUS && encashOptions[self.selectedRow!] != RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            self.txtEncashPrice.endEditing(true)
            if NumberUtils.validateTextFieldForSpecialCharacters(textField: txtEncashPrice , viewController: self){
                return
            }
            let encashAmtStr = txtEncashPrice.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines
            )
            if (encashAmtStr == nil || encashAmtStr!.isEmpty == true || Int(encashAmtStr!) == nil) {
                MessageDisplay.displayAlert( messageString: Strings.amount_should_valid,viewController: self,handler: nil)
                return
            }
            AccountUtils().addLinkWalletSuggestionAlert(title: Strings.redeem_title, message: nil, viewController: self) { (walletAdded, walletType) in
                if walletAdded{
                    self.walletAddedOrDeleted()
                }
                else if walletType != nil{
                    self.encashConfirmation(encashType: walletType!)
                }
                else{
                    self.encashPoints()
                }
            }
        }else{
            encashPoints()
        }
        
    }
    func getTheRechargeAmount(encash_points : String){
        if self.rechargedPoints > 0 && self.encashOptions[self.selectedRow!] != RedemptionRequest.REDEMPTION_TYPE_PAYTM && self.encashOptions[self.selectedRow!] != RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL && self.encashOptions[self.selectedRow!] != RedemptionRequest.REDEMPTION_TYPE_TMW && self.encashOptions[self.selectedRow!] != RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY{
            let rechargedAmountRedemedChargesDialouge = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RechargedAmountRedemedChargesDialouge") as! RechargedAmountRedemedChargesDialouge
            rechargedAmountRedemedChargesDialouge.initializeDataBeforePresentingView(rechargedAmount: self.rechargedPoints, redemedPoints: self.txtEncashPrice.text!,viewController: self, handler: { (result) in
                if result == Strings.confirm_caps{
                    if self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
                        self.encashThroughSodexoCard()
                    }
                    else{
                        self.encashThroughPetroCard(encash_points: encash_points)
                    }
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rechargedAmountRedemedChargesDialouge)
        }else if self.encashOptions[self.selectedRow!] ==  RedemptionRequest.REDEMPTION_TYPE_PAYTM || self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL || self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_TMW || self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || encashOptions[selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            self.encashConfirmation(encashType: self.encashOptions[self.selectedRow!])
        }else if self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            encashThroughSodexoCard()
        }else{
            self.encashThroughPetroCard(encash_points: encash_points)
        }
    }
    
    func payTmRedemptionReceived(payTmAccountId : String, encashType : String)
    {
        self.tmwAccountId = payTmAccountId
        if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM{
            AccountUtils().linkRequestedWallet(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM) { (walletAdded, walletType) in
                if walletAdded{
                    self.walletAddedOrDeleted()
                }
            }
        }
        else if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW{
            AccountUtils().linkRequestedWallet(walletType: AccountTransaction.TRANSACTION_WALLET_TYPE_TMW) { (walletAdded, walletType) in
                if walletAdded{
                    self.walletAddedOrDeleted()
                }
            }
        }
        else if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM || encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
        {
            var params : [String : String] = [String : String]()
            params[Account.FLD_ACCOUNT_ID] = self.userId
            params[Account.POINTS] = self.txtEncashPrice.text!
            params[Account.CONTACT_NO] = payTmAccountId
            if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM{
               params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_PAYTM
            }else{
               params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
            }
           if rechargedPoints > 0{
                params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
            }
            else{
                params[Account.RECHARGED_AMOUNT] = nil
            }
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.postEncashRequest(body: params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
                self.handleEncashResponse(responseObject: responseObject, error: error)
            })
        }else if encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY{
                var params = [String : String]()
                params[Account.FLD_ACCOUNT_ID] = self.userId
                params[Account.POINTS] = self.txtEncashPrice.text!
                params[Account.CONTACT_NO] = payTmAccountId
                params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY
                if rechargedPoints > 0{
                    params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
                }
                else{
                    params[Account.RECHARGED_AMOUNT] = nil
                }
                QuickRideProgressSpinner.startSpinner()
                AccountRestClient.postEncashRequest(body : params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
                    self.handleEncashResponse(responseObject: responseObject, error: error)
                })
        }else if encashType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            checkRegistrationAndRedeemThroughBank()
        }
        else
        {
            var params = [String : String]()
            params[Account.FLD_ACCOUNT_ID] = self.userId
            params[Account.POINTS] = self.txtEncashPrice.text!
            params[Account.CONTACT_NO] = payTmAccountId
            params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_TMW
            if rechargedPoints > 0{
                params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
            }
            else{
                params[Account.RECHARGED_AMOUNT] = nil
            }
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.postEncashRequest(body : params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
                self.handleEncashResponse(responseObject: responseObject, error: error)
            })
            
        }
    }
    private func encashPoints() {
        AppDelegate.getAppDelegate().log.debug("encashPoints()")
        
        self.txtEncashPrice.endEditing(true)
        
        if NumberUtils.validateTextFieldForSpecialCharacters(textField: txtEncashPrice , viewController: self){
            return
        }
        
        let encashAmtStr = txtEncashPrice.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines
        )
        
        if (encashAmtStr == nil || encashAmtStr!.isEmpty == true) {
            MessageDisplay.displayAlert( messageString: Strings.amount_should_valid,viewController: self,handler: nil)
            return
        }
        
        let encashAmountEntered = Int(encashAmtStr!)
        
        if encashAmountEntered == nil || encashAmountEntered! <= 0
        {
            MessageDisplay.displayAlert( messageString : Strings.invalid_amount_redemption,viewController: self,handler: nil)
            return
        }
        if encashAmountEntered! > Int(self.userAccount!.earnedPoints) + Int(self.userAccount!.purchasedPoints)
        {
            MessageDisplay.displayAlert( messageString : Strings.encash_error_msgexceedbal,viewController: self,handler: nil)
            return
        }
        
        if encashInformation != nil && encashAmountEntered! > (self.encashInformation!.redeemablePoints + Int(self.userAccount!.purchasedPoints)){
            MessageDisplay.displayAlert(messageString: Strings.more_than_encashable_points_msg_part1, viewController: self,handler: nil)
            return
        }else{
            rechargedPoints = encashAmountEntered! - Int(self.userAccount!.earnedPoints)
            getTheRechargeAmount(encash_points: String(encashAmountEntered!))
        }
    }
    func checkAndMoveToProfile(){
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
                vc.initializeDataBeforePresentingView(profileId: QRSessionManager.getInstance()!.getUserId(), isRiderProfile: UserRole.None, rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView: false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    
    func generateOrderIDWithPrefix () -> String{
        AppDelegate.getAppDelegate().log.debug("generateOrderIDWithPrefix()")
        return QRSessionManager.getInstance()!.getUserId()+DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)!
    }
    func encashConfirmation(encashType: String)
    {
        let encashConfirmationViewController : EncashConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EncashConfirmationViewController") as! EncashConfirmationViewController
        encashConfirmationViewController.initializeDataBeforePresentingView(amount: self.txtEncashPrice.text,userId: self.phoneNo!,payTmRedemptionReceiver : self,encashType: encashType, rechargedPoints: rechargedPoints)
        ViewControllerUtils.addSubView(viewControllerToDisplay: encashConfirmationViewController)
    }
    
    private func encashThroughPetroCard(encash_points : String)
    {
        if self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD && shellStatus == FuelCardRegistration.OPEN{
            let firstEncashVC = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "FirstEncashmentViewController") as! FirstEncashmentViewController
            firstEncashVC.initializeDataBeforePresentingView(preferredFuelCompany: encashOptions[selectedRow!]) {(cardRegistered) in
                if cardRegistered{
                    self.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: nil)
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: firstEncashVC)
        }else if self.encashOptions[self.selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_HP_CARD && hpStatus == FuelCardRegistration.OPEN{
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.hp_fuel_card, aboutText: Strings.about_hp, stepsTitle: Strings.hp_steps_title, stepsText: Strings.hp_steps, contact: Strings.hp_contact_no, email: Strings.hp_email, fuelCardRegistrationReceiver: { (cardRegistered) in
                if cardRegistered{
                    let fuelCardRegistration = FuelCardRegistration(userId: ((QRSessionManager.getInstance()?.getUserId())!), preferredFuelCompany: self.encashOptions[self.selectedRow!], cardStatus: FuelCardRegistration.ACTIVE)
                    self.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: fuelCardRegistration)
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }else if encashOptions[selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_HP_PAY && hpPayStatus == FuelCardRegistration.OPEN {
            let hPPayRegistrationViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "HPPayRegistrationViewController") as! HPPayRegistrationViewController
            hPPayRegistrationViewController.initializeDataBeforePresentingView() {(cardRegistered) in
                if cardRegistered{
                    self.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: nil)
                }
            }
            self.navigationController?.pushViewController(hPPayRegistrationViewController, animated: false)
        } else if encashOptions[selectedRow!] == RedemptionRequest.REDEMPTION_TYPE_IOCL && !SharedPreferenceHelper.getUserRegisteredForIOCL() {
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.iocl_fuel_card, aboutText: Strings.about_iocl, stepsTitle: Strings.iocl_steps_title, stepsText: Strings.iocl_steps, contact: RedemptionRequest.iocl_toll_free, email: RedemptionRequest.iocl_email, fuelCardRegistrationReceiver: { (cardRegistered) in
                if cardRegistered{
                    let fuelCardRegistration = FuelCardRegistration(userId: ((QRSessionManager.getInstance()?.getUserId())!), preferredFuelCompany: self.encashOptions[self.selectedRow!], cardStatus: FuelCardRegistration.ACTIVE)
                    self.firstRedemption = true
                    self.continueRedeemThroughPetroCard(fuelCardRegistration: fuelCardRegistration)
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }else{
            continueRedeemThroughPetroCard(fuelCardRegistration: nil)
        }
    }
    func continueRedeemThroughPetroCard(fuelCardRegistration: FuelCardRegistration?){
        var params = [String : String]()
        params[Account.FLD_ACCOUNT_ID] = self.userId
        params[Account.POINTS] = self.txtEncashPrice.text!
        params[RedemptionRequest.TYPE] = self.encashOptions[self.selectedRow!]
        params[FuelCardRegistration.PREFERRED_FUEL_COMPANY] = fuelCardRegistration?.preferredFuelCompany
        params[FuelCardRegistration.CARD_STATUS] = fuelCardRegistration?.cardStatus
        if rechargedPoints > 0{
            params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
        }else{
            params[Account.RECHARGED_AMOUNT] = nil
        }
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.postEncashRequest(body : params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
            self.handleEncashResponse(responseObject: responseObject, error: error)
        })
    }

    private func handleEncashResponse(responseObject: NSDictionary?, error: NSError?) {
        QuickRideProgressSpinner.stopSpinner()
        if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS"{
            self.redemptionRequest = Mapper<RedemptionRequest>().map(JSONObject: responseObject!["resultData"])! as RedemptionRequest
            UserDataCache.getInstance()?.refreshAccountInformationInCache()
            if self.labelAvailablePoints.text != "" && self.txtEncashPrice.text != ""
            {
                var remainingBalance = Double(self.labelAvailablePoints.text!)! - Double(self.txtEncashPrice.text!)!
                if remainingBalance < 0{
                    remainingBalance = 0.0
                }
                self.labelAvailablePoints.text = StringUtils.getPointsInDecimal(points: remainingBalance)
                self.handleHidingOfEarnedPointsView(availablePoints: remainingBalance)
            }
            FaceBookEventsLoggingUtils.logAmountDebitEvent(amount: Double(self.txtEncashPrice.text!)!, currency: "INR")
            if RedemptionRequest.REDEMPTION_TYPE_TMW == redemptionRequest?.type || RedemptionRequest.REDEMPTION_TYPE_PEACH == redemptionRequest?.type || RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY == redemptionRequest?.type
            {
                let tmwEncashSuccessViewController : TMWEncashSuccessViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWEncashSuccessViewController") as! TMWEncashSuccessViewController
                var message : String?
                if RedemptionRequest.REDEMPTION_TYPE_PEACH == redemptionRequest?.type
                {
                    message = String(format: Strings.redemption_success_peach, arguments: [self.txtEncashPrice.text!])
                }else if RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY == redemptionRequest?.type
                {
                    message = String(format: Strings.amazon_pay_encash_success, arguments: [self.txtEncashPrice.text!,self.tmwAccountId!])
                }
                else
                {
                    message = String(format: Strings.tmw_encash_success, arguments: [self.txtEncashPrice.text!,self.tmwAccountId!])
                }
                tmwEncashSuccessViewController.initializeMessage(message: message!)
                self.navigationController?.view.addSubview(tmwEncashSuccessViewController.view)
                self.navigationController?.addChild(tmwEncashSuccessViewController)
            }
            else
            {
                if SharedPreferenceHelper.getDontShowReferMessage() == false{
                    let dontShowAgainAlertDialouge = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "DontShowAgainAlertDialouge") as! DontShowAgainAlertDialouge
                    dontShowAgainAlertDialouge.initializeDataBeforePersentingView(titlemsg:  "\(txtEncashPrice.text!) \(Strings.points_encashed)", message: getMessageOnEncashmentSuccess()+"\n"+Strings.redemption_sucess_msg, viewController: self, positiveActnTitle: Strings.refer, negativeActionTitle: Strings.later_caps, handler: { (result, checkBoxSelected) in
                        SharedPreferenceHelper.setDontShowReferMessage(status: checkBoxSelected)
                        if Strings.refer == result{
                            let shareEarnVC = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController)
                            self.navigationController?.pushViewController(shareEarnVC, animated: false)
                        }
                        
                    })
                    ViewControllerUtils.addSubView(viewControllerToDisplay: dontShowAgainAlertDialouge)
                    
                }
                else{
                    MessageDisplay.displayErrorAlertWithAction(title : "\(txtEncashPrice.text!) \(Strings.points_encashed)", isDismissViewRequired : false, message1: getMessageOnEncashmentSuccess(), message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil, linkButtonText: nil, viewController: self, handler: { (result) in
                        
                    })
                }
            }
            txtEncashPrice.text = ""
        } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
            let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
            if responseError?.errorCode == ServerErrorCodes.UNVERIFIED_USER_REDEEM_LIMITATION_ERROR {
                var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
                if clientConfiguration == nil{
                    clientConfiguration = ClientConfigurtion()
                }
                MessageDisplay.displayErrorAlertWithAction(title: Strings.redemption_limit_alert, isDismissViewRequired: true, message1: String(format: Strings.min_redemption_for_unverified_user_alert, arguments: [String(clientConfiguration!.minEncashableAmountForNonVerifiedUser), String(100)]), message2: nil, positiveActnTitle: Strings.verify_now_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler:{ (result) in
                    if Strings.verify_now_caps == result{
                        self.checkAndMoveToProfile()
                    }
                })
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        } else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    
    func handleHidingOfEarnedPointsView(availablePoints: Double){
        if availablePoints == 0.0 && self.encashOptions.isEmpty{
            self.labelEarnedPoolPoints.isHidden = true
            self.labelAvailablePoints.isHidden = true
        }
        else{
            self.labelEarnedPoolPoints.isHidden = false
            self.labelAvailablePoints.isHidden = false
        }
    }
    func getMessageOnEncashmentSuccess() -> String{
        var description : String
        
        if firstRedemption == false{
            if(RedemptionRequest.REDEMPTION_TYPE_PAYTM == redemptionRequest?.type && RedemptionRequest.REDEMPTION_REQUEST_STATUS_PROCESSED == redemptionRequest?.status){
                description = Strings.paytm_encash_success_message
            }else if RedemptionRequest.REDEMPTION_TYPE_PAYTM == redemptionRequest!.type && RedemptionRequest.REDEMPTION_REQUEST_STATUS_REVIEW == redemptionRequest!.status{
                description = Strings.paytm_encash_review_message
            }else{
                description = Strings.encash_success_message
            }
        }else if redemptionRequest?.type == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
            description = Strings.first_encash_success_message
            self.firstRedemption = false
        }else if redemptionRequest?.type == RedemptionRequest.REDEMPTION_TYPE_HP_PAY{
            self.firstRedemption = false
            description = Strings.encash_success_message
        }else{
            description = Strings.hp_first_encash_success
            self.firstRedemption = false
        }
        return description
    }
    
    @objc func transactionTapped(_ sender: UIGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("transactionTapped()")
        if QRReachability.isConnectedToNetwork() == false{
            txtEncashPrice.endEditing(false)
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
            return
        }
        let transactionVC : RedemptionsHistoryViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RedemptionsHistoryViewController") as! RedemptionsHistoryViewController
        self.navigationController?.pushViewController(transactionVC, animated: false)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == txtEncashPrice{
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

    func linkedWalletInfoChanged() {
        checkWhetherWalletLinkedAndAdjustViews()
    }
    
    override func checkWhetherWalletLinkedAndAdjustViews() {
        super.checkWhetherWalletLinkedAndAdjustViews()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if let linkedWallets = UserDataCache.getInstance()?.getAllLinkedWallets(), linkedWallets.count > 0{
            for linkedWallet in linkedWallets{
                if !clientConfiguration.availableRedemptionWalletOptions.contains(linkedWallet.type!) {
                    linkedWalletTitle.isHidden = true
                }else {
                    linkedWalletTitle.isHidden = false
                }
            }
        }else {
            linkedWalletTitle.isHidden = true
        }
    }
    
    override func handleTableViewAfterLinkAndDelete(){
        if redemptionLinkWalletOptions.isEmpty{
            redemptionLinkWalletTableView.isHidden = true
            redemptionLinkWalletTableViewHieghtConstraint.constant = 0
            walletHeadingView.isHidden = true
            walletHeadingViewHeightContstraint.constant = 0
        }else{
            redemptionLinkWalletTableView.register(UINib(nibName: "AllLinkWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "AllLinkWalletXibTableViewCell")
            redemptionLinkWalletTableView.isHidden = false
            walletHeadingView.isHidden = false
            walletHeadingViewHeightContstraint.constant = 80
            redemptionLinkWalletTableView.delegate = self
            redemptionLinkWalletTableView.dataSource = self
            redemptionLinkWalletTableView.reloadData()
            redemptionLinkWalletTableViewHieghtConstraint.constant = CGFloat(redemptionLinkWalletOptions.count*85)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(netHex: 0xe9e9e9)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
    
    func encashThroughSodexoCard(){
        if sodexoStatus == FuelCardRegistration.PENDING{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.sodexo_pending_msg, message2: nil, positiveActnTitle: Strings.cantact_support, negativeActionTitle : Strings.ok_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if result == Strings.cantact_support{
                    let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
                    sodexoRegistrationViewController.initializeView(cardStatus: self.sodexoStatus)
                    ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
                }
            })
        }else if sodexoStatus == FuelCardRegistration.ACTIVE{
            var params = [String : String]()
            params[Account.FLD_ACCOUNT_ID] = self.userId
            params[Account.POINTS] = self.txtEncashPrice.text!
            params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_SODEXO
            if rechargedPoints > 0{
                params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
            }
            else{
                params[Account.RECHARGED_AMOUNT] = nil
            }
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.postEncashRequest(body : params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
                self.handleEncashResponse(responseObject: responseObject, error: error)
            })
        }else if sodexoStatus == FuelCardRegistration.OPEN{
            let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
            sodexoRegistrationViewController.initializeView(cardStatus: self.sodexoStatus)
            ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
        }else{
            getPreferredFuelCompanyAndCardStatus()
        }
    }
    
    override func walletAddedOrDeleted() {
        super.walletAddedOrDeleted()
    }
    
    private func checkRegistrationAndRedeemThroughBank(){
        if SharedPreferenceHelper.getBankRegistration(){
            encashThroughBank()
        }else{
            let bankAccountRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "BankAccountRegistrationViewController") as! BankAccountRegistrationViewController
            bankAccountRegistrationViewController.initialiseRegistration(isRequiredToEditBankDetails: false) { (isBankRegisterd) in
                if isBankRegisterd{
                    self.encashThroughBank()
                }
            }
            self.navigationController?.pushViewController(bankAccountRegistrationViewController, animated: false)
        }
    }
    private func encashThroughBank(){
        var params = [String : String]()
        params[Account.FLD_ACCOUNT_ID] = self.userId
        params[Account.POINTS] = self.txtEncashPrice.text!
        params[RedemptionRequest.TYPE] = RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER
        if rechargedPoints > 0{
            params[Account.RECHARGED_AMOUNT] = StringUtils.getStringFromDouble(decimalNumber: Double(rechargedPoints))
        }
        else{
            params[Account.RECHARGED_AMOUNT] = nil
        }
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.postEncashRequest(body: params, targetViewController: self,completionHandler: { (responseObject, error) -> Void in
            self.handleEncashResponse(responseObject: responseObject, error: error)
        })
    }
}
