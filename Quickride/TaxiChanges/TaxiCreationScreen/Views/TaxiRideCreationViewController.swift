//
//  TaxiRideCreationMapViewController.swift
//  Quickride
//
//  Created by Ashutos on 14/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import FloatingPanel
import ObjectMapper
import CoreLocation
import Lottie

class TaxiRideCreationMapViewController: UIViewController {

    @IBOutlet weak private var mapView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var bookNowbutton: QRCustomButton!
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var loaderView: AnimatedControl!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var applyCouponView: UIView!
    @IBOutlet weak var appliedCouponView: UIView!
    @IBOutlet weak var couponCodeLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var expiredTag: UIButton!
    @IBOutlet weak var behalfBookingView: UIView!
    @IBOutlet weak var customerNameDetails: UILabel!
    @IBOutlet weak var animationLoader: AnimationView!
    @IBOutlet weak var animationStackView: UIStackView!
    private var viewMap: GMSMapView!
    private var taxiRideCreationViewModel = TaxiRideCreationViewModel()
    var fpc: FloatingPanelController!
    private var taxiRideCreationBottomViewController: TaxiRideCreationBottomViewController!
    private var routeDistanceMarker: GMSMarker?
    private var startMarker :GMSMarker?
    private var endMaker : GMSMarker?
    private var selectedPolyLine: GMSPolyline?
    private var path = GMSPath()
    private var animationPolyline = GMSPolyline()
    private var animationPath = GMSMutablePath()
    private var index: UInt = 0
    private var timer: Timer?
    private var isTappedOnMarkerInfoOnMap = false
    private var taxiMarkers = [GMSMarker]()
    var routePolylines = [GMSPolyline]()
    var viewFrame = UIView()

    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    private var joinFlowUI: NewJoinShimmerViewController?
    private var locationManager = CLLocationManager()


    func initialiseData(startLocation: Location?, endLocation: Location?,selectedRouteId : Double,tripType: String,journeyType : String?, commuteContactNo: String?, commutePassengerName: String?) {
        self.taxiRideCreationViewModel = TaxiRideCreationViewModel(startLocation: startLocation, endLocation: endLocation,selectedRouteId: selectedRouteId, rideType: tripType, journeyType: journeyType, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName)

    }

    func initialiseData(passengerRide : PassengerRide) {
        self.taxiRideCreationViewModel = TaxiRideCreationViewModel(passengerRide : passengerRide)
    }
    func initialiseTaxiRidePassengerRide(taxiRidePassenger: TaxiRidePassenger){
        self.taxiRideCreationViewModel = TaxiRideCreationViewModel(taxiRidePassenger: taxiRidePassenger)
    }

