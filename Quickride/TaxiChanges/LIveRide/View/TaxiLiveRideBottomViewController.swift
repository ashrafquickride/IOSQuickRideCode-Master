
//
//  TaxiLiveRideBottomViewController.swift
//  Quickride
//
//  Created by Ashutos on 24/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class TaxiLiveRideBottomViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var taxiLiveRideCardTableView: UITableView!

    //MARK: Variables
    private var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()

    func prepareDataForUI(taxiLiveRideViewModel: TaxiPoolLiveRideViewModel) {
        self.taxiLiveRideViewModel = taxiLiveRideViewModel
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UITableView.appearance().tableHeaderView = .init(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        self.taxiLiveRideCardTableView.sectionHeaderHeight = 0.0
        registerCells()
        setUpUI()
        updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
        updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.floatingPanelController.move(to: .half, animated: true)
        }

        self.taxiLiveRideViewModel.gettaxiRidePassengerDetails(handler: { (responseError, error) in
            if responseError == nil && error == nil {
                self.taxiLiveRideViewModel.getAvailableDriverDetailsTime(complition: { [self](response) in
                    if response {
                        taxiLiveRideViewModel.allowtedtime = taxiLiveRideViewModel.getallocationTime()
                        updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
                        taxiLiveRideCardTableView.reloadData()


                    }
                })
            }
        })
        taxiLiveRideCardTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        confirmObservers()
        checkAndDisplayNewDriverAllotedPopup()
        taxiLiveRideViewModel.getFareBrakeUpData()
        taxiLiveRideCardTableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        taxiLiveRideViewModel.timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    private func registerCells() {
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiRideJoinedMembersTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiRideJoinedMembersTableViewCell")
        //        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiTripStepsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripStepsTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "PaymentPendingCardTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentPendingCardTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "PaymentDetailsOutStationTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentDetailsOutStationTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "OutStationTaxiShowingTableViewCell", bundle: nil), forCellReuseIdentifier: "OutStationTaxiShowingTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "HomeScreenAndLiveRideOfferTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeScreenAndLiveRideOfferTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "InstantDriverNotAvailableTableViewCell", bundle: nil), forCellReuseIdentifier: "InstantDriverNotAvailableTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "InstantTripSearchingDriverTableViewCell", bundle: nil), forCellReuseIdentifier: "InstantTripSearchingDriverTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "RescheduledTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "RescheduledTaxiTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "RescheduledTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "RescheduledTaxiTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiBookedTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiBookedTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiAllotedTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiAllotedTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiStartedTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiStartedTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiPaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPaymentTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "InstantHighFareDriverAvailableTableViewCell", bundle: nil), forCellReuseIdentifier: "InstantHighFareDriverAvailableTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "EditTaxiTripTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTaxiTripTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "OutstationInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationInfoTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "CarpoolContactCustomerCareTableViewCell", bundle: nil), forCellReuseIdentifier: "CarpoolContactCustomerCareTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiEtiquettesTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiEtiquettesTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "OptionHeadersTableViewCell", bundle: nil), forCellReuseIdentifier: "OptionHeadersTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "OutstationTaxiInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationTaxiInfoTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "PoolMyTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "PoolMyTaxiTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxipoolJoinedMembersTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxipoolJoinedMembersTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "InviteCarpoolRideGiversTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteCarpoolRideGiversTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "RentalStopLocationPointTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalStopLocationPointTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "OutStationTaxiBookedTableViewCell", bundle: nil), forCellReuseIdentifier: "OutStationTaxiBookedTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "InviteByContactTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteByContactTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "BookExclusiveTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "BookExclusiveTaxiTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiNotFoundTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiNotFoundTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "CancelRescheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "CancelRescheduleTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "CancelTableViewCell", bundle: nil), forCellReuseIdentifier: "CancelTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "FareSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "FareSummaryTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "DriverAddedChargesTableViewCell", bundle: nil), forCellReuseIdentifier: "DriverAddedChargesTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "CashPaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CashPaymentsTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "TaxiFarePaidTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiFarePaidTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "BalanceToBePaidTableViewCell", bundle: nil), forCellReuseIdentifier: "BalanceToBePaidTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "PayTaxiAmountTableViewCell", bundle: nil), forCellReuseIdentifier: "PayTaxiAmountTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "RentalTaxiDriverDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalTaxiDriverDetailsTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "LocationDetailseTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationDetailseTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "SectionTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTitleTableViewCell")
        taxiLiveRideCardTableView.register(UINib(nibName: "EditRouteAndDistanceDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "EditRouteAndDistanceDetailTableViewCell")
    }



    func getRequiredDataForBottomSheet(){
        if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot(){
            addObserver()
            updateInstantTripStatus()
        }
        self.taxiLiveRideViewModel.getBalanceOfLinkedWallet(complitionHandler: { [weak self](result) in
            if result{
                self?.taxiLiveRideCardTableView.reloadData()
            }
        })
        self.taxiLiveRideViewModel.getAvailableDriverDetailsTime(complition: { [self](response) in
            if response {
                taxiLiveRideViewModel.allowtedtime = taxiLiveRideViewModel.getallocationTime()
                taxiLiveRideCardTableView.reloadData()
            }
        })
        if let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger,taxiRidePassenger.endLat != TaxiRidePassenger.UNKNOWN_LAT,taxiRidePassenger.endLng != TaxiRidePassenger.UNKNOWN_LNG, let endAddress = taxiRidePassenger.endAddress, !endAddress.isEmpty{
            MatchedUsersCache.getInstance().getAllMatchedRidersForTaxi(taxiRide: taxiRidePassenger, dataReceiver: self)
        }
    }
    private func confirmObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(payTaxiPendingBill), name: .payTaxiPendingBill, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleInstantRideLater), name: .scheduleInstantRideLater, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaxiLiveRideUI), name: .updateTaxiLiveRideUI, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOutStationFareSummary), name: .refreshOutStationFareSummary, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taxiTripUpdated), name: .taxiTripUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initiateUPIPayment), name: .initiateUPIPayment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayNewDriverAllotedView), name: .newDriverAlloted ,object: nil)
    }

    @objc func payTaxiPendingBill(_ notification: Notification){
        QuickRideProgressSpinner.startSpinner()
        self.taxiLiveRideViewModel.payTaxiBill { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiPendingBillException = Mapper<TaxiPendingBillException>().map(JSONObject: responseObject!["resultData"])
                if taxiPendingBillException?.taxiDemandManagementException?.error?.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI, let extraInfo = taxiPendingBillException?.taxiDemandManagementException?.error?.extraInfo, !extraInfo.isEmpty{
                    self.taxiLiveRideViewModel.initiateUPIPayment(paymentInfo: extraInfo)
                }else{
                    self.taxiLiveRideViewModel.getOutstationFareSummaryDetails()
                    self.taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount = 0
                    self.taxiLiveRideCardTableView.reloadData()
                }
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if responseError != nil {
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: responseError!, viewController: self, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.taxiLiveRideCardTableView.reloadData()
                    })
                } else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }

    @objc func taxiTripUpdated(_ notification: Notification){
        updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
        self.taxiLiveRideCardTableView.reloadData()
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.getTaxiRideDetails()

        }
    }

    @objc func scheduleInstantRideLater(_ notification: Notification){
        self.displayDatePicker()
    }
    @objc func displayNewDriverAllotedView(_ notification: Notification){
        checkAndDisplayNewDriverAllotedPopup()
    }
    @objc func initiateUPIPayment(_ notification: Notification){
        if let orderId = notification.userInfo?["orderId"] as? String,let amount = notification.userInfo?["amount"] as? String{
            let paymentAcknowledgementViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "PaymentRequestLoaderViewController") as! PaymentAcknowledgementViewController
            paymentAcknowledgementViewController.initializeData(orderId: orderId, rideId: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id,isFromTaxi: false,amount: Double(amount) ?? 0) { (result) in
                if result == Strings.success {
                    self.taxiLiveRideViewModel.getOutstationFareSummaryDetails()
                    self.taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount = 0
                    self.taxiLiveRideCardTableView.reloadData()
                }
            }
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: paymentAcknowledgementViewController, animated: false)
        }
    }

    @objc func updateTaxiLiveRideUI(_ notification: Notification){
        if let taxiRidePassengerDetails = notification.userInfo?["taxiRidePassengerDetails"] as? TaxiRidePassengerDetails {
            taxiLiveRideViewModel.taxiRidePassengerDetails = taxiRidePassengerDetails
        }
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.paymentTableView.reloadData()
        }
        updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
    }

    @objc func refreshOutStationFareSummary(_ notification: Notification){
        self.taxiLiveRideViewModel.getOutstationFareSummaryDetails()
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }



    private func setUpUI(){
        taxiLiveRideViewModel.getOffers()
    }

    func updateInstantTripStatus(){
        taxiLiveRideViewModel.timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(showNextStatus), userInfo: nil, repeats: true)
    }
    private func checkAndDisplayNewDriverAllotedPopup(){
        if SharedPreferenceHelper.getNewDriverAllotedNotification() {
            if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideDriverChangeInfo?.driverChangeStatus ==  TaxiTripChangeDriverInfo.DRIVER_CHANGE_STATUS_NEW_DRIVER_ALLOTTED {
                let newDriverAssignedVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewDriverAssignedViewController") as! NewDriverAssignedViewController
                newDriverAssignedVC.initialiseData(taxiRideGroup: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup)
                ViewControllerUtils.addSubView(viewControllerToDisplay: newDriverAssignedVC)
            }
        }
        SharedPreferenceHelper.storeNewDriverAllotedNotification(isRequiredToShowNewDriverAllotedPopup: false)
    }

    @objc private func showNextStatus(){
        var creationTimeMs = 0.0
        if let taxiUpdate = taxiLiveRideViewModel.taxiRideUpdateSuggestion,taxiUpdate.isSuggestionShowed{
            creationTimeMs = Double(taxiUpdate.updatedTimeMs)
        }else{
            creationTimeMs = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.creationTimeMs ?? 0
        }
        let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: NSDate().getTimeStamp(), time2: creationTimeMs)
        if timeDiff < 140 || timeDiff/60 >= 3{
            taxiLiveRideCardTableView.reloadData()
        }
        if taxiLiveRideViewModel.isRequiredToShowInstantRideCancellation(){
            taxiLiveRideCardTableView.reloadData()
        }
    }

    func addObserver(){// These observer only for instant trip
        NotificationCenter.default.addObserver(self, selector: #selector(cancelInstantTrip), name: .cancelInstantTrip, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taxiFareUpadted), name: .taxiFareUpadted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMaximumFareDriversAvailableSuggestion), name: .receivedMaximumFareDriversAvailableSuggestion, object: nil)
    }
    private func searchingForNewDriver(taxiRidePassengerDetails: TaxiRidePassengerDetails?){
        let newTaxiRidePassengerDetails = taxiRidePassengerDetails
        self.taxiLiveRideViewModel.taxiRidePassengerDetails = newTaxiRidePassengerDetails
        taxiLiveRideCardTableView.reloadData()
    }
    @objc func cancelInstantTrip(_ notification: Notification){
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger, let taxiRideId = taxiRidePassenger.id else { return }
        taxiLiveRideViewModel.cancelTaxiRide(taxiId: taxiRideId, cancellationReason: "Instant ride cancellation by user", complition: { (result) in
            if result {

                self.navigationController?.popViewController(animated: false)
            }
        })
    }

    @objc func taxiFareUpadted(_ notification: Notification){
        updateInstantTripStatus()
        taxiLiveRideCardTableView.reloadData()
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.floatingPanelController.move(to: .tip, animated: true)
        }
    }

    @objc func receivedMaximumFareDriversAvailableSuggestion(_ notification: Notification){
        taxiLiveRideViewModel.taxiRideUpdateSuggestion = SharedPreferenceHelper.getTaxiRideGroupSuggestionUpdate(taxiGroupId: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiGroupId ?? 0)
        taxiLiveRideCardTableView.reloadData()
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.floatingPanelController.move(to: .half, animated: true)
        }
    }

    func displayDatePicker() {

        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return  }
        let scheduleLater:ScheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        let minPickupTime = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: taxiRidePassenger.tripType!, fromLatitude: taxiRidePassenger.startLat! , fromLongitude: taxiRidePassenger.startLng!)
        let defaultDate = taxiRidePassenger.pickupTimeMs! > minPickupTime ? taxiRidePassenger.pickupTimeMs : minPickupTime

        scheduleLater.initializeDataBeforePresentingView(minDate: minPickupTime/1000,maxDate: nil, defaultDate: defaultDate!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        scheduleLater.delegate = self
        scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime

        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }

    func showPackageInfo(){
        let rentalRulesAndRestrictionsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalRulesAndRestrictionsViewController") as! RentalRulesAndRestrictionsViewController
        let rentalPackage = RentalPackageConfig(vehicleClass: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiVehicleCategory, extraKmFare: taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?[0].extraKmFare ?? 0, extraMinuteFare: taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?[0].extraMinFare ?? 0,pkgDistanceInKm: Int(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.distance ?? 0),pkgDurationInMins: (DateUtils.getDifferenceBetweenTwoDatesInMins(time1: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, time2: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.expectedEndTimeMs)))
        var rentalPackageConfig = [RentalPackageConfig]()
        rentalPackageConfig.append(rentalPackage)
        rentalRulesAndRestrictionsViewController.initialiseData(rentalPackageConfig: rentalPackageConfig)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rentalRulesAndRestrictionsViewController)
    }
}
//MARK: UITableViewDataSource
extension TaxiLiveRideBottomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            return 21
        } else if taxiLiveRideViewModel.isRentalTrip(){
            return 19
        }else{
            return 23
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            switch section {
            case 0: // outstation taxi booked card
                return 1
            case 1:
                if taxiLiveRideViewModel.isrequiredtoshowCancelview && !taxiLiveRideViewModel.isTaxiStarted() ||  taxiLiveRideViewModel.isrequiredtoshowCancelview && !taxiLiveRideViewModel.isTaxiAllotted() {
                    return 1
                } else{
                    return 0
                }
            case 2: // outstation ride data taxi
                return 4 + taxiLiveRideViewModel.wayPoints.count
            case 3: // outstation payment
                if taxiLiveRideViewModel.outstationTaxiFareDetails != nil{
                    return 1
                }else{
                    return 0
                }
            case 4: // outstation payment
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.estimateFareData.count
                }else{
                    return 0
                }
            case 5:
                if taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0 > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1 //Charges Added by Driver title
                }else{
                    return 0
                }
            case 6://   driver added paymnets
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0
                } else {
                    return 0
                }
            case 7:// total fare
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {
                    return 0
                }

            case 8: // Advance paid

                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION && taxiLiveRideViewModel.isrequiredtoshowFareView{
                    return 1
                } else {
                    return 0
                }
            case 9:

                if taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit != 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {

                    return 0
                }
            case 10:  //cash payments by passenger in fare summary

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0
                }else{
                    return 0
                }

            case 11: // addpayments
                if ((taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) == 0 && taxiLiveRideViewModel.isrequiredtoshowFareView) && (!taxiLiveRideViewModel.isLocalTrip() && taxiLiveRideViewModel.isTaxiStarted()) {
                    return 1
                }else{
                    return 0
                }
            case 12:

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0) > 0 {
                    return (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0)
                }else{
                    return 0
                }
            case 13:
                return 1
            case 14:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) <= 0 || taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.SAVAARI{
                    return 0
                } else {
                    return 1
                }

            case 15: // add payment
                if taxiLiveRideViewModel.isTaxiStarted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.ZYPY{
                    return 1
                }else{
                    return 0
                }

            case 16:
                if  !taxiLiveRideViewModel.isRequiredToShowInfo {
                    return 1
                }
                if let data =  taxiLiveRideViewModel.getDataForFacilitiesAndInclusionAndExclusion() {
                    if data.count == 0{
                        return 0
                    } else {
                        return data.count + 1
                    }
                } else {
                    return 0
                }
            case 17: //etiquettes
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 1
                }else{
                    return 0
                }

            case 18: // Offers
                if taxiLiveRideViewModel.finalOfferList.count > 0 {
                    return 1
                }else{
                    return 0
                }
            case 19://help
                return 1
            case 20:// edit trip
                return 1
            default:
                return 0
            }
        } else if taxiLiveRideViewModel.isRentalTrip(){
            switch section {
            case 0: // rental taxi booked card
                return 1
            case 1:
                if taxiLiveRideViewModel.isrequiredtoshowCancelview && !taxiLiveRideViewModel.isTaxiStarted() ||  taxiLiveRideViewModel.isrequiredtoshowCancelview && !taxiLiveRideViewModel.isTaxiAllotted() || taxiLiveRideViewModel.isrequiredtoshowCancelview && (taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() == nil) {
                    return 1
                } else{
                    return 0
                }

            case 2: // rental payment
                return 1
            case 3: // outstation payment
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.estimateFareData.count
                }else{
                    return 0
                }
            case 4:
                if taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0 > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1 //Charges Added by Driver title
                }else{
                    return 0
                }
            case 5:// driver added paymnets
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0
                } else {
                    return 0
                }
            case 6:// total fare
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {
                    return 0
                }

            case 7: // Advance paid

                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {
                    return 0
                }
            case 8:

                if taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit != 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {

                    return 0
                }
            case 9:  //cash payments by passenger in fare summary

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0
                }else{
                    return 0
                }

            case 10: // addpayments
                if ((taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) == 0 && taxiLiveRideViewModel.isrequiredtoshowFareView)  && (!taxiLiveRideViewModel.isLocalTrip() && taxiLiveRideViewModel.isTaxiStarted()) {
                    return 1
                }else{
                    return 0
                }
            case 11:

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0) > 0 {
                    return (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0)
                }else{
                    return 0
                }
            case 12:

                return 1

            case 13:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) <= 0 || taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.SAVAARI{
                    return 0
                } else {
                    return 1
                }
            case 14:
                if taxiLiveRideViewModel.isTaxiStarted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.ZYPY{
                    return 1
                }else{
                    return 0
                }
            case 15:
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 1
                }else{
                    return 0
                }
            case 16: // offer
                if taxiLiveRideViewModel.finalOfferList.count > 0 {
                    return 1
                }else{
                    return 0
                }
            case 17:// help
                return 1
            case 18: // edit trip
                return 1
            default:
                return 0
            }
        }else {
            switch section {
            case 0: // Instant ride
                if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot(){
                    return 1
                } else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING && taxiLiveRideViewModel.isTaxiAllotted(){
                    return 1
                    // booked/alloted/started
                }  else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE{
                    return 1
                }else{
                    return 0
                }

            case 1:
                if  taxiLiveRideViewModel.isrequiredtoshowCancelview &&  !taxiLiveRideViewModel.isTaxiAllotted() ||  taxiLiveRideViewModel.isrequiredtoshowCancelview && (taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() == nil) || taxiLiveRideViewModel.isrequiredtoshowCancelview &&  !taxiLiveRideViewModel.isTaxiStarted() {
                    return 1
                } else {
                    return 0
                }
            case 2: // taxi joined member
                if taxiLiveRideViewModel.isTaxiAllotted() &&  taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0 >= 1{
                    return 1
                }
                else if !taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING {
                    return 1
                }else{
                    return 0
                }
            case 3: // Book taxi exclusive if sharing not confirmed
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING && (taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0) < 2 && !taxiLiveRideViewModel.isTaxiAllotted(){
                    return 1
                }else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE && !taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.isSharingEnabled(){
                    return 1
                }else {
                    return 0
                }
            case 4:// trip details
                return 4 + taxiLiveRideViewModel.wayPoints.count
            case 5:
                if !taxiLiveRideViewModel.carpoolDrivers.isEmpty,ConfigurationCache.getObjectClientConfiguration().showCarpoolersForTaxiRide && !taxiLiveRideViewModel.isTaxiAllotted() && (taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0) < 2{
                    return 1
                }else{
                    return 0
                }
            case 6: // taxipool invite by contact
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.shareType == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING{
                    return 1
                }else{
                    return 0
                }

            case 7:// add payment
                return 0 // As of now not supporting Add payment so commented
                //                if taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.ZYPY{
                //                    return 1
                //                }else{
                //                    return 0
                //                }
            case 8:// taxi paymnet

                return 1
            case 9: // outstation payment
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.estimateFareData.count
                }else{
                    return 0
                }
            case 10:
                if taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0 > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1 //Charges Added by Driver title
                }else{
                    return 0
                }
            case 11:// driver added paymnets
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0
                } else {
                    return 0
                }
            case 12:// total fare
                if taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {
                    return 0
                }

            case 13: // Advance paid

                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {
                    return 0
                }
            case 14:

                if taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit != 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return 1
                } else {

                    return 0
                }
            case 15:  //cash payments by passenger in fare summary

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) > 0 && taxiLiveRideViewModel.isrequiredtoshowFareView {
                    return taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0
                }else{
                    return 0
                }
            case 16:

                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0) > 0  {
                    return (taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails.count ?? 0)
                }else{
                    return 0
                }
            case 17:
                return 1
            case 18:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) <= 0 || taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.SAVAARI {
                    return 0
                } else {
                    return 1
                }
            case 19: //etiquettes
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 1
                }else{
                    return 0
                }
            case 20: // Offers
                if taxiLiveRideViewModel.finalOfferList.count > 0 {
                    return 1
                }else{
                    return 0
                }
            case 21:// help
                return 1
            case 22:// edit trip
                return 1
            default:
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            switch indexPath.section {
            case 0:
                if taxiLiveRideViewModel.isTaxiStarted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiStartedTableViewCell", for: indexPath) as! TaxiStartedTableViewCell
                    cell.initialiseDriverView(viewModel: taxiLiveRideViewModel) { completed in
                        if completed {
                            self.moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: nil, alreadySelectedLocation: nil)
                        }
                    }
                    return cell
                } else if taxiLiveRideViewModel.isTaxiAllotted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiAllotedTableViewCell", for: indexPath) as! TaxiAllotedTableViewCell
                    cell.initialiseDriverView(viewModel: taxiLiveRideViewModel){ completed in
                        if completed {
                            self.moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: nil, alreadySelectedLocation: nil)
                        }
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OutStationTaxiBookedTableViewCell", for: indexPath) as! OutStationTaxiBookedTableViewCell
                    cell.initialiseView(viewModel: taxiLiveRideViewModel)
                    return cell
                }

            case 1:
                return setupCell(indexPath: indexPath)
            case 2:
                return setupLocationDetails(indexPath: indexPath)
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPaymentTableViewCell", for: indexPath) as! TaxiPaymentTableViewCell
                cell.initialisePaymentCard(outstationTaxiFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails, paymentMode: taxiLiveRideViewModel.paymentMode){ isCellTapping in
                    if isCellTapping {
                        if !self.taxiLiveRideViewModel.isrequiredtoshowFareView {

                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: true)
                        } else {

                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)

                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                            taxiLiveRideMapViewController.handlePaymentViewVisibility()
                        }
                    }
                }

                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                var currentData = taxiLiveRideViewModel.estimateFareData[indexPath.row]
                cell.titleLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                if currentData.key == ReviewScreenViewModel.RIDE_FARE{
                    cell.separatorView.isHidden = false
                    cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_CAR{
                        currentData.key = "Ride Fare (Excludes GST)"
                    }
                }else{
                    cell.separatorView.isHidden = true
                }
                cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Charges Added by Driver" , amount: "")
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DriverAddedChargesTableViewCell", for: indexPath) as! DriverAddedChargesTableViewCell
                cell.driverAddedCharges(viewModel: taxiLiveRideViewModel, taxiTripExtraFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails[indexPath.row])
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Total Fare" , amount: String(taxiLiveRideViewModel.getTotalFareOfTrip()))
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Advance Paid" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.advanceAmount ?? 0))
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Discount" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit ?? 0))
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CashPaymentsTableViewCell", for: indexPath) as! CashPaymentsTableViewCell
                let paymentDetails = taxiLiveRideViewModel.getCashPaymentDetails(taxiUserAdditionalPaymentDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails[indexPath.row])
                var isRequiredToShowAddPayments = false
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE && ((taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) - 1) == indexPath.row{
                    isRequiredToShowAddPayments = true
                }
                cell.updateUIForFare(title: paymentDetails.0, amount: paymentDetails.1, isRequiredShowDisputed: paymentDetails.2, isRequiredShowAddPayment: isRequiredToShowAddPayments, taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
                return cell
            case 11:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CashPaymentsTableViewCell", for: indexPath) as! CashPaymentsTableViewCell
                cell.updateUIForFare(title: "", amount: "", isRequiredShowDisputed: false, isRequiredShowAddPayment: true, taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
                return cell
            case 12:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiFarePaidTableViewCell", for: indexPath) as! TaxiFarePaidTableViewCell
                cell.showOnlinePaymentDetail(taxiRidePaymentDetail: taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails[indexPath.row],isRequiredToShowDate: self.taxiLiveRideViewModel.showDateDataList[indexPath.row]){ isFareTapped in
                    if isFareTapped {
                        self.taxiLiveRideViewModel.showDateDataList[indexPath.row] = !self.taxiLiveRideViewModel.showDateDataList[indexPath.row]
                        self.taxiLiveRideCardTableView.reloadData()
                    }
                }
                return cell
            case 13:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceToBePaidTableViewCell", for: indexPath) as! BalanceToBePaidTableViewCell
                cell.showPendingAmount(amount: taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0)
                return cell
            case 14:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayTaxiAmountTableViewCell", for: indexPath) as! PayTaxiAmountTableViewCell
                cell.initialisePaymentDetails(viewModel: taxiLiveRideViewModel, isFromBottomDrawer: false, actionComplitionHandler: nil)
                return cell
            case 15:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutstationInfoTableViewCell", for: indexPath) as! OutstationInfoTableViewCell
                cell.viewModel = taxiLiveRideViewModel
                return cell
            case 16:
                switch indexPath.row {
                case 0:
                    let tabHeaderCell = tableView.dequeueReusableCell(withIdentifier: "OptionHeadersTableViewCell", for: indexPath) as! OptionHeadersTableViewCell
                    tabHeaderCell.updatDataAsPerUI(selectedIndex: taxiLiveRideViewModel.selectedOptionTabIndex , screenWidth: Double(self.view.frame.size.width), isRequiredToShowInfo: taxiLiveRideViewModel.isRequiredToShowInfo, isFromLiveRide: true) { showInfo in
                        if showInfo {
                            self.taxiLiveRideViewModel.isRequiredToShowInfo = true
                        } else {
                            self.taxiLiveRideViewModel.isRequiredToShowInfo = false
                        }
                        self.taxiLiveRideCardTableView.reloadData()
                    }
                    tabHeaderCell.delegate = self
                    return tabHeaderCell

                default:
                    let outstationTaxiInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OutstationTaxiInfoTableViewCell", for: indexPath) as! OutstationTaxiInfoTableViewCell
                    var imageUri: String?
                    if taxiLiveRideViewModel.selectedOptionTabIndex != 3{
                        imageUri = taxiLiveRideViewModel.getDataForFacilitiesAndInclusionAndExclusion()?[indexPath.row - 1].imageUri
                    }
                    outstationTaxiInfoTableViewCell.facilitiesUI(data: taxiLiveRideViewModel.getDataForFacilitiesAndInclusionAndExclusion()?[indexPath.row - 1].desc ?? "", imageUrl: imageUri)
                    return outstationTaxiInfoTableViewCell
                }

            case 17:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEtiquettesTableViewCell", for: indexPath) as! TaxiEtiquettesTableViewCell
                cell.initializeView(taxiType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType)
                return cell
            case 18:
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
                cell.prepareData(offerList: taxiLiveRideViewModel.finalOfferList, isFromLiveRide: true)
                return cell
            case 19:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolContactCustomerCareTableViewCell", for: indexPath) as! CarpoolContactCustomerCareTableViewCell
                    cell.initialiseHelp(title: "NEED HELP", tripStatus: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status, tripType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType, sharing: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType(), isFromTaxiPool: true)
                return cell
            case 20:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTaxiTripTableViewCell", for: indexPath) as! EditTaxiTripTableViewCell
                cell.initialiseEditView(taxiLiveRideViewModel: taxiLiveRideViewModel, viewController: self) { completed in
                    if completed {
                        self.displayDatePicker()
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        } else if taxiLiveRideViewModel.isRentalTrip(){
            switch indexPath.section {
            case 0:
                if let _ = taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InstantHighFareDriverAvailableTableViewCell", for: indexPath) as! InstantHighFareDriverAvailableTableViewCell
                    cell.initialiseView(taxiLiveRideViewModel: taxiLiveRideViewModel)
                    return cell

                } else if taxiLiveRideViewModel.isTaxiStarted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RentalTaxiDriverDetailsTableViewCell", for: indexPath) as! RentalTaxiDriverDetailsTableViewCell
                    cell.initialiseDriverView(viewModel: taxiLiveRideViewModel)
                    return cell
                } else if taxiLiveRideViewModel.isTaxiAllotted() {
                    if let startOdometerReading = taxiLiveRideViewModel.outstationTaxiFareDetails?.startOdometerReading, startOdometerReading != 0.0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "RentalTaxiDriverDetailsTableViewCell", for: indexPath) as! RentalTaxiDriverDetailsTableViewCell
                        cell.initialiseDriverView(viewModel: taxiLiveRideViewModel)
                        return cell
                    }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiAllotedTableViewCell", for: indexPath) as! TaxiAllotedTableViewCell
                        cell.initialiseDriverView(viewModel: taxiLiveRideViewModel) { completed in
                            if completed {
                                self.moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: nil, alreadySelectedLocation: nil)
                            }
                        }
                        return cell
                    }
                }else if taxiLiveRideViewModel.isRequiredToShowInstantRideCancellation(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiNotFoundTableViewCell", for: indexPath) as! TaxiNotFoundTableViewCell
                    cell.initialiseView(viewModel: taxiLiveRideViewModel) { (updateUi) in
                        if updateUi {
                            self.taxiLiveRideViewModel.gettaxiRidePassengerDetails { responseError, error in
                                if responseError != nil || error != nil {
                                    return
                                }else {
                                    self.taxiLiveRideViewModel.rentalRescheduleTaxitime(taxiridePassengerDetails: self.taxiLiveRideViewModel.taxiRidePassengerDetails, complition: { (result) in
                                        TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: (self.taxiLiveRideViewModel.taxiRidePassengerDetails)!)
                                        NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
                                    })

                                }
                            }
                        }
                    }
                    return cell
                }else if taxiLiveRideViewModel.isAllocationStarted() {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InstantTripSearchingDriverTableViewCell", for: indexPath) as! InstantTripSearchingDriverTableViewCell
                    cell.initialiseInstantTripStatus(viewModel: taxiLiveRideViewModel) { isCellTapping in
                        if isCellTapping {
                            if !self.taxiLiveRideViewModel.isrequiredtoshowCancelview {
                                self.updateUIBasedOnTapping(isrequiredtoshowCancelview: true)
                            } else {
                                self.updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
                            }

                        }


                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OutStationTaxiShowingTableViewCell", for: indexPath) as! OutStationTaxiShowingTableViewCell
                    cell.updateUI(viewModel: taxiLiveRideViewModel)
                    return cell
                }

            case 1:
                return setupCell(indexPath: indexPath)
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPaymentTableViewCell", for: indexPath) as! TaxiPaymentTableViewCell
                cell.initialisePaymentCard(outstationTaxiFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails, paymentMode: taxiLiveRideViewModel.paymentMode){ isCellTapping in
                    if isCellTapping {
                        if !self.taxiLiveRideViewModel.isrequiredtoshowFareView {

                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: true)

                        } else {

                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)

                        }
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                                taxiLiveRideMapViewController.handlePaymentViewVisibility()
                            }
                        }
                    }
                }

                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                var currentData = taxiLiveRideViewModel.estimateFareData[indexPath.row]
                cell.titleLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                if currentData.key == ReviewScreenViewModel.RIDE_FARE{
                    cell.separatorView.isHidden = false
                    cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_CAR{
                        currentData.key = "Ride Fare (Excludes GST)"
                    }
                }else{
                    cell.separatorView.isHidden = true
                }
                cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Charges Added by Driver" , amount: "")
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DriverAddedChargesTableViewCell", for: indexPath) as! DriverAddedChargesTableViewCell
                cell.driverAddedCharges(viewModel: taxiLiveRideViewModel, taxiTripExtraFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails[indexPath.row])
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Total Fare" , amount: String(taxiLiveRideViewModel.getTotalFareOfTrip()))
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Advance Paid" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.advanceAmount ?? 0))
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Discount" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit ?? 0))
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CashPaymentsTableViewCell", for: indexPath) as! CashPaymentsTableViewCell
                let paymentDetails = taxiLiveRideViewModel.getCashPaymentDetails(taxiUserAdditionalPaymentDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails[indexPath.row])
                var isRequiredToShowAddPayments = false
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE && ((taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) - 1) == indexPath.row{
                    isRequiredToShowAddPayments = true
                }
                cell.updateUIForFare(title: paymentDetails.0, amount: paymentDetails.1, isRequiredShowDisputed: paymentDetails.2, isRequiredShowAddPayment: isRequiredToShowAddPayments, taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CashPaymentsTableViewCell", for: indexPath) as! CashPaymentsTableViewCell
                cell.updateUIForFare(title: "", amount: "", isRequiredShowDisputed: false, isRequiredShowAddPayment: true, taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
                return cell
            case 11:

                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiFarePaidTableViewCell", for: indexPath) as! TaxiFarePaidTableViewCell
                cell.showOnlinePaymentDetail(taxiRidePaymentDetail: taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails[indexPath.row], isRequiredToShowDate: self.taxiLiveRideViewModel.showDateDataList[indexPath.row]) { isFareTapped in
                    if isFareTapped {
                        self.taxiLiveRideViewModel.showDateDataList[indexPath.row] = !self.taxiLiveRideViewModel.showDateDataList[indexPath.row]
                        self.taxiLiveRideCardTableView.reloadData()
                    }
                }
                return cell
            case 12:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceToBePaidTableViewCell", for: indexPath) as! BalanceToBePaidTableViewCell
                cell.showPendingAmount(amount: taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0)
                return cell
            case 13:

                let cell = tableView.dequeueReusableCell(withIdentifier: "PayTaxiAmountTableViewCell", for: indexPath) as!  PayTaxiAmountTableViewCell
                cell.initialisePaymentDetails(viewModel: taxiLiveRideViewModel, isFromBottomDrawer: false, actionComplitionHandler: nil)
                return cell
            case 14:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutstationInfoTableViewCell", for: indexPath) as! OutstationInfoTableViewCell
                cell.viewModel = taxiLiveRideViewModel
                return cell

            case 15:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEtiquettesTableViewCell", for: indexPath) as! TaxiEtiquettesTableViewCell
                cell.initializeView(taxiType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType)
                return cell

            case 16:
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
                cell.prepareData(offerList: taxiLiveRideViewModel.finalOfferList, isFromLiveRide: true)
                return cell
            case 17:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolContactCustomerCareTableViewCell", for: indexPath) as! CarpoolContactCustomerCareTableViewCell
                cell.initialiseHelp(title: "NEED HELP", tripStatus: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status, tripType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType, sharing: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType(), isFromTaxiPool: true)
                return cell
            case 18:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTaxiTripTableViewCell", for: indexPath) as! EditTaxiTripTableViewCell
                cell.initialiseEditView(taxiLiveRideViewModel: taxiLiveRideViewModel, viewController: self){ completed in
                    if completed {
                        self.displayDatePicker()
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        }else{
            switch indexPath.section {
            case 0:
                if let _ = taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InstantHighFareDriverAvailableTableViewCell", for: indexPath) as! InstantHighFareDriverAvailableTableViewCell
                    cell.initialiseView(taxiLiveRideViewModel: taxiLiveRideViewModel)
                    return cell
                } else if taxiLiveRideViewModel.isTaxiStarted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiStartedTableViewCell", for: indexPath) as! TaxiStartedTableViewCell
                    cell.initialiseDriverView(viewModel: taxiLiveRideViewModel) { completed in
                        if completed {
                            self.moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: nil, alreadySelectedLocation: nil)
                        }
                    }
                    return cell
                }else if taxiLiveRideViewModel.isTaxiAllotted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiAllotedTableViewCell", for: indexPath) as! TaxiAllotedTableViewCell
                    cell.initialiseDriverView(viewModel: taxiLiveRideViewModel) { completed in
                        if completed {
                            self.moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: nil, alreadySelectedLocation: nil)
                        }
                    }
                    return cell
                }else if taxiLiveRideViewModel.isAllocationStarted(), !taxiLiveRideViewModel.isRequiredToShowInstantRideCancellation(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InstantTripSearchingDriverTableViewCell", for: indexPath) as! InstantTripSearchingDriverTableViewCell
                    cell.initialiseInstantTripStatus(viewModel: taxiLiveRideViewModel){ isCellTapping in
                        if isCellTapping {
                            if !self.taxiLiveRideViewModel.isrequiredtoshowCancelview {
                                self.updateUIBasedOnTapping(isrequiredtoshowCancelview: true)
                            } else {
                                self.updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
                            }
                        }
                    }
                    return cell
                } else if taxiLiveRideViewModel.isRequiredToShowInstantRideCancellation(){

                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiNotFoundTableViewCell", for: indexPath) as! TaxiNotFoundTableViewCell
                    cell.initialiseView(viewModel: taxiLiveRideViewModel){ (updateUi) in
                        if updateUi {
                            self.taxiLiveRideViewModel.getFareforVehicleClass(taxiridePassengerDetails: self.taxiLiveRideViewModel.taxiRidePassengerDetails) { (result) in
                                if result {
                                    self.taxiLiveRideViewModel.toRescheduleTaxitime(complition: { (result) in
                                        if result {
                                            self.taxiLiveRideViewModel.gettaxiRidePassengerDetails { responseError, error in
                                                if responseError != nil || error != nil {
                                                    return
                                                }else {
                                                    self.taxiLiveRideCardTableView.reloadData()
                                                }
                                            }

                                        }
                                    })
                                }
                            }

                        }
                    }
                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiBookedTableViewCell", for: indexPath) as! TaxiBookedTableViewCell

                    cell.initialiseView(viewModel: taxiLiveRideViewModel)

                    return cell

                }

            case 1:
                return setupCell(indexPath: indexPath)
            case 2:
                if taxiLiveRideViewModel.isTaxiAllotted(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxipoolJoinedMembersTableViewCell", for: indexPath) as! TaxipoolJoinedMembersTableViewCell

                    cell.showJoinedMembers(joinedMembers: nil, isFromLiveRide: true,taxiRidePassengerBasicInfos: taxiLiveRideViewModel.getJoinedMemebersOfTaxiPool())
                    return cell
                }else{// after alloting
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiRideJoinedMembersTableViewCell", for: indexPath) as! TaxiRideJoinedMembersTableViewCell
                    cell.initialisationData(viewModel: taxiLiveRideViewModel)
                    return cell
                }

            case 3:
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PoolMyTaxiTableViewCell", for: indexPath) as! PoolMyTaxiTableViewCell
                    cell.showUserPreference(viewModel: taxiLiveRideViewModel)
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "BookExclusiveTaxiTableViewCell", for: indexPath) as! BookExclusiveTaxiTableViewCell
                    cell.showUserBookTaxiPreference(viewModel: taxiLiveRideViewModel)
                    return cell
                }
            case 4:
                return setupLocationDetails(indexPath: indexPath)
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCarpoolRideGiversTableViewCell", for: indexPath) as! InviteCarpoolRideGiversTableViewCell
                if let taxiRide = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger{
                    cell.showCarpoolRideGivers(matchedRideGivers: taxiLiveRideViewModel.carpoolDrivers,taxiRide: taxiRide)
                }
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InviteByContactTableViewCell", for: indexPath) as! InviteByContactTableViewCell
                cell.initializeInviteByContactView(ride: nil,isFromLiveride: true, viewContoller: self,taxiRide: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger)
                return cell

            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutstationInfoTableViewCell", for: indexPath) as! OutstationInfoTableViewCell
                cell.viewModel = taxiLiveRideViewModel
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPaymentTableViewCell", for: indexPath) as! TaxiPaymentTableViewCell
                cell.initialisePaymentCard(outstationTaxiFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails, paymentMode: taxiLiveRideViewModel.paymentMode){ isCellTapping in
                    if isCellTapping {
                        if !self.taxiLiveRideViewModel.isrequiredtoshowFareView {

                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: true)

                        } else {
                            self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)

                        }
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                                taxiLiveRideMapViewController.handlePaymentViewVisibility()
                            }
                        }
                    }
                }
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                var currentData = taxiLiveRideViewModel.estimateFareData[indexPath.row]
                cell.titleLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                if currentData.key == ReviewScreenViewModel.RIDE_FARE{
                    cell.separatorView.isHidden = false
                    cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                    if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_CAR{
                        currentData.key = "Ride Fare (Excludes GST)"
                    }
                }else{
                    cell.separatorView.isHidden = true
                }
                cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Charges Added by Driver" , amount: "")
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 11:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DriverAddedChargesTableViewCell", for: indexPath) as! DriverAddedChargesTableViewCell
                cell.driverAddedCharges(viewModel: taxiLiveRideViewModel, taxiTripExtraFareDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails[indexPath.row])
                return cell
            case 12:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Total Fare" , amount: String(taxiLiveRideViewModel.getTotalFareOfTrip()))
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
                return cell
            case 13:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Advance Paid" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.advanceAmount ?? 0))
                return cell
            case 14:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
                cell.updateUIForFare(title: "Discount" , amount: "- " + String(taxiLiveRideViewModel.outstationTaxiFareDetails?.couponBenefit ?? 0))
                return cell
            case 15:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CashPaymentsTableViewCell", for: indexPath) as! CashPaymentsTableViewCell
                let paymentDetails = taxiLiveRideViewModel.getCashPaymentDetails(taxiUserAdditionalPaymentDetails: taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails[indexPath.row])
                var isRequiredToShowAddPayments = false
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE && ((taxiLiveRideViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) - 1) == indexPath.row{
                    isRequiredToShowAddPayments = true
                }
                cell.updateUIForFare(title: paymentDetails.0, amount: paymentDetails.1, isRequiredShowDisputed: paymentDetails.2, isRequiredShowAddPayment: isRequiredToShowAddPayments, taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
                return cell
            case 16:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiFarePaidTableViewCell", for: indexPath) as! TaxiFarePaidTableViewCell
                cell.showOnlinePaymentDetail(taxiRidePaymentDetail: taxiLiveRideViewModel.outstationTaxiFareDetails?.ridePaymentDetails[indexPath.row], isRequiredToShowDate: self.taxiLiveRideViewModel.showDateDataList[indexPath.row]){ isFareTapped in
                    if isFareTapped {
                        self.taxiLiveRideViewModel.showDateDataList[indexPath.row] = !self.taxiLiveRideViewModel.showDateDataList[indexPath.row]
                        self.taxiLiveRideCardTableView.reloadData()
                    }
                }
                return cell
            case 17:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceToBePaidTableViewCell", for: indexPath) as! BalanceToBePaidTableViewCell
                cell.showPendingAmount(amount: taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0)
                return cell
            case 18:

                let cell = tableView.dequeueReusableCell(withIdentifier: "PayTaxiAmountTableViewCell", for: indexPath) as! PayTaxiAmountTableViewCell
                cell.initialisePaymentDetails(viewModel: taxiLiveRideViewModel, isFromBottomDrawer: false, actionComplitionHandler: nil)
                return cell
            case 19:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEtiquettesTableViewCell", for: indexPath) as! TaxiEtiquettesTableViewCell
                cell.initializeView(taxiType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType)
                return cell
            case 20:
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
                cell.prepareData(offerList: taxiLiveRideViewModel.finalOfferList, isFromLiveRide: true)
                return cell
            case 21:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolContactCustomerCareTableViewCell", for: indexPath) as! CarpoolContactCustomerCareTableViewCell
                cell.initialiseHelp(title: "NEED HELP", tripStatus: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status, tripType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType, sharing: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType(), isFromTaxiPool: true)
                return cell
            case 22:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTaxiTripTableViewCell", for: indexPath) as! EditTaxiTripTableViewCell
                cell.initialiseEditView(taxiLiveRideViewModel: taxiLiveRideViewModel, viewController: self){ completed in
                    if completed {
                        self.displayDatePicker()
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }

    func setupCell(indexPath: IndexPath) -> UITableViewCell {

        let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "CancelRescheduleTableViewCell", for: indexPath) as! CancelRescheduleTableViewCell
        cell.initialiseView(taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
        return cell
    }

    func setUpCancelCell(indexPath: IndexPath)-> UITableViewCell {

        let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "CancelTableViewCell", for: indexPath) as! CancelTableViewCell
        cell.initialiseView(taxiRidePassengerDetails: taxiLiveRideViewModel.taxiRidePassengerDetails)
        return cell
    }

    func hiddingAndUnhiddingTableViewCell() {

        if !taxiLiveRideViewModel.isrequiredtoshowCancelview {
            updateUIBasedOnTapping(isrequiredtoshowCancelview: true)
        } else {
            updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
        }
    }

    func setupLocationDetails(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // section title
            let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell", for: indexPath) as! SectionTitleTableViewCell
            if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.OUTSTATION {
                cell.initialiseData(tripType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.journeyType)
            }
            return cell
        }else if indexPath.row == 1 { // start adderss
            let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "LocationDetailseTableViewCell", for: indexPath) as! LocationDetailseTableViewCell
            cell.initialiseData(locationType: LocationType.pickup, location: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startAddress ?? ""){ completed in
                let location = Location(latitude: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat ?? 0, longitude: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng ?? 0, shortAddress: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startAddress)
                self.moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: location, alreadySelectedLocation: location)
            }
            return cell
        }else if taxiLiveRideViewModel.wayPoints.count > 0, indexPath.row < taxiLiveRideViewModel.wayPoints.count + 2 { // via points
            let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "LocationDetailseTableViewCell", for: indexPath) as! LocationDetailseTableViewCell
            cell.initialiseData(locationType: LocationType.viapoint, location: taxiLiveRideViewModel.wayPoints[indexPath.row - 2].address ?? "") { completed in
                if completed {
                    self.taxiLiveRideViewModel.viaPointRemoved(index: (indexPath.row - 2))
                    self.getRoutes()
                }else {
                    self.moveToEditRouteView()
                }
            }
            return cell
        }else if indexPath.row == taxiLiveRideViewModel.wayPoints.count + 2 { // end address
            let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "LocationDetailseTableViewCell", for: indexPath) as! LocationDetailseTableViewCell
            cell.initialiseData(locationType: LocationType.drop, location: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endAddress ?? "") { completed in
                let location = Location(latitude: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLat ?? 0, longitude: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLng ?? 0, shortAddress: self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endAddress)
                self.moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: location, alreadySelectedLocation: location)
            }
            return cell
        }else { // edit route button
            let cell = taxiLiveRideCardTableView.dequeueReusableCell(withIdentifier: "EditRouteAndDistanceDetailTableViewCell", for: indexPath) as! EditRouteAndDistanceDetailTableViewCell
            cell.initialiseData(viewModel: taxiLiveRideViewModel)
            return cell
        }
    }
}
//MARK: UITableViewDataSource
extension TaxiLiveRideBottomViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.handlePaymentViewVisibility()
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            switch section {
            case 1:
                return 14
            case 2:
                if taxiLiveRideViewModel.outstationTaxiFareDetails != nil{
                    return 14
                }else{
                    return 0
                }
            case 13:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) == 0 {
                    return 14
                } else {
                    return 0
                }
            case 14:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) > 0 || taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.SAVAARI{
                    return 14
                } else {
                    return 0
                }
            case 15:
                if taxiLiveRideViewModel.isTaxiStarted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.ZYPY{
                    return 14
                }else{
                    return 0
                }
            case 16:
                return 14
            case 17:
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 14
                }else{
                    return 0
                }
            case 18:
                if taxiLiveRideViewModel.finalOfferList.count > 0{
                    return 14
                }else{
                    return 0
                }
            default:
                return 0
            }
        }else if taxiLiveRideViewModel.isRentalTrip(){
            switch section {
            case 1:
                return 14
            case 13:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) == 0 {
                    return 14
                } else {
                    return 0
                }
            case 14:
                if (taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount ?? 0) > 0 || taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.SAVAARI{
                    return 14
                } else {
                    return 0
                }
            case 15:
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 14
                }else{
                    return 0
                }
            case 16: // offer
                if taxiLiveRideViewModel.finalOfferList.count > 0 {
                    return 14
                }else{
                    return 0
                }
            case 17:
                return 1
            default:
                return 0
            }
        }else {
            switch section {
            case 0: // Instant ride
                guard taxiLiveRideViewModel.isTaxiAllotted() || taxiLiveRideViewModel.isTaxiStarted() else {
                    return 0
                }
                if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot(){
                    return 14
                } else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING && taxiLiveRideViewModel.isTaxiAllotted(){
                    return 14
                    // booked/alloted/started
                }  else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE{
                    return 14
                }else{
                    return 0
                }
            case 1:
                if  taxiLiveRideViewModel.isrequiredtoshowCancelview &&  !taxiLiveRideViewModel.isTaxiAllotted() ||  taxiLiveRideViewModel.isrequiredtoshowCancelview && (taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() == nil) || taxiLiveRideViewModel.isrequiredtoshowCancelview &&  !taxiLiveRideViewModel.isTaxiStarted() {
                    return 14
                } else {
                    return 0
                }
            case 2:
                if taxiLiveRideViewModel.isTaxiAllotted() &&  taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0 >= 1{
                    return 14
                }
                else if !taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING {
                    return 14
                }else{
                    return 0
                }
            case 3: // Book taxi exclusive if sharing not confirmed
                if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING && (taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0) < 2 && !taxiLiveRideViewModel.isTaxiAllotted(){
                    return 14
                }else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE && !taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.isSharingEnabled(){
                    return 14
                }else {
                    return 0
                }

            case 5:
                if  !taxiLiveRideViewModel.carpoolDrivers.isEmpty,ConfigurationCache.getObjectClientConfiguration().showCarpoolersForTaxiRide && !taxiLiveRideViewModel.isTaxiAllotted() && (taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0) < 2{
                    return 14
                }else{
                    return 0
                }
            case 6: //payment card
                if (taxiLiveRideViewModel.outstationTaxiFareDetails != nil) && (taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.shareType == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING){
                    return 14
                }else{
                    return 0
                }
            case 7: //add payment
                return 0
                //                if taxiLiveRideViewModel.isTaxiAllotted() && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.taxiPartnerCode == TaxiRideGroup.ZYPY{
                //                    return 14
                //                }else{
                //                    return 0
                //                }

            case 18:
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 14
                }else{
                    return 0
                }
            case 19:
                if !ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList.isEmpty{
                    return 14
                }else{
                    return 0
                }
            case 20:
                if taxiLiveRideViewModel.finalOfferList.count > 0 {
                    return 14
                }else{
                    return 0
                }
            default:
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if taxiLiveRideViewModel.isRentalTrip() {
            if indexPath.section == 2 && (taxiLiveRideViewModel.rentalStopPointList?.count ?? 0) + 1 == indexPath.row{
                moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: nil, alreadySelectedLocation: nil)
            }
        }

        if indexPath.section == 0 && !taxiLiveRideViewModel.isTaxiStarted(), !taxiLiveRideViewModel.isTaxiAllotted(),(taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() == nil) {
            hiddingAndUnhiddingTableViewCell()

        }

    }

    func updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: Bool){
        taxiLiveRideViewModel.isrequiredtoshowFareView = isrequiredtoshowFareView
        taxiLiveRideViewModel.getFareBrakeUpData()
        self.taxiLiveRideCardTableView.reloadData()
    }



    func updateUIBasedOnTapping(isrequiredtoshowCancelview: Bool){
        taxiLiveRideViewModel.isrequiredtoshowCancelview = isrequiredtoshowCancelview
        self.taxiLiveRideCardTableView.reloadData()
    }


    func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

    func addNewStopPoint(endAddress: String,endlat: Double,endlng: Double){
        QuickRideProgressSpinner.startSpinner()
        var startLatitude: Double?
        var startLongitude: Double?
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status == TaxiRidePassenger.STATUS_STARTED{
            if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                startLatitude = taxiLiveRideMapViewController.currentLocation?.latitude
                startLongitude = taxiLiveRideMapViewController.currentLocation?.longitude
            }
        }
        taxiLiveRideViewModel.addNewRentalStopPoints(startAddress : nil, startLatitude: startLatitude, startLongitude: startLongitude, endAddress: endAddress ,endlat: endlat ,endlng: endlng) { (responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                taxiLiveRideMapViewController.refreshMapWithNewData()
                taxiLiveRideMapViewController.refreshUI(isRefreshClicked: false)
            }
            self.taxiLiveRideCardTableView.reloadData()
            if responseError != nil && error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
            }
        }
    }
}


