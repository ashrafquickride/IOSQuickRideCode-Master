//
//  TaxiTripReportViewController.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripReportViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var taxiBillTableView: UITableView!
    
    //MARK: Variables
    private var taxiTripReportViewModel = TaxiTripReportViewModel()
    
    func initialiseData(taxiRideInvoice: TaxiRideInvoice?,taxiRide: TaxiRidePassenger,cancelTaxiRideInvoice: [CancelTaxiRideInvoice]) {
        taxiTripReportViewModel = TaxiTripReportViewModel(taxiRideInvoice: taxiRideInvoice,taxiRide: taxiRide,cancelTaxiRideInvoice: cancelTaxiRideInvoice)
    }
    
    //MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        if taxiTripReportViewModel.taxiRide?.status == TaxiRidePassenger.STATUS_COMPLETED{
            taxiTripReportViewModel.getFeedBack(complitionHandler: { [weak self]
                result in
                if result{
                    self?.taxiBillTableView.reloadData()
                }
            })
            taxiTripReportViewModel.getExtraChargesAddedByDriverAndPassenger(complitionHandler: { [weak self]
                result in
                if result{
                    self?.taxiBillTableView.reloadData()
                }
            })
        }
        if taxiTripReportViewModel.taxiRideInvoice?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL {
            taxiTripReportViewModel.getAllRentalStopPoints{ [self] (responseError, error) in
                if responseError != nil && error != nil {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
                    return
                }
                self.taxiBillTableView.reloadData()
            }
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
    
    private func registerCell() {
        taxiBillTableView.register(UINib(nibName: "TripMapTableViewCell", bundle: nil), forCellReuseIdentifier: "TripMapTableViewCell")
        taxiBillTableView.register(UINib(nibName: "DriverDetailsAndFareBrekupTableViewCell", bundle: nil), forCellReuseIdentifier: "DriverDetailsAndFareBrekupTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiTripHelpTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripHelpTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiBillRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiBillRatingTableViewCell")
        taxiBillTableView.register(UINib(nibName: "CancelledTripTableViewCell", bundle: nil), forCellReuseIdentifier: "CancelledTripTableViewCell")
        taxiBillTableView.register(UINib(nibName: "FareSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "FareSummaryTableViewCell")
        taxiBillTableView.register(UINib(nibName: "AdditionalPaymnetActionTableViewCell", bundle: nil), forCellReuseIdentifier: "AdditionalPaymnetActionTableViewCell")
        taxiBillTableView.register(UINib(nibName: "TaxiEmailInvoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiEmailInvoiceTableViewCell")
    }
    
    private func confirmObservers(){

        NotificationCenter.default.addObserver(self, selector: #selector(ratingGivenForDriver), name: .ratingGivenForDriver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startSpinner), name: .startSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .stopSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    func updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: Bool){
        taxiTripReportViewModel.isrequiredtoshowFareView = isrequiredtoshowFareView
        if taxiTripReportViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            taxiTripReportViewModel.getFareBrakeUpData()
        } else if taxiTripReportViewModel.taxiRideInvoice?.tripType == TaxiPoolConstants.TRIP_TYPE_RENTAL {
            taxiTripReportViewModel.getFareBrakeUpDataForRental()
        } else {
            taxiTripReportViewModel.getFareBrakeUpData()
        }
        self.taxiBillTableView.reloadData()
    }
    
    private func sendInvoice() {
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
                taxiTripReportViewModel.sendInvoiceToPassenger()
            }
        }else{
            var  modelLessDialogue: ModelLessDialogue?
            modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as? ModelLessDialogue
            modelLessDialogue?.initializeViews(message: Strings.emailid_not_given_for_profile, actionText: Strings.configure_email)
            modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditingVC(_:))))
            modelLessDialogue?.isUserInteractionEnabled = true
            modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height ?? 0/2, width: self.view.frame.width ?? 0, height: 80)
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

    @objc func ratingGivenForDriver(_ notification: Notification){
        let taxiRideFeedback = notification.userInfo?["taxiRideFeedback"] as? TaxiRideFeedback
        self.taxiTripReportViewModel.taxiRideFeedBack = taxiRideFeedback
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
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: UITableViewDataSource
extension TaxiTripReportViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let outstationTaxiFareDetails = taxiTripReportViewModel.outstationTaxiFareDetails else { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            if taxiTripReportViewModel.taxiRide?.status == TaxiRidePassenger.STATUS_COMPLETED{
                return 1
            }else{
                return 0
            }
        case 2:
            if taxiTripReportViewModel.isrequiredtoshowFareView {
                return taxiTripReportViewModel.estimateFareData.count
            } else {
                return 0
            }
        case 3:
            if taxiTripReportViewModel.isrequiredtoshowFareView && (!outstationTaxiFareDetails.taxiUserAdditionalPaymentDetails.isEmpty || !outstationTaxiFareDetails.taxiTripExtraFareDetails.isEmpty) {
                return 1
            }
            return 0
        case 4:
            if taxiTripReportViewModel.isrequiredtoshowFareView {
                return 1
            } else {
                return 0
            }
        case 5:
            if taxiTripReportViewModel.isFeedBackLoaded{ //Showing rating after feedback loaded
                return 1
            }else{
                return 0
            }
        case 6:
            if !taxiTripReportViewModel.cancelTaxiRideInvoices.isEmpty{
                return taxiTripReportViewModel.cancelTaxiRideInvoices.count
            }else{
                return 0
            }
        case 7:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripMapTableViewCell", for: indexPath) as! TripMapTableViewCell
            cell.initalizeRoute(taxiTripReportViewModel: taxiTripReportViewModel)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverDetailsAndFareBrekupTableViewCell", for: indexPath) as! DriverDetailsAndFareBrekupTableViewCell
            cell.initialiseDriverDetails(taxiRideInvoice: taxiTripReportViewModel.taxiRideInvoice,taxiTripReportViewModel: taxiTripReportViewModel){ isCellTapping in
                if isCellTapping {
                    if !self.taxiTripReportViewModel.isrequiredtoshowFareView {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: true)
                    } else {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)
                    }
                }
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            let currentData = taxiTripReportViewModel.estimateFareData[indexPath.row]
            
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
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdditionalPaymnetActionTableViewCell", for: indexPath) as! AdditionalPaymnetActionTableViewCell
            cell.initialisingData(outstationTaxiFareDetails: taxiTripReportViewModel.outstationTaxiFareDetails)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEmailInvoiceTableViewCell", for: indexPath) as! TaxiEmailInvoiceTableViewCell
            cell.initialiseDriverDetails(paymentType: taxiTripReportViewModel.taxiRide?.paymentType) { showInvoiceView in
                if showInvoiceView {
                    self.sendInvoice()
                }
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiBillRatingTableViewCell", for: indexPath) as! TaxiBillRatingTableViewCell
            cell.initializeRatingCell(taxiRideFeedBack: taxiTripReportViewModel.taxiRideFeedBack,taxiRidePassenger: taxiTripReportViewModel.taxiRide,taxiRideInvoice:taxiTripReportViewModel.taxiRideInvoice,driverName: taxiTripReportViewModel.taxiRideInvoice?.toUserName ?? "")
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CancelledTripTableViewCell", for: indexPath) as! CancelledTripTableViewCell
            cell.initialiseCancellationCell(cancelTaxiRideInvoice: taxiTripReportViewModel.cancelTaxiRideInvoices[indexPath.row], taxiRide: taxiTripReportViewModel.taxiRide)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripHelpTableViewCell", for: indexPath) as! TaxiTripHelpTableViewCell
            cell.initialiseHelpView(title: "NEED HELP", taxiRide: taxiTripReportViewModel.taxiRide)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}