    func initialiseData(startLocation: Location?, selectedRentalPackage: RentalPackageEstimate?, rentalPackageEstimates: [RentalPackageEstimate]?, commuteContactNo: String?, commutePassengerName: String?) {
        self.taxiRideCreationViewModel = TaxiRideCreationViewModel(startLocation: startLocation, selectedRentalPackage: selectedRentalPackage, rentalPackageEstimates: rentalPackageEstimates, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            fpc.surfaceView.cornerRadius = 20.0
        } else {
            fpc.surfaceView.cornerRadius = 0.0
        }
        fpc.surfaceView.shadowHidden = false
        fpc.surfaceView.grabberTopPadding = 10
        taxiRideCreationBottomViewController = storyboard?.instantiateViewController(withIdentifier: "TaxiRideCreationBottomViewController") as? TaxiRideCreationBottomViewController
        taxiRideCreationBottomViewController.initialiseData(taxiRideCreationViewModel: taxiRideCreationViewModel)
        fpc.set(contentViewController: taxiRideCreationBottomViewController)
        fpc.track(scrollView: taxiRideCreationBottomViewController.taxiRideDetailstableView)
        fpc.addPanel(toParent: self, animated: true)
        prepareMapUI()
        if taxiRideCreationViewModel.selectedRouteId > 0{
            getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
        }else  if taxiRideCreationViewModel.selectedRentalPackage == nil {
            getAvailableRoutes(routeId: nil)
        }
        else {
            fpc.move(to: .full, animated: true)
        }
        if taxiRideCreationViewModel.refRequestId != nil{
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        if let startLocation = taxiRideCreationViewModel.startLocation {
            getAvailableNearbyTaxi(location: startLocation)
        }
        setUpUI()
        setUpPaymentAndBookingUI()
        self.view.addSubview(contentView)
    }
    override func viewWillAppear(_ animated: Bool) {
        setPromoCodeView()
        setUpUI()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }

    private func prepareMapUI() {
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        setMapViewPadding()
        self.viewMap.delegate = self
        self.viewMap.isMyLocationEnabled = false
        clearRouteData()
        let location = CLLocationCoordinate2D(latitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0, longitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0)
        moveToCoordinate(coordinate: location)
        if taxiRideCreationViewModel.selectedOptionIndex == 1{
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: false)
        } else{
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: true)
        }
    }

    func setUpUI() {
        bottomView.isHidden = false
        contentView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        updateBookNowButtonUI()
        taxiRideCreationViewModel.checkCityAndStateExistanceElseGetFromGeocoder()
        showBehalfBookingViewIfRequired()
    }

    func updateBookNowButtonUI(){
        if taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_LOCAL, !(taxiRideCreationViewModel.selectedOptionIndex == 1){
            bookNowbutton.setTitle(Strings.book_taxi, for: .normal)
            walletView.isHidden = false
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: true)
        }else if taxiRideCreationViewModel.selectedOptionIndex == 1 {
            bookNowbutton.setTitle(Strings.book_taxi, for: .normal)
            walletView.isHidden = false
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: false)
        }else {
            bookNowbutton.setTitle(Strings.review_booking, for: .normal)
            walletView.isHidden = true
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: true)
        }
    }

    func showBehalfBookingViewIfRequired(){
        if let commutePassengerName = taxiRideCreationViewModel.commutePassengerName {
            behalfBookingView.isHidden = false
            customerNameDetails.text = commutePassengerName
        } else {
            behalfBookingView.isHidden = true
        }
    }



    func setUpPaymentAndBookingUI() {
        walletView.isHidden = false
        if let paymentMode = self.taxiRideCreationViewModel.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            walletNameLabel.text = Strings.payment_type_cash
            walletTypeImageView.image = UIImage(named: "payment_type_cash")
            loaderView.isHidden = true
            availableBalanceLabel.isHidden = true
            expiredTag.isHidden = true
            return
        }
        if  let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() {
            setTitleAndImage(type: linkedWallet.type!)
            if linkedWallet.status == LinkedWallet.EXPIRED{
                expiredTag.isHidden = false
                availableBalanceLabel.isHidden = true
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
                expiredTag.isHidden = true
                availableBalanceLabel.isHidden = true
            }else{
                expiredTag.isHidden = true
                getDefaultLinkedWalletBalance()
            }
        }else{
            walletNameLabel.text = Strings.add_wallet
            walletTypeImageView.image = UIImage(named: "qr_wallet")
            availableBalanceLabel.isHidden = true
            loaderView.isHidden = true
        }
    }

    private func getDefaultLinkedWalletBalance() {
        showLOTAnimation(isShow: true)
        guard let defaultLinkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {return}
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), types: defaultLinkedWallet.type!,viewController: self, handler: { [weak self] (responseObject, error) in
            self?.showLOTAnimation(isShow: false)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
                if let wallet = linkedWalletBalances.first(where: {$0.type == defaultLinkedWallet.type}){
                    UserDataCache.getInstance()?.getDefaultLinkedWallet()?.balance = wallet.balance
                    self?.availableBalanceLabel.isHidden = false
                    self?.availableBalanceLabel.text = StringUtils.getPointsInDecimal(points: wallet.balance)
                }
            }else{
                self?.availableBalanceLabel.isHidden = false
                self?.availableBalanceLabel.text = StringUtils.getPointsInDecimal(points: defaultLinkedWallet.balance ?? 0)
            }
        })
    }



    private func showLOTAnimation(isShow: Bool) {
        if isShow {
            loaderView.isHidden = false
            loaderView.animationView.animation = Animation.named("simple-dot-loader")
            loaderView.animationView.play()
            loaderView.animationView.loopMode = .loop
        } else {
            loaderView.isHidden = true
            loaderView.animationView.stop()
        }
    }

    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletTypeImageView.image = UIImage(named: "paytm_new")
            walletNameLabel.text = Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletTypeImageView.image = UIImage(named: "lazypay_logo")
            walletNameLabel.text = Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletTypeImageView.image = UIImage(named: "simpl_new")
            walletNameLabel.text = Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletTypeImageView.image = UIImage(named: "tmw_new")
            walletNameLabel.text = Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletTypeImageView.image = UIImage(named: "mobikwik_logo")
            walletNameLabel.text = Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletTypeImageView.image = UIImage(named: "frecharge_logo")
            walletNameLabel.text = Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletTypeImageView.image = UIImage(named : "apay_linked_wallet")
            walletNameLabel.text = Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletTypeImageView.image = UIImage(named : "upi")
            walletNameLabel.text = Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletTypeImageView.image = UIImage(named : "gpay_icon_with_border")
            walletNameLabel.text = Strings.gpay
        default:
            walletTypeImageView.isHidden = true
            walletNameLabel.text = ""
        }
    }

    private func setMapViewPadding() {
        self.viewMap.padding = UIEdgeInsets(top: 10, left: 20, bottom: 40, right: 20)
//        self.viewMap.animate(toZoom: 16)
    }

    func getAvailableNearbyTaxi(location : Location){
        var taxiType = TaxiPoolConstants.TAXI_TYPE_CAR
        if taxiRideCreationViewModel.selectedOptionIndex == 0 {
            if taxiRideCreationViewModel.fareForVehicleDetail.count > taxiRideCreationViewModel.selectedTaxiTypeIndex ,let taxitype = taxiRideCreationViewModel.fareForVehicleDetail[taxiRideCreationViewModel.selectedTaxiTypeIndex].taxiType {
            taxiType = taxitype
            }
        } else {
            if (taxiRideCreationViewModel.selectedRentalPackage?.rentalPackageConfigList.count ?? 0) >  taxiRideCreationViewModel.selectedVehicleIndex,let taxitype = taxiRideCreationViewModel.selectedRentalPackage?.rentalPackageConfigList[taxiRideCreationViewModel.selectedVehicleIndex].taxiType {
            taxiType = taxitype
            }
        }
        removeAllNearbyTaxiMarker()
        taxiRideCreationViewModel.getNearbyTaxi(location: location, taxiType: taxiType){ (responseError, error)  in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                self.drawMapComponents()
            }
        }
    }

    private func showNearbyTaxi(){
        guard let listOfNearbyTaxi = taxiRideCreationViewModel.partnerRecentLocationInfo, !listOfNearbyTaxi.isEmpty else {
            return
        }
        removeAllNearbyTaxiMarker()
        for item in listOfNearbyTaxi {
            let taxiMarker = TaxiUtils.getNearbyTaxiMarkers(partnerRecentLocationInfo: item, viewMap: viewMap)
            taxiMarkers.append(taxiMarker)
        }
        if taxiRideCreationViewModel.selectedOptionIndex == 1{
            let taxiMarkerAndRoutePolyline = addTaxiMarkerAndRoute(routePolyline: nil)
            GoogleMapUtils.fitToScreen(route: taxiMarkerAndRoutePolyline, map: viewMap)
            prepareStartAndEndMarkers(isRequiredToShowEndMarker: false)
        }
    }

    func removeAllNearbyTaxiMarker(){
        for item in taxiMarkers{
            item.map = nil
        }
        taxiMarkers.removeAll()
    }

    @IBAction func currentLocationButtonpressed(_ sender: UIButton) {
        self.viewMap.padding = UIEdgeInsets(top: 10, left: 20, bottom: 40, right: 20)
        if !taxiRideCreationViewModel.fareForVehicleDetail.isEmpty, let overviewPolyline =  taxiRideCreationViewModel.fareForVehicleDetail[0].overviewPolyline, taxiRideCreationViewModel.selectedOptionIndex == 0{
            let taxiMarkerAndRoutePolyline = addTaxiMarkerAndRoute(routePolyline: overviewPolyline)
            GoogleMapUtils.fitToScreen(route: taxiMarkerAndRoutePolyline, map: viewMap)
        }else{
            let location = CLLocationCoordinate2D(latitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0, longitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0)
            moveToCoordinate(coordinate: location)
        }
        currentLocationButton.isHidden = true
    }

    @IBAction func editBehalfBookingDetailsButtonTapped(_ sender: Any) {
        moveToTaxiBookingSomeOneView()
    }
    
    func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        var routeSelectionDelegate: RouteSelectionDelegate?  = self
        var alreadySelectedLocation = alreadySelectedLocation
        if taxiRideCreationViewModel.selectedOptionIndex == 1 {
            routeSelectionDelegate = nil
            alreadySelectedLocation = nil
        }
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.receiveBehalfBookingDetails = self
        changeLocationVC.behalfBookingPhoneNumber = taxiRideCreationViewModel.commuteContactNo
        changeLocationVC.behalfBookingName = taxiRideCreationViewModel.commutePassengerName
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: routeSelectionDelegate, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func relinkTapped(_ sender: Any) {
        relinkWallet()
    }

    private func relinkWallet(){
        guard let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {return}
        AccountUtils().linkRequestedWallet(walletType: linkedWallet.type ?? "") { [weak self] (walletAdded, walletType) in
            if walletAdded{
                self?.setUpPaymentAndBookingUI()
            }
        }
    }

    @IBAction func changeWalletOptionPressed(_ sender: UIButton) {
        showPaymentDrawer()
    }

    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        var isDefaultPaymentModeCash = false
        if let paymentMode = self.taxiRideCreationViewModel.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            isDefaultPaymentModeCash = true
        }
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: isDefaultPaymentModeCash, isRequiredToShowCash: true, isRequiredToShowCCDC: nil) {(data) in
            if data == .cashSelected {
                self.taxiRideCreationViewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_CASH

            }else {
                self.taxiRideCreationViewModel.paymentMode = nil
            }
            self.setUpPaymentAndBookingUI()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }

    @IBAction func bookNowPressed(_ sender: UIButton) {
        continueTaxiBooking()
    }

    private func continueTaxiBooking(){
        if let erroMessage = taxiRideCreationViewModel.validateInputsForTaxiBooking(),taxiRideCreationViewModel.selectedOptionIndex != 1 {
            UIApplication.shared.keyWindow?.makeToast(erroMessage)
            return
        }
        if taxiRideCreationViewModel.selectedOptionIndex == 0 && taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            checkDuplicationRide()
        }else if  (UserDataCache.getInstance()?.getDefaultLinkedWallet()) != nil || taxiRideCreationViewModel.paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            if taxiRideCreationViewModel.selectedOptionIndex == 1{
                checkLinkedWalletBalanceAndBookTaxi()
            }else {
                checkDuplicationRide()
            }
        }else{
            showPaymentDrawer()
        }
    }

    func checkDuplicationRide(){
        let taxiPassengerRide = TaxiRidePassenger(startLat: taxiRideCreationViewModel.startLocation?.latitude, startLng: taxiRideCreationViewModel.startLocation?.longitude, startAddress: taxiRideCreationViewModel.startLocation?.shortAddress, endLat: taxiRideCreationViewModel.endLocation?.latitude, endLng: taxiRideCreationViewModel.endLocation?.longitude, endAddress: taxiRideCreationViewModel.endLocation?.shortAddress, startTimeMs: taxiRideCreationViewModel.startTime)
        if let duplicateRide = MyActiveTaxiRideCache.getInstance().checkForDuplicateRideOnSameDay(taxiRide: taxiPassengerRide) {
            displayDuplicatedRideForSameDayAlertDialog(duplicateRide: duplicateRide)
        }else {
            if taxiRideCreationViewModel.selectedOptionIndex == 0 && taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
                reviewBookingPressed()
            }else{
                checkLinkedWalletBalanceAndBookTaxi()
            }
        }
    }

    func displayDuplicatedRideForSameDayAlertDialog(duplicateRide : TaxiRidePassenger) {
        MessageDisplay.displayErrorAlertWithAction(title: Strings.duplicate_ride_alert, isDismissViewRequired : true, message1: Strings.ride_duplication_alert, message2: nil, positiveActnTitle: Strings.view_caps, negativeActionTitle : Strings.createNew_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if result == Strings.createNew_caps{
                if self.taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
                    self.reviewBookingPressed()
                }else{
                    self.checkLinkedWalletBalanceAndBookTaxi()
                }
            }else if result == Strings.view_caps{
                self.moveToLiveRideTaxiPool(rideId: duplicateRide.id ?? 0)
            }
        })
    }

    private func reviewBookingPressed() {
        let reviewScreen = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OutStationReviewViewController") as! OutStationReviewViewController
        if !taxiRideCreationViewModel.fareForVehicleDetail.isEmpty {
            let fareForVehicleClass = taxiRideCreationViewModel.fareForVehicleDetail[taxiRideCreationViewModel.selectedTaxiTypeIndex]
            var journeyType = TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY
            if taxiRideCreationViewModel.isRoundTrip {
                journeyType = TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP
            }
            reviewScreen.prepareDataForView(fareForVehicleClass: fareForVehicleClass, startLocation: taxiRideCreationViewModel.startLocation, endLocation: taxiRideCreationViewModel.endLocation, startTime: taxiRideCreationViewModel.startTime , selectedTaxiIndex: taxiRideCreationViewModel.selectedTaxiTypeIndex , journeyType: journeyType, endTime: taxiRideCreationViewModel.endTime, isFromLiveRide: false, selectedRouteId: taxiRideCreationViewModel.selectedRouteId, refRequestId: taxiRideCreationViewModel.refRequestId, commuteContactNo: taxiRideCreationViewModel.commuteContactNo, commutePassengerName: taxiRideCreationViewModel.commutePassengerName)
        }
        self.navigationController?.pushViewController(reviewScreen, animated: false)
    }

    private func checkLinkedWalletBalanceAndBookTaxi(){
        if taxiRideCreationViewModel.paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            if taxiRideCreationViewModel.selectedOptionIndex == 1 {
                bookRentalTaxi()
            }else {
                bookTaxi()
            }
        }else if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(),linkedWallet.status == LinkedWallet.EXPIRED{
            relinkWallet()
        }else if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(), linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            if taxiRideCreationViewModel.checkUserHasInSufficieantAmountToBook() {
                let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
                addMoneyViewController.initializeView(errorMsg: Strings.add_money_for_product){ (result) in
                    if result == .addMoney {
                        self.setUpPaymentAndBookingUI()
                        if self.taxiRideCreationViewModel.selectedOptionIndex == 1 {
                            self.bookRentalTaxi()
                        }else {
                            self.bookTaxi()
                        }
                    }else if result == .changePayment {
                        self.showPaymentDrawer()
                    }
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: addMoneyViewController)
            }else{
                if taxiRideCreationViewModel.selectedOptionIndex == 1 {
                    bookRentalTaxi()
                }else {
                    bookTaxi()
                }
            }
        }else{
            if taxiRideCreationViewModel.selectedOptionIndex == 1 {
                bookRentalTaxi()
            }else {
                bookTaxi()
            }
        }
    }

    private func bookTaxi() {
        var routeId: Double?
        var endTime: Double?
        var journeyType: String?
        var taxiAdvPercentage: Int?
        if taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            taxiAdvPercentage = taxiRideCreationViewModel.advaceAmountPercentageForOutstation
            if taxiRideCreationViewModel.isRoundTrip {
                endTime = taxiRideCreationViewModel.endTime
                journeyType = TaxiPoolConstants.JOURNEY_TYPE_ROUND_TRIP
            }else{
                journeyType  = TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY
            }
        }
        if taxiRideCreationViewModel.selectedRouteId != -1 {
            routeId = taxiRideCreationViewModel.selectedRouteId
        }

        addAnimationViewAsSubView()
        let createTaxiDetails = CreateTaxiPoolHandler(startLocation: taxiRideCreationViewModel.startLocation, endLocation: taxiRideCreationViewModel.endLocation, tripType: taxiRideCreationViewModel.rideType, routeId: routeId, startTime: taxiRideCreationViewModel.startTime, selectedVehicleDetails: taxiRideCreationViewModel.fareForVehicleDetail[taxiRideCreationViewModel.selectedTaxiTypeIndex], endTime: endTime, journeyType: journeyType, advancePercentageForOutstation: taxiAdvPercentage, refRequestId: taxiRideCreationViewModel.refRequestId, viewController: self, couponCode: taxiRideCreationViewModel.userCouponCode?.couponCode, paymentMode: taxiRideCreationViewModel.paymentMode, taxiGroupId: nil, refInviteId: nil, commuteContactNo: taxiRideCreationViewModel.commuteContactNo, commutePassengerName: taxiRideCreationViewModel.commutePassengerName)
        createTaxiDetails.createTaxiPool  { [weak self](data, error) in
            self?.removeAnimationView()
            if let data = data,let taxiRidePassenger = data.taxiRidePassenger {
                TaxiRideDetailsCache.getInstance().setTaxiRideDetailsToCache(rideId: taxiRidePassenger.id ?? 0, taxiRidePassengerDetails: data)
                MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)

                self?.moveToLiveRideTaxiPool(rideId: taxiRidePassenger.id ?? 0.0)
            }
        }
    }

    func bookRentalTaxi(){
        if taxiRideCreationViewModel.rentalPackageId == nil || taxiRideCreationViewModel.rentalPackageId == 0, let id = taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedOptionIndex].rentalPackageConfigList[0].id, let taxiVehicleCategory = taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedOptionIndex].rentalPackageConfigList[0].vehicleClass{
            taxiRideCreationViewModel.rentalPackageId = id
            taxiRideCreationViewModel.taxiVehicleCategory = taxiVehicleCategory
        }
        addAnimationViewAsSubView()
        taxiRideCreationViewModel.bookRentalTaxi { (taxiPassengerDetails, responseError, error) in
            self.removeAnimationView()
            if let taxiPassengerDetails = taxiPassengerDetails, let taxiRidePassenger = taxiPassengerDetails.taxiRidePassenger {
                TaxiRideDetailsCache.getInstance().setTaxiRideDetailsToCache(rideId: taxiRidePassenger.id ?? 0, taxiRidePassengerDetails: taxiPassengerDetails)
                MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)
                self.moveToLiveRideTaxiPool(rideId: taxiRidePassenger.id ?? 0.0)
            } else if responseError != nil {
                RideManagementUtils.handleRiderInviteFailedException(errorResponse: responseError!, viewController: self, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                    self.checkLinkedWalletBalanceAndBookTaxi()
                })
            }
        }
    }

    private func addAnimationViewAsSubView() {

        viewFrame = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 130))
        viewFrame.backgroundColor =  UIColor.white.withAlphaComponent(0.6)
        animationLoader.isHidden = false
        animationLoader.animation = Animation.named("CircleLoader")
        animationLoader.play()
        animationLoader.loopMode = .loop
        let navigationCOntroller = ViewControllerUtils.getCenterViewController() as? UINavigationController
        let displayViewController = navigationCOntroller?.topViewController
        displayViewController?.view.addSubview(viewFrame)
        animationLoader.isHidden = false
    }

    private func removeAnimationView(){
        viewFrame.removeFromSuperview()
        animationLoader.isHidden = true
    }

    private func moveToLiveRideTaxiPool(rideId: Double) {
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: rideId)
        let myTripsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyTripsViewController") as! MyTripsViewController
        self.navigationController?.pushViewController(myTripsViewController, animated: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 3)
    }

    @IBAction func applyPromoCodeClicked(_ sender: UIButton) {
        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
        applyPromoCodeView?.initializeDataBeforePresentingView(title: Strings.apply_coupon, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: nil, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.coupon, promoCodeAppliedMsg: nil, handler: { (text, result) in
            if let code = text,Strings.apply_caps == result{
                self.verifyPromoCode(promoCode: code)
            }else{
                self.applyPromoCodeView = nil
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
    }

    private func verifyPromoCode(promoCode : String){
        QuickRideProgressSpinner.startSpinner()
        taxiRideCreationViewModel.verifyAppliedPromoCode(promoCode: promoCode, handler: { [weak self] responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self?.taxiRideCreationViewModel.userCouponCode = Mapper<UserCouponCode>().map(JSONObject: responseObject?["resultData"])
                self?.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.promo_code_applied, arguments: [promoCode]))
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                self?.taxiRideCreationViewModel.userCouponCode = nil
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]) {
                    self?.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
                } else {
                    self?.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
                }
            } else{
                self?.taxiRideCreationViewModel.userCouponCode = nil
                self?.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
            }
            self?.setPromoCodeView()
        })
    }
    private func setPromoCodeView(){
        if let couponCode = taxiRideCreationViewModel.userCouponCode{
            appliedCouponView.isHidden = false
            applyCouponView.isHidden = true
            couponCodeLabel.text = "\(couponCode.couponCode) Applied"
            savedAmountLabel.text = String(format: Strings.saved_amount, arguments: [StringUtils.getStringFromDouble(decimalNumber: couponCode.maxDiscount)])
            taxiRideCreationBottomViewController.taxiRideDetailstableView.reloadData()
        } else {
            appliedCouponView.isHidden = true
            applyCouponView.isHidden = false
        }
    }

    @IBAction func removeAppliedCouponTapped(_ sender: Any) {
        taxiRideCreationViewModel.userCouponCode = nil
        applyCouponView.isHidden = false
        appliedCouponView.isHidden = true
        couponCodeLabel.text = ""
        taxiRideCreationBottomViewController.taxiRideDetailstableView.reloadData()
    }

    func rideStartLocationChanged(location : Location){
        AppDelegate.getAppDelegate().log.debug("rideStartLocationChanged()")
        clearRouteData()

        getAvailableNearbyTaxi(location: location)
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16))
    }
}

