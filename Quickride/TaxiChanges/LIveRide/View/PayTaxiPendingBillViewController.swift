//
//  PayTaxiPendingBillViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Lottie
typealias taxiPendingBillClearComplitionHandler = (_ isPendingCleared: Bool) -> Void

class PayTaxiPendingBillViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changeButtonSeperatorView: UIView!
    @IBOutlet weak var changeButton: QRCustomButton!
    @IBOutlet weak var payNowView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var paymentAnimationView: AnimationView!
    @IBOutlet weak var fareBreakUpTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fareBreakUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var paymentInitiatedMessageView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var paymentStatusShowingView: UIView!
    @IBOutlet weak var errorShowingImageIconView: UIView!
    @IBOutlet weak var retryButtonView: UIView!
    @IBOutlet weak var subErrorMessageLabelView: UIView!
    @IBOutlet weak var subErrorMessageLabel: UILabel!
    @IBOutlet weak var paidCashButtonContainerView: UIView!
    @IBOutlet weak var paidCashButton: QRCustomButton!
    
    
    //MARK: Variables
    private var payTaxiPendingBillViewModel = PayTaxiPendingBillViewModel()
    
    func initialisePendingBill(taxiRideId: Double,taxiPendingBill: TaxiPendingBill,taxiRideInvoice: TaxiRideInvoice?,paymentMode: String?,taxiGroupId: Double?, isRequiredToInitiatePayment: Bool?, handler: @escaping taxiPendingBillClearComplitionHandler){
        payTaxiPendingBillViewModel = PayTaxiPendingBillViewModel(taxiRideId: taxiRideId,taxiPendingBill: taxiPendingBill,taxiRideInvoice: taxiRideInvoice, paymentMode: paymentMode,taxiGroupId: taxiGroupId,isRequiredToInitiatePayment: isRequiredToInitiatePayment, handler: handler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTaxiRideInvoiceAndSetupUI()
        getTaxiRideDetails()
        getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(type: 1, actionComplitionHandler: nil)
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: payTaxiPendingBillViewModel.taxiPendingBill?.amountPending)])
        paymentAnimationView.contentMode = .scaleAspectFill
        paymentAnimationView.animation = Animation.named("payment_pending")
        setupUIForCashTrip()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getTaxiRideInvoiceAndSetupUI(){
        if payTaxiPendingBillViewModel.taxiRideInvoice == nil{
            fareBreakUpButton.isHidden = true
            payTaxiPendingBillViewModel.getTaxiRideInvoice(handler: {[weak self] (result) in
                if result.result != nil {
                    self?.fareBreakUpButton.isHidden = false
                }else{
                    self?.fareBreakUpButton.isHidden = true
                }
            })
        }else{
            fareBreakUpButton.isHidden = false
        }
    }
    
    private func getTaxiRideDetails(){
        payTaxiPendingBillViewModel.gettaxiRidePassengerDetails { responseError, error in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                if self.payTaxiPendingBillViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.paymentMode != TaxiRidePassenger.PAYMENT_MODE_CASH, self.payTaxiPendingBillViewModel.isRequiredToInitiatePayment {
                    self.payTripPendingAmount()
                }
            }
        }
    }
    
    private func getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(type: Int?,actionComplitionHandler: actionComplitionHandler? ){
        QuickRideProgressSpinner.startSpinner()
        payTaxiPendingBillViewModel.getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(type: type) { isCashHandleInitiated, responseError, error  in
            QuickRideProgressSpinner.stopSpinner()
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else if isCashHandleInitiated, type == 1 {
                self.moveToCashHandleInitiatedView()
            }
            if let actionComplitionHandler = actionComplitionHandler {
                actionComplitionHandler(isCashHandleInitiated)
            }
        }
    }
    
    private func confirmObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(taxiBillClearedUpadteUI), name: .taxiBillClearedUpadteUI, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taxiPeningPaymentFailed), name: .taxiPeningPaymentFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initiateUPIPayment), name: .initiateUPIPayment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taxiPaymentStatusUpdated), name: .taxiPaymentStatusUpdated, object: nil)
    }
   
    @objc func taxiPaymentStatusUpdated(_ notification: Notification){
        getPendingBillToVerify()
    }
    @objc func taxiBillClearedUpadteUI(_ notification: Notification){
        stopAnimation()
        payTaxiPendingBillViewModel.handler?(true)
        navigationController?.popViewController(animated: false)
    }
    
    @objc func taxiPeningPaymentFailed(_ notification: Notification){
        self.stopAnimation()
        setupErrorShowingView()
    }
    
    private func setupErrorShowingView(){
        if payTaxiPendingBillViewModel.paymentMode != TaxiRidePassenger.PAYMENT_MODE_CASH {
            paymentStatusShowingView.isHidden = false
            errorShowingImageIconView.isHidden = false
            retryButtonView.isHidden = false
            errorLabel.text = "Payment Failed"
            errorLabel.textColor = UIColor(netHex: 0xe20000)
            if let type = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type {
                subErrorMessageLabelView.isHidden = false
                subErrorMessageLabel.text = String(format: Strings.payment_failed_error_message, arguments: [getWalletType(type: type)])
            } else {
                subErrorMessageLabelView.isHidden = true
            }
        }
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseError = notification.userInfo?["responseError"] as? ResponseError
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
    }
    
    @objc func initiateUPIPayment(_ notification: Notification){
        if let orderId = notification.userInfo?["orderId"] as? String,let amount = notification.userInfo?["amount"] as? String{
            let paymentAcknowledgementViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "PaymentRequestLoaderViewController") as! PaymentAcknowledgementViewController
            paymentAcknowledgementViewController.initializeData(orderId: orderId, rideId: payTaxiPendingBillViewModel.taxiRideId,isFromTaxi: true,amount: Double(amount) ?? 0) { (result) in
                if result == Strings.success {
                    self.startAnimation()
                    self.payTaxiPendingBillViewModel.getPendingBillToVerify(actionComplitionHandler: nil)
                }else if result == Strings.failed{
                    self.setupErrorShowingView()
                    self.subErrorMessageLabelView.isHidden = true
                }
            }
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: paymentAcknowledgementViewController, animated: false)
        }
    }
    
    private func getWalletType(type: String) -> String {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            return Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            return Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            return Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            return Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            return Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            return Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            return Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            return Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            return Strings.gpay
        default:
            return ""
        }
    }
    
    private func setupUIForCashTrip(){
        if payTaxiPendingBillViewModel.paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH {
            payNowView.isHidden = true
            paidCashButtonContainerView.isHidden = false
            changeButton.contentHorizontalAlignment = .center
            changeButtonSeperatorView.isHidden = true
        }else {
            payNowView.isHidden = false
            paidCashButtonContainerView.isHidden = true
            changeButton.contentHorizontalAlignment = .left
            changeButtonSeperatorView.isHidden = false
        }
    }
    
    @IBAction func payNowTapped(_ sender: Any) {
        payTaxiPendingBillViewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_ONLINE
        payTripPendingAmount()
    }
    
    private func moveToPayByCashConfirmationView(){
        let payByCashConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pending_due_storyboard,bundle: nil).instantiateViewController(withIdentifier: "PayByCashConfirmationViewController") as! PayByCashConfirmationViewController
        payByCashConfirmationViewController.initializeData(amount: payTaxiPendingBillViewModel.taxiPendingBill?.amountPending){ completed in
            if completed {
                QuickRideProgressSpinner.startSpinner()
                self.payTaxiPendingBillViewModel.confirmCashPaidByPassenger { result in
                    QuickRideProgressSpinner.stopSpinner()
                    if result{
                        self.moveToCashHandleInitiatedView()
                        payByCashConfirmationViewController.removeFromParent()
                    }
                }
            }else {
                self.displayPayByOtherModes()
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: payByCashConfirmationViewController)
    }
    
    private func moveToCashHandleInitiatedView(){
        let cashHandleInitiatedViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pending_due_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CashHandleInitiatedViewController") as! CashHandleInitiatedViewController
        cashHandleInitiatedViewController.initializeData(){ completed in
            if completed {
                QuickRideProgressSpinner.startSpinner()
                self.payTaxiPendingBillViewModel.getPendingBillToVerify(){ completed in
                    if completed {
                        QuickRideProgressSpinner.stopSpinner()
                    }
                }
            }else {
                self.getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(type: 2){ completed in
                    if !completed {
                        cashHandleInitiatedViewController.closeView()
                    }
                }
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: cashHandleInitiatedViewController)
    }
    
    private func payTripPendingAmount(){
        startAnimation()
        payTaxiPendingBillViewModel.payTaxiBill { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiPendingBillException = Mapper<TaxiPendingBillException>().map(JSONObject: responseObject!["resultData"])
                if taxiPendingBillException?.taxiDemandManagementException?.error?.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI, let extraInfo = taxiPendingBillException?.taxiDemandManagementException?.error?.extraInfo, !extraInfo.isEmpty{
                    self.stopAnimation()
                    self.payTaxiPendingBillViewModel.initiateUPIPayment(paymentInfo: extraInfo)
                }else{
                    self.payTaxiPendingBillViewModel.getPendingBillToVerify(actionComplitionHandler: nil)
                }
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                self.stopAnimation()
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if responseError != nil, self.payTaxiPendingBillViewModel.paymentMode != TaxiRidePassenger.PAYMENT_MODE_CASH {
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: responseError!, viewController: self, addMoneyOrWalletLinkedComlitionHanler: nil)
                } else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }else{
                self.stopAnimation()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func changePaymentButtonTapped(_ sender: Any) {
        showSetPaymentMethodView()
    }
    
    private func showSetPaymentMethodView(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        var isDefaultPaymentModeCash = false
        if payTaxiPendingBillViewModel.paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            isDefaultPaymentModeCash = true
        }
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: isDefaultPaymentModeCash, isRequiredToShowCash: true, isRequiredToShowCCDC: true) {(data) in
            
            if data == .cashSelected {
                self.payTaxiPendingBillViewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_CASH
            }else if data == .ccdcSelected {
                self.displayPayByOtherModes()
                self.payTaxiPendingBillViewModel.paymentMode = nil
            }else  {
                self.payTaxiPendingBillViewModel.paymentMode = nil
            }
            self.changePaymentMode()
            self.payTripPendingAmount()
            self.setupUIForCashTrip()
            self.paymentStatusShowingView.isHidden = true
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    @IBAction func payByURLTapped(_ sender: Any) {
        displayPayByOtherModes()
    }
    @IBAction func payByCashButtonTapped(_ sender: Any) {
        payTaxiPendingBillViewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_ONLINE
        moveToPayByCashConfirmationView()
    }
    private func displayPayByOtherModes(){
        guard let taxiRidePassengerId = payTaxiPendingBillViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id else {
            return
        }
        TaxiPoolRestClient.getPaymentLinkForPayment(taxiRidePassengerId: taxiRidePassengerId) { responseObject, error in
            let result = RestResponseParser<TaxiPayByOtherModesInfo>().parse(responseObject: responseObject, error: error)
            if let taxiPayByOtherModesInfo = result.0{
                if let linkUrl = taxiPayByOtherModesInfo.paymentLink, let successURL = taxiPayByOtherModesInfo.redirectionUrl {
                    let queryItems1 = URLQueryItem(name: "&isMobile", value: "true")
                    var urlcomps1 = URLComponents(string :  linkUrl )
                    urlcomps1?.queryItems = [queryItems1]
                    
                    let queryItems2 = URLQueryItem(name: "&isMobile", value: "true")
                    var urlcomps2 = URLComponents(string :  successURL )
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
        }
    }
    
    private func changePaymentMode(){
        var selectedPaymentType = ""
        if let paymentMode = payTaxiPendingBillViewModel.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            selectedPaymentType = paymentMode
        }else{
            selectedPaymentType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? ""
            payTaxiPendingBillViewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_ONLINE
        }
        payTaxiPendingBillViewModel.chandePaymentMode(paymentType: selectedPaymentType)
    }
    
    private func startAnimation(){
        paymentAnimationView.contentMode = .scaleAspectFill
        paymentAnimationView.play()
        paymentAnimationView.loopMode = .loop
    }
    
    private func stopAnimation(){
        paymentAnimationView.stop()
    }
    
    
    @IBAction func fareBreakUpTapped(_ sender: Any) {
        if fareBreakUpTableView.isHidden{
            payTaxiPendingBillViewModel.getFareBrakeUpData()
            fareBreakUpTableView.isHidden = false
            setUpUI()
        }else{
            fareBreakUpTableView.isHidden = true
            tableViewHeightConstraint.constant = 0
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        getPendingBillToVerify()
    }
    
    private func getPendingBillToVerify(){
        QuickRideProgressSpinner.startSpinner()
        payTaxiPendingBillViewModel.getPendingBillToVerify(){ completed in
            if completed {
                QuickRideProgressSpinner.stopSpinner()
            }
        }
    }
    
    private func setUpUI() {
        fareBreakUpTableView.register(UINib(nibName: "TaxiFareDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiFareDetailsTableViewCell")
        //ForOutStation
        fareBreakUpTableView.register(UINib(nibName: "FareSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "FareSummaryTableViewCell")
        fareBreakUpTableView.reloadData()
        if payTaxiPendingBillViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION  {
            tableViewHeightConstraint.constant = CGFloat((payTaxiPendingBillViewModel.estimateFareData.count + 1)*46)
        }else{
            var tableviewHeight = 86
            if (payTaxiPendingBillViewModel.taxiRideInvoice?.tax ?? 0) > 0{
                tableviewHeight += 35
            }
            let convenienceFee = (payTaxiPendingBillViewModel.taxiRideInvoice?.scheduleConvenienceFee ?? 0) + (payTaxiPendingBillViewModel.taxiRideInvoice?.scheduleConvenienceFeeTax ?? 0)
            if convenienceFee > 0{
                tableviewHeight += 35
            }
            if (payTaxiPendingBillViewModel.taxiRideInvoice?.extraPickUpCharges ?? 0) > 0{
                tableviewHeight += 35
            }
            if payTaxiPendingBillViewModel.taxiRideInvoice?.couponDiscount != 0{
                tableviewHeight += 35
            }
            tableViewHeightConstraint.constant = CGFloat(tableviewHeight)
        }
    }
    @IBAction func paidCashButtonTapped(_ sender: Any) {
        initiateCashPayment()
    }
    
    private func initiateCashPayment(){
        QuickRideProgressSpinner.startSpinner()
        self.payTaxiPendingBillViewModel.confirmCashPaidByPassenger { result in
            QuickRideProgressSpinner.stopSpinner()
        }
    }
}
//MARK: UITableViewDataSource
extension PayTaxiPendingBillViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if payTaxiPendingBillViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION  {
            return payTaxiPendingBillViewModel.estimateFareData.count+1
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if payTaxiPendingBillViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let taxiRideInvoice = payTaxiPendingBillViewModel.taxiRideInvoice,taxiRideInvoice.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            switch indexPath.section {
            case payTaxiPendingBillViewModel.estimateFareData.count:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                var amount = taxiRideInvoice.amount
                cell.updateUIForFare(title: "Balance to be paid", amount: String(amount?.roundToPlaces(places: 1) ?? 0))
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                let currentData = payTaxiPendingBillViewModel.estimateFareData[indexPath.section]
                cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
                if currentData.key == ReviewScreenViewModel.RIDE_FARE{
                    cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                    cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                    cell.separatorView.isHidden = false
                }else{
                    cell.separatorView.isHidden = true
                }
                return cell
            }
        }else{
            if let taxiRideInvoice = payTaxiPendingBillViewModel.taxiRideInvoice{
                let taxiBillCell = tableView.dequeueReusableCell(withIdentifier: "TaxiFareDetailsTableViewCell", for: indexPath) as! TaxiFareDetailsTableViewCell
                taxiBillCell.updateUIWithData(taxiRideInvoice: taxiRideInvoice)
                return taxiBillCell
            }
        }
        return UITableViewCell()
    }
}
//MARK: UITableViewDataSource
extension PayTaxiPendingBillViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == payTaxiPendingBillViewModel.estimateFareData.count - 1{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xE1E1E1)
        return view
    }
}
