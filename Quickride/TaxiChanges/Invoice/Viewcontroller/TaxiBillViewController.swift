//
//  TaxiBillViewController.swift
//  Quickride
//
//  Created by Ashutos on 29/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiBillViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var taxiBillTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var needHelpAndDoneBtnView: UIView!
    @IBOutlet weak var needHelpViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var taxiBillViewModel = TaxiBillViewModel()
    
    func initialiseData(taxiRideInvoice: TaxiRideInvoice,taxiRide: TaxiRidePassenger, isFromClosedRidesOrTransaction: Bool, isRequiredToInitiatePayment: Bool? ) {
        taxiBillViewModel = TaxiBillViewModel(taxiRideInvoice: taxiRideInvoice,taxiRide: taxiRide, isFromClosedRidesOrTransaction: isFromClosedRidesOrTransaction, isRequiredToInitiatePayment: isRequiredToInitiatePayment)
    }
    
    //MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpUI()
        taxiBillViewModel.getFeedBack(complitionHandler: { [weak self]
            result in
            self?.taxiBillTableView.reloadData()
        })
        taxiBillViewModel.getExtraChargesAddedByDriverAndPassenger(complitionHandler: { [weak self]
            result in
            if result{
                self?.taxiBillTableView.reloadData()
            }
        })
        checkCurrentTripBillIsClearedOrNot()
        if taxiBillViewModel.taxiRide?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
            getRentalStopPoints()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        confirmObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI() {
        if taxiBillViewModel.isFromClosedRidesOrTransaction{
            taxiBillViewModel.isExpandableBill = true
            doneButton.isHidden = true
        }else{
            doneButton.isHidden = false
        }
        taxiBillTableView.estimatedRowHeight = 160
        taxiBillTableView.rowHeight = UITableView.automaticDimension
        ViewCustomizationUtils.addBorderToView(view: needHelpButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        needHelpButton.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        needHelpButton.layer.shadowOffset = CGSize(width: 0,height: 1)
        needHelpButton.layer.shadowRadius = 3
        needHelpButton.layer.shadowOpacity = 1
        doneButton.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        doneButton.layer.shadowOffset = CGSize(width: 0,height: 1)
        doneButton.layer.shadowRadius = 3
        doneButton.layer.shadowOpacity = 1
        needHelpAndDoneBtnView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
    }
    
    private func registerCell() {
        taxiBillTableView.register(UINib(nibName: "BillHeaderCardTableViewCell", bundle: nil), forCellReuseIdentifier: "BillHeaderCardTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiTripLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripLocationTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiDriverDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiDriverDetailsTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiBillRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiBillRatingTableViewCell")
        taxiBillTableView.register(UINib(nibName: "ScheduleReturnTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleReturnTaxiTableViewCell")
        taxiBillTableView.register(UINib(nibName: "RentalStopLocationPointTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalStopLocationPointTableViewCell")
        taxiBillTableView.register(UINib(nibName: "RentalTripTimeAndDateTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalTripTimeAndDateTableViewCell")
        taxiBillTableView.register(UINib(nibName: "FareSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "FareSummaryTableViewCell")
        taxiBillTableView.register(UINib(nibName: "AdditionalPaymnetActionTableViewCell", bundle: nil), forCellReuseIdentifier: "AdditionalPaymnetActionTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiEmailInvoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiEmailInvoiceTableViewCell")
    }
    private func confirmObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(viewFareBreakUp), name: .viewFareBreakUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ratingGivenForDriver), name: .ratingGivenForDriver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startSpinner), name: .startSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .stopSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    @objc func viewFareBreakUp(_ notification: Notification){
        if self.taxiBillViewModel.isExpandableBill{
            self.taxiBillViewModel.isExpandableBill = false
        }else{
            self.taxiBillViewModel.isExpandableBill = true
        }
        self.taxiBillTableView.reloadData()
    }
    
    @objc func ratingGivenForDriver(_ notification: Notification){
        let taxiRideFeedback = notification.userInfo?["taxiRideFeedback"] as? TaxiRideFeedback
        self.taxiBillViewModel.taxiRideFeedBack = taxiRideFeedback
        self.taxiBillTableView.reloadData()
    }
    
    @objc func startSpinner(_ notification: Notification){
        QuickRideProgressSpinner.startSpinner()
    }
    
    @objc func stopSpinner(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    func getRentalStopPoints(){
        QuickRideProgressSpinner.startSpinner()
        taxiBillViewModel.getAllRentalStopPoints{ (responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            self.taxiBillTableView.reloadData()
            if responseError != nil && error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
            }
        }
    }
    
    func updateUIBasedOnTappingOnFare(isrequiredtoshowFareBreakUpView: Bool){
        taxiBillViewModel.isrequiredtoshowFareBreakUpView = isrequiredtoshowFareBreakUpView
        if taxiBillViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            taxiBillViewModel.getFareBrakeUpData()
        } else if taxiBillViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_RENTAL {
            taxiBillViewModel.getFareBrakeUpDataForRental()
        } else {
            taxiBillViewModel.getFareBrakeUpData()
        }
        self.taxiBillTableView.reloadData()
    }
    
    
    
    func sendInvoice() {
        if let userProfile = UserDataCache.getInstance()?.userProfile, let emailForCommunication = userProfile.emailForCommunication,!emailForCommunication.isEmpty{
            let emailPreferences = UserDataCache.getInstance()?.getLoggedInUsersEmailPreferences()
            if emailPreferences?.unSubscribe == true || emailPreferences?.receiveRideTripReports == false{
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.preference_unsubsribe_message, message2: nil, positiveActnTitle: Strings.subscribe, negativeActionTitle : Strings.later_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
                    if Strings.subscribe == result{
                        let communicationPreference = UIStoryboard(name : StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CommunicationPreferencesViewController") as! CommunicationPreferencesViewController
                        self.navigationController?.pushViewController(communicationPreference, animated: false)
                    }
                })
            }else{
                taxiBillViewModel.sendInvoiceToPassenger()
            }
        }else{
            var  modelLessDialogue: ModelLessDialogue?
            modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as? ModelLessDialogue
            modelLessDialogue?.initializeViews(message: Strings.emailid_not_given_for_profile, actionText: Strings.configure_email)
            modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditingVC(_:))))
            modelLessDialogue?.isUserInteractionEnabled = true
            modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height, width: self.view.frame.width ?? 0, height: 80)
            self.view.addSubview(modelLessDialogue!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                modelLessDialogue?.removeFromSuperview()
            }
        }
    }
    
    @objc private func profileEditingVC(_ recognizer: UITapGestureRecognizer) {
        let profileEditViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(profileEditViewController, animated: false)
    }
    
    private func checkCurrentTripBillIsClearedOrNot(){
        if !taxiBillViewModel.isPaymentCompleted(){
            QuickRideProgressSpinner.startSpinner()
            taxiBillViewModel.getPendingBillForCurrentTrip { (taxiPendingBill) in
                QuickRideProgressSpinner.stopSpinner()
                if let pendingBill = taxiPendingBill,pendingBill.amountPending != 0{
                    let payTaxiPendingBillViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pending_due_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PayTaxiPendingBillViewController") as! PayTaxiPendingBillViewController
                    payTaxiPendingBillViewController.initialisePendingBill(taxiRideId: self.taxiBillViewModel.taxiRide?.id ?? 0,taxiPendingBill: pendingBill,taxiRideInvoice: self.taxiBillViewModel.taxiRideInvoice,paymentMode: self.taxiBillViewModel.taxiRide?.paymentMode,taxiGroupId: self.taxiBillViewModel.taxiRide?.taxiGroupId, isRequiredToInitiatePayment: self.taxiBillViewModel.isRequiredToInitiatePayment) {(isPendingBillCleared) in
                        if isPendingBillCleared{
                            self.taxiBillViewModel.taxiRide?.pendingAmount = 0
                        }
                    }
                    self.navigationController?.pushViewController(payTaxiPendingBillViewController, animated: false)
                }
            }
        }
    }
    
    //MARK: Actions
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        backButtonClicked()
    }
    
    @IBAction func needHelpBtnPressed(_ sender: UIButton) {
        let taxiHelpViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiHelpViewController") as! TaxiHelpViewController
        taxiHelpViewController.initialiseTaxiStatus(tripStatus: taxiBillViewModel.taxiRide?.status, tripType: taxiBillViewModel.taxiRide?.tripType, sharing: taxiBillViewModel.taxiRide?.shareType, isfromTaxiLiveRide: false)
        self.navigationController?.pushViewController(taxiHelpViewController, animated: true)
    }
    
    private func backButtonClicked() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}