//MARK: Floating Panel
extension TaxiRideCreationMapViewController : FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return TaxiRideFloatingPanelLayout()
    }

    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .full{
                            self.fpc.surfaceView.cornerRadius = 20.0
                            self.fpc.surfaceView.grabberHandle.isHidden = false
                            self.fpc.backdropView.isHidden = false
                            self.fpc.surfaceView.shadowHidden = false
                        }else{
                            if #available(iOS 11, *) {
                                self.fpc.surfaceView.cornerRadius = 20.0
                            } else {
                                self.fpc.surfaceView.cornerRadius = 0.0
                            }
                            self.fpc.surfaceView.grabberHandle.isHidden = false
                            self.fpc.backdropView.isHidden = false
                            self.fpc.surfaceView.shadowHidden = false
                        }
        }, completion: nil)
    }
}

class TaxiRideFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 70 // A top inset from safe area
            case .half: return 500 // A bottom inset from the safe area
            case .tip: return 365 // A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
        }
    }
}

//MArk Draw route and polylines
extension TaxiRideCreationMapViewController {

    func addTaxiMarkerAndRoute(routePolyline: String?) -> String{
        var polylineCoordinate = [CLLocationCoordinate2D]()
        if taxiRideCreationViewModel.selectedOptionIndex == 0, let routePolyline = routePolyline, let routePolylineCoordinate = Polyline(encodedPolyline: routePolyline).coordinates {
            polylineCoordinate = routePolylineCoordinate
        }
        if let partnerRecentLocationInfo = taxiRideCreationViewModel.partnerRecentLocationInfo, !partnerRecentLocationInfo.isEmpty {
            for item in partnerRecentLocationInfo {
                let partnerRecentLocation = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
                polylineCoordinate.append(partnerRecentLocation)
            }
        }
        if let startLatitute = taxiRideCreationViewModel.startLocation?.latitude, let startLongitude = taxiRideCreationViewModel.startLocation?.longitude {
            let currentLocation = CLLocationCoordinate2D(latitude: startLatitute, longitude: startLongitude)
            polylineCoordinate.append(currentLocation)
        }
        let addedTaxiMarkerAndRoutePolyline = Polyline(coordinates: polylineCoordinate)
        return addedTaxiMarkerAndRoutePolyline.encodedPolyline
    }

