//
//  RideHistoryViewController.swift
//  Quickride
//
//  Created by Bandish Kumar on 01/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class RideHistoryViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var rideHistoryTableView: UITableView!
    @IBOutlet weak var noRideView: UIView!
    @IBOutlet weak var createRideButton: UIButton!
    //MARK: Properties
    var rideParticipant: RideParticipant?
    var overFlowMenuDropDown = DropDown()
    var rideRepeatDropDown = DropDown()
    lazy var myRideHistoryViewModel: MyRideHistoryViewModel = { [unowned self] in
        return MyRideHistoryViewModel()
    }()
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        myRideHistoryViewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRideHistoryViewModel.registerForClosedRideDetails()
        configureEmptyRideView()
        self.navigationController?.isNavigationBarHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //MARK: Methods
    func configureEmptyRideView() {
        if  myRideHistoryViewModel.closedRidesHashTable.count > 0 {
            noRideView.isHidden = true
            rideHistoryTableView.isHidden = false
            createRideButton.isHidden = true
        } else {
            rideHistoryTableView.isHidden = true
            noRideView.isHidden = false
            createRideButton.isHidden = false
        }
    }

    //MARK: Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        ContainerTabBarViewController.indexToSelect = 1
        self.navigationController?.popToRootViewController(animated: false)
    }
}
//MARK: UITableViewDataSource
extension RideHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myRideHistoryViewModel.closedRidesHashTable.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let closedRideSection = myRideHistoryViewModel.closedRidesHashTable
        if closedRideSection.count > 0 {
            let rides =  closedRideSection[section].value
            return rides.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryTableViewCell", for: indexPath) as! RideHistoryTableViewCell
        let closeRideSection = myRideHistoryViewModel.closedRidesHashTable
        if closeRideSection.count > 0 {
            let rides: [Ride] =  closeRideSection[indexPath.section].value
            if  rides.count > 0 {
                cell.overflowButton.tag = indexPath.row
                cell.delegate = self
                cell.configureView(ride: rides[indexPath.row])
                if indexPath.row == 0 {
                    cell.setSectionHeader(isHeaderShow: true, ride: rides[indexPath.row])
                } else {
                    cell.setSectionHeader(isHeaderShow: false, ride: rides[indexPath.row])
                }
                return cell
            } else {
                noRideView.isHidden = false
                rideHistoryTableView.isHidden = true
                return UITableViewCell()
            }
            
        }
        noRideView.isHidden = false
        return UITableViewCell()
    }
    
}
//MARK: UITableViewDelegate
extension RideHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rides: [Ride] =  myRideHistoryViewModel.closedRidesHashTable[indexPath.section].value
        displayTripReport(ride: rides[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xececec)
        return view
    }
    
    func displayTripReport(ride: Ride) {
        AppDelegate.getAppDelegate().log.debug("\(ride)")
        if Ride.RIDER_RIDE == ride.rideType, Ride.RIDE_STATUS_COMPLETED == ride.status, (ride as! RiderRide).noOfPassengers > 0 {
            navigateToTripReport(selectedRide: ride)
        }else if Ride.RIDER_RIDE == ride.rideType,Ride.RIDE_STATUS_COMPLETED == ride.status,(ride as! RiderRide).noOfPassengers == 0{
            moveToRideCompletedWithEmptySeatView(ride: ride)
        }else if Ride.PASSENGER_RIDE == ride.rideType, Ride.RIDE_STATUS_COMPLETED == ride.status {
            let passengerRide = ride as! PassengerRide
            if passengerRide.taxiRideId == nil && passengerRide.taxiRideId == 0.0 && (ride as! PassengerRide).riderRideId != 0 {
                return
            }else{
                navigateToTripReport(selectedRide: ride)
            }
        }else if Ride.RIDE_STATUS_CANCELLED == ride.status{
            myRideHistoryViewModel.getRideCancellationReport(userId: UserDataCache.getInstance()?.userId ?? "", ride: ride, viewController: self, delegate: self)
        }
    }
    private func moveToRideCompletedWithEmptySeatView(ride: Ride){
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.rideCompletionWithEmptySeatViewController) as! RideCompletionWithEmptySeatViewController
        viewController.initialiseData(riderRide: ride,isFromRideHistory: true)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func navigateToTripReport(selectedRide: Ride){
        AppDelegate.getAppDelegate().log.debug("\(selectedRide)")
        if !QRReachability.isConnectedToNetwork() {
            UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
        } else {
            let tripReportToCompletedRides : TripReportForCompletedRides = TripReportForCompletedRides(ride: selectedRide, viewController: self, receiver: self)
            tripReportToCompletedRides.getTripReport()
        }
    }
}

//MARK: RideHistoryTableViewCellDelegate
extension RideHistoryViewController: RideHistoryTableViewCellDelegate {
    
    
    func rideHistoryEditCellButtonTapped(ride: Ride?, senderTag: Int, dropDownView: AnchorView?) {
        guard let ride = ride, let dropDownView = dropDownView  else { return }
        let rideActionsMenuController = RideActionsMenuController(ride: ride, isFromRideView :false, viewController: self, rideUpdateListener: myRideHistoryViewModel, delegate: myRideHistoryViewModel)
        setupOverFlowDropDownView(rideActionsMenuController: rideActionsMenuController, anchorView: dropDownView)
    }
    
