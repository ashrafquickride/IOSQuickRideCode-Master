//
//  AccountPaymentViewController.swift
//  PlacesLookup
//
//  Created by KNM Rao on 10/22/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class AccountPaymentViewController: UIViewController {
    
    @IBOutlet weak var accountTableView: UITableView!
    
    var topViewController : PaymentViewController?
    private var accountPaymentViewModel = AccountPaymentViewModel()
    
    static var OTPValidationViewController : OTPValidationViewController?
    static let PAY_LATER = "payLater"
    static let WALLETS_OR_GIFT_CARDS = "walletsOrGiftCards"
    static let U_P_I = "UPI"
    
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        regesterCells()
        getTransactionDetail()
        accountTableView.delegate = self
        accountTableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func regesterCells(){
        accountTableView.register(UINib(nibName: "LinkedWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "LinkedWalletXibTableViewCell")
        accountTableView.register(UINib(nibName: "AllLinkWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "AllLinkWalletXibTableViewCell")
        accountTableView.register(UINib(nibName: "PaymentMethodTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentMethodTableViewCell")
        accountTableView.register(UINib(nibName: "OtherPaymentMethodsTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherPaymentMethodsTableViewCell")
        accountTableView.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        accountTableView.register(UINib(nibName: "TransationViewTableViewCell", bundle: nil), forCellReuseIdentifier: "TransationViewTableViewCell")
    }
    
    private func getTransactionDetail(){
        if QRReachability.isConnectedToNetwork() == false {
            DispatchQueue.main.async(execute: {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            })
            return
        }
        accountPaymentViewModel.getTransactionDetails { (responseError, error) in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                self.accountTableView.reloadData()
            }
        }
    }
    
    
     func checkWhetherWalletLinkedAndAdjustViews(){
        accountPaymentViewModel.linkedWallets = UserDataCache.getInstance()!.getAllLinkedWallets()
        accountPaymentViewModel.addAllWalletsToList()
        accountPaymentViewModel.removeLinkedTypeFromList()
        accountPaymentViewModel.addAvailableWalletsToList()
        getAllLinkedWallet()
        accountTableView.reloadData()
    }
    
    private func getAllLinkedWallet(){
        accountPaymentViewModel.getAllLinkedWalletByUser(){ (responseError, error) in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                self.accountTableView.reloadData()
            }
        }
    }
    
   private func getTaxiTripInvoice(taxiRideRide: Double) {
        guard let  taxiRidePassenger = MyActiveTaxiRideCache.getInstance().getClosedTaxiRidePassenger(taxiRideId: taxiRideRide) else {
            return
        }
        accountPaymentViewModel.getTaxiTripInvoice(taxiRide: taxiRidePassenger){(taxiRideInvoice, cancelTaxiInvoices, responseError, error) in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else if let taxiRideInvoice = taxiRideInvoice {
                self.moveToTaxiTripReport(taxiRideInvoice: taxiRideInvoice, taxiRide: taxiRidePassenger, cancelTaxiRideInvoice: [CancelTaxiRideInvoice]())
            }else if let cancelTaxiInvoices = cancelTaxiInvoices {
                self.moveToTaxiTripReport(taxiRideInvoice: nil, taxiRide: taxiRidePassenger, cancelTaxiRideInvoice: cancelTaxiInvoices)
            }
        }
    }
   private func moveToTaxiTripReport(taxiRideInvoice: TaxiRideInvoice?,taxiRide: TaxiRidePassenger,cancelTaxiRideInvoice: [CancelTaxiRideInvoice]){
        let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
        taxiBillVC.initialiseData(taxiRideInvoice: taxiRideInvoice,taxiRide: taxiRide, cancelTaxiRideInvoice: cancelTaxiRideInvoice)
        self.navigationController?.pushViewController(taxiBillVC, animated: true)
    }
    
    func getPassengerBill(userId: Double?, passengerRideId: String, rideType: String?){
        QuickRideProgressSpinner.startSpinner()
        accountPaymentViewModel.getPassengerBill(id: passengerRideId, userId: StringUtils.getStringFromDouble(decimalNumber: userId)){(rideBillingDetails, responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else if let rideBillingDetails = rideBillingDetails {
                self.pushBillViewController(rideBillingDetails: rideBillingDetails, rideType: rideType ?? "", currentUserRideId: Double(passengerRideId)!)
            }
        }
    }
    
    func getRiderBill(userId: String?, riderRideId: String, rideType: String){
        QuickRideProgressSpinner.startSpinner()
        accountPaymentViewModel.getRiderBill(id: riderRideId, userId: userId ?? ""){(rideBillingDetails, responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else if let rideBillingDetails = rideBillingDetails {
                self.pushBillViewController(rideBillingDetails: rideBillingDetails, rideType: rideType, currentUserRideId: Double(rideBillingDetails.last?.sourceRefId ?? "") ?? 0)
            }
        }
    }
    
    func pushBillViewController(rideBillingDetails: [RideBillingDetails]?, rideType : String,currentUserRideId : Double){
        
        let BillVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        BillVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails, isFromClosedRidesOrTransaction: true,rideType: rideType,currentUserRideId: currentUserRideId)
        self.navigationController?.pushViewController(BillVC, animated: false)
    }
}

extension AccountPaymentViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            if accountPaymentViewModel.linkedWallets.count > 0 {
                return 1
            }
            return 0
        case 1:
            return accountPaymentViewModel.linkedWallets.count
        case 2:
            if accountPaymentViewModel.linkedWallets.count > 0 {
                return 1
            }
            return 0
        case 3:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.payLaterLinkWalletOptions.count > 0  {
                return 1
            }
            return 0
        case 4:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.PAY_LATER {
                return accountPaymentViewModel.payLaterLinkWalletOptions.count
            }
            return 0
        case 5:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.rechargeLinkWalletOptions.count > 0 {
                return 1
            }
            return 0
        case 6:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.WALLETS_OR_GIFT_CARDS {
                return accountPaymentViewModel.rechargeLinkWalletOptions.count
            }
            return 0
        case 7:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.upiLinkWalletOptions.count > 0{
                return 1
            }
            return 0
        case 8:
            if !accountPaymentViewModel.isWalletAdded() && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.U_P_I {
                return accountPaymentViewModel.upiLinkWalletOptions.count
            }
            return 0
        case 9:
            if accountPaymentViewModel.accountTransactionDetails.count > 0 {
                return 1
            }
            return 0
        case 10:
            let count = self.accountPaymentViewModel.accountTransactionDetails.count
            if count > 0 {
                if count < 6 {
                    return count
                } else {
                    return 5
                }
            }
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPaymentMethodsTableViewCell", for: indexPath as  IndexPath) as! OtherPaymentMethodsTableViewCell
            cell.titlelabel.text = "LINKED WALLETS"
            cell.titlelabel.textColor = UIColor(netHex: 0x7F7F7F)
            cell.labelBottomSpaceConstraint.constant = 10
            cell.titlelabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedWalletXibTableViewCell", for: indexPath as  IndexPath) as! LinkedWalletXibTableViewCell
            cell.initializeDataInCell(linkedWallet: accountPaymentViewModel.linkedWallets[indexPath.row],showSelectButton: false, viewController: self, listener: self)
            if indexPath.row == accountPaymentViewModel.linkedWallets.endIndex - 1{
                cell.separatorView.isHidden = true
            }else{
                cell.separatorView.isHidden = false
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPaymentMethodsTableViewCell", for: indexPath as  IndexPath) as! OtherPaymentMethodsTableViewCell
            cell.titlelabel.text = "Other Payment Methods"
            cell.titlelabel.textColor = UIColor(netHex: 0x007AFF)
            cell.labelBottomSpaceConstraint.constant = 20
            cell.titlelabel.font = UIFont(name: "HelveticaNeue", size: 16)
            return cell
        case 3:
            return setupUI(indexPath: indexPath, index: 0)
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: accountPaymentViewModel.payLaterLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell
        case 5:
            return setupUI(indexPath: indexPath, index: 1)
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: accountPaymentViewModel.rechargeLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell
        case 7:
            return setupUI(indexPath: indexPath, index: 2)
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: accountPaymentViewModel.upiLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransationViewTableViewCell", for: indexPath as  IndexPath) as! TransationViewTableViewCell
            cell.intialisingDataForUpdateUi(isFromRewardHistory: false)
            if accountPaymentViewModel.accountTransactionDetails.count > 5 {
                cell.viewAllBtn.isHidden = false
            } else {
                cell.viewAllBtn.isHidden = true
            }
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath as  IndexPath) as! TransactionsTableViewCell
            cell.initializeCellData(accountTransaction: accountPaymentViewModel.accountTransactionDetails[indexPath.row])
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func setupUI(indexPath: IndexPath, index: Int) -> UITableViewCell {
        let cell = accountTableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath as  IndexPath) as! PaymentMethodTableViewCell
        
        if (index == 0 && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.PAY_LATER) ||
            (index == 1 && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.WALLETS_OR_GIFT_CARDS) ||
            (index == 2 && accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.U_P_I) {
            cell.initialiseData(paymentTypeInfo: accountPaymentViewModel.paymentMethodslist[index], arrowImage: UIImage(named: "left-arrow")!, showDefaultLabel: false)
        } else {
            cell.initialiseData(paymentTypeInfo: accountPaymentViewModel.paymentMethodslist[index], arrowImage: UIImage(named: "arrow-right")!, showDefaultLabel: false)
        }
        if index == 0 {
            cell.separatorView.isHidden = true
        }else {
            cell.separatorView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch indexPath.section {
        case 2:
            showAddPaymentMethodView()
        case 3:
            if accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.PAY_LATER {
                accountPaymentViewModel.selectedWalletSection = ""
            }else {
                accountPaymentViewModel.selectedWalletSection = AccountPaymentViewController.PAY_LATER
            }
        case 5:
            if accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.WALLETS_OR_GIFT_CARDS {
                accountPaymentViewModel.selectedWalletSection = ""
            }else {
                accountPaymentViewModel.selectedWalletSection = AccountPaymentViewController.WALLETS_OR_GIFT_CARDS
            }
        case 7:
            if accountPaymentViewModel.selectedWalletSection == AccountPaymentViewController.U_P_I {
                accountPaymentViewModel.selectedWalletSection = ""
            }else {
                accountPaymentViewModel.selectedWalletSection = AccountPaymentViewController.U_P_I
            }
        case 10:
            let accountTransaction = self.accountPaymentViewModel.accountTransactionDetails[indexPath.row]
            if accountTransaction.transactiontype! == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_DEBIT{
                if let refAccountId = Int(accountTransaction.refAccountId ?? ""),refAccountId >= 20 && refAccountId <= 40,(accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT || accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_CANCEL_DEBIT){
                    getTaxiTripInvoice(taxiRideRide: Double(accountTransaction.sourceRefId ?? "") ?? 0)
                }else if accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT{
                    self.getPassengerBill(userId: accountTransaction.accountId, passengerRideId: accountTransaction.sourceRefId!, rideType: Ride.PASSENGER_RIDE)
                }
            }else if accountTransaction.transactiontype! == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_CREDIT && accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_EARNED{
                self.getPassengerBill(userId: accountTransaction.accountId, passengerRideId: accountTransaction.sourceRefId!, rideType: Ride.RIDER_RIDE)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        default:
            return
        }
        accountTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(netHex: 0xe9e9e9)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
    
    private func showAddPaymentMethodView(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: nil) {(data) in
            self.checkWhetherWalletLinkedAndAdjustViews()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
}
extension AccountPaymentViewController: LinkedWalletUpdateDelegate {
    func linkedWalletInfoChanged() {
        checkWhetherWalletLinkedAndAdjustViews()
    }
}
extension AccountPaymentViewController: LinkWalletReceiver {
    func linkWallet(walletType: String){
        checkWhetherWalletLinkedAndAdjustViews()
    }
}