    func prepareStartAndEndMarkers(isRequiredToShowEndMarker: Bool){
        startMarker?.map = nil
        endMaker?.map = nil
        startMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0, longitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        startMarker?.zIndex = 12
        if isRequiredToShowEndMarker {
            endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: taxiRideCreationViewModel.endLocation?.latitude ?? 0 ,longitude : taxiRideCreationViewModel.endLocation?.longitude ?? 0), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            endMaker?.zIndex = 12
        }
    }

    private func displayTimeAndDistanceInfoView(routePathData : RideRoute){
         let tolls = taxiRideCreationViewModel.getNoOfTolls()
        if tolls > 0{
            let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "DistanceAndDurationWithTollsView") as! DistanceAndDurationWithTollsView
            routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!, duration: routePathData.duration,noOfTolls: tolls)
            routeTimeAndChangeRouteInfoView.mainView.addShadow()
            ViewCustomizationUtils.addCornerRadiusToView(view: routeTimeAndChangeRouteInfoView.mainView, cornerRadius: 5)

            let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView.mainView)
            let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
            routeDistanceMarker?.map = nil
            if path != nil && path!.count() != 0{
                routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
            }
        }else{
            let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "RouteTimeAndChangeRouteInfoView") as! RouteTimeAndChangeRouteInfoView
            routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!, duration: routePathData.duration)
            routeTimeAndChangeRouteInfoView.mainView.addShadow()
            ViewCustomizationUtils.addCornerRadiusToView(view: routeTimeAndChangeRouteInfoView.mainView, cornerRadius: 5)

            let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView.mainView)
            let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
            routeDistanceMarker?.map = nil
            if path != nil && path!.count() != 0{
                routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
            }
        }


    }

    private func clearRouteData(){
        animationPath.removeAllCoordinates()
        animationPath = GMSMutablePath()
        selectedPolyLine?.map = nil
        selectedPolyLine = nil
        animationPolyline.map = nil
        animationPolyline.path = nil
        if startMarker != nil{
            startMarker?.map = nil
            startMarker = nil
        }
        if endMaker != nil{
            endMaker?.map = nil
            endMaker = nil
        }
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil

        viewMap.clear()
    }
}

