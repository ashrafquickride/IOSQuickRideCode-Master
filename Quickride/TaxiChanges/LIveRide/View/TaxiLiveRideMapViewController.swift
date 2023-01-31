//
//  TaxiLiveRideMapViewController.swift
//  Quickride
//
//  Created by Ashutos on 24/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import FloatingPanel
import Polyline
import GoogleMaps

class TaxiLiveRideMapViewController: UIViewController {

    //MARK: Nav View
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var tripStatusLabel: UILabel!
    @IBOutlet weak var navItemsStackView: UIStackView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var unReadMessageLabel: UILabel!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var unreadNotificationView: UIView!
    @IBOutlet weak var unreadMsgView: UIView!
    @IBOutlet weak var liveRideMapView: UIView!
    @IBOutlet weak var mapElementsBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var emergencyButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var refreshAnimationView: AnimatedControl!
    @IBOutlet weak var mapComponentsView: UIView!
    @IBOutlet weak var rideTimeLabel: UILabel!
    @IBOutlet weak var behalfBookingView: UIView!
    @IBOutlet weak var customerNameDetails: UILabel!

    @IBOutlet weak var rentalPackageDetailsContainerView: UIView!
    @IBOutlet weak var scrollArrowDirectionImageContainerView: UIView!
    @IBOutlet weak var stopPointDetailTableView: UITableView!
    @IBOutlet weak var rentalPackageDetailLabel: UILabel!
    @IBOutlet weak var packageInfoButton: UIButton!
    @IBOutlet weak var scrollArrowDirectionImageView: UIImageView!
    @IBOutlet weak var rentalPackageDetailsStackView: UIStackView!
    @IBOutlet weak var rentalStopPointBottomSeperatorView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var paymentTableView: UITableView!

    //MARK: MAP components
    weak private var viewMap: GMSMapView!
    var floatingPanelController: FloatingPanelController!
    private var routeNavigationMarker: GMSMarker!
    private var startMarker :GMSMarker?
    private var endMaker : GMSMarker?
    private var confirmPickPointMarker :GMSMarker?
    private var pickUpRoute: GMSPolyline?
    private var selectedPolyLine = GMSPolyline()
    private var path = GMSPath()
    private var animationPolyline = GMSPolyline()
    private var animationPath = GMSMutablePath()
    private var index: UInt = 0
    private var pathTimer: Timer?
    var currentLocation :CLLocationCoordinate2D?
    private var taxiMarkers = [GMSMarker]()
    var userInteractedWithMap = false


    private var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()
    private var taxiLiveRideBottomViewController: TaxiLiveRideBottomViewController!
    private var taxiLiveRideLocationUpdateListener : TaxiLiveRideLocationUpdateListener?

    static let taxiLiveRideMapViewControllerKey = "taxiLiveRideMapViewController"

    func initializeDataBeforePresenting(rideId: Double) {
        taxiLiveRideViewModel = TaxiPoolLiveRideViewModel(taxiRideID: rideId)
    }