//MARK: SelectDateDelegate
extension TaxiLiveRideBottomViewController: SelectDateDelegate {
    func getTime(date: Double) {
        AppDelegate.getAppDelegate().log.debug("getTime")
        if let taxiRideUpdateSuggestion = taxiLiveRideViewModel.taxiRideUpdateSuggestion{
            rescheduleTaxiRide(startTime: date*1000, fixedFareId: taxiRideUpdateSuggestion.fixedFareId ?? "")
        }else if taxiLiveRideViewModel.isRentalTrip(){
            getTaxiRentalConfig(startTime: date*1000)
        }
        else{
            getAvailableVehicleClassAndReschedule(startTime: date*1000)
        }
    }

    func getTaxiRentalConfig(startTime: Double) {
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else {
            return
        }
        QuickRideProgressSpinner.startSpinner()
        TaxiUtils.getRentalPackage(startLat: taxiRidePassenger.startLat!, startLng: taxiRidePassenger.startLng!, startAddress: taxiRidePassenger.startAddress!, startCity: taxiRidePassenger.startCity, taxiVehicleCategory: taxiRidePassenger.taxiVehicleCategory!, distance: taxiRidePassenger.distance!,startTime: taxiRidePassenger.startTimeMs!) { package, responseError, error in
            QuickRideProgressSpinner.stopSpinner()
            if let package = package,let fare = package.pkgFare{
                TaxiUtils.displayFareToConfirm(currentFare: taxiRidePassenger.initialFare!, newFare: Double(fare)) {
                    [weak self] result in
                    if !result{
                        return
                    }
                    QuickRideProgressSpinner.startSpinner()
                    self?.taxiLiveRideViewModel.rescheduleRentalTaxiRide(startTime: startTime, complition: { result in
                        QuickRideProgressSpinner.stopSpinner()
                        if result{
                            self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs = startTime
                            TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: (self?.taxiLiveRideViewModel.taxiRidePassengerDetails)!)
                            NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
                            let topRow = IndexPath(row: 0, section: 0)
                            self?.taxiLiveRideCardTableView.scrollToRow(at: topRow, at: .top, animated: false)
                            UIApplication.shared.keyWindow?.makeToast(Strings.ride_rescheduled)
                            if let taxiLiveRideMapViewController = self?.parent?.parent as? TaxiLiveRideMapViewController {
                                taxiLiveRideMapViewController.floatingPanelController.move(to: .half, animated: true)
                            }
                            self?.taxiLiveRideCardTableView.reloadData()
                        }
                    })
                }

            }else{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)

            }
        }
    }

    private func getAvailableVehicleClassAndReschedule(startTime: Double){
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        QuickRideProgressSpinner.startSpinner()
        TaxiUtils.getAvailableVehicleClass(startTime: startTime, startAddress: taxiRidePassenger.startAddress, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: taxiRidePassenger.routeId) {[weak self] detailedEstimatedFare, responseError, error in

            QuickRideProgressSpinner.stopSpinner()
            if let detailedEstimatedFare = detailedEstimatedFare, let fareForVehicleClass = TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimatedFare, taxiVehicleCategory: taxiRidePassenger.taxiVehicleCategory!) {
                TaxiUtils.displayFareToConfirm(currentFare: taxiRidePassenger.initialFare!, newFare: fareForVehicleClass.maxTotalFare!) {
                    [weak self] result in
                    if !result{
                        return
                    }
                    self?.rescheduleTaxiRide(startTime: startTime, fixedFareId: fareForVehicleClass.fixedFareId!)
                }

            }else{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self?.parent)
            }
        }
    }

    private func rescheduleTaxiRide(startTime: Double,fixedFareId: String){
        QuickRideProgressSpinner.startSpinner()
        taxiLiveRideViewModel.rescheduleTaxiRide(startTime: startTime, fixedFareId: fixedFareId) { [weak self] (result) in
            QuickRideProgressSpinner.stopSpinner()
            if result{
                TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: (self?.taxiLiveRideViewModel.taxiRidePassengerDetails)!)
                NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
                self?.updateUI()

                UIApplication.shared.keyWindow?.makeToast(Strings.ride_rescheduled)
                self?.taxiLiveRideCardTableView.reloadData()
            }
        }
    }

    private func updateUI(){
        taxiLiveRideCardTableView.reloadData()
        if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
            taxiLiveRideMapViewController.updateUI()
        }

    }

}
extension TaxiLiveRideBottomViewController: OptionHeadersTableViewCellDelegate{
    func selectedTab(selectedIndex: Int) {
        self.taxiLiveRideViewModel.selectedOptionTabIndex = selectedIndex
        self.taxiLiveRideCardTableView.reloadData()
    }
}
//MARK: TaxiMatchedRidersDataReceiver
extension TaxiLiveRideBottomViewController: TaxiMatchedRidersDataReceiver{
    func receiveMatchedRidersList(matchedRiders: [MatchedRider]) {
        taxiLiveRideViewModel.carpoolDrivers = matchedRiders
        updateUIBasedOnTapping(isrequiredtoshowCancelview: false)
        taxiLiveRideCardTableView.reloadData()
    }
    func matchingRidersRetrievalFailed(responseObject: NSDictionary?, error: NSError?) {}
}

extension TaxiLiveRideBottomViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }

        if taxiLiveRideViewModel.isRentalTrip(){
            addNewStopPoint(endAddress: location.address ?? "", endlat: location.latitude , endlng: location.longitude)
        }else{
            if requestLocationType == ChangeLocationViewController.ORIGIN {
                getFareDetails(startTime: taxiRidePassenger.pickupTimeMs!, startAddress: location.address, startLatitude: location.latitude, startLongitude: location.longitude, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: nil) { result, responseError, error in
                    if let mapVC = self.parent?.parent as? TaxiLiveRideMapViewController, (result != nil) {
                        mapVC.getTaxiRideDetails()
                        mapVC.getNearbyTaxiIfRequired()
                    }
                }
            }else {
                if let pickupLat = taxiRidePassenger.startLat, let pickupLng = taxiRidePassenger.startLng, LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: pickupLat, toLongitude: pickupLng) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES {
                    UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff)
                    return
                }
                getFareDetails(startTime: taxiRidePassenger.pickupTimeMs!, startAddress: taxiRidePassenger.startAddress!, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: location.latitude, endLongitude: location.longitude, endAddress: location.shortAddress!, journeyType: taxiRidePassenger.journeyType!, routeId: nil) { detailedEstimatedFare, responseError, error in }
            }
        }
    }

    func locationSelectionCancelled(requestLocationType: String) {

    }
}
extension TaxiLiveRideBottomViewController: RouteReceiver{ // remove via point