//MARK: Location selection delegates
extension TaxiRideCreationMapViewController: ReceiveLocationDelegate,RouteSelectionDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        
        if taxiRideCreationViewModel.selectedOptionIndex == 1{
            if taxiRideCreationViewModel.endLocation?.latitude == location.latitude && taxiRideCreationViewModel.endLocation?.longitude == location.longitude {
                taxiRideCreationViewModel.endLocation = nil
            }
            taxiRideCreationViewModel.startLocation = location
            
            taxiRideCreationViewModel.isRequiredToReloadData = true
            getAvailableNearbyTaxi(location: location)
            rideStartLocationChanged(location: location)
            taxiRideCreationViewModel.getRentalPackages { (responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                self.taxiRideCreationBottomViewController.taxiRideDetailstableView.reloadData()
                if responseError != nil || error != nil {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
            if validateIsBookingForSome() {
                self.moveToTaxiBookingSomeOneView()
            }
            
        }else {
            taxiRideCreationViewModel.selectedRouteId = -1.0
            handleselectedLocation(location: location, requestLocationType: requestLocationType)
        }
    }
    private func validateIsBookingForSome() -> Bool{
        guard !taxiRideCreationViewModel.isCheckedForBehalfBooking, let location = locationManager.location,let startLat = taxiRideCreationViewModel.startLocation?.latitude , let startLng = taxiRideCreationViewModel.startLocation?.longitude  else {
            return false
        }
        let distanceBetweenTwoLocation = LocationClientUtils.getDistance(fromLatitude: location.coordinate.latitude, fromLongitude: location.coordinate.longitude, toLatitude: startLat, toLongitude: startLng)
        if distanceBetweenTwoLocation > 3000 {
            taxiRideCreationViewModel.isCheckedForBehalfBooking = true
            return true
        }else{
            return false
        }
        
    }
    private func moveToTaxiBookingSomeOneView(){
        let tripTypeViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_behalf_someone_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TripTypeViewController") as! TripTypeViewController
        tripTypeViewController.initialiseData(behalfBookingPhoneNumber: taxiRideCreationViewModel.commuteContactNo, behalfBookingName: taxiRideCreationViewModel.commutePassengerName){  contactName, contactNumber in
            if let contactName = contactName, let contactNumber = contactNumber {
                self.taxiRideCreationViewModel.commutePassengerName = contactName
                self.taxiRideCreationViewModel.commuteContactNo = contactNumber
                self.showBehalfBookingViewIfRequired()
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: tripTypeViewController)
    }

    func locationSelectionCancelled(requestLocationType: String) {
        isTappedOnMarkerInfoOnMap = false
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
    }

    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.TAXI_PICKUP{
            if let endLocation = taxiRideCreationViewModel.endLocation{
               let distance = LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: endLocation.latitude, toLongitude: endLocation.longitude)
                if distance < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES{
                    UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                    return
                }
            }
            taxiRideCreationViewModel.startLocation = location
            taxiRideCreationViewModel.isRequiredToReloadData = true
            getAvailableNearbyTaxi(location: location)
            moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            if validateIsBookingForSome() {
                self.moveToTaxiBookingSomeOneView()
            }
        }else{
            if let startLocation = taxiRideCreationViewModel.startLocation{
               let distance = LocationClientUtils.getDistance(fromLatitude: startLocation.latitude, fromLongitude: startLocation.longitude, toLatitude: location.latitude, toLongitude: location.longitude)
                if distance < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES{
                    UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                    return
                }
            }
            taxiRideCreationViewModel.endLocation = location
        }
        getAvailableRoutes(routeId: nil)
        if fpc.position == FloatingPanelPosition.full{
          fpc.move(to: .half, animated: true)
        }
    }

    func getAvailableRoutes(routeId: Double?){

        clearRouteData()
        taxiRideCreationViewModel.distance = 0
        taxiRideCreationViewModel.routePaths.removeAll()
        getEstimatedFares(routeId: routeId)

    }
    func getEstimatedFares(routeId: Double?) {
        let wayPoints = getSelectedRouteWayPoints(routeId: routeId)
        if let routeId = routeId, let presentRouteId = taxiRideCreationViewModel.detailedEstimateFare?.routeId, routeId == presentRouteId{
            updateLocation()
            return
        } else {
            taxiRideCreationViewModel.detailedEstimateFare = nil
            taxiRideCreationViewModel.fareForVehicleDetail = []
        }
        taxiRideCreationViewModel.isTaxiDetailsFetchingFromServer = true
        taxiRideCreationBottomViewController.taxiRideDetailstableView.reloadData()
        taxiRideCreationViewModel.getAvailableTaxiData(routeId: routeId, wayPoints: wayPoints) { [weak self] (responseError, error) in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                self?.bottomView.isHidden = true
                if let isFromScheduleReturnRide = self?.taxiRideCreationViewModel.isFromScheduleReturnRide, !isFromScheduleReturnRide{
                    self?.taxiRideCreationViewModel.setStartTime()
                }
            }else{
                self?.drawMapComponents()
            }
            self?.updateLocation()
        }
    }

    func getSelectedRouteWayPoints(routeId: Double?) -> String?{
        guard let routeId = routeId else {
            return nil
        }
           let selectedRoute = taxiRideCreationViewModel.routePaths.first(where: { $0.routeId == routeId})
            return selectedRoute?.waypoints
    }


    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        taxiRideCreationViewModel.routePaths.append(route)
        taxiRideCreationViewModel.selectedRouteId = route.routeId ?? -1
        getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
        drawMapComponents()
    }

    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        if preferredRoute.fromLocation != nil{
            taxiRideCreationViewModel.startLocation?.latitude = preferredRoute.fromLatitude!
            taxiRideCreationViewModel.startLocation?.longitude = preferredRoute.fromLongitude!
            taxiRideCreationViewModel.startLocation?.address = preferredRoute.fromLocation!
            taxiRideCreationViewModel.startLocation?.shortAddress = preferredRoute.fromLocation!
            taxiRideCreationViewModel.isRequiredToReloadData = true
            if let location = taxiRideCreationViewModel.startLocation {
                getAvailableNearbyTaxi(location: location)
            }
        }
        if preferredRoute.toLocation != nil{
            taxiRideCreationViewModel.endLocation?.latitude = preferredRoute.toLatitude!
            taxiRideCreationViewModel.endLocation?.longitude = preferredRoute.toLongitude!
            taxiRideCreationViewModel.endLocation?.address = preferredRoute.toLocation!
            taxiRideCreationViewModel.endLocation?.shortAddress = preferredRoute.toLocation
        }
        taxiRideCreationViewModel.routePaths.removeAll()
        if let rideRoute = preferredRoute.rideRoute {
            taxiRideCreationViewModel.routePaths.append(rideRoute)
        }
        taxiRideCreationViewModel.selectedRouteId = preferredRoute.routeId ?? 0
        getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
        if fpc.position == FloatingPanelPosition.full{
          fpc.move(to: .half, animated: true)
        }
    }

    private func updateLocation(){
        updateTaxiDetails()
        taxiRideCreationViewModel.checkCityAndStateExistanceElseGetFromGeocoder()
        taxiRideCreationBottomViewController.taxiRideDetailstableView.reloadData()
        setUpUI()
    }

    func updateTaxiDetails(){
        if !taxiRideCreationViewModel.fareForVehicleDetail.isEmpty {
            bottomView.isHidden = false
            updateBookNowButtonUI()
            fpc.move(to: .half, animated: true)
        }
    }
}
//MARK: GMSMapViewDelegate
extension TaxiRideCreationMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            currentLocationButton.isHidden = false
        }else{
            currentLocationButton.isHidden = true
        }
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        AppDelegate.getAppDelegate().log.debug("changeRouteClicked")
        isTappedOnMarkerInfoOnMap = true
        if let rideRoute = taxiRideCreationViewModel.getSelectedRoute(){
            AppDelegate.getAppDelegate().log.debug("route found ")
        let taxiRideEditRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideEditRouteViewController") as! TaxiRideEditRouteViewController
            taxiRideEditRouteViewController.initialiseData(startLocation: taxiRideCreationViewModel.startLocation, endLocation: taxiRideCreationViewModel.endLocation, rideRoute: rideRoute, routeSelectionDelegate: self)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiRideEditRouteViewController, animated: false)
        }else{
            AppDelegate.getAppDelegate().log.debug("route not found")
        }
        return nil
    }
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        AppDelegate.getAppDelegate().log.debug("didTapOverlay")
        guard let polyline = overlay as? GMSPolyline,let routeId = polyline.userData as? Double else{
            return
        }
        if taxiRideCreationViewModel.selectedRouteId == routeId{
            return
        }
        taxiRideCreationViewModel.selectedRouteId = routeId
        drawMapComponents()
        getEstimatedFares(routeId: routeId)
    }
    private func moveToCoordinate(coordinate : CLLocationCoordinate2D){
        AppDelegate.getAppDelegate().log.debug("moveToCoordinate()")
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16))
//        let taxiMarkerAndRoutePolyline = addTaxiMarkerAndRoute(routePolyline: nil)
//        GoogleMapUtils.fitToScreen(route: taxiMarkerAndRoutePolyline, map: viewMap)
    }
}
//MARK: RouteReceiver
extension TaxiRideCreationMapViewController {