    private func setupOverFlowDropDownView(rideActionsMenuController: RideActionsMenuController, anchorView: AnchorView){
        overFlowMenuDropDown.anchorView = anchorView
        overFlowMenuDropDown.bottomOffset = CGPoint(x: -70, y: 0)
        overFlowMenuDropDown.topOffset = CGPoint(x: -70, y: 0)
        overFlowMenuDropDown.textFont = UIFont(name: "HelveticaNeue", size: 14)!
        myRideHistoryViewModel.dropDownDataList.removeAll()
        myRideHistoryViewModel.dropDownDataList.append(Strings.repeat_ride_options)
        myRideHistoryViewModel.dropDownDataList.append(Strings.archive)
        overFlowMenuDropDown.dataSource = myRideHistoryViewModel.dropDownDataList
        overFlowMenuDropDown.selectionAction = { [weak self] (index, item) in
            switch item {
            case Strings.repeat_ride_options:
                self?.showRepeatDropDown(rideActionsMenuController: rideActionsMenuController, anchorView: anchorView)
            case Strings.archive:
                rideActionsMenuController.archiveRide()
            default :
                break
            }
            
        }
        overFlowMenuDropDown.show()
    }
        
    private func showRepeatDropDown(rideActionsMenuController: RideActionsMenuController, anchorView: AnchorView){
        myRideHistoryViewModel.dropDownDataList.removeAll()
        rideRepeatDropDown.anchorView = anchorView
        rideRepeatDropDown.bottomOffset = CGPoint(x: -100, y: 0)
        rideRepeatDropDown.topOffset = CGPoint(x: -100, y: 0)
        rideRepeatDropDown.textFont = UIFont(name: "HelveticaNeue", size: 14)!
        myRideHistoryViewModel.dropDownDataList.append(Strings.repeat_once)
        myRideHistoryViewModel.dropDownDataList.append(Strings.repeat_regular)
        myRideHistoryViewModel.dropDownDataList.append(Strings.return_ride)
        rideRepeatDropDown.dataSource = myRideHistoryViewModel.dropDownDataList
        rideRepeatDropDown.selectionAction = { (index, item) in
            switch item {
            case Strings.repeat_once:
                rideActionsMenuController.repeatRide()
            case Strings.repeat_regular:
                rideActionsMenuController.createRegularRide()
            case Strings.return_ride:
                rideActionsMenuController.createReturnRide()
            default:
                break
            }
        }
        rideRepeatDropDown.show()
    }
        
}

//MARK: TripReportReceiver
extension RideHistoryViewController: TripReportReceiver {
    func riderTripReportReceived(rideBillingDetails: [RideBillingDetails]?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideBillingDetails))")
        QuickRideProgressSpinner.stopSpinner()
         let BillVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        BillVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails, isFromClosedRidesOrTransaction: true,rideType: Ride.RIDER_RIDE,currentUserRideId: Double(rideBillingDetails?.last?.sourceRefId ?? "") ?? 0)
        self.navigationController?.pushViewController(BillVC, animated: false)
    }
    
    func passengerTripReportReceived(rideBillingDetails: RideBillingDetails, passengerRideId: Double) {
        AppDelegate.getAppDelegate().log.debug("Bill : \(rideBillingDetails) PassengerRideId : \(passengerRideId)")
        
        let BillVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        var rideBillingDetailsList = [RideBillingDetails]()
        rideBillingDetailsList.append(rideBillingDetails)
        BillVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetailsList, isFromClosedRidesOrTransaction: true,rideType: Ride.PASSENGER_RIDE,currentUserRideId: Double(passengerRideId))
        self.navigationController?.pushViewController(BillVC, animated: false)
    }
    
    func receiveTripReportFailed() {
        QuickRideProgressSpinner.stopSpinner()
        UIApplication.shared.keyWindow?.makeToast( Strings.bill_failed)
    }
}
//MARK: MyRideHistoryViewModelDelgate
extension RideHistoryViewController: MyRideHistoryViewModelDelgate {
   
    func receiveError(responseObject: NSDictionary?, error: NSError?) {
         ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    func receiveClosedRides() {
        rideHistoryTableView.reloadData()
    }
}
//MARK: MyRideHistoryViewModelDelgate
extension RideHistoryViewController: CancelledRideReport {
    func receivedCancelRideReport(ride: Ride,rideCancellationReport: [RideCancellationReport]){
        let cancelRideBillViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CancelRideBillViewController") as! CancelRideBillViewController
        cancelRideBillViewController.initializeCancelRideRepoet(ride: ride, rideCancellationReport: rideCancellationReport)
        self.navigationController?.pushViewController(cancelRideBillViewController, animated: false)
    }
}