    func initializeDataBeforePresenting(rideId: Double, isRequiredToInitiatePayment: Bool?) {
        taxiLiveRideViewModel = TaxiPoolLiveRideViewModel(taxiRideID: rideId, isRequiredToInitiatePayment: isRequiredToInitiatePayment)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stopPointDetailTableView.register(UINib(nibName: "RentalStopPointDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalStopPointDetailTableViewCell")
        paymentTableView.register(UINib(nibName: "PayTaxiAmountTableViewCell", bundle: nil), forCellReuseIdentifier: "PayTaxiAmountTableViewCell")
        stopPointDetailTableView.dataSource = self
        stopPointDetailTableView.delegate = self
        paymentTableView.dataSource = self
        addLiveRideCardViewController()
        setUpUI()
        getTaxiRideDetails()
        getRentalStopPoints()
        rentalPackageDetailsStackView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: 3))
        paymentView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        self.view.addSubview(paymentView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.getAppDelegate().log.debug("Taxi Live Ride opend and status is\(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status)")
        self.navigationController?.isNavigationBarHidden = true
        handleNotificationCountAndDisplay()
        addObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pathTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        if let taxigroupId = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.id {
            taxiLiveRideLocationUpdateListener?.unSubscribeToLocationUpdatesForRide(taxiGroupId: taxigroupId)
            taxiLiveRideViewModel.stopRefreshTaxiRideLocation()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(taxiStatusReceived), name: .taxiRideStatusReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taxiLocationUpdate), name: .taxiLocationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upadteTaxiStartTime), name: .upadteTaxiStartTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTaxiLiveRideNotification), name: .showTaxiLiveRideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRideStatusTitle), name: .taxiDriverAllocationStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePaymentView), name: .updatePaymentView, object: nil)
    }

    @objc func taxiStatusReceived(_ notification: Notification){
        AppDelegate.getAppDelegate().log.debug("taxiRideStatusReceived Observed")
        self.taxiLiveRideViewModel.gettaxiRidePassengerDetails(handler: { [weak self] (responseError, error) in
            if responseError == nil && error == nil {
                self?.checkTaxiRideStatusAndUpdate(isRefreshClicked: false)
            }
        })
        getRentalStopPoints()
    }

    @objc func taxiLocationUpdate(_ notification: Notification){
        self.updateUIForLocationUpdate()
    }

    @objc func upadteTaxiStartTime(_ notification: Notification){
        setTripStatusHeaderLabel()
        self.refreshMapWithNewData()
    }

    @objc func updateRideStatusTitle(_ notification: Notification){
        refreshMapWithNewData()
    }

    @objc func updatePaymentView(_ notification: Notification){
        self.handlePaymentViewVisibility()
        self.paymentTableView.reloadData()
    }

    func setTripStatusHeaderLabel(){
        self.rideTimeLabel.text = self.taxiLiveRideViewModel.getRidedateAndTime()
        self.hideAllMapComponetsIfItInstantRide()
        if taxiLiveRideViewModel.isOutstationTrip(){
            if taxiLiveRideViewModel.isTaxiStarted(), let destination = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endArea, !destination.isEmpty {
                tripStatusLabel.text = String(format: Strings.heading_to_destination, arguments: [getDestinationBasedOnRouteCategory(destination: destination)])
            }else if let journeyType = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.journeyType, !journeyType.isEmpty,
                     let city = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endArea  {
                if journeyType == TaxiRidePassenger.oneWay{
                    tripStatusLabel.text = Strings.one_way + " to " + city
                }else if journeyType == TaxiRidePassenger.roundTrip {
                    tripStatusLabel.text = Strings.round_trip + " to " + city
                }
            }
        }else if taxiLiveRideViewModel.isRentalTrip(){
            if taxiLiveRideViewModel.isTaxiStarted(), let destination = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endArea, !destination.isEmpty {
                tripStatusLabel.text = String(format: Strings.heading_to_destination, arguments: [getDestinationBasedOnRouteCategory(destination: destination)])
            }else {
                if let taxiRidePassengerDetails = taxiLiveRideViewModel.taxiRidePassengerDetails {
                    if taxiLiveRideViewModel.isAllocationStarted() {
                        tripStatusLabel.text  = TaxiUtils.getTaxiTripStatus(taxiRidePassengerDetails: taxiRidePassengerDetails)
                    }else {
                        tripStatusLabel.text  = "Rental " + TaxiUtils.getTaxiTripStatus(taxiRidePassengerDetails: taxiRidePassengerDetails)
                    }
                }
            }
        }else{
            if taxiLiveRideViewModel.isTaxiStarted(), let destination = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endArea, !destination.isEmpty {
                tripStatusLabel.text = String(format: Strings.heading_to_destination, arguments: [getDestinationBasedOnRouteCategory(destination: destination)])
            }else {
                if let taxiRidePassengerDetails = taxiLiveRideViewModel.taxiRidePassengerDetails {
                tripStatusLabel.text  = TaxiUtils.getTaxiTripStatus(taxiRidePassengerDetails: taxiRidePassengerDetails)
                }
            }
        }
    }

    func getDestinationBasedOnRouteCategory(destination: String) -> String{
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.routeCategory == TaxiPoolConstants.ROUTE_CATEGORY_CITY_TO_AIRPORT {
            return "Airport"
        }
        return destination
    }

    func showBehalfBookingViewIfRequired(){
        if let commutePassengerName = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideCommutePassengerDetails?.passengerName {
            behalfBookingView.isHidden = false
            customerNameDetails.text = commutePassengerName
        } else {
            behalfBookingView.isHidden = true
        }
    }

    @objc func driverCancelledTrip(_ notification: Notification){
        if !self.taxiLiveRideViewModel.driverCancelledInfoShown{
            let driverCancelledTripInfoView = GreetingDisplayView.loadFromNibNamed(nibNamed: "DriverCancelledTripInfoView",bundle: nil) as! DriverCancelledTripInfoView
            driverCancelledTripInfoView.showDriverCancelledView(viewController: self)
            self.taxiLiveRideViewModel.driverCancelledInfoShown = true
        }
    }

    @objc func showTaxiLiveRideNotification(_ notification: Notification){
        let driverCancelledTripInfoView = GreetingDisplayView.loadFromNibNamed(nibNamed: "DriverCancelledTripInfoView",bundle: nil) as! DriverCancelledTripInfoView
        let result = notification.userInfo?["result"] as? String
        if result == TaxiRidePassenger.TAXI_CANCELED_MESSAGE {
            if !self.taxiLiveRideViewModel.driverCancelledInfoShown{
                driverCancelledTripInfoView.showDriverCancelledView(viewController: self)
                driverCancelledTripInfoView.messageLabel.text = Strings.dreiver_cancel_the_trip_message
                self.taxiLiveRideViewModel.driverCancelledInfoShown = true
            }
        }else if result == TaxiRidePassenger.TAXI_TRIP_UPDATED{
            if let fare = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.initialFare {
                driverCancelledTripInfoView.messageLabel.text = String(format: Strings.route_updated_message, arguments: [String(Int(fare.rounded()))])
                driverCancelledTripInfoView.showDriverCancelledView(viewController: self)
            }
        }
    }

    func checkTaxiRideStatusAndUpdate(isRefreshClicked: Bool){
        guard let taxiRide = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        AppDelegate.getAppDelegate().log.debug("taxiRideStatusReceived current status is \(String(describing: taxiRide.status)), \(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.status)")
        switch taxiRide.status {
        case TaxiRidePassenger.STATUS_COMPLETED:
            taxiLiveRideViewModel.updateTaxiRideCacheOnCancelOrComplete()
            goToBillView(taxiRide: taxiRide)
        case TaxiRidePassenger.STATUS_CANCELLED, TaxiRidePassenger.STATUS_NOT_BOARDED:
            taxiLiveRideViewModel.updateTaxiRideCacheOnCancelOrComplete()
            if let taxiRideId = taxiRide.id, let passenerRide = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRide(taxiRideId: taxiRideId) {
                self.navigationController?.popToRootViewController(animated: false)
                let liveRideVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
                liveRideVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: passenerRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: liveRideVC, animated: true)
            }else{
                rideCancelled()
            }
        default:
            taxiLiveRideBottomViewController.taxiLiveRideCardTableView.reloadData()
            refreshMapWithNewData()
            setTripStatusHeaderLabel()
        }
        updateUIAfterGettingRideDetailInfo(isRefreshClicked: isRefreshClicked)
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.OUTSTATION,
           let journeyType = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.journeyType, journeyType != "",
           let endAddress = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endAddress, let city = endAddress.components(separatedBy: ",").first  {
            if journeyType == TaxiRidePassenger.oneWay{
                tripStatusLabel.text = Strings.one_way + " to " + city
            }else if journeyType == TaxiRidePassenger.roundTrip {
                tripStatusLabel.text = Strings.round_trip + " to " + city
            }
        }
        self.rideTimeLabel.text = taxiLiveRideViewModel.getRidedateAndTime()
        hideAllMapComponetsIfItInstantRide()
        hideAndUnhideEmergencyButton()
        self.taxiLiveRideViewModel.getOutstationFareSummaryDetails()
    }

    private func hideAllMapComponetsIfItInstantRide(){
        if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot(), !taxiLiveRideViewModel.isRentalTrip(){
            moreView.isHidden = true
            messageView.isHidden = true
            notificationView.isHidden = true
            floatingPanelController.surfaceView.grabberHandle.isHidden = true
        }else{
            moreView.isHidden = false
            notificationView.isHidden = false
            floatingPanelController.surfaceView.grabberHandle.isHidden = false
        }
        mapComponentsView.isHidden = false
    }

    private func hideAndUnhideEmergencyButton(){
        if taxiLiveRideViewModel.isTaxiStarted(){
            emergencyButton.isHidden = false
            if let initiatedTime = SharedPreferenceHelper.getEmeregencyInitiatedTime(),DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: NSDate().getTimeStamp(), time2: initiatedTime) < 5{
                emergencyButton.backgroundColor = UIColor(netHex: 0xE20000)
                emergencyButton.setImage(UIImage(named: "emergency_after_pressed"), for: UIControl.State.normal)
            }else{
                emergencyButton.setImage(UIImage(named: "emergency_pressed"), for: UIControl.State.normal)
            }
        }else{
            emergencyButton.isHidden = true
        }
    }


    private func updateUIForLocationUpdate() {
        if let taxiGroupId = taxiLiveRideViewModel.getTaxiRideGroup()?.id, let taxiLocation =  TaxiRideDetailsCache.getInstance().getLocationUpdateForTaxi(taxiGroupId: taxiGroupId){
            let newLocation = CLLocationCoordinate2D(latitude: taxiLocation.latitude ?? 0.0, longitude: taxiLocation.longitude ?? 0.0)
            handleVehicleLocationChange(rideParticipantLocation: taxiLocation, newLocation: newLocation)
            guard let taxiRidePassenger = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else {
                return
            }
            if taxiRidePassenger.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION, self.taxiLiveRideViewModel.isTaxiStarted() {
                return
            }
            var routeId: Double?
            var dest: LatLng
            if taxiLiveRideViewModel.isRentalTrip(), let rentalLastStopPoint = taxiLiveRideViewModel.rentalStopPointList?.last {
                dest = LatLng(lat: rentalLastStopPoint.stopPointLat ?? 0 ,long: rentalLastStopPoint.stopPointLng ?? 0)
                routeId = rentalLastStopPoint.scheduledRouteId
            }else {
                dest = LatLng(lat: taxiRidePassenger.endLat!,long: taxiRidePassenger.endLng!)
                routeId = taxiRidePassenger.routeId
            }
            if !self.taxiLiveRideViewModel.isTaxiStarted(){
                routeId = Double(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.pickupRouteId ?? 0)
                dest = LatLng(lat: taxiRidePassenger.startLat!,long: taxiRidePassenger.startLng!)
            }

            ETAFinder.getInstance().getETA(userId: taxiRidePassenger.userId!, rideId: taxiRidePassenger.id!, useCase: "iOS.App.TaxiPassenger.Eta.ETACalculator.LiveRide", source: LatLng(lat: newLocation.latitude, long: newLocation.longitude), destination: dest, routeId: routeId ?? 0, startTime: NSDate().getTimeStamp(), vehicleType: taxiLiveRideViewModel.getVehicleTypeForEtaService(vehicleType: taxiRidePassenger.taxiVehicleCategory!),routeStartLatitude: taxiRidePassenger.startLat ?? 0, routeStartLongitude: taxiRidePassenger.startLng ?? 0, routeEndLatitude: taxiRidePassenger.endLat ?? 0, routeEndLongitude: taxiRidePassenger.endLng ?? 0, routeWaypoints: taxiRidePassenger.wayPoints, routeOverviewPolyline: taxiRidePassenger.routePolyline) { [weak self] (etaResponse) in
                guard let self = self else {
                    return
                }
                self.taxiLiveRideViewModel.etaResponse = etaResponse
                self.taxiLiveRideBottomViewController.taxiLiveRideCardTableView.reloadData()
                self.drawPickupRoute(currentLocation: newLocation)
                if !self.taxiLiveRideViewModel.isTaxiStarted() && (self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.pickupRouteId ==  0) {
                    self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.pickupRouteId = Int(etaResponse.routeId)
                    dest = LatLng(lat: taxiRidePassenger.startLat!,long: taxiRidePassenger.startLng!)
                }
            }
        }
    }

    private func handleVehicleLocationChange(rideParticipantLocation : RideParticipantLocation, newLocation: CLLocationCoordinate2D) {
        if routeNavigationMarker == nil {
            routeNavigationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!))
            routeNavigationMarker.map = viewMap
            routeNavigationMarker.zIndex = 15
            routeNavigationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            routeNavigationMarker.isFlat = true
            routeNavigationMarker.isTappable = true
            setVehicleImage()
        }else{
            updateVehicleOrRiderImageBasedOnLocation(newLocation: newLocation)

        }
        drawPickupRoute(currentLocation: newLocation)
        handaleRouteZoomBasedOnStatus()
    }

    private func setVehicleImage() {
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE{
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "bike_top") ?? UIImage(), targetSize: CGSize(width: 42,height: 42))
            }else if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "Auto_tracking") ?? UIImage(), targetSize: CGSize(width: 38,height: 38))
            }else{
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "exclusive_taxi_tracking") ?? UIImage(), targetSize: CGSize(width: 40,height: 40))
            }
        } else {
            routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "taxi_tracking") ?? UIImage(), targetSize: CGSize(width: 40,height: 40))
        }
    }

    private func updateVehicleOrRiderImageBasedOnLocation(newLocation: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({[weak self] () -> Void in
            guard let routeNavigationMarker = self?.routeNavigationMarker else { return }
            if newLocation.latitude != routeNavigationMarker.position.latitude, newLocation.longitude != routeNavigationMarker.position.longitude{
                let newLoc = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                let bearing = newLoc.getDirection(prevLat: routeNavigationMarker.position.latitude, prevLng: routeNavigationMarker.position.longitude)
                if bearing != 0{
                    routeNavigationMarker.rotation = bearing
                }
            }
            routeNavigationMarker.position = newLocation
        })
        CATransaction.commit()
    }

    private func rideCancelled() {
        UIApplication.shared.keyWindow?.makeToast(Strings.oops_this_trip_closed)
        self.navigationController?.popViewController(animated: false)
    }

    private func goToBillView(taxiRide: TaxiRidePassenger) {
        taxiLiveRideViewModel.getBillAndUpdate(handler: {[weak self] (result) in
            if let taxiRideInvoice = result.result {
                TaxiUtils.sendTaxiCompletedEvent(taxiRidePassenger: taxiRide)
                let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.taxiBillViewController) as! TaxiBillViewController
                taxiBillVC.initialiseData(taxiRideInvoice: taxiRideInvoice,taxiRide: taxiRide, isFromClosedRidesOrTransaction: false, isRequiredToInitiatePayment: self?.taxiLiveRideViewModel.isRequiredToInitiatePayment )
                self?.navigationController?.pushViewController(taxiBillVC, animated: false)
            }else{
                ErrorProcessUtils.handleResponseError(responseError: result.responseError, error: result.error, viewController: self)
            }
        })
    }

    func updateUIAfterGettingRideDetailInfo(isRefreshClicked: Bool) {
        if taxiLiveRideViewModel.isTaxiAllotted() || taxiLiveRideViewModel.isTaxiStarted(){
            taxiLiveRideViewModel.startRefreshTaxiRideLocation(isRefreshClicked: isRefreshClicked)
            if let taxigroupId = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.id{
                taxiLiveRideLocationUpdateListener = TaxiLiveRideLocationUpdateListener()
                taxiLiveRideLocationUpdateListener!.subscribeToLocationUpdatesForRide(taxiGroupId: taxigroupId)
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    private var joinFlowUI: NewJoinShimmerViewController?

    private func addJoinViewAsSubView() {
        joinFlowUI = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewJoinShimmerViewController") as? NewJoinShimmerViewController
        if let taxiRidePassenger = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: taxiLiveRideViewModel.taxiRideID!),taxiRidePassenger.getShareType() == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            joinFlowUI!.initLiseData(shareType: TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE, startTime: taxiRidePassenger.pickupTimeMs, isOldTaxiRide: true,taxiType:taxiRidePassenger.taxiType ?? "")
        }else{
            joinFlowUI!.initLiseData(shareType: TaxiPoolConstants.SHARE_TYPE_ANY_SHARING, startTime: NSDate().getTimeStamp(), isOldTaxiRide: true,taxiType: TaxiPoolConstants.TAXI_TYPE_CAR)
        }
        if let joinFlowUI = joinFlowUI {
            ViewControllerUtils.addSubView(viewControllerToDisplay: joinFlowUI)
        }
    }

    private func removeJoinViewFromSuperView() {
        joinFlowUI?.removeFromParent()
        joinFlowUI?.view.removeFromSuperview()
    }
    func getRentalStopPoints(){

        taxiLiveRideViewModel.getAllRentalStopPoints{ [self] (responseError, error) in
            if responseError != nil && error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
                return
            }
            setTripStatusHeaderLabel()
            refreshMapWithNewData()
            self.taxiLiveRideBottomViewController.taxiLiveRideCardTableView.reloadData()
            self.handleVisibilityOfRentalPackageDetails()
        }
    }

    func getTaxiRideDetails() {
        addJoinViewAsSubView()
        taxiLiveRideViewModel.gettaxiRidePassengerDetails(handler: { [weak self] (responseError, error) in
            self?.removeJoinViewFromSuperView()
            if responseError != nil || error != nil {
                self?.onRetrievalFailure(responseError: responseError, error: error)
            }else{
                self?.setTripStatusHeaderLabel()
                self?.handleVisibilityOfRentalPackageDetails()
                self?.checkTaxiRideStatusAndUpdate(isRefreshClicked: false)
                self?.taxiLiveRideBottomViewController.getRequiredDataForBottomSheet()
                self?.getNearbyTaxiIfRequired()
                self?.showBehalfBookingViewIfRequired()
                self?.paymentTableView.reloadData()
                self?.handlePaymentViewVisibility()
                if self?.taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot() ?? false{
                    self?.taxiLiveRideViewModel.taxiRideUpdateSuggestion = SharedPreferenceHelper.getTaxiRideGroupSuggestionUpdate(taxiGroupId: self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiGroupId ?? 0)
                    if self?.taxiLiveRideViewModel.isTaxiFareChangeSuggestionReceived() != nil || self?.taxiLiveRideViewModel.isRequiredToShowInstantRideCancellation() ?? false{
                    }
                }else{
                    self?.floatingPanelController.move(to: .half, animated: true)
                }
            }
        })
    }
    private  func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self) { result in
            self.navigationController?.popViewController(animated: false)
        }

    }

    private func setUpUI() {
        definesPresentationContext = true
        viewMap = QRMapView.getQRMapView(mapViewContainer: liveRideMapView)
        NotificationStore.getInstance().addNotificationListChangeListener(key: TaxiLiveRideMapViewController.taxiLiveRideMapViewControllerKey, listener: self)
        handleNotificationCountAndDisplay()
        checkNewMessage()
    }

    func getNearbyTaxiIfRequired(){
        removeAllNearbyTaxiMarker()
        if taxiLiveRideViewModel.isAllocationStarted(), let latitude = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat, let longitude = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng {
           let location = Location(latitude: latitude, longitude: longitude, shortAddress: "")
            taxiLiveRideViewModel.getNearbyTaxi(location: location, taxiType: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType){ (responseError, error)  in
                if responseError != nil || error != nil {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }else {
                    self.showNearbyTaxi()
                }
            }
        }
    }

    private func handleVisibilityOfRentalPackageDetails(){
        if taxiLiveRideViewModel.isRentalTrip() {
            if taxiLiveRideViewModel.rentalStopPointList?.count ?? 0 > 0 {
                scrollArrowDirectionImageContainerView.isHidden = false
            }else {
                scrollArrowDirectionImageContainerView.isHidden = true
            }
            rentalPackageDetailLabel.isHidden = false
            rentalPackageDetailsContainerView.isHidden = false
            let taxiTypeAndtripType = (taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiVehicleCategory ?? "") + " " + (taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType ?? "")
            let rentalPackage = String(format: Strings.x_hr, arguments: [String(DateUtils.getDifferenceBetweenTwoDatesInMins(time1: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, time2: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.expectedEndTimeMs) / 60)]) + " " + String(format: Strings.distance_in_km, arguments: [String(Int(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.distance ?? 0))])
            rentalPackageDetailLabel.text = taxiTypeAndtripType + " " + rentalPackage
            stopPointDetailTableView.isHidden = false
            rentalStopPointBottomSeperatorView.isHidden = false
            stopPointDetailTableView.reloadData()
            if let count = taxiLiveRideViewModel.rentalStopPointList?.count {
                let row = IndexPath(row: count + 1 , section: 0)
                stopPointDetailTableView.scrollToRow(at: row, at: .bottom, animated: false)
                taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList = true
            }
        }else {
            rentalPackageDetailsContainerView.isHidden = true
            scrollArrowDirectionImageContainerView.isHidden = true
            stopPointDetailTableView.isHidden = true
            rentalStopPointBottomSeperatorView.isHidden = true
        }
    }

    private func showNearbyTaxi(){
        guard let listOfNearbyTaxi = taxiLiveRideViewModel.partnerRecentLocationInfo, !listOfNearbyTaxi.isEmpty else {
            return
        }
        removeAllNearbyTaxiMarker()
        for item in listOfNearbyTaxi {
            let taxiMarker = TaxiUtils.getNearbyTaxiMarkers(partnerRecentLocationInfo: item, viewMap: viewMap)
            taxiMarkers.append(taxiMarker)
        }
        let taxiMarkerAndRoutePolyline = addTaxiMarkerAndRoute(routePolyline: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.routePolyline)
        GoogleMapUtils.fitToScreen(route: taxiMarkerAndRoutePolyline, map: viewMap)
    }

    func addTaxiMarkerAndRoute(routePolyline: String?) -> String{
        var polylineCoordinate = [CLLocationCoordinate2D]()
        if let routePolyline = routePolyline, let routePolylineCoordinate = Polyline(encodedPolyline: routePolyline).coordinates {
            polylineCoordinate = routePolylineCoordinate
        }
        if let partnerRecentLocationInfo = taxiLiveRideViewModel.partnerRecentLocationInfo, !partnerRecentLocationInfo.isEmpty {
            for item in partnerRecentLocationInfo {
                let partnerRecentLocation = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
                polylineCoordinate.append(partnerRecentLocation)
            }
        }
        if let startLatitute = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat, let startLongitude = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng {
            let currentLocation = CLLocationCoordinate2D(latitude: startLatitute, longitude: startLongitude)
            polylineCoordinate.append(currentLocation)
        }
        let addedTaxiMarkerAndRoutePolyline = Polyline(coordinates: polylineCoordinate)
        return addedTaxiMarkerAndRoutePolyline.encodedPolyline
    }

    func removeAllNearbyTaxiMarker(){
        for item in taxiMarkers{
            item.map = nil
        }
        taxiMarkers.removeAll()
    }

    @IBAction func rentalPackageInfoButtonTapped(_ sender: Any) {
        let rentalRulesAndRestrictionsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalRulesAndRestrictionsViewController") as! RentalRulesAndRestrictionsViewController
        let rentalPackage = RentalPackageConfig(vehicleClass: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiVehicleCategory, extraKmFare: taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?[0].extraKmFare ?? 0, extraMinuteFare: taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo?[0].extraMinFare ?? 0,pkgDistanceInKm: Int(taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.distance ?? 0),pkgDurationInMins: (DateUtils.getDifferenceBetweenTwoDatesInMins(time1: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, time2: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.expectedEndTimeMs)))
        var rentalPackageConfig = [RentalPackageConfig]()
        rentalPackageConfig.append(rentalPackage)
        rentalRulesAndRestrictionsViewController.initialiseData(rentalPackageConfig: rentalPackageConfig)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rentalRulesAndRestrictionsViewController)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func helpButtonTapped(_ sender: Any) {
        if let phoneNumber = ConfigurationCache.getInstance()?.getClientConfiguration()?.taxiSupportMobileNumber {
            AppUtilConnect.callSupportNumber(phoneNumber: phoneNumber, targetViewController: self)
        } else {
            return
        }
    }

    @IBAction func notificationBtnPressed(_ sender: UIButton) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: notificationViewController, animated: false)
    }
    @IBAction func chatBtnPressed(_ sender: UIButton) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.centralChatViewController)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: centralChatViewController, animated: false)
    }

    @IBAction func menuBtnPressed(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if !taxiLiveRideViewModel.isTaxiStarted() {
            optionMenu.addAction(getCancelTaxiRideAlertAction())
        }
        if let editRouteAlertAction = getEditRouteAlertAction() {
            optionMenu.addAction(editRouteAlertAction)
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }

    private func getEditRouteAlertAction() -> UIAlertAction?{
        guard let taxiRidePassenger = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else {
            return nil
        }
        guard !taxiLiveRideViewModel.isRentalTrip() else {
            return nil
        }
        let editRout = UIAlertAction(title: Strings.edit_ride, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let taxiRideEditViewController = UIStoryboard(name: "TaxiEdit", bundle: nil).instantiateViewController(withIdentifier: "TaxiRideEditViewController") as! TaxiRideEditViewController
            taxiRideEditViewController.initialiseData(taxiRidePassenger: taxiRidePassenger.copy() as! TaxiRidePassenger) { [weak self]
                (taxiRidePassenger) in
                self?.getTaxiRideDetails()
            }
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiRideEditViewController, animated: true)
        })
        return editRout
    }

    private func getCancelTaxiRideAlertAction() -> UIAlertAction{
        let cancelRideOption = UIAlertAction(title: Strings.cancel_ride, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
                if let taxiRidePassenger = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger{
                    let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CancelTaxiPoolViewController") as! CancelTaxiPoolViewController
                    rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(taxiRide: taxiRidePassenger, completionHandler: { [weak self] (cancelReason) in
                        if let taxiRide = self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger,let cancelReason = cancelReason {
                            self?.taxiLiveRideViewModel.cancelTaxiRide(taxiId: taxiRide.id ?? 0, cancellationReason: cancelReason, complition: { (result) in
                                if result {


                                    self?.taxiLiveRideViewModel.getCancelTaxiRideInvoice(taxiRideId: taxiRide.id ?? 0, completionHandler: { (cancelTaxiRideInvoices) in
                                        if let cancelTaxiInvoices = cancelTaxiRideInvoices,!cancelTaxiInvoices.isEmpty{
                                            var feeAppliedTaxiRides = [CancelTaxiRideInvoice]()
                                            for cancelRideInvoice in cancelTaxiInvoices{
                                                if cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER || cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
                                                    feeAppliedTaxiRides.append(cancelRideInvoice)
                                                }
                                            }
                                            if !feeAppliedTaxiRides.isEmpty{
                                                let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                                                taxiBillVC.initialiseData(taxiRideInvoice: nil,taxiRide: taxiRide, cancelTaxiRideInvoice: feeAppliedTaxiRides)
                                                self?.navigationController?.pushViewController(taxiBillVC, animated: true)
                                                self?.navigationController?.viewControllers.remove(at: (self?.navigationController?.viewControllers.count ?? 0) - 2)
                                            }else{
                                                UIApplication.shared.keyWindow?.makeToast( Strings.ride_cancelled)
                                                self?.navigationController?.popViewController(animated: false)
                                            }
                                        }else{
                                            UIApplication.shared.keyWindow?.makeToast( Strings.ride_cancelled)
                                            self?.navigationController?.popViewController(animated: false)
                                        }
                                    })
                                }
                            })
                        }
                    })
                    ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
                }
        })
        return cancelRideOption
    }



    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        userInteractedWithMap = false
        handaleRouteZoomBasedOnStatus()
    }

    @IBAction func refreshBtnPressed(_ sender: UIButton) {
        refreshButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.refreshButton.isUserInteractionEnabled = true
        }
        refreshAnimationView.isHidden = false
        refreshAnimationView.animationView.animation = Animation.named("loading_refresh")
        refreshAnimationView.animationView.play()
        refreshAnimationView.animationView.loopMode = .loop
        userInteractedWithMap = false
        refreshUI(isRefreshClicked: true)
    }

    @IBAction func rentalStopPointScrollButtonTapped(_ sender: Any) {
        if taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList {
            let row = IndexPath(row: 0, section: 0)
            stopPointDetailTableView.scrollToRow(at: row, at: .top, animated: false)
            scrollArrowDirectionImageView.image = UIImage(named: "icon_arrow_scroll_up")
            taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList = false
        }else {
            if let count = taxiLiveRideViewModel.rentalStopPointList?.count {
                let row = IndexPath(row: count + 1 , section: 0)
                stopPointDetailTableView.scrollToRow(at: row, at: .bottom, animated: false)
            }
            scrollArrowDirectionImageView.image = UIImage(named: "icon_arrow_scroll_down")
            taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList = true
        }
    }

    @IBAction func showFareBreakUpButtonTapped(_ sender: Any) {
        self.floatingPanelController.move(to: .full, animated: true)
        var indexPath = IndexPath()
        taxiLiveRideViewModel.getFareBrakeUpData()
        taxiLiveRideViewModel.isrequiredtoshowFareView = true
        taxiLiveRideBottomViewController.taxiLiveRideCardTableView.reloadData()
        if taxiLiveRideViewModel.isOutstationTrip() {
            indexPath = IndexPath(item: 0, section: 3)
        }else if taxiLiveRideViewModel.isRentalTrip() {
            indexPath = IndexPath(item: 0, section: 2)
        }else {
            indexPath = IndexPath(item: 0, section: 8)
        }
        self.taxiLiveRideBottomViewController.taxiLiveRideCardTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    func refreshUI(isRefreshClicked: Bool){
        QRReachability.isInternetAvailable {(isConnectedToNetwork) in
            if !isConnectedToNetwork {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                self.refreshAnimationView.isHidden = true
                self.refreshAnimationView.animationView.stop()
            }else{
                self.taxiLiveRideViewModel.getTaxiRideFromServer(handler: { [weak self] (responseError, error) in
                    self?.refreshAnimationView.isHidden = true
                    self?.refreshAnimationView.animationView.stop()
                    if responseError != nil || error != nil {
                        self?.onRetrievalFailure(responseError: responseError, error: error)
                    }else{
                        self?.checkTaxiRideStatusAndUpdate(isRefreshClicked: isRefreshClicked)
                        self?.getNearbyTaxiIfRequired()
                    }
                })
                self.getRentalStopPoints()
            }
        }
    }
    func updateUI(){
        getNearbyTaxiIfRequired()
        setTripStatusHeaderLabel()
        mapComponentsView.isHidden = false
    }
}
//MARK: Emergency
extension TaxiLiveRideMapViewController{
    @IBAction func emergencyBtnPressed(_ sender: UIButton) {
        if let initiatedTime = SharedPreferenceHelper.getEmeregencyInitiatedTime(),DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: NSDate().getTimeStamp(), time2: initiatedTime) < 5{
            showEmeregencyStartedScreen(isEmergencyStarted: true)
        }else {
            let taxiEmergencyConfirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiEmergencyConfirmationViewController") as! TaxiEmergencyConfirmationViewController
            taxiEmergencyConfirmationViewController.initialiseEmergencyConfirmation { (isEmergencyStarted) in
                if isEmergencyStarted{
                    SharedPreferenceHelper.storeEmeregencyInitiatedTime(initiatedTime: NSDate().getTimeStamp())
                    self.emergencyButton.backgroundColor = UIColor(netHex: 0xE20000)
                    self.emergencyButton.setImage(UIImage(named: "emergency_after_pressed"), for: UIControl.State.normal)
                    self.showEmeregencyStartedScreen(isEmergencyStarted: false)
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: taxiEmergencyConfirmationViewController)
        }
    }