    func drawAllPossibleRoutesWithSelectedRoute(){

        AppDelegate.getAppDelegate().log.debug("drawAllPossibleRoutesWithSelectedRoute()")

        if taxiRideCreationViewModel.endLocation == nil || taxiRideCreationViewModel.endLocation?.latitude == nil || taxiRideCreationViewModel.endLocation?.longitude == nil || taxiRideCreationViewModel.routePaths.isEmpty {
            return
        }

        for polyline in routePolylines{
            polyline.map = nil
        }
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        routePolylines.removeAll()

        var routeIdToSelect = taxiRideCreationViewModel.selectedRouteId
        if routeIdToSelect == -1{
            if let fareForTaxis = taxiRideCreationViewModel.detailedEstimateFare?.fareForTaxis, !fareForTaxis.isEmpty, !fareForTaxis[0].fares.isEmpty, let routeId = fareForTaxis[0].fares[0].routeId
            {
                routeIdToSelect = Double(routeId) ?? taxiRideCreationViewModel.routePaths[0].routeId!
            }else{
                routeIdToSelect = taxiRideCreationViewModel.routePaths[0].routeId!
            }
        }
        for route in taxiRideCreationViewModel.routePaths {
            if route.routeId! == routeIdToSelect && route.overviewPolyline != nil{
                taxiRideCreationViewModel.distance = route.distance ?? 0
                drawUserRoute(rideRoute: route)
                displayTimeAndDistanceInfoView(routePathData: route)
            }else{
                let polyline = GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!, map: viewMap, colorCode: UIColor(netHex: 0x767676), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
                polyline.userData = route.routeId
                routePolylines.append(polyline)
            }
        }

    }
    func drawUserRoute(rideRoute : RideRoute )
    {
        guard let overViewPolyline = rideRoute.overviewPolyline else{
            return
        }
        prepareStartAndEndMarkers(isRequiredToShowEndMarker: true)
        selectedPolyLine = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: viewMap, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        selectedPolyLine!.userData = rideRoute.routeId
        routePolylines.append(selectedPolyLine!)
        let polyline = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: viewMap, colorCode: UIColor(netHex: 0x005BA4), width: GoogleMapUtils.POLYLINE_WIDTH_10, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
        routePolylines.append(polyline)
        let taxiMarkerAndRoutePolyline = addTaxiMarkerAndRoute(routePolyline: overViewPolyline)
        GoogleMapUtils.fitToScreen(route: taxiMarkerAndRoutePolyline, map: viewMap)
    }

    func drawMapComponents(){
        if taxiRideCreationViewModel.selectedOptionIndex == 1{
            showNearbyTaxi()
        }else {
            drawAllPossibleRoutesWithSelectedRoute()
            showNearbyTaxi()
        }
    }

}
extension TaxiRideCreationMapViewController: ReceiveBehalfBookingDetails{
    func receiveBehalfBookingDetails(commuteContactNo: String?, commutePassengerName: String?){
        taxiRideCreationViewModel.commuteContactNo = commuteContactNo
        taxiRideCreationViewModel.commutePassengerName = commutePassengerName
        showBehalfBookingViewIfRequired()
    }
}