//MARK: UITableViewDataSource
extension TaxiBillViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 9
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let outstationTaxiFareDetails = taxiBillViewModel.outstationTaxiFareDetails else { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            if taxiBillViewModel.taxiRide?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
                return (taxiBillViewModel.rentalStopPointList?.count ?? 0) + 1
            }else {
                return 1
            }
        case 2:
            if taxiBillViewModel.taxiRide?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
                return 1
            }else {
                return 0
            }
        case 3:
            return 1
            
        case 4:
            if taxiBillViewModel.isrequiredtoshowFareBreakUpView {
                return taxiBillViewModel.estimateFareData.count
            } else {
                 return 0
             }
        case 5:
            if taxiBillViewModel.isrequiredtoshowFareBreakUpView && (!outstationTaxiFareDetails.taxiUserAdditionalPaymentDetails.isEmpty || !outstationTaxiFareDetails.taxiTripExtraFareDetails.isEmpty) {
                return 1
            }
            return 0
        case 6:
            if taxiBillViewModel.isrequiredtoshowFareBreakUpView {
                return 1
            } else {
                return 0
            }
        case 7:
            return 1
        case 8:
            if taxiBillViewModel.isFeedBackLoaded{ //Showing rating after feedback loaded
                return 1
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
            cell.initialiseDataForTaxiPool(taxiRideInvoice: taxiBillViewModel.taxiRideInvoice, isFromClosedRidesOrTransaction: taxiBillViewModel.isFromClosedRidesOrTransaction, delegate: self)
            return cell
        case 1:
            if taxiBillViewModel.taxiRide?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RentalStopLocationPointTableViewCell", for: indexPath) as! RentalStopLocationPointTableViewCell
                var stopPoint: String?
                var isFirstIndex = false
                if indexPath.row == 0 {
                    stopPoint = taxiBillViewModel.taxiRide?.startAddress
                    isFirstIndex = true
                    cell.titleLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiBillViewModel.taxiRide?.pickupTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MMM_YYYY_h_mm_a)
                    cell.rentalTripIdLabel.text = "Invoice No: " + String(Int(taxiBillViewModel.taxiRideInvoice?.id ?? 0))
                    cell.rentalTripIdLabel.textColor = UIColor.gray
                    cell.dotView.backgroundColor = UIColor(netHex: 0x99D8A8)
                    cell.infoImageView.isHidden = true
                }else if taxiBillViewModel.rentalStopPointList?.count ?? 0 > indexPath.row - 1{
                    stopPoint = taxiBillViewModel.rentalStopPointList?[indexPath.row - 1].stopPointAddress
                    cell.dotView.backgroundColor = UIColor.gray
                }
                cell.setupUI(stopPoint: stopPoint, isFirstIndex: isFirstIndex){ completed in }
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripLocationTableViewCell", for: indexPath) as! TaxiTripLocationTableViewCell
                cell.initialiseLocations(taxiRide: taxiBillViewModel.taxiRide,taxiRideInvoice: taxiBillViewModel.taxiRideInvoice)
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentalTripTimeAndDateTableViewCell", for: indexPath) as! RentalTripTimeAndDateTableViewCell
            let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: taxiBillViewModel.taxiRide?.startTimeMs, time2: taxiBillViewModel.taxiRide?.expectedEndTimeMs)
            var durationInStr = ""
            if duration < 60{
                durationInStr = String(format: Strings.time_in_min, arguments: [String(duration)])
            } else {
                let durationHrInStr = String(format: Strings.x_hr, arguments: [String(duration/60)])
                let remainingDurationInmin = duration % 60
                if remainingDurationInmin > 0{
                    durationInStr = durationHrInStr + " "  + String(format: Strings.time_in_min, arguments: [String(remainingDurationInmin)])
                }else {
                    durationInStr = durationHrInStr
                }
            }
            if let distance = taxiBillViewModel.taxiRide?.distance {
            let distanceAndTime = String(format: Strings.distance_in_km, arguments: [String(Int(distance))]) + " " + durationInStr
            cell.tripDurationAnddistanceLabel.text = distanceAndTime
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiDriverDetailsTableViewCell", for: indexPath) as! TaxiDriverDetailsTableViewCell
            cell.taxiBillViewModel = taxiBillViewModel
            cell.initialiseDriverDetails(isExpandable: taxiBillViewModel.isExpandableBill, taxiRideInvoice: taxiBillViewModel.taxiRideInvoice){ isCellTapping in
                if isCellTapping {
                    if !self.taxiBillViewModel.isrequiredtoshowFareBreakUpView {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareBreakUpView: true)
                    } else {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareBreakUpView: false)
                    }
                }
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            let currentData = taxiBillViewModel.estimateFareData[indexPath.row]
            
            if currentData.key == ReviewScreenViewModel.RIDE_FARE || currentData.key == "Total Fare"{
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                cell.separatorView.isHidden = false
            }else{
                cell.titleLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                cell.separatorView.isHidden = true
            }
            cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdditionalPaymnetActionTableViewCell", for: indexPath) as! AdditionalPaymnetActionTableViewCell
            cell.initialisingData(outstationTaxiFareDetails: taxiBillViewModel.outstationTaxiFareDetails)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEmailInvoiceTableViewCell", for: indexPath) as! TaxiEmailInvoiceTableViewCell
            cell.initialiseDriverDetails(paymentType: taxiBillViewModel.taxiRide?.paymentType) { showInvoiceView in
                if showInvoiceView {
                    self.sendInvoice()
                }
            }
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleReturnTaxiTableViewCell", for: indexPath) as! ScheduleReturnTaxiTableViewCell
            cell.initialiseCell(taxiRide: taxiBillViewModel.taxiRide)
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiBillRatingTableViewCell", for: indexPath) as! TaxiBillRatingTableViewCell
            cell.separatorView.isHidden = true
            cell.initializeRatingCell(taxiRideFeedBack: taxiBillViewModel.taxiRideFeedBack,taxiRidePassenger: taxiBillViewModel.taxiRide, taxiRideInvoice: taxiBillViewModel.taxiRideInvoice,driverName: taxiBillViewModel.taxiRideInvoice?.toUserName ?? "")
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: BillHeaderCardTableViewCellDelegate
extension TaxiBillViewController: BillHeaderCardTableViewCellDelegate {
    func backButtonTapped() {
        backButtonClicked()
    }
    
    func menuButtonTapped() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendByEmailOption = UIAlertAction(title: Strings.sendmail, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sendInvoice()
        })
        optionMenu.addAction(sendByEmailOption)
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
   
    
    
}
extension TaxiBillViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section{
        case 2 :
            return 10
        case 3:
            return 10
        case 7:
            return 14
        default:
            return 0
        }
    }
}