    private func showEmeregencyStartedScreen(isEmergencyStarted: Bool){
        let taxiEmergencyViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiEmergencyViewController") as! TaxiEmergencyViewController
        taxiEmergencyViewController.iniatialiseEmergencyView(isEmergencyAlreadyStarted: isEmergencyStarted,taxiPassengerRide: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger,driverName: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverName ?? "",driverContactNo: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.driverContactNo ?? "")
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiEmergencyViewController)
    }
}

//MARK: notification, chat
extension TaxiLiveRideMapViewController {
    private func checkNewMessage(){
        let unreadCount = MessageUtils.getUnreadCountOfChat()
        if unreadCount > 0{
            unreadMsgView.isHidden = false
            unReadMessageLabel.text = String(unreadCount)
        }else{
            unreadMsgView.isHidden = true
        }
    }

    private func handleNotificationCountAndDisplay(){
        let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0 {
            unreadNotificationView.isHidden = false
            notificationCountLabel.text = "\(pendingNotificationCount)"
        } else {
            unreadNotificationView.isHidden = true
        }
    }
}

//MARK: panel
extension TaxiLiveRideMapViewController: FloatingPanelControllerDelegate {
    private func addLiveRideCardViewController() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self

        // Initialize FloatingPanelController and add the view
        floatingPanelController.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            floatingPanelController.surfaceView.cornerRadius = 20.0
        } else {
            floatingPanelController.surfaceView.cornerRadius = 0.0
        }
        floatingPanelController.surfaceView.shadowHidden = false
        floatingPanelController.surfaceView.grabberTopPadding = 10
        taxiLiveRideBottomViewController = storyboard?.instantiateViewController(withIdentifier: "TaxiLiveRideBottomViewController") as? TaxiLiveRideBottomViewController
        taxiLiveRideBottomViewController.prepareDataForUI(taxiLiveRideViewModel: taxiLiveRideViewModel)
        floatingPanelController.set(contentViewController: taxiLiveRideBottomViewController)
        floatingPanelController.track(scrollView: taxiLiveRideBottomViewController.taxiLiveRideCardTableView)
        floatingPanelController.addPanel(toParent: self, animated: true)
    }

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let taxiLiveRideFloatingPanelLayout = TaxiLiveRideFloatingPanelLayout()
        taxiLiveRideFloatingPanelLayout.initialiseData(taxiLiveRideViewModel: taxiLiveRideViewModel)
        return taxiLiveRideFloatingPanelLayout
    }

    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
            if targetPosition == .full {
                self.floatingPanelController.surfaceView.cornerRadius = 0.0
                self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
                self.floatingPanelController.backdropView.isHidden = true
                self.floatingPanelController.surfaceView.shadowHidden = true
            }else{
                if #available(iOS 11, *) {
                    self.floatingPanelController.surfaceView.cornerRadius = 20.0
                } else {
                    self.floatingPanelController.surfaceView.cornerRadius = 0.0
                }
                self.floatingPanelController.backdropView.isHidden = false
                self.floatingPanelController.surfaceView.shadowHidden = false
            }

            if targetPosition == .full {
                self.mapComponentsView.isHidden = true
            } else {
                self.hideAllMapComponetsIfItInstantRide()
            }
        }, completion: { _ in
            self.handlePaymentViewVisibility()})

    }

    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        handlePaymentViewVisibility()
    }

    func floatingPanel(_ vc: FloatingPanelController, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot() && floatingPanelController.position == .tip{
            self.floatingPanelController.move(to: .half, animated: true)
        }
        return false
    }



}
//FloatingPanelLayout
class TaxiLiveRideFloatingPanelLayout: FloatingPanelLayout {
    var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()
    func initialiseData(taxiLiveRideViewModel: TaxiPoolLiveRideViewModel){
        self.taxiLiveRideViewModel = taxiLiveRideViewModel
    }
    public var initialPosition: FloatingPanelPosition {
        return .half
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 55.0
        case .half:
            return 300
        case .tip:
            return 299.5

        default: return nil
        }
    }
}