    func getRoutes(){
        QuickRideProgressSpinner.startSpinner()
        let wayPoints = taxiLiveRideViewModel.wayPoints
        if !wayPoints.isEmpty{
            let viaPoints = LocationClientUtils.simplifyWayPoints(wayPoints: wayPoints)
            let wayPointsString = viaPoints?.toJSONString()
            MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App.CustomRoute.TaxiRideEditView", rideId: 0 ,startLatitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat ?? 0, startLongitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng ?? 0, endLatitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLat ?? 0, endLongitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLng ?? 0 ,wayPoints: wayPointsString, routeReceiver : self,saveCustomRoute: false)
        }else{
            getEstimatedFare()
        }

    }

    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        if rideRoute.isEmpty{
            return
        }
        if !alternative {
            getEstimatedFare(selectedRouteId: rideRoute[0].routeId)
        }
    }

    func getEstimatedFare(selectedRouteId: Double? = nil){
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        getFareDetails(startTime: taxiRidePassenger.startTimeMs!, startAddress: taxiRidePassenger.startAddress!, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: selectedRouteId) { result, responseError, error in
            if let mapVC = self.parent?.parent as? TaxiLiveRideMapViewController, (result != nil) {
                mapVC.getTaxiRideDetails()
                mapVC.getNearbyTaxiIfRequired()
            }
        }
    }

    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {    }
    private func moveToEditRouteView() {
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        let taxiRideEditViewController = UIStoryboard(name: "TaxiEdit", bundle: nil).instantiateViewController(withIdentifier: "TaxiRideEditViewController") as! TaxiRideEditViewController
        taxiRideEditViewController.initialiseData(taxiRidePassenger: taxiRidePassenger.copy() as! TaxiRidePassenger) { [weak self]
                    (taxiRidePassenger) in
            if let mapVC = self?.parent?.parent as? TaxiLiveRideMapViewController {
                mapVC.getTaxiRideDetails()
            }
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiRideEditViewController, animated: true)
    }

    func getFareDetails(startTime: Double,startAddress : String?, startLatitude: Double,startLongitude: Double,endLatitude: Double, endLongitude: Double,endAddress : String?,journeyType: String, routeId: Double?, handler: @escaping(_ result: DetailedEstimateFare?, _ responseError : ResponseError?, _ error: NSError?)->()){
        QuickRideProgressSpinner.startSpinner()
        TaxiUtils.getAvailableVehicleClass(startTime: startTime , startAddress: startAddress, startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, endAddress: endAddress, journeyType: journeyType, routeId: routeId) { result, responseError, error in
            QuickRideProgressSpinner.stopSpinner()
            if let detailedEstimatedFare = result, let taxiRidePassenger = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger ,let fareForVehicleClass = TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimatedFare, taxiVehicleCategory: taxiRidePassenger.taxiVehicleCategory!) {

                TaxiUtils.displayFareToConfirm(currentFare: taxiRidePassenger.initialFare!, newFare: fareForVehicleClass.maxTotalFare!) {
                    [weak self] result in

                    if !result{
                        return
                    }
                    QuickRideProgressSpinner.startSpinner()
                    self?.taxiLiveRideViewModel.updateTaxiTrip(endLatitude: endLatitude, endLongitude: endLongitude, endAddress: endAddress, taxiRidePassengerId: taxiRidePassenger.id!, startLatitude: startLatitude, startLongitude: startLongitude, startAddress: startAddress, pickupNote: nil, selectedRouteId: Double(fareForVehicleClass.routeId!)!, fixedFareId: fareForVehicleClass.fixedFareId!, complition: { result in
                        QuickRideProgressSpinner.stopSpinner()
                        handler(detailedEstimatedFare, nil, nil)
                    })
                }

            }else{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parent)
            }
        }
    }

}
