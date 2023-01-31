//
//  TransactionViewController.swift
//  PlacesLookup
//
//  Created by Swagat Kumar Bisoyi on 10/25/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import MessageUI

class TransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
  var arrayPoints = [String]()
  var arrayDate = [String]()
  var arrayDetails = [String]()
  var arrayTime = [String]()
  var arrayID = [String]()
  var arraytransactiontype = [String]()
  var arraySourceType = [String]()
  var arraysourceRefId = [String]()
    var isFromRewardHistory: Bool?
  var messageFrame = UIView()
  var activityIndicator = UIActivityIndicatorView()
  var strLabel = UILabel()
  var userId : String!
  var accountTransactionDetails : [AccountTransaction] = [AccountTransaction]()
  
  @IBOutlet weak var tblTransaction: UITableView!
    
  @IBOutlet weak var noTransactionsView: UIView!
    @IBOutlet weak var priorTransactionView: UIView!
    @IBOutlet weak var priorTransactionLabel: UILabel!
    @IBOutlet weak var monthlyReportLbl: UIButton!
    
    
    func intialisingData(isFromRewardHistory: Bool?){
        self.isFromRewardHistory = isFromRewardHistory
    }
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
      tblTransaction.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
    tblTransaction.estimatedRowHeight = 120
    tblTransaction.rowHeight = UITableView.automaticDimension
   // self.tblTransaction.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
    self.userId = QRSessionManager.getInstance()?.getUserId()
      if isFromRewardHistory == true{
          monthlyReportLbl.isHidden = true
      } else {
          monthlyReportLbl.isHidden = false
      }
    
    getTransactionDetails()
    // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func letsStartClicked(_ sender: Any) {
        
            ContainerTabBarViewController.indexToSelect = 1
        self.navigationController?.popToRootViewController(animated: false)
        
    }
    
    func getTransactionDetails() {
    AppDelegate.getAppDelegate().log.debug("getTransactionDetails()")
    if QRReachability.isConnectedToNetwork() == false {
      DispatchQueue.main.async(execute: {
        ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
    })
      return
    }
    
    QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getTransactionDetails(userId: Double(self.userId!) ?? 0) { (responseObject, error) -> Void in
        DispatchQueue.main.async(execute: {
            QuickRideProgressSpinner.stopSpinner()
        })
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let accountTransactionDetails = Mapper<AccountTransaction>().mapArray(JSONObject: responseObject!["resultData"])!
            self.filterTransactions(accountTransactions: accountTransactionDetails)
        }else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
  }
    private func filterTransactions(accountTransactions: [AccountTransaction]){
        if isFromRewardHistory == true {
    accountTransactionDetails = accountTransactions.filter{$0.walletSource == AccountTransaction.WALLET_SOURCE_TYPE_REWARDS }
        } else {
        let dateString = ConfigurationCache.getObjectClientConfiguration().accountTransactionsDisplayStartDate
        var isRequiredToShowPriorInfo = false
        if let timestamp = DateUtils.getTimeStampFromString(dateString: dateString, dateFormat: DateUtils.DATE_FORMAT_DD_MM_YYYY){
            for transaction in accountTransactions{
                if let date = transaction.date, date > timestamp{
                    accountTransactionDetails.append(transaction)
                }else{
                    isRequiredToShowPriorInfo = true
                }
            }
        }else{
          accountTransactionDetails = accountTransactions
        }
        }
        
        if accountTransactionDetails.isEmpty == true{
            noTransactionsView.isHidden = false
            tblTransaction.isHidden = true
        }else{
            noTransactionsView.isHidden = true
            tblTransaction.isHidden = false
            accountTransactionDetails = self.accountTransactionDetails.reversed()
            DispatchQueue.main.async(execute: {
                self.messageFrame.removeFromSuperview()
            })
            tblTransaction.reloadData()
        }
//        if isRequiredToShowPriorInfo{
//            priorTransactionView.isHidden = false
//            let date = DateUtils.getDateStringFromString(date: dateString, requiredFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy, currentFormat: DateUtils.DATE_FORMAT_DD_MM_YYYY)
//            priorTransactionLabel.attributedText = ViewCustomizationUtils.getAttributedString(string: String(format: Strings.prior_transaction_info, arguments: [date ?? ""]), rangeofString: "support@quickride.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 14)
//        }else{
//            priorTransactionView.isHidden = true
//        }
       
    }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func btnBackTapped(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.accountTransactionDetails.count
  }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
        if self.accountTransactionDetails.endIndex <= indexPath.row{
            return cell
        }
        cell.initializeCellData(accountTransaction: accountTransactionDetails[indexPath.row])
        return cell
    }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let accountTransaction = self.accountTransactionDetails[indexPath.row]
    
    if accountTransaction.transactiontype! == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_DEBIT{
        if let refAccountId = Int(accountTransaction.refAccountId ?? ""),refAccountId >= 20 && refAccountId <= 40,(accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT || accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_CANCEL_DEBIT){
            getTaxiTripInvoice(taxiRideRide: Double(accountTransaction.sourceRefId ?? "") ?? 0)
        }else if accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT{
            self.getPassengerBill(userId: accountTransaction.accountId, passengerRideId: accountTransaction.sourceRefId!, rideType: Ride.PASSENGER_RIDE)
        }
    }else if accountTransaction.transactiontype! == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_CREDIT && accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_EARNED{
        self.getPassengerBill(userId: accountTransaction.accountId, passengerRideId: accountTransaction.sourceRefId!, rideType: Ride.RIDER_RIDE)
    }else if accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_REFUND_CREDIT_EXTERNAL_WALLET, let srcRefId = accountTransaction.sourceRefId, let passengerRideId = Double(srcRefId){
        QuickRideProgressSpinner.startSpinner()
        PassengerRideServiceClient.getPassengerRide(rideId: passengerRideId, targetViewController: nil) { responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            let restRespnse = RestResponseParser<PassengerRide>().parse(responseObject: responseObject, error: error)
            if let passengerRide = restRespnse.0{
                RideCancelActionProxy.moveToCancelledReport(ride: passengerRide, viewController: self)
            }else{
                ErrorProcessUtils.handleResponseError(responseError: restRespnse.1, error: restRespnse.2, viewController: self)
            }
        }
    }
    tableView.deselectRow(at: indexPath, animated: false)
  }
  func progressBarDisplayer(msg:String, _ indicator:Bool ) {
    AppDelegate.getAppDelegate().log.debug("progressBarDisplayer()")
          AppDelegate.getAppDelegate().log.debug("msg")
    strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
    strLabel.text = msg
    strLabel.textColor = UIColor.white
    messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
    messageFrame.layer.cornerRadius = 15
    messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
    if indicator {
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
      activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
      activityIndicator.startAnimating()
      messageFrame.addSubview(activityIndicator)
    }
    messageFrame.addSubview(strLabel)
    self.tblTransaction.addSubview(messageFrame)
  }
    func getPassengerBill(userId: Double?, passengerRideId: String, rideType: String?){
        QuickRideProgressSpinner.startSpinner()
        BillRestClient.getPassengerRideBillingDetails(id: passengerRideId , userId: StringUtils.getStringFromDouble(decimalNumber: userId), completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            
            let restResponse = RestResponseParser<RideBillingDetails>().parse(responseObject: responseObject, error: error)
            if let rideBillingDetails = restResponse.0 {
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                self.pushBillViewController(rideBillingDetails: rideBillingDetailslist, rideType: rideType ?? " ", currentUserRideId: Double(passengerRideId)!)
            }else if restResponse.1 != nil || restResponse.2 != nil{
                ErrorProcessUtils.handleResponseError(responseError: restResponse.1, error: restResponse.2, viewController: self, handler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.bill_failed)
            }
            
            
        })
  }
    func getRiderBill(userId: String?, riderRideId: String, rideType: String){
        QuickRideProgressSpinner.startSpinner()
        
        BillRestClient.getRiderRideBillingDetails(id: riderRideId, userId: userId ?? "") { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            let result = RestResponseParser<RideBillingDetails>().parseArray(responseObject: responseObject, error: error)
            if let rideBillingDetailslist = result.0 {
                self.pushBillViewController(rideBillingDetails: rideBillingDetailslist, rideType: rideType, currentUserRideId: Double(rideBillingDetailslist.last?.sourceRefId ?? "") ?? 0)
            }else if result.1 != nil || result.2 != nil{
                ErrorProcessUtils.handleResponseError(responseError: result.1, error: result.2, viewController: self, handler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.bill_failed)
            }
        }
    }
    
    func getTaxiTripInvoice(taxiRideRide: Double) {
        let taxiRidePassenger = MyActiveTaxiRideCache.getInstance().getClosedTaxiRidePassenger(taxiRideId: taxiRideRide)
        if let taxiRide = taxiRidePassenger{
            if taxiRide.status == TaxiRidePassenger.STATUS_COMPLETED{
                QuickRideProgressSpinner.startSpinner()
                TaxiPoolRestClient.getTaxiPoolInvoice(refId: taxiRide.id ?? 0) {(responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        if let taxiRideInvoice = Mapper<TaxiRideInvoice>().map(JSONObject: responseObject!["resultData"]){
                            let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                            taxiBillVC.initialiseData(taxiRideInvoice: taxiRideInvoice,taxiRide: taxiRide, cancelTaxiRideInvoice: [CancelTaxiRideInvoice]())
                            self.navigationController?.pushViewController(taxiBillVC, animated: true)
                        }
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                    }
                }
            }else{
                QuickRideProgressSpinner.startSpinner()
                TaxiPoolRestClient.getCancelTripInvoice(taxiRideId: taxiRide.id ?? 0 , userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        let cancelTaxiRideInvoice = Mapper<CancelTaxiRideInvoice>().mapArray(JSONObject: responseObject!["resultData"])
                        if let cancelTaxiInvoices = cancelTaxiRideInvoice,!cancelTaxiInvoices.isEmpty{
                            var feeAppliedTaxiRides = [CancelTaxiRideInvoice]()
                            for cancelRideInvoice in cancelTaxiInvoices{
                                if cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER || cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
                                    feeAppliedTaxiRides.append(cancelRideInvoice)
                                }
                            }
                            if !feeAppliedTaxiRides.isEmpty{
                                let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                                taxiBillVC.initialiseData(taxiRideInvoice: nil,taxiRide: taxiRide, cancelTaxiRideInvoice: feeAppliedTaxiRides)
                                self.navigationController?.pushViewController(taxiBillVC, animated: true)
                            }
                        }
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                    }
                }
            }
        }
    }
    
    
    func pushBillViewController(rideBillingDetails: [RideBillingDetails]?, rideType : String,currentUserRideId : Double){
        
        let BillVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
         BillVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails, isFromClosedRidesOrTransaction: true,rideType: rideType,currentUserRideId: currentUserRideId)
         self.navigationController?.pushViewController(BillVC, animated: false)
    }
    
    
    
    
    
    
    @IBAction func refundBtnClicked(_ sender: UIButton) {
        if sender.tag > self.accountTransactionDetails.count - 1 {
            return
        }
        let accountTransaction = self.accountTransactionDetails[sender.tag]
        if accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_RECHARGE && accountTransaction.refAccountId == AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM{
            let refundAmountRequestAlertController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RefundAmountRequestAlertController") as! RefundAmountRequestAlertController
            refundAmountRequestAlertController.initializeDataBeforePresentingView(points: accountTransaction.value!, handler: { (text, result) in
                if Strings.done_caps == result
                {
                    self.handlePaytmReachargeRefund(transactionId: StringUtils.getStringFromDouble(decimalNumber: accountTransaction.transactionId), refundValue: text)
                }
            })
            self.navigationController?.view.addSubview(refundAmountRequestAlertController.view!)
            self.navigationController?.addChild(refundAmountRequestAlertController)
        }
        else{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.refund+" "+StringUtils.getPointsInDecimal(points: accountTransaction.value!)+" "+Strings.points, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self) { (result) in
                if result == Strings.yes_caps{
                    self.handleCancellationOfCompensation(accountTransaction: accountTransaction)
                }
            }
        }
       
    }
    
    func handlePaytmReachargeRefund(transactionId: String, refundValue: String?){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.refundRechargeAmount(transactionId: transactionId, value: refundValue, targetViewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
                self.getTransactionDetails()
            }
            else{
               ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    func handleCancellationOfCompensation(accountTransaction : AccountTransaction){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.cancelCompensationTransaction(accountTransactionId: accountTransaction.transactionId!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
                self.getTransactionDetails()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    @IBAction func contactSupportTapped(_ sender: Any) {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: "" , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
    
    
    
    @IBAction func monthlyReportTapped(_ sender: Any) {
        let monthlyreportVC = UIStoryboard(name: StoryBoardIdentifiers.accountsb_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransationHistoryMailViewController") as! TransationHistoryMailViewController
        self.navigationController?.pushViewController(monthlyreportVC, animated: false)
    }
    
    
    
    /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
//MARK: Review
extension TransactionViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}

extension UIColor{
  
  convenience init(red : Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red : CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
  }
  
  convenience init(netHex : Int) {
    self.init(red : (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
  }
}


extension NSDate {
  convenience init?(jsonDate: String) {
    let prefix = "/Date("
    let suffix = ")/"
    let scanner = Scanner(string: jsonDate)
    
    // Check prefix:
    if scanner.scanString(prefix, into: nil) {
      
      // Read milliseconds part:
      var milliseconds : Int64 = 0
      if scanner.scanInt64(&milliseconds) {
        // Milliseconds to seconds:
        var timeStamp = TimeInterval(milliseconds)/1000.0
        
        // Read optional timezone part:
        var timeZoneOffset : Int = 0
        if scanner.scanInt(&timeZoneOffset) {
          let hours = timeZoneOffset / 100
          let minutes = timeZoneOffset % 100
          // Adjust timestamp according to timezone:
          timeStamp += TimeInterval(3600 * hours + 60 * minutes)
        }
        
        // Check suffix:
        if scanner.scanString(suffix, into: nil) {
          // Success! Create NSDate and return.
          self.init(timeIntervalSince1970: timeStamp)
          return
        }
      }
    }
    
    // Wrong format, return nil. (The compiler requires us to
    // do an initialization first.)
    self.init(timeIntervalSince1970: 0)
    return nil
  }
}