//MARK: NotificationChangeListener delegate
extension TaxiLiveRideMapViewController: NotificationChangeListener {
    func handleNotificationListChange() {
        handleNotificationCountAndDisplay()
    }
}

//MARK: Map Component, markers, route,eta
extension TaxiLiveRideMapViewController {
    func refreshMapWithNewData() {
        viewMap.delegate = self
        self.viewMap.clear()
        routeNavigationMarker?.map = nil
        routeNavigationMarker = nil
        startMarker?.map = nil
        startMarker = nil
        endMaker?.map = nil
        endMaker = nil
        confirmPickPointMarker?.map = nil
        confirmPickPointMarker = nil
        pickUpRoute?.map = nil
        pickUpRoute = nil
        drawRouteForRide()
        viewMap.isMyLocationEnabled = false
        handaleRouteZoomBasedOnStatus()
    }

    private func drawRouteForRide() {
        guard let taxiRidePassengerDetails = taxiLiveRideViewModel.taxiRidePassengerDetails,let taxiRideGroup = taxiRidePassengerDetails.taxiRideGroup else { return }
        prepareStartAndEndMarkers(taxiRide: taxiRideGroup)

        if taxiLiveRideViewModel.isRentalTrip(){
            if let polyline = taxiLiveRideViewModel.getRentalPolyline(), !polyline.isEmpty {
                GoogleMapUtils.drawRoute(pathString: polyline, map: viewMap, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_5, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
            }

        }else {
            path = GMSPath(fromEncodedPath: taxiRideGroup.routePolyline ?? "") ?? GMSPath()
            selectedPolyLine.path = path
            selectedPolyLine.strokeColor = UIColor.black
            selectedPolyLine.strokeWidth = 4
            selectedPolyLine.map = viewMap
            if taxiLiveRideViewModel.checkCurrentTripIsInstantOrNot(){
                floatingPanelController.surfaceView.grabberHandle.isHidden = true
                pathTimer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
            }else{
                floatingPanelController.surfaceView.grabberHandle.isHidden = false
                pathTimer?.invalidate()
            }
            self.drawOtherPassengerPickAndDropOverMap()
        }

    }
    private func drawOtherPassengerPickAndDropOverMap(){
        guard let taxiRidePassengerBasicInfos = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.otherPassengersInfo, taxiRidePassengerBasicInfos.count > 0 else {
            return
        }

        for taxiRidePassengerBasicInfo in taxiRidePassengerBasicInfos
        {
            let pickup = CLLocationCoordinate2D(latitude: taxiRidePassengerBasicInfo.startLat!, longitude: taxiRidePassengerBasicInfo.startLng!)
            let pickupMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickup)
            let pickupView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
            pickupView.initializeView(name: taxiRidePassengerBasicInfo.userName!, colorCode: UIColor(netHex: 0x656766))
            pickupMarker.icon = ViewCustomizationUtils.getImageFromView(view: pickupView)
            pickupMarker.zIndex = 12
            pickupMarker.title = taxiRidePassengerBasicInfo.userName!
            pickupMarker.isTappable = true
            pickupMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
            pickupMarker.map = viewMap
            if let endLat = taxiRidePassengerBasicInfo.endLat, endLat != -999 ,let endLng = taxiRidePassengerBasicInfo.endLng, endLng != -999 {
                let drop = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)

                let dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop)
                let dropView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
                dropView.initializeView(name: taxiRidePassengerBasicInfo.userName!, colorCode: UIColor(netHex: 0xB50000))
                dropMarker.icon = ViewCustomizationUtils.getImageFromView(view: dropView)
                dropMarker.zIndex = 12
                dropMarker.title =  taxiRidePassengerBasicInfo.userName!
                dropMarker.isTappable = true
                dropMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
                dropMarker.map = viewMap
            }
        }

    }



    @objc func animatePolylinePath() {
        if (index < path.count()) {
            animationPath.add(path.coordinate(at: index))
            animationPolyline.path = self.animationPath
            animationPolyline.strokeColor = UIColor.lightGray
            animationPolyline.strokeWidth = 4
            animationPolyline.map = viewMap
            index += 1
        }else {
            index = 0
            animationPath = GMSMutablePath()
            animationPolyline.map = nil
        }
    }

    private func prepareStartAndEndMarkers(taxiRide: TaxiRideGroup){
        if let startlat = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat, let startlng = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng {
            confirmPickPointMarker?.map = nil
            startMarker?.map = nil
            let startPoint = CLLocationCoordinate2D(latitude: startlat , longitude: startlng )
            if !taxiLiveRideViewModel.isRentalTrip(), !taxiLiveRideViewModel.isTaxiStarted(){
                let confirmPickUpPoint = UIView.loadFromNibNamed(nibNamed: "ConfirmPickupPointMarker") as! ConfirmPickupPointMarker
                confirmPickUpPoint.addShadow()
                let icon = ViewCustomizationUtils.getImageFromView(view: confirmPickUpPoint)
                confirmPickPointMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: startPoint, shortIcon: icon, tappable: true, anchor: CGPoint(x: 0.20, y: 1.2))
                confirmPickPointMarker?.zIndex = 10
                confirmPickPointMarker?.isFlat = true
            } else {
                startMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: startPoint, shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
                startMarker?.zIndex = 12
            }
        }

        if taxiLiveRideViewModel.isRentalTrip(), let endlat = taxiLiveRideViewModel.rentalStopPointList?.last?.stopPointLat,
           let endlng = taxiLiveRideViewModel.rentalStopPointList?.last?.stopPointLng {

            endMaker?.map = nil
            endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: endlat, longitude : endlng), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            endMaker?.zIndex = 12
        }
        if let endLat = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLat, endLat != TaxiRidePassenger.UNKNOWN_LAT, let endLng = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.endLng, endLng != TaxiRidePassenger.UNKNOWN_LNG {
            endMaker?.map = nil
            endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: endLat, longitude : endLng), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            endMaker?.zIndex = 12

        }

    }


    private func drawPickupRoute(currentLocation: CLLocationCoordinate2D) {
        pickUpRoute?.map = nil
        pickUpRoute = nil
        if !taxiLiveRideViewModel.isTaxiStarted() && taxiLiveRideViewModel.isTaxiAllotted(){
            if let overViewPolyline = taxiLiveRideViewModel.etaResponse?.overViewPolyline{
                let driverCurrentLoc = CLLocationCoordinate2D(latitude: currentLocation.latitude , longitude: currentLocation.longitude)
                let pickUp = CLLocationCoordinate2D(latitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat ?? 0, longitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng ?? 0)
                let newRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: driverCurrentLoc, dropLatLng: pickUp, polyline: overViewPolyline)
                if newRoute.count < 3{
                    return
                }
                let polyline = Polyline(coordinates: newRoute)
                pickUpRoute = GoogleMapUtils.drawdashedRoute(routeString: polyline.encodedPolyline, mapView: viewMap, color: .black, zIndex: GoogleMapUtils.Z_INDEX_10, polyLineWidth: GoogleMapUtils.POLYLINE_WIDTH_2)
            }else{
                let driverCurrentLoc = CLLocation(latitude: currentLocation.latitude , longitude: currentLocation.longitude)
                let pickUp = CLLocation(latitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLat ?? 0, longitude: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startLng ?? 0)
                pickUpRoute = GoogleMapUtils.drawStraightLineFromCurrentLocationToPickUp(start: driverCurrentLoc, end: pickUp, map: viewMap, colorCode: Colors.link, zindex: GoogleMapUtils.Z_INDEX_10)
            }
        }
    }
    func handaleRouteZoomBasedOnStatus(){



        self.viewMap.padding = UIEdgeInsets(top: 20, left: 20, bottom: 330, right: 20)
        if userInteractedWithMap {
            return
        }
        if let taxiGroup = taxiLiveRideViewModel.getTaxiRideGroup(),let location =  TaxiRideDetailsCache.getInstance().getLocationUpdateForTaxi(taxiGroupId: taxiGroup.id!){
            currentLocation = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
        }
        if let currentLoc = currentLocation,taxiLiveRideViewModel.isTaxiStarted(){
            self.viewMap.animate(toLocation: currentLoc)
            self.viewMap.animate(toZoom: 16)
        }else{
            if let bounds  = getGMSBoundsToFocusBasedOnStatus(currentLocation: currentLocation){
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
            }else if let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger, let startLat = taxiRidePassenger.startLat, let startLng = taxiRidePassenger.startLng  {
                self.viewMap.animate(toLocation: CLLocationCoordinate2D(latitude: startLat,longitude: startLng))
                self.viewMap.animate(toZoom: 16)
            }
        }
    }

    func getGMSBoundsToFocusBasedOnStatus(currentLocation :CLLocationCoordinate2D?) -> GMSCoordinateBounds? {
        guard let  taxiRidePassengerDetails = taxiLiveRideViewModel.taxiRidePassengerDetails else {
            return nil
        }
        if taxiLiveRideViewModel.isRentalTrip() {
            if currentLocation != nil {
                if  taxiRidePassengerDetails.isTaxiStarted(), let endStop = taxiLiveRideViewModel.rentalStopPointList?.last, let endLat = endStop.stopPointLat, let endLng = endStop.stopPointLng  {
                    return GMSCoordinateBounds(coordinate: currentLocation!, coordinate: CLLocationCoordinate2D(latitude: endLat, longitude: endLng))
                }else{
                    return GMSCoordinateBounds(coordinate: currentLocation!, coordinate: CLLocationCoordinate2D(latitude: taxiRidePassengerDetails.taxiRidePassenger!.startLat!, longitude: taxiRidePassengerDetails.taxiRidePassenger!.startLng!))
                }

            }else {

                guard let polyline = taxiLiveRideViewModel.getRentalPolyline(), let gmsPath =  GMSPath(fromEncodedPath: polyline) else {
                    return nil
                }

                return GMSCoordinateBounds(path: gmsPath)

            }
        }else{
            if currentLocation != nil {
                if  taxiRidePassengerDetails.isTaxiStarted(){
                    return GMSCoordinateBounds(coordinate: currentLocation!, coordinate: CLLocationCoordinate2D(latitude: taxiRidePassengerDetails.taxiRidePassenger!.endLat!, longitude: taxiRidePassengerDetails.taxiRidePassenger!.endLng!))

                }else{
                    return GMSCoordinateBounds(coordinate: currentLocation!, coordinate: CLLocationCoordinate2D(latitude: taxiRidePassengerDetails.taxiRidePassenger!.startLat!, longitude: taxiRidePassengerDetails.taxiRidePassenger!.startLng!))
                }

            }else {

                guard let polyline = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRideGroup?.routePolyline, let gmsPath =  GMSPath(fromEncodedPath: polyline) else {
                    return nil
                }

                return GMSCoordinateBounds(path: gmsPath)

            }
        }
    }

}
//MARK: GMSMapViewDelegate
extension TaxiLiveRideMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        LiveRideViewModel.MAP_ZOOM = position.zoom
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            currentLocationButton.isHidden = false
            self.userInteractedWithMap = true
        }else{
            currentLocationButton.isHidden = true
            self.userInteractedWithMap = false
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == confirmPickPointMarker {
            moveToConfirmPickupView()
        }
        return true
    }

    private func moveToConfirmPickupView() {
        guard let taxiRide = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.copy() as? TaxiRidePassenger else {return}
        let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickupDropEditViewController") as! PickupDropEditViewController
        object_setClass(pickUpDropViewController, TaxiConfirmPickupPointViewController.self)
        guard let taxiConfirmPickupPointViewController = pickUpDropViewController as? TaxiConfirmPickupPointViewController else { return }
        taxiConfirmPickupPointViewController.showConfirmPickPointView(taxiRide: taxiRide,delegate: self)
        self.navigationController?.pushViewController(taxiConfirmPickupPointViewController, animated: false)
    }
}
//MARK: GMSMapViewDelegate
extension TaxiLiveRideMapViewController: TaxiPickupSelectionDelegate{
    func pickupChanged(taxiRide: TaxiRidePassenger) {
        QuickRideProgressSpinner.startSpinner()
        TaxiUtils.getAvailableVehicleClass(startTime: taxiRide.pickupTimeMs!, startAddress: taxiRide.startAddress, startLatitude: taxiRide.startLat!, startLongitude: taxiRide.startLng!, endLatitude: taxiRide.endLat!, endLongitude: taxiRide.endLng!, endAddress: taxiRide.endAddress,journeyType: taxiRide.journeyType!, routeId: nil) { [weak self] detailedEstimateFare, responseError, error in
            QuickRideProgressSpinner.stopSpinner()
            guard let self = self else {
                return
            }
            if let detailedEstimateFare = detailedEstimateFare, let fareForVehicle =  TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimateFare, taxiVehicleCategory: taxiRide.taxiVehicleCategory!), let fare = fareForVehicle.maxTotalFare {
                TaxiUtils.displayFareToConfirm(currentFare: taxiRide.initialFare!,newFare: fare) { [weak self] result in
                    if !result{
                        return
                    }
                    QuickRideProgressSpinner.startSpinner()
                    self?.taxiLiveRideViewModel.updateTaxiTrip(endLatitude: taxiRide.endLat, endLongitude: taxiRide.endLng, endAddress: taxiRide.endAddress, taxiRidePassengerId: taxiRide.id! , startLatitude: taxiRide.startLat, startLongitude: taxiRide.startLng, startAddress: taxiRide.startAddress, pickupNote: taxiRide.pickupNote, selectedRouteId: Double(fareForVehicle.routeId ?? "0"), fixedFareId: fareForVehicle.fixedFareId!) { [weak self] result in
                        QuickRideProgressSpinner.stopSpinner()
                        if result {
                            self?.getTaxiRideDetails()
                            self?.getNearbyTaxiIfRequired()
                        }
                    }
                }
            }else{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }
        }
    }
}
extension TaxiLiveRideMapViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stopPointDetailTableView {
            if let rentalStopPoints = taxiLiveRideViewModel.rentalStopPointList, rentalStopPoints.count > 0 {
                return rentalStopPoints.count + 2
            } else {
                return 2
            }
        }else {
           return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stopPointDetailTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentalStopPointDetailTableViewCell", for: indexPath) as! RentalStopPointDetailTableViewCell
            cell.stopPointLocationButton.titleLabel?.numberOfLines = 1
            if indexPath.row == 0 {
                cell.initialiseData(stopPointLocation: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startAddress, actionComplitionHandler: nil)
                cell.dotView.backgroundColor = UIColor(netHex: 0x99D8A8)
                return cell
            }else if taxiLiveRideViewModel.rentalStopPointList?.count ?? 0 > indexPath.row - 1 {
                cell.initialiseData(stopPointLocation: taxiLiveRideViewModel.rentalStopPointList?[indexPath.row - 1].stopPointAddress, actionComplitionHandler: nil)
                cell.dotView.backgroundColor = UIColor.gray
                return cell
            }else {
                cell.initialiseData(stopPointLocation: nil){ completed in
                    self.moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN , location: nil, alreadySelectedLocation: nil)
                }
                if taxiLiveRideViewModel.rentalStopPointList?.count ?? 0 > 0{
                    cell.stopPointLocationButton.setTitle("Add Stop Point", for: .normal)
                }else {
                    cell.stopPointLocationButton.setTitle("Add Destination", for: .normal)
                }
                cell.dotView.backgroundColor = UIColor(netHex: 0xD89999)
                return cell
            }
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayTaxiAmountTableViewCell", for: indexPath) as! PayTaxiAmountTableViewCell
            cell.initialisePaymentDetails(viewModel: taxiLiveRideViewModel, isFromBottomDrawer: true) { completed in
                if completed {
                    self.showFareBreakUp()
                }
            }
            return cell
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let visibleRect = CGRect(origin: stopPointDetailTableView.contentOffset, size: stopPointDetailTableView.bounds.size)
        let visibleTopPoint = CGPoint(x: visibleRect.minX, y: visibleRect.minY)
        if let indexPath =  stopPointDetailTableView.indexPathForRow(at: visibleTopPoint),let count = taxiLiveRideViewModel.rentalStopPointList?.count{
            if indexPath.row == 0{
                taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList = true
                scrollArrowDirectionImageView.image = UIImage(named: "icon_arrow_scroll_down")
            }else if indexPath.row == count {
                taxiLiveRideViewModel.isRequiredToScrollDownRentaStopPointList = false
                scrollArrowDirectionImageView.image = UIImage(named: "icon_arrow_scroll_up")
            }
        }
    }

    func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

}
extension TaxiLiveRideMapViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        addNewStopPoint(endAddress: location.address ?? "", endlat: location.latitude , endlng: location.longitude)
    }

    func locationSelectionCancelled(requestLocationType: String) {

    }

   private func addNewStopPoint(endAddress: String,endlat: Double,endlng: Double){
        var startLatitude: Double?
        var startLongitude: Double?
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.status == TaxiRidePassenger.STATUS_STARTED{
            if let taxiLiveRideMapViewController = self.parent?.parent as? TaxiLiveRideMapViewController {
                startLatitude = taxiLiveRideMapViewController.currentLocation?.latitude
                startLongitude = taxiLiveRideMapViewController.currentLocation?.longitude
            }
        }
       QuickRideProgressSpinner.startSpinner()
       taxiLiveRideViewModel.addNewRentalStopPoints(startAddress : nil, startLatitude: startLatitude, startLongitude: startLongitude, endAddress: endAddress ,endlat: endlat ,endlng: endlng) { (responseError, error) in
           QuickRideProgressSpinner.stopSpinner()
           self.refreshMapWithNewData()
           self.refreshUI(isRefreshClicked: false)
           self.handleVisibilityOfRentalPackageDetails()
           if responseError != nil && error != nil {
               ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
           }
       }
    }
}
//MARK: Payment Option
extension TaxiLiveRideMapViewController {
    func handlePaymentViewVisibility(){
        guard let pendingAmount = taxiLiveRideViewModel.outstationTaxiFareDetails?.pendingAmount, pendingAmount > 0 else {
            paymentView.isHidden = true
            return
        }
        paymentView.isHidden = false
        var indexPath = IndexPath()
        if taxiLiveRideViewModel.isOutstationTrip() {
            indexPath = IndexPath(item: 0, section: 14)
        }else if taxiLiveRideViewModel.isRentalTrip() {
            indexPath = IndexPath(item: 0, section: 13)
        }else {
            indexPath = IndexPath(item: 0, section: 18)
        }
        let rectOfCellInTableView = taxiLiveRideBottomViewController.taxiLiveRideCardTableView.rectForRow(at: indexPath)
        let rectOfCellInSuperview = taxiLiveRideBottomViewController.taxiLiveRideCardTableView.convert(rectOfCellInTableView, to: self.view)
        let paymentViewCellPosition = rectOfCellInSuperview.minY
        let frameHeight =  self.view.safeAreaLayoutGuide.layoutFrame.maxY
        if frameHeight < paymentViewCellPosition {
            paymentView.isHidden = false
            paymentView.frame = CGRect(x: 0, y: frameHeight - 65 , width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 65)
        }else if frameHeight - paymentViewCellPosition < 80 {
            paymentView.isHidden = false
            paymentView.frame = CGRect(x: 0, y: ((frameHeight - 65) + (frameHeight - paymentViewCellPosition)) , width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 65)
        }else {
            paymentView.isHidden = true
        }
    }

    private func showFareBreakUp() {
         self.floatingPanelController.move(to: .full, animated: true)
         var indexPath = IndexPath()
         taxiLiveRideViewModel.getFareBrakeUpData()
         taxiLiveRideViewModel.isrequiredtoshowFareView = true
         taxiLiveRideBottomViewController.taxiLiveRideCardTableView.reloadData()
         if taxiLiveRideViewModel.isOutstationTrip() {
             indexPath = IndexPath(item: 0, section: 3)
         }else if taxiLiveRideViewModel.isRentalTrip() {
             indexPath = IndexPath(item: 0, section: 2)
         }else {
             indexPath = IndexPath(item: 0, section: 8)
         }
         self.taxiLiveRideBottomViewController.taxiLiveRideCardTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
     }
}
