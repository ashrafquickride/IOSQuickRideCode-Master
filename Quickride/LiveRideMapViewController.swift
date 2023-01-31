//
//  LiveRideMapViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 11/14/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import Polyline
import GoogleMaps
import MessageUI
import FloatingPanel

class LiveRideMapViewController: UIViewController, MatchedUsersDataReceiver {

    //MARK: Outlets
    @IBOutlet weak var viewLeftNavigationItems: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var labelRideScheduledTime: UILabel!
    @IBOutlet weak var labelRideStatus: UILabel!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var buttonChat: CustomUIButton!
    @IBOutlet weak var buttonChatWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonMenu: CustomUIButton!
    @IBOutlet weak var buttonNoticicationIcon: CustomUIButton!
    @IBOutlet weak var buttonEmergency: UIButton!
    @IBOutlet weak var viewMapContainer: UIView!
    @IBOutlet weak var buttonCurrentLoc: UIButton!
    @IBOutlet weak var buttonGoogleMapNavigation: UIButton!
    @IBOutlet weak var buttonPendingNotification: UIButton!
    @IBOutlet weak var viewWalkPath: UIView!
    @IBOutlet weak var viewWalkPathHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWalkPathFomStartToPickUp: UIView!
    @IBOutlet weak var labelWalkPathDistanceFromStartToPickUp: UILabel!
    @IBOutlet weak var viewWalkPathFromDropToEnd: UIView!
    @IBOutlet weak var labelWalkPthDistanceFromDropToEnd: UILabel!
    @IBOutlet weak var imageViewWalkPathCarIcon: UIImageView!
    @IBOutlet weak var viewWalkPathWidthFromStartToPickUp: NSLayoutConstraint!
    @IBOutlet weak var viewWalkPathWidthFromDropToEnd: NSLayoutConstraint!
    @IBOutlet weak var viewNavigationBarItems: UIView!
    @IBOutlet weak var viewFirstRideCreatedInfo: UIView!
    @IBOutlet weak var labelFirstRideInfo1: UILabel!
    @IBOutlet weak var labelFirstRideInfo2: UILabel!
    @IBOutlet weak var mapUtilitiesBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideRequestAckView: UIView!
    @IBOutlet weak var rideRequestAckLabel: UILabel!
    @IBOutlet weak var viewUnreadMsg: UIView!
    @IBOutlet weak var unreadChatCountLabel: UILabel!
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    @IBOutlet weak var buttonRefresh: UIButton!
    @IBOutlet weak var firstRideAnimationView: AnimatedControl!
    @IBOutlet weak var topDataView: UIView!
    @IBOutlet weak var viewMapComponent: UIView!
    @IBOutlet weak var refreshButtonAnimationView: AnimatedControl!
    @IBOutlet weak var tripInsuranceView: UIView!
    @IBOutlet weak var walkPathCenterXSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tripInsuranceViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftNavigationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryCriticallyLowBackgroundView: UIView!
    @IBOutlet weak var batteryCriticallyLowView: UIView!
    @IBOutlet weak var lowBatteryImageView: UIView!
    @IBOutlet weak var vehicleView: UIView!
    @IBOutlet weak var riderImageView: UIImageView!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var ButtonCurrentLocWidth: NSLayoutConstraint!
    //MARK: TaxiPool
    @IBOutlet weak var taxiPoolIcon: UIImageView!
    @IBOutlet weak var rideDateAndTimeShowingCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var helpViewForTaxiPool: QuickRideCardView!

    //MARK: Relay ride
    @IBOutlet weak var firstRelayRideView: UIView!
    @IBOutlet weak var secondRelayRideView: UIView!

    //MARK: ride Action
    @IBOutlet weak var rideActionStackView: UIStackView!
    @IBOutlet weak var rideActionContainerView: UIView!
    @IBOutlet weak var labelRideActionTitle: UILabel!
    @IBOutlet weak var viewRideActionSlider: UIView!
    @IBOutlet weak var checkInAnimationView: AnimatedControl!
    @IBOutlet weak var rideConfirmationIsPendingInfoView: UIView!
    @IBOutlet weak var rideConfirmationInfoImageView: UIImageView!
    @IBOutlet weak var rideConfirmationTitleLabel: UILabel!
    @IBOutlet weak var rideConfirmationSubTitleLabel: UILabel!
    
    private var warningAlert : WarningAlertView?
    private var routeDeviationInfoViewController: RouteDeviationInfoViewController?

    //MARK: Properties
    weak var viewMap: GMSMapView!
    private var routeNavigationMarker: GMSMarker!
    private var locationUpdateMarker: GMSMarker!
    private var confirmPickPoint: GMSMarker?
    private var rideParticipantMarkers = [Double : RideParticipantElements]()
    private var dropMarkers = [GMSMarker]()
    private var pickUpMarkerImage : UIImage?
    private var pickupMarker: GMSMarker?
    private var matchedUsersMarkers = [GMSMarker]()
    private var liveRideViewModel = LiveRideViewModel()
    private var floatingPanelController: FloatingPanelController!
    private var liveRideCardViewController: LiveRideCardViewController!

    private var rideActionLabelCenter : CGPoint = CGPoint(x:0,y: 0)
    private var checkInActionSlideArrowCenter : CGPoint = CGPoint(x:0,y: 0)
    private let slideThersoldPercentage : CGFloat = 0.2
    private var transperentView = UIView()

    static let liveRideMapViewControllerKey = "LiveRideMapViewController"
    static let passengerIcon = ImageUtils.RBResizeImage(image: UIImage(named: "passenger_marker")!, targetSize: CGSize(width: 20, height: 20))
    static let carIcon = ImageUtils.RBResizeImage(image: UIImage(named: "car_marker")!, targetSize: CGSize(width: 20, height: 20))
    static let bikeIcon = ImageUtils.RBResizeImage(image: UIImage(named: "bike_marker")!, targetSize: CGSize(width: 25, height: 25))


    //MARK: Initializer
    func initializeDataBeforePresenting(riderRideId: Double, rideObj: Ride?, isFromRideCreation: Bool, isFreezeRideRequired: Bool, isFromSignupFlow: Bool,relaySecondLegRide: Ride?,requiredToShowRelayRide: String) {
        self.liveRideViewModel = LiveRideViewModel(riderRideId: riderRideId, rideObj: rideObj, isFromRideCreation: isFromRideCreation, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: isFromSignupFlow,relaySecondLegRide: relaySecondLegRide,requiredToShowRelayRide: requiredToShowRelayRide)
    }

    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        if !liveRideViewModel.isRideDataValid(){
            displayRideClosedDialogue()
            return
        }
        displayFirstRideCreationView()
        addLiveRideCardViewController()
        mapUtilitiesBottomSpaceConstraint.constant = (floatingPanelController.layout.insetFor(position: floatingPanelController.position) ?? 0) + 15
        viewMap = QRMapView.getQRMapView(mapViewContainer: viewMapContainer)
        viewLeftNavigationItems.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonClicked(_:))))
        batteryCriticallyLowBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(batteryCriticallyLowBackgroundViewTapped(_:))))
        progressSpinner.hidesWhenStopped = true
        self.view.addSubview(batteryCriticallyLowBackgroundView)
        self.view.addSubview(batteryCriticallyLowView)
        let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
        if emergencyContactNo == nil || emergencyContactNo!.isEmpty
        {
            AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
        }
        if AppDelegate.getAppDelegate().getEmergencyInitializer() != nil{
            buttonEmergency.backgroundColor = UIColor(netHex: 0xE20000)
            buttonEmergency.setImage(UIImage(named: "emergency_after_pressed"), for: UIControl.State.normal)
        }
        RideViewUtils.displaySubscriptionDialogueBasedOnStatus()
        tripInsuranceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(insuranceViewTapped(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        guard let ride = liveRideViewModel.currentUserRide , let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance() else {
            goBackToCallingViewController()
            return
        }
        myActiveRidesCache.addRideUpdateListener(listener: self,key: MyActiveRidesCache.LiveRideMapViewController_key)
        NotificationStore.getInstance().addNotificationListChangeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey, listener: self)
        if ride.rideType == Ride.RIDER_RIDE {
            NotificationCenter.default.addObserver(self, selector: #selector(checkLocationUpdateStatusAndDisplayAlert), name: .locationUpdateSatatus, object: nil)
            checkLocationUpdateStatusAndDisplayAlert()
        }
        if ride.status == Ride.RIDE_STATUS_STARTED {
            FaceBookEventsLoggingUtils.logViewedContentEvent(contentType: "", contentData: "LiveRideScreen", contentId: "", currency: "", price: 0)
        }
        viewWalkPath.isHidden = true
        self.viewWalkPathHeightConstraint.constant = 0
        displayFirstRideCreationView()

        let riderRideId = liveRideViewModel.getRiderRideId()
        if  riderRideId != 0 {
            RidesGroupChatCache.getInstance()?.addRideGroupChatListener(rideId: riderRideId, listener: self)
            checkNewMessage()
        }
        LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
        setUpUI()
        addNotificationObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(rideActionStackView)
        guard liveRideViewModel.currentUserRide != nil , MyActiveRidesCache.getRidesCacheInstance() != nil else {
            goBackToCallingViewController()
            return
        }
        if !liveRideViewModel.isRideDetailInfoRetrieved {
            if liveRideViewModel.getRiderRideId() == 0 {
                handleRequestedRide()
                    liveRideCardViewController.handleRequestedRide()
            }else{
                handleScheduleRide()
            }
        }
        if liveRideViewModel.requiredToShowRelayRide == RelayRideMatch.SHOW_FIRST_RELAY_RIDE && liveRideViewModel.secondRelayRide != nil{
            secondRelayRideView.isHidden = false
            firstRelayRideView.isHidden = true
        }else if liveRideViewModel.requiredToShowRelayRide == RelayRideMatch.SHOW_SECOND_RELAY_RIDE && liveRideViewModel.firstRelayRide != nil{
            secondRelayRideView.isHidden = true
            firstRelayRideView.isHidden = false
        }else{
            secondRelayRideView.isHidden = true
            firstRelayRideView.isHidden = true
        }
        handleNotificationCountAndDisplay()
        handleVisibilityOfRideConfirmationIsPendingInfoView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        liveRideViewModel.stopLocationUpates()
    }

    private func addLiveRideCardViewController(){
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

        liveRideCardViewController = storyboard?.instantiateViewController(withIdentifier: "LiveRideCardViewController") as? LiveRideCardViewController
        liveRideCardViewController.initializeDataBeforePresenting(liveRideViewModel: liveRideViewModel)

        // Set a content view controller
        floatingPanelController.set(contentViewController: liveRideCardViewController)
        floatingPanelController.track(scrollView: liveRideCardViewController.liveRideTableView)
        floatingPanelController.addPanel(toParent: self, animated: true)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: liveRideCardViewController.liveRideTableView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
    }
    

    @objc func rideInvitationsUpdated(_ notification: Notification){
        handleVisibilityOfRideConfirmationIsPendingInfoView()
    }
    
    private func handleVisibilityOfRideConfirmationIsPendingInfoView(){
        guard  liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE else {
            rideConfirmationIsPendingInfoView.isHidden = true
            return
        }
        if liveRideViewModel.getPaymentPendingRideCountForPassengerRide() > 0 {
            rideConfirmationIsPendingInfoView.isHidden = false
            rideConfirmationIsPendingInfoView.backgroundColor = UIColor(netHex: 0xCC1419)
            rideConfirmationInfoImageView.image = UIImage(named: "info_circular")
            rideConfirmationTitleLabel.text = Strings.payment_pending
            rideConfirmationTitleLabel.textColor = .white
            rideConfirmationSubTitleLabel.textColor = .white
            if liveRideViewModel.getPaymentPendingRideCountForPassengerRide() > 1 {
                rideConfirmationSubTitleLabel.text = String(liveRideViewModel.getPaymentPendingRideCountForPassengerRide()) + " " + Strings.ride_givers_accepted_info
            }else {
                rideConfirmationSubTitleLabel.text =  Strings.ride_giver_accepted_info
            }
        }else if liveRideViewModel.getOutGoingInvitesCount() > 0, liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_REQUESTED {
            rideConfirmationIsPendingInfoView.isHidden = false
            rideConfirmationIsPendingInfoView.backgroundColor = UIColor(netHex: 0xF6D155)
            rideConfirmationInfoImageView.image = UIImage(named: "icon_bulb_hint_info")
            rideConfirmationTitleLabel.text = Strings.please_note
            rideConfirmationSubTitleLabel.text = Strings.ride_confirmation_is_pending
            rideConfirmationTitleLabel.textColor = .black
            rideConfirmationSubTitleLabel.textColor = .black
        }else {
            rideConfirmationIsPendingInfoView.isHidden = true
        }
    }

    //MARK: Methods
    private func setUpUI() {
        buttonCurrentLoc.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonCurrentLoc.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonGoogleMapNavigation.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonGoogleMapNavigation.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonRefresh.addTarget(self, action:#selector(HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonRefresh.addTarget(self, action:#selector(HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonMenu.changeBackgroundColorBasedOnSelection()
        buttonChat.changeBackgroundColorBasedOnSelection()
        buttonNoticicationIcon.changeBackgroundColorBasedOnSelection()
        ViewCustomizationUtils.addCornerRadiusToView(view: tripInsuranceView, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: tripInsuranceView, borderWidth: 1.0, color: UIColor(netHex: 0x007AFF))
        ViewCustomizationUtils.addBorderToView(view: buttonPendingNotification, borderWidth: 2.0, color: UIColor.white)
        ViewCustomizationUtils.addBorderToView(view: viewUnreadMsg, borderWidth: 2.0, color: UIColor.white)
        rideActionStackView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        NotificationCenter.default.addObserver(self, selector: #selector(rideInvitationsUpdated), name: .rideMatchesUpdated, object: nil)
    }


    private func handleRequestedRide(){
        AppDelegate.getAppDelegate().log.debug("handleRequestedRide()")
        let passengerRideId = liveRideViewModel.currentUserRide?.rideId
        liveRideViewModel.currentUserRide =  MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: passengerRideId!)
        if !liveRideViewModel.isRideDataValid() {
            goBackToCallingViewController()
            return
        }
        liveRideViewModel.updateIsModerator()
        progressSpinner.isHidden = true
        progressSpinner.stopAnimating()
        liveRideViewModel.rideDetailInfo = nil
        updateRideViewControlsAsPerStatus()
        displayRideScheduledTime()
        self.displayRideStatusAndFareDetailsToUser(status: Ride.RIDE_STATUS_REQUESTED)
        refreshMapWithNewData()
        handleZoomBasedOnStatus()
    }


    private func handleScheduleRide() {
        progressSpinner.startAnimating()
        let rideParticipantLocations = liveRideViewModel.rideDetailInfo?.rideParticipantLocations
        liveRideViewModel.getRideDetailInfo { [weak self] ( responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            self?.progressSpinner.stopAnimating()
            self?.showHideTaxiPoolIcon()
            if responseError != nil || error != nil {
                self?.onRetrievalFailure(responseError: responseError, error: error)
            }else {
                self?.liveRideViewModel.rideDetailInfo?.rideParticipantLocations = rideParticipantLocations
                self?.liveRideViewModel.isRideDetailInfoRetrieved = true
                self?.receiveRideDetailInfo()
                self?.liveRideViewModel.startLocationUpates()
            }
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func showHideTaxiPoolIcon() {
        if self.liveRideViewModel.taxiRideId != 0 {
            taxiPoolIcon.isHidden = false
            labelRideStatus.text = ""
            rideDateAndTimeShowingCenterConstraint.constant = -2
            buttonChat.isHidden = true
            buttonChatWidthConstraint.constant = 0
            if ((liveRideViewModel.rideDetailInfo?.taxiShareRide?.driverName) != nil) {
                guard let taxishareRide = liveRideViewModel.rideDetailInfo?.taxiShareRide else {
                    return
                }
                let pickupTime = getPickUPTime(taxiShareRide: taxishareRide)

                labelRideScheduledTime.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa)!
            }
        } else {
            taxiPoolIcon.isHidden = true
        }
    }

     private func getPickUPTime(taxiShareRide: TaxiShareRide) -> Double{
          for data in taxiShareRide.taxiShareRidePassengerInfos ?? [] {
              if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0"){
                  return data.pickUpTime ?? 0
              }
          }
          return 0
      }

    func receiveRideDetailInfo() {

        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()

        guard liveRideViewModel.isRideDataValid(),let status = liveRideViewModel.getCurrentUserStatusImRide() else {
            self.displayRideClosedDialogue()
            return
        }
        if status == Ride.RIDE_STATUS_COMPLETED && liveRideViewModel.currentUserRide!.rideType == Ride.PASSENGER_RIDE{
            completePassengerRide()
            return
        }
        if status == Ride.RIDE_STATUS_COMPLETED && liveRideViewModel.currentUserRide!.rideType == Ride.RIDER_RIDE{
            RideManagementUtils.completeRiderRide(riderRideId: liveRideViewModel.getRiderRideId(), targetViewController: self, rideActionCompletionDelegate: nil)
            return
        }
        updateRideViewMapWithRideData()
        MyActiveRidesCache.singleCacheInstance?.addRideUpdateListener(listener: self,key: MyActiveRidesCache.LiveRideMapViewController_key)
            liveRideCardViewController.handleScheduleRide()
        self.loadRideParticipantMarkers()
        if liveRideViewModel.taxiRideId == 0 {
            liveRideViewModel.isParticipantlocationLoaded = false
            liveRideViewModel.loadRideParticipantLocations {
                guard let rideDetailInfo = self.liveRideViewModel.rideDetailInfo,let rideParticipantLocations = rideDetailInfo.rideParticipantLocations else {return}
                self.handleETAForRider()
                self.handleETAForPassenger()
                self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())
                self.initializeWalkMarker()
                self.handleZoomBasedOnStatus()
                self.liveRideCardViewController.handleRideParticipantLocations(rideParticipantLocations : rideParticipantLocations)
            }
        }
        showGreetingBasedOnCriteria()
    }

    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {

        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: ViewControllerUtils.getCenterViewController()) { result in
            self.goBackToCallingViewController()
        }

    }


    private func refreshMapWithNewData()
    {
        guard let currentRide = liveRideViewModel.currentUserRide else { return }
        viewMap.delegate = self
        self.viewMap.clear()
        routeNavigationMarker?.map = nil
        routeNavigationMarker = nil
        confirmPickPoint?.map = nil
        confirmPickPoint = nil
        passengerWalkMarker?.map = nil
        passengerWalkMarker = nil
        passengerWalkETAMarker?.map = nil
        passengerWalkETAMarker = nil
        clearLocationUpdateMarker()
        liveRideViewModel.updateIsModerator()
        viewMap.isMyLocationEnabled = false
        if(currentRide.rideType == Ride.PASSENGER_RIDE && currentRide.status == Ride.RIDE_STATUS_REQUESTED ) {
            drawRoutePathAndAddMarkersForRequestedRide()
        } else if (currentRide.rideType == Ride.PASSENGER_RIDE && currentRide.status == Ride.RIDE_STATUS_STARTED ) {
            drawPassengerRouteWithWalkingdropToEndDistance()
        }else {
            drawRoutePathAndAddMarkersForScheduledRide()
        }
        viewMap.isTrafficEnabled = false
        handleZoomBasedOnStatus()
    }

    //MARK: Displaying first ride creation animation coming from Signup flow
    private func displayFirstRideCreationView() {
        if liveRideViewModel.isFromSignupFlow {
            self.viewFirstRideCreatedInfo.isHidden = false
            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0x00b557)
            self.labelFirstRideInfo1.text = "Cool! You have created your first ride"
            self.labelFirstRideInfo2.text = "Finding rides for you..."
            firstRideAnimationView.animationView.animation = Animation.named("signup_like")
            firstRideAnimationView.animationView.play()
            firstRideAnimationView.animationView.loopMode = .loop
            self.buttonGoogleMapNavigation.isHidden = true
            self.buttonEmergency.isHidden = true
            helpViewForTaxiPool.isHidden = true
            self.viewNavigationBarItems.isHidden = true
            self.buttonRefresh.isHidden = true
        }
        else{
            self.unhidingOfUtilities()
            displayNoConnectionDialogue()
        }
    }

    private func unhidingOfUtilities(){
        liveRideViewModel.isFromSignupFlow = false
        firstRideAnimationView.animationView.stop()
        self.viewFirstRideCreatedInfo.isHidden = true
        self.buttonGoogleMapNavigation.isHidden = false
        self.viewNavigationBarItems.isHidden = false
        self.buttonRefresh.isHidden = false
    }

    //MARK: No internet connection dialogue
    private func displayNoConnectionDialogue(){
        InternetTrackerUtils().checkInternetAvailability(viewController: self) { (value) in
            if value{
                self.viewWalkPath.isHidden = true
                self.viewWalkPathHeightConstraint.constant = 0
            }
            else{
                if let ride = self.liveRideViewModel.currentUserRide, ride.rideType == Ride.PASSENGER_RIDE && (ride.status == Ride.RIDE_STATUS_SCHEDULED || ride.status == Ride.RIDE_STATUS_STARTED || ride.status == Ride.RIDE_STATUS_DELAYED) && !self.liveRideViewModel.isWalkPathViewHidden {
                    if  !self.liveRideViewModel.isMapFullView{
                        self.viewWalkPath.isHidden = false
                    }
                    self.viewWalkPathHeightConstraint.constant = 40
                }
                else{
                    self.viewWalkPath.isHidden = true
                    self.viewWalkPathHeightConstraint.constant = 0
                }
            }
        }
    }
    func completePassengerRide() {
        if let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide {
            if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0  {
                MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
                RideManagementUtils.completePassengerRide(riderRideId: passengerRide.riderRideId, passengerRideId: passengerRide.rideId,
                                                          userId: passengerRide.userId, targetViewController: self,
                                                          rideCompletionActionDelegate: nil)
            }else{
                MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
                RideManagementUtils.getPassengerBill(riderRideId: passengerRide.taxiRideId!, passengerRideId: passengerRide.rideId, userId: passengerRide.userId, targetViewController: self, rideCompletionActionDelegate: nil)
            }
        }
    }


    //MARK: Draw User Route
    private func drawRoutePathAndAddMarkersForRequestedRide(){
        AppDelegate.getAppDelegate().log.debug("drawRoutePathAndAddMarkersForRequestedRide()")
        guard let ride = liveRideViewModel.currentUserRide else { return }
        let start = CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude)
        let end = CLLocationCoordinate2D(latitude: (ride.endLatitude)!, longitude: (ride.endLongitude)!)
        GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start,end : end,route: ride.routePathPolyline, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_5)
    }
    
    private func drawPassengerRouteWithWalkingdropToEndDistance() {
        AppDelegate.getAppDelegate().log.debug("drawPassengerRouteWithWalkingdropToEndDistance()")
        if let riderRide = liveRideViewModel.rideDetailInfo?.riderRide {
            guard let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide  else { return }
            let start = CLLocationCoordinate2D(latitude: riderRide.startLatitude, longitude: riderRide.startLongitude)
            let end = CLLocationCoordinate2D(latitude: riderRide.endLatitude!, longitude: riderRide.endLongitude!)
            GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start, end: end, route: riderRide.routePathPolyline, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_7)
            GoogleMapUtils.drawPassengerRouteWithWalkingdropToEndDistance(rideId: passengerRide.rideId, useCase: "iOS.App.Passenger.WalkRoute.RideView", riderRoutePolyline: riderRide.routePathPolyline,passengerRoutePolyline:passengerRide.routePathPolyline,passengerEnd: CLLocation(latitude: passengerRide.endLatitude!, longitude: passengerRide.endLongitude!),drop: CLLocation(latitude: passengerRide.dropLatitude, longitude: passengerRide.dropLongitude), passengerRideDistance: passengerRide.distance!, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
                self.initializeWalkPathView(distance: cumalativeDistance!)
            })
        }
    }

    private func drawRoutePathAndAddMarkersForScheduledRide() {
        AppDelegate.getAppDelegate().log.debug("drawRoutePathAndAddMarkersForScheduledRide()")

        if let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide{
            if passengerRide.taxiRideId != nil && liveRideViewModel.rideDetailInfo?.taxiShareRide != nil {
                GoogleMapUtils.drawPassengerPathWithDrop(riderRoutePolyline: liveRideViewModel.rideDetailInfo?.taxiShareRide?.routePathPolyline ?? "", passengerRide: passengerRide, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_7)
                    return
            }
            if let riderRide = liveRideViewModel.rideDetailInfo?.riderRide {
                if liveRideViewModel.isModerator {
                        let start = CLLocationCoordinate2D(latitude: riderRide.startLatitude, longitude: riderRide.startLongitude)
                        let end = CLLocationCoordinate2D(latitude: riderRide.endLatitude!, longitude: riderRide.endLongitude!)
                        GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start, end: end, route: riderRide.routePathPolyline, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_7)
                } else {
                    if let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide {
                        GoogleMapUtils.drawPassengerPathFromPickToDrop(riderRoutePolyline: riderRide.routePathPolyline,passengerRide: passengerRide, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_7)
                        GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: passengerRide.rideId, useCase: "iOS.App.Passenger.WalkRoute.RideView", riderRoutePolyline: riderRide.routePathPolyline,passengerRoutePolyline:passengerRide.routePathPolyline,passengerStart: CLLocation(latitude: passengerRide.startLatitude, longitude: passengerRide.startLongitude),passengerEnd: CLLocation(latitude: passengerRide.endLatitude!, longitude: passengerRide.endLongitude!), pickup: CLLocation(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude), drop: CLLocation(latitude: passengerRide.dropLatitude, longitude: passengerRide.dropLongitude), passengerRideDistance: passengerRide.distance!, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
                            self.initializeWalkPathView(distance: cumalativeDistance!)
                        })
                    }
                }
                if liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_STARTED && liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED{
                    let location = CLLocationCoordinate2D(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude)
                    confirmPickPoint = GoogleMapUtils.addMarker(googleMap: viewMap, location: location, shortIcon: UIImage(named: "ic_edit_pickup")!, tappable: true, anchor: CGPoint(x: 0.5, y: 0.5))
                    confirmPickPoint?.zIndex = 10
                    confirmPickPoint?.isFlat = true
                }else{
                    let location = CLLocationCoordinate2D(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude)
                    GoogleMapUtils.addMarker(googleMap: viewMap, location: location, shortIcon: ImageUtils.RBResizeImage(image: UIImage(named: "green")!, targetSize: CGSize(width: 28,height: 28)),tappable: false)
                }
            }
        }else{
            let rideObj = liveRideViewModel.currentUserRide
            let start = CLLocationCoordinate2D(latitude: (rideObj?.startLatitude)!, longitude: (rideObj?.startLongitude)!)
            let end = CLLocationCoordinate2D(latitude: (rideObj?.endLatitude)!, longitude: (rideObj?.endLongitude)!)
            GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start, end: end, route: (rideObj?.routePathPolyline)!, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_7)
        }

    }

    //MARK: Showing walkpath view
    func initializeWalkPathView(distance : CummulativeTravelDistance){


        if distance.passengerStartToPickup > 0.01 && distance.passengerDropToEnd > 0.01{
            liveRideViewModel.isWalkPathViewHidden = false
            if !liveRideViewModel.isMapFullView{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFomStartToPickUp.isHidden = false
            viewWalkPathWidthFromStartToPickUp.constant = 100
            labelWalkPathDistanceFromStartToPickUp.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerStartToPickup)
            setTintedIconToWalkPathView()
            viewWalkPathFromDropToEnd.isHidden = false
            viewWalkPathWidthFromDropToEnd.constant = 100
            labelWalkPthDistanceFromDropToEnd.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerDropToEnd)
            setWalkPathCenterXConstraint(value: -135)


        }else if distance.passengerStartToPickup > 0.01{
            liveRideViewModel.isWalkPathViewHidden = false
            if !liveRideViewModel.isMapFullView{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFomStartToPickUp.isHidden = false
            viewWalkPathWidthFromStartToPickUp.constant = 100
            setTintedIconToWalkPathView()
            labelWalkPathDistanceFromStartToPickUp.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerStartToPickup)

            viewWalkPathFromDropToEnd.isHidden = true
            viewWalkPathWidthFromDropToEnd.constant = 0
            setWalkPathCenterXConstraint(value: -80)
        }else if distance.passengerDropToEnd > 0.01{
            liveRideViewModel.isWalkPathViewHidden = false
            if !liveRideViewModel.isMapFullView{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFromDropToEnd.isHidden = false
            viewWalkPathWidthFromDropToEnd.constant = 100
            setTintedIconToWalkPathView()
            labelWalkPthDistanceFromDropToEnd.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerDropToEnd)
            viewWalkPathFomStartToPickUp.isHidden = true
            viewWalkPathWidthFromStartToPickUp.constant = 0
            setWalkPathCenterXConstraint(value: -80)

        }else{
            if tripInsuranceView.isHidden{
                liveRideViewModel.isWalkPathViewHidden = true
                viewWalkPath.isHidden = true
                self.viewWalkPathHeightConstraint.constant = 0
            }else{
                liveRideViewModel.isWalkPathViewHidden = false
                viewWalkPath.isHidden = false
                self.viewWalkPathHeightConstraint.constant = 40
                walkPathCenterXSpaceConstraint.constant = -100
            }
            viewWalkPathFomStartToPickUp.isHidden = true
            viewWalkPathWidthFromStartToPickUp.constant = 0
            viewWalkPathFromDropToEnd.isHidden = true
            viewWalkPathWidthFromDropToEnd.constant = 0
            imageViewWalkPathCarIcon.isHidden = true
        }
    }
    var passengerWalkMarker : GMSMarker?
    var passengerWalkETAMarker : GMSMarker?
    func initializeWalkMarker(){

        guard (liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_DELAYED || liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_SCHEDULED), let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide,let location =  liveRideViewModel.rideDetailInfo?.getRideParticipantLocation(userId: UserDataCache.getCurrentUserId()),  passengerRide.pickupTime - NSDate().getTimeStamp() < 15*60*1000 else {
            passengerWalkMarker?.map = nil
            passengerWalkMarker = nil
            passengerWalkETAMarker?.map = nil
            passengerWalkETAMarker = nil
            return
        }
        let distance = LocationClientUtils.getDistance(fromLatitude: location.latitude!, fromLongitude: location.longitude!, toLatitude: passengerRide.pickupLatitude, toLongitude: passengerRide.pickupLongitude)

        let position = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
        if passengerWalkMarker == nil {
            passengerWalkMarker = GMSMarker(position: position)
            passengerWalkMarker?.map = viewMap
            passengerWalkMarker?.icon = UIImage(named: "ic_walk_navigation")
            passengerWalkMarker?.zIndex = 15
            passengerWalkMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            passengerWalkMarker?.isFlat = true
            passengerWalkMarker?.isTappable = true
        }else{
            passengerWalkMarker?.position = position
        }
        let walkETAView = UIView.loadFromNibNamed(nibNamed: "WalkETAView") as! WalkETAView
        walkETAView.initailizeView(distance: distance)
        guard let icon = ViewCustomizationUtils.getImageFromUIView(view: walkETAView) else {
            return
        }
        if passengerWalkETAMarker != nil {
            passengerWalkETAMarker?.icon = icon
            passengerWalkETAMarker?.position = position
        }else{
            passengerWalkETAMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: position, shortIcon: icon, tappable: true, anchor: CGPoint(x: 0.0, y: 1.0))
            passengerWalkETAMarker?.zIndex = 10
            passengerWalkETAMarker?.isFlat = true
            passengerWalkETAMarker?.isTappable = true
        }
    }

    func setWalkPathCenterXConstraint(value : CGFloat){
        if tripInsuranceView.isHidden{
            walkPathCenterXSpaceConstraint.constant = -60
        }else{
            walkPathCenterXSpaceConstraint.constant = value
        }
    }


    func setTintedIconToWalkPathView(){

        imageViewWalkPathCarIcon.isHidden = false
        guard let riderRide = liveRideViewModel.rideDetailInfo?.riderRide else {
            return
        }
        if riderRide.vehicleType ==  Vehicle.VEHICLE_TYPE_BIKE{
            imageViewWalkPathCarIcon.image = UIImage(named : "motorbike")
        }else{
            imageViewWalkPathCarIcon.image = UIImage(named : "car_new")
        }
    }

    private func updateRideViewMapWithRideData(){

        if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_COMPLETED{
            return
        }
        updateRideViewControlsAsPerStatus()
        displayRideScheduledTime()
        MyActiveRidesCache.getRidesCacheInstance()!.addRideLocationChangeListener(rideParticipantLocationListener: self, key: MyActiveRidesCache.LiveRideMapViewController_key)
        displayRideStatusAndFareDetailsToUser(status: liveRideViewModel.currentUserRide!.status)
        refreshMapWithNewData()
        checkNewMessage()
    }

    func displayRideStatusAndFareDetailsToUser(status : String){
        guard let ride = liveRideViewModel.currentUserRide else { return }
        if liveRideViewModel.taxiRideId != 0 {
            return
        }
        let fare = liveRideViewModel.getFareDetails()
        if fare > 0{
            self.labelRideStatus.text = RideViewUtils().getRideStatusAsTitle(status: status, rideType: ride.rideType!) + " | " + StringUtils.getStringFromDouble(decimalNumber: fare) + " Pts"
        }
        else{
            self.labelRideStatus.text = RideViewUtils().getRideStatusAsTitle(status: status,rideType: ride.rideType!)
        }
    }

    private func displayRideScheduledTime(){
        self.labelRideScheduledTime.text = RideViewUtils.getRideStartTime(ride: liveRideViewModel.currentUserRide!,format: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa)
    }

    @objc private func checkLocationUpdateStatusAndDisplayAlert() {
        DispatchQueue.main.async {
            let locationStatus = LocationChangeListener.getInstance().currentLocationUpdateStatus
            if locationStatus == LocationStatus.LocationDenied {
                self.displayWarningAlert(backGroundColor: UIColor.red, warningIncon: UIImage(named: "location_off_icon") ?? UIImage(), warningTitle: Strings.location_service_off_title, warningMessage: Strings.location_service_off_msg, actionMessage: Strings.go_to_settings)
            } else if locationStatus == LocationStatus.BatteryCriticallyLow {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = false
                self.batteryCriticallyLowView.isHidden = false
                ViewCustomizationUtils.addCornerRadiusToView(view: self.lowBatteryImageView, cornerRadius: self.lowBatteryImageView.frame.height / 2)
                ViewCustomizationUtils.addCornerRadiusToView(view: self.batteryCriticallyLowView, cornerRadius: 8.0)
            } else if locationStatus == LocationStatus.BatteryLow {
                self.displayWarningAlert(backGroundColor: UIColor(netHex: 0xE7782F), warningIncon: UIImage(named: "battery_low_warning") ?? UIImage(), warningTitle: Strings.phone_battery_low_title, warningMessage: Strings.phone_battery_low_msg, actionMessage: nil)
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            } else if locationStatus == LocationStatus.BatteryOk {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            } else {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            }
        }
    }

    private func displayWarningAlert(backGroundColor : UIColor,warningIncon : UIImage,warningTitle : String? ,warningMessage : String?, actionMessage: String?) {
        warningAlert?.removeFromSuperview()
        self.batteryCriticallyLowBackgroundView.isHidden = true
        self.batteryCriticallyLowView.isHidden = true
        warningAlert = Bundle.main.loadNibNamed("WarningAlertView", owner: self, options: nil)?[0] as? WarningAlertView
        warningAlert!.frame = CGRect(x: 0, y: topDataView.frame.maxY, width: self.view.frame.size.width, height: 88)
        warningAlert!.initializeViews(backGroundColor: backGroundColor, warningIncon: warningIncon, warningTitle: warningTitle, warningMessage: warningMessage, actionMessage: actionMessage, handler: { (action) in
            if action == Strings.go_to_settings {
                if let settingsUrl = NSURL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl as URL) {
                    UIApplication.shared.open(settingsUrl as URL, options: [:], completionHandler: nil)
                }
            }
        })
        view.addSubview(warningAlert!)
        view!.layoutIfNeeded()
    }

    @objc func HoldButton(_ sender: UIButton){
        sender.backgroundColor = UIColor.lightGray
    }

    @objc func HoldRelease(_ sender: UIButton){
        sender.backgroundColor = UIColor.white
    }

    private func handleNotificationCountAndDisplay(){
        let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0 {
            buttonPendingNotification.isHidden = false
            buttonPendingNotification.setTitle(String(pendingNotificationCount), for: .normal)
        } else {
            buttonPendingNotification.isHidden = true
        }
    }

    private func continueRefreshAction(ride: Ride) {
        if ride.rideType == Ride.PASSENGER_RIDE {
            if (ride as! PassengerRide).riderRideId == 0{
                let syncPassengerActiveRideTask = SyncPassengerActiveRideTask(userId: ride.userId, rideId: ride.rideId, status: ride.status, passengerActiveRideReceive: { (passengerRide) in
                    if passengerRide != nil
                    {
                        self.syncPassengerData(passengerRide : passengerRide!)
                    }
                    self.refreshButtonAnimationView.isHidden = true
                    self.refreshButtonAnimationView.animationView.stop()
                })
                syncPassengerActiveRideTask.getPassengerRide()
            }else{
                MyActiveRidesCache.getRidesCacheInstance()?.removeRideDetailInformationForRiderRide(riderRideId: liveRideViewModel.getRiderRideId())
                handleScheduleRide()
            }
        }else{
            MyActiveRidesCache.getRidesCacheInstance()?.removeRideDetailInformationForRiderRide(riderRideId: liveRideViewModel.getRiderRideId())
            handleScheduleRide()
        }
    }

    private func syncPassengerData( passengerRide: PassengerRide)
    {
        if passengerRide.riderRideId != 0{
            let newRideStatus = RideStatus(ride: passengerRide)
            MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: newRideStatus)
        }

    }

    private func showGreetingBasedOnCriteria(){
        if liveRideViewModel.taxiRideId != 0 {
            return
        }
        guard let ride = liveRideViewModel.currentUserRide, let userDataCache = UserDataCache.getInstance() else {
            return
        }
        var type : String?

        if ride.rideType == Ride.PASSENGER_RIDE && ride.status  == Ride.RIDE_STATUS_SCHEDULED {
            if let pickupTime = (ride as? PassengerRide)?.pickupTime, pickupTime - NSDate().getTimeStamp() <= 10*60*1000 {
                if !userDataCache.getEntityDisplayStatus(key: UserDataCache.WELCOME_GREETING) && (SharedPreferenceHelper.getRideId() == nil || SharedPreferenceHelper.getRideId() != ride.rideId){
                    type = Strings.welcome
                }
            }

        }else if ride.rideType == Ride.PASSENGER_RIDE && ride.status == Ride.RIDE_STATUS_STARTED {
            if !userDataCache.getEntityDisplayStatus(key: UserDataCache.THANKYOU_GREETING) && (SharedPreferenceHelper.getRiderRideId() == nil || SharedPreferenceHelper.getRiderRideId() != liveRideViewModel.rideDetailInfo?.riderRide?.rideId){
                type = Strings.thank_you_greeting
            }
        }

        if type != nil, let greetingDetails = UserCoreDataHelper.getGreetingDetails(type: type!), greetingDetails.displayedCount < 3{
            if type == Strings.welcome{
                SharedPreferenceHelper.storeRideId(rideId: ride.rideId)
                userDataCache.updateEntityDisplayStatus(key: UserDataCache.WELCOME_GREETING, status: true)
            } else if type == Strings.thank_you_greeting{
                SharedPreferenceHelper.storeRiderRideId(riderRideId: liveRideViewModel.rideDetailInfo?.riderRide?.rideId)
                userDataCache.updateEntityDisplayStatus(key: UserDataCache.THANKYOU_GREETING, status: true)
            }
            greetingDetails.displayedCount += 1
            UserCoreDataHelper.saveGreetingDetails(greetingDetails: [greetingDetails])
            if let gifImageURL = greetingDetails.gifImageUrl{
                let greetingDisplayView = GreetingDisplayView.loadFromNibNamed(nibNamed: "GreetingDisplayView",bundle: nil) as! GreetingDisplayView
                DispatchQueue.main.async {
                    ImageCache.getInstance().getGifImageFromCache(gifUrl: gifImageURL) { (image, imageURI) in
                        if image != nil {
                            let yPosition: CGFloat?
                            if  self.liveRideViewModel.isMapFullView{
                                yPosition = 10
                            } else {
                                yPosition = self.topDataView.frame.origin.y
                            }
                            greetingDisplayView.initializeViews(greetingDetails: greetingDetails, image: image, x: 0, y: yPosition!,viewController: self) {
                                greetingDetails.displayedCount = 3
                                UserCoreDataHelper.saveGreetingDetails(greetingDetails: [greetingDetails])
                            }
                        }
                    }
                }
            }
        }
    }

    //MARK: Participant status change
    func handleRiderStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleRiderStatusChange")
        liveRideViewModel.getRideDetailInfo { (responseError, error) in

        }
        guard let currentUserRide = liveRideViewModel.currentUserRide else {
            return
        }

        let newRideStatus : String = rideStatus.status!
        if Ride.RIDE_STATUS_STARTED == newRideStatus{

            loadRideParticipantMarkers()
            self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())
            handleETAForRider()
            handleETAForPassenger()

        } else if Ride.RIDE_STATUS_DELAYED == newRideStatus {
           loadRideParticipantMarkers()
            self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())
        } else if Ride.RIDE_STATUS_CANCELLED == newRideStatus {
            if self.liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE{
                handleRequestedRide()
                liveRideCardViewController.handleRiderStatusChange(rideStatus :  rideStatus)
            }else{
                goBackToCallingViewController()
            }
        }else if Ride.RIDE_STATUS_COMPLETED == newRideStatus {

            if currentUserRide.rideType == Ride.PASSENGER_RIDE {

                if currentUserRide.status == Ride.RIDE_STATUS_STARTED || currentUserRide.status == Ride.RIDE_STATUS_COMPLETED{
                    completePassengerRide()
                    return
                }else if currentUserRide.status == Ride.RIDE_STATUS_SCHEDULED{
                    goBackToCallingViewController()
                    return
                }
            }
        }
        displayRideStatusAndFareDetailsToUser(status: newRideStatus)
        liveRideCardViewController.handleRiderStatusChange(rideStatus: rideStatus)
    }

    func handlePassengerStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handlePassengerStatusChange")
        let newRideStatus : String = rideStatus.status!

        liveRideViewModel.getRideDetailInfo { (responseError, error) in

        }
        guard let currentUserRide = liveRideViewModel.currentUserRide else {
            return
        }


        if Ride.RIDE_STATUS_SCHEDULED == newRideStatus{
            if rideStatus.userId == currentUserRide.userId{
                handleScheduleRide()
                return
            }else{
                loadRideParticipantMarkers()
            }
            showGreetingBasedOnCriteria()
        } else if Ride.RIDE_STATUS_STARTED == newRideStatus{

            loadRideParticipantMarkers()
            self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())

            handleETAForRider()
            handleETAForPassenger()
            showGreetingBasedOnCriteria()
        } else if Ride.RIDE_STATUS_COMPLETED == newRideStatus || Ride.RIDE_STATUS_CANCELLED == newRideStatus{
            if Ride.RIDE_STATUS_CANCELLED == newRideStatus && currentUserRide.rideType == Ride.PASSENGER_RIDE && currentUserRide.rideId == rideStatus.rideId{
                goBackToCallingViewController()
                return
            }
            loadRideParticipantMarkers()
            self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())
            handleETAForRider()
            handleETAForPassenger()

            if Ride.RIDE_STATUS_COMPLETED == newRideStatus && currentUserRide.rideType == Ride.PASSENGER_RIDE && currentUserRide.rideId == rideStatus.rideId{
                MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
            }
        }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
            if currentUserRide.rideType == Ride.RIDER_RIDE{
                self.checkAndDisplayRiderMarker( participantLocation: self.liveRideViewModel.getRiderCurrentLocationBasedOnStatus())
                handleETAForRider()
                handleETAForPassenger()
            } else if rideStatus.userId == currentUserRide.userId{
                handleRequestedRide()
            } else {
                loadRideParticipantMarkers()
            }
        }
        initializeWalkMarker()
        self.liveRideCardViewController.handlePassengerStatusChange(rideStatus: rideStatus)
    }

    @objc func insuranceViewTapped(_ gesture : UITapGestureRecognizer){
        let rideLevelInsuranceViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideLevelInsuranceViewController") as! RideLevelInsuranceViewController

        rideLevelInsuranceViewController.initializeDataBeforePresenting(policyUrl: liveRideViewModel.policyUrl, passengerRideId: liveRideViewModel.currentUserRide!.rideId, riderId: nil, rideId: nil, isInsuranceClaimed: false, insurancePoints: liveRideViewModel.insurancePoints, dismissHandler: { [weak self] in
            self?.handleVisibilityOfInsuranceView()
        })
        self.navigationController?.view.addSubview(rideLevelInsuranceViewController.view)
        self.navigationController?.addChild(rideLevelInsuranceViewController)
    }

    private func updateRideViewControlsAsPerStatus(){
        if !liveRideViewModel.isFromSignupFlow {
            if self.liveRideViewModel.taxiRideId != 0 {
                buttonChat.isHidden = true
                buttonChatWidthConstraint.constant = 0
                return
            }
            if let rideParticipants = liveRideViewModel.rideDetailInfo?.rideParticipants, rideParticipants.count > 1{
                buttonChat.isHidden = false
                buttonChatWidthConstraint.constant = 45

            }else{
                buttonChat.isHidden = true
                buttonChatWidthConstraint.constant = 0
            }
        }
        handleEmergencyButtonVisibility()
        handleVisibilityOfInsuranceView()
    }

    private func handleVisibilityOfInsuranceView(){
        if let currentUserRide = liveRideViewModel.currentUserRide , let rideParticipants = liveRideViewModel.rideDetailInfo?.rideParticipants, !rideParticipants.isEmpty{
            if let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: currentUserRide.userId, rideParticipants: rideParticipants){
                if rideParticipant.insurancePoints != 0{
                    tripInsuranceView.isHidden = false
                    if currentUserRide.rideType == Ride.RIDER_RIDE{
                        viewWalkPath.isHidden = true
                        viewWalkPathHeightConstraint.constant = 0
                    }else{
                        viewWalkPath.isHidden = false
                        viewWalkPathHeightConstraint.constant = 40
                    }
                    liveRideViewModel.policyUrl = rideParticipant.insurancePolicyUrl
                    liveRideViewModel.insurancePoints = rideParticipant.insurancePoints
                }else{
                    tripInsuranceView.isHidden = true
                    walkPathCenterXSpaceConstraint.constant = -60
                }
            }
        }else{
            viewWalkPath.isHidden = true
            viewWalkPathHeightConstraint.constant = 0
        }
    }

    private func handleEmergencyButtonVisibility(){
        if liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_STARTED{
            buttonEmergency.isHidden = false
            if liveRideViewModel.taxiRideId != 0 {
                helpViewForTaxiPool.isHidden = false
            }
        }else{
            buttonEmergency.isHidden = true
            helpViewForTaxiPool.isHidden = true
        }
    }

    //MARK: Unread chat message count
    private func checkNewMessage(){
        if let unreadCount = RidesGroupChatCache.getInstance()?.getUnreadMessageCountOfRide(rideId: liveRideViewModel.getRiderRideId()),unreadCount > 0{
            viewUnreadMsg.isHidden = false
            unreadChatCountLabel.text = String(unreadCount)
        }else{
            viewUnreadMsg.isHidden = true
        }
    }

    private func goBackToCallingViewController(){
        AppDelegate.getAppDelegate().log.debug("goBackToCallingViewController()")
        removeListeners()
        clearAllDetails()
        self.navigationController?.popViewController(animated: false)
    }

    private func clearAllDetails()
    {
        clearRoute()
        viewMap?.delegate = nil
        liveRideViewModel.rideDetailInfo = nil
    }

    private func clearRoute() {
        if rideParticipantMarkers.count > 0 {
            for rideParticipantElement in rideParticipantMarkers.values {
                AppDelegate.getAppDelegate().log.debug("removeMarker: \(String(describing: liveRideViewModel.currentUserRide?.userId))")
                rideParticipantElement.removeRideParticipantElement()
            }
            rideParticipantMarkers.removeAll()
        }
        if self.viewMap != nil{
            viewMap.clear()
        }
        routeNavigationMarker?.map = nil
        routeNavigationMarker = nil
        pickupMarker?.map = nil
        pickupMarker = nil
        confirmPickPoint?.map = nil
        confirmPickPoint = nil
        clearLocationUpdateMarker()
    }

    private func clearLocationUpdateMarker() {
        if locationUpdateMarker == nil {
            return
        }
        locationUpdateMarker.map = nil
        locationUpdateMarker = nil
    }


    private func removeListeners() {
        MyActiveRidesCache.singleCacheInstance?.removeRideUpdateListener(key: MyActiveRidesCache.LiveRideMapViewController_key)
        NotificationStore.getInstance().removeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
        let riderRideId = liveRideViewModel.getRiderRideId()
        if riderRideId != 0 {
            RidesGroupChatCache.getInstance()?.removeRideGroupChatListener(rideId: riderRideId)
        }
        liveRideViewModel.stopLocationUpates()
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideLocationChangeListener(rideParticipantLocationListener: self)
    }



    func displayRideClosedDialogue(){
        AppDelegate.getAppDelegate().log.debug("displayRideClosedDialogue")
        if liveRideViewModel.closedDialogueDisplayed{
            return
        }
        liveRideViewModel.closedDialogueDisplayed = true
        MessageDisplay.displayAlert( messageString: "Oops ! This ride is already closed", viewController: self,  handler: { (result) -> Void in
            if result == Strings.ok_caps {
                self.goBackToCallingViewController()
                self.liveRideViewModel.closedDialogueDisplayed = false
            }
        })
    }

    @objc func backButtonClicked(_ gesture: UITapGestureRecognizer) {
        goBackToCallingViewController()
    }

    @objc func batteryCriticallyLowBackgroundViewTapped(_ gesture: UITapGestureRecognizer) {
        self.batteryCriticallyLowBackgroundView.isHidden = true
        self.batteryCriticallyLowView.isHidden = true
    }

    private func displayConfirmationDialog(){
        MessageDisplay.displayErrorAlertWithAction(title: Strings.want_to_start_emergency, isDismissViewRequired : false, message1: Strings.emergency_initiation_msg, message2: nil, positiveActnTitle: Strings.confirm_caps, negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: { (result) in
            if Strings.confirm_caps == result{
                self.checkForTheEmergencyContact()
            }
        })
    }

    private func checkForTheEmergencyContact(){
        let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
        if emergencyContactNo == nil || emergencyContactNo!.isEmpty {

            self.navigateToEmergencyContactSelection()
        }
        else{
            self.initiateEmergency()
        }
    }

    private func navigateToEmergencyContactSelection(){
        let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
        selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
        selectContactViewController.modalPresentationStyle = .overFullScreen
        self.present(selectContactViewController, animated: false, completion: nil)
    }

    private func initiateEmergency() {
        AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: self)
        buttonEmergency.backgroundColor = UIColor(netHex: 0xE20000)
        buttonEmergency.setImage(UIImage(named: "emergency_after_pressed"), for: UIControl.State.normal)
        let emergencyService =  EmergencyService(viewController: self)
        let shareRidePath = ShareRidePath(viewController: self, rideId: StringUtils.getStringFromDouble(decimalNumber : liveRideViewModel.getRiderRideId()))
        shareRidePath.prepareRideTrackCoreURL { (url) in
            emergencyService.startEmergency(urlToBeAttended: url)
            self.liveRideViewModel.initiateEmeregency(url: url)
        }
        UIApplication.shared.keyWindow?.makeToast(Strings.emerg_initiated, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
    }

    //MARK: Actions
    @IBAction func rideOptionsButtonClick(_ sender: UIButton) {
        guard let currentUserRide = liveRideViewModel.currentUserRide else {
            return
        }

        let liveRideMenuActions = LiveRideMenuActions(ride: currentUserRide)


        let rideStatusObj = RideStatus(ride : currentUserRide)
        liveRideMenuActions.addChangeRoleAction() {
            RideActionHandler(ride: currentUserRide, viewController: self, rideActionDelegate: self).cancelCurrentRideAndCreateNewRideWithDifferentRole()
        }
        liveRideMenuActions.addFreezeAction() { (freeze) in
            let rideActionHandler = RideActionHandler(ride: currentUserRide, viewController: self, rideActionDelegate: self)
            if freeze {
                rideActionHandler.freezeRide()
            }else{
                rideActionHandler.handleFreezeRide(freezeRide: false)
            }
        }
        if (currentUserRide.rideType == Ride.PASSENGER_RIDE && currentUserRide.status == Ride.RIDE_STATUS_REQUESTED) || rideStatusObj.isCancelRideAllowed(){
            liveRideMenuActions.addRideCancelAlertAction {
                RideActionHandler(ride: currentUserRide, viewController: self, rideActionDelegate: self).handleCancelRide(riderRide: self.liveRideViewModel.rideDetailInfo?.riderRide, rideParticipants: self.liveRideViewModel.rideDetailInfo?.rideParticipants, rideCancelDelegate: self, rideUpdateDelegate: self)
            }
        }
        liveRideMenuActions.showAlertController(viewController: self)

    }

    @IBAction private func notificationIconTapped(_ sender: UIButton) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }

    @IBAction private func refreshButtonTapped(_ sender: UIButton) {
        self.liveRideViewModel.userInteractedWithMap = false
        refreshButtonAnimationView.isHidden = false
        refreshButtonAnimationView.animationView.animation = Animation.named("loading_refresh")
        refreshButtonAnimationView.animationView.play()
        refreshButtonAnimationView.animationView.loopMode = .loop
        QRReachability.isInternetAvailable { (isConnectedToNetwork) in
            if !isConnectedToNetwork {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                self.refreshButtonAnimationView.isHidden = true
                self.refreshButtonAnimationView.animationView.stop()
            }else{
                guard let ride = self.liveRideViewModel.currentUserRide else {
                    self.refreshButtonAnimationView.isHidden = true
                    self.refreshButtonAnimationView.animationView.stop()
                    return
                }
                self.continueRefreshAction(ride: ride)
            }
        }
    }

    @IBAction private func moveToCurrentPath(_ sender: UIButton) {
        if liveRideViewModel.currentUserRide == nil{
            return
        }
        self.liveRideViewModel.userInteractedWithMap = false
        handleZoomBasedOnStatus()
    }

    @IBAction private func emergencyButtonClicked(_ sender: UIButton) {
        let emergencyInitializer = AppDelegate.getAppDelegate().getEmergencyInitializer()
        if emergencyInitializer == nil{
            displayConfirmationDialog()
        }else {
            UIApplication.shared.keyWindow?.makeToast(Strings.emerg_initiated_already, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
        }
    }

    @IBAction func helpBtnPressed(_ sender: UIButton) {
        CustomerSupportDetailsParser.getInstance().getCustomerSupportElement { (customerSupportElement) in
                    self.moveToTaxiPoolFAQ(customerSupportElement: customerSupportElement!,index: 9)
        }
    }

    @IBAction func chatButtonClicked(_ sender: UIButton) {
        let riderRideId = liveRideViewModel.getRiderRideId()
        let groupChatViewController  = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
        groupChatViewController.initailizeGroupChatView(riderRideID: riderRideId, isFromCentralChat: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: groupChatViewController, animated: false)
    }

    @IBAction func navigationButtonTappped(_ sender: UIButton) {
        guard let ride = liveRideViewModel.currentUserRide else { return }
        let rideStatusObj = RideStatus(ride : ride)
        var endPoint = String(ride.endLatitude!.roundToPlaces(places: 5))+","+String(ride.endLongitude!.roundToPlaces(places: 5))
        var mode = "driving"
        var wayPointsString: String?
        var wayPoints = [String]()
        let startPoint: String?
        if let riderCurrentLocation = liveRideViewModel.getRiderCurrentLocationBasedOnStatus() {
            startPoint = String(riderCurrentLocation.latitude!.roundToPlaces(places: 5))+","+String(riderCurrentLocation.longitude!.roundToPlaces(places: 5))
        } else {
            startPoint = String(ride.startLatitude.roundToPlaces(places: 5))+","+String(ride.startLongitude.roundToPlaces(places: 5))
        }
        if rideStatusObj.isStartRideAllowed() || rideStatusObj.isStopRideAllowed() || liveRideViewModel.isModerator {
            endPoint = String(ride.endLatitude!.roundToPlaces(places: 5))+","+String(ride.endLongitude!.roundToPlaces(places: 5))
            mode = "driving"
            let passengers = RideViewUtils.getPassengersYetToPickupInOrder(rideParticipants: liveRideViewModel.rideDetailInfo?.rideParticipants)

            var wayPoint: String?

            for passenger in passengers {
                wayPoint = String(passenger.startPoint!.latitude.roundToPlaces(places: 5)) + "," + String(passenger.startPoint!.longitude.roundToPlaces(places: 5))
                if wayPoints.contains(wayPoint!) || startPoint == wayPoint {
                    continue
                }
                wayPoints.append(wayPoint!)
            }
            if !wayPoints.isEmpty {
                wayPointsString = "&waypoints=" + wayPoints.joined(separator: "|")
            }
        } else if rideStatusObj.isCheckInRideAllowed() || rideStatusObj.isDelayedCheckinAllowed(){

            endPoint = String((ride as! PassengerRide).pickupLatitude.roundToPlaces(places: 5))+","+String((ride as! PassengerRide).pickupLongitude.roundToPlaces(places: 5))

            mode = "walking"
        } else if rideStatusObj.isCheckOutRideAllowed(){
            endPoint = String((ride as! PassengerRide).dropLatitude.roundToPlaces(places: 5))+","+String((ride as! PassengerRide).dropLongitude.roundToPlaces(places: 5))

            mode = "driving"
        }
        var urlString = "https://www.google.com/maps/dir/?api=1&origin=" + startPoint! + "&destination=" + endPoint + "&travelmode=" + mode + "&dir_action=navigate"
        if wayPointsString != nil {
            urlString += wayPointsString!
        }
        if let enodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: enodedUrlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast("Can't open Google maps in this device.", point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
        }
    }

    @IBAction func firstRelayRideTapped(_ sender: UIButton) {
       let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: liveRideViewModel.firstRelayRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: liveRideViewModel.secondRelayRide, requiredToShowRelayRide: RelayRideMatch.SHOW_FIRST_RELAY_RIDE)
        self.navigationController?.pushViewController(mainContentVC, animated: true)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
    }
    @IBAction func secondRelayRideTapped(_ sender: UIButton) {
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: liveRideViewModel.firstRelayRide , isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: liveRideViewModel.secondRelayRide,requiredToShowRelayRide: RelayRideMatch.SHOW_SECOND_RELAY_RIDE)
        self.navigationController?.pushViewController(mainContentVC, animated: true)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
    }

    private func moveToTaxiPoolFAQ(customerSupportElement: CustomerSupportElement,index: Int) {
        let element = customerSupportElement.customerSupportElement![index]
        let customerInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerInfoViewController") as! CustomerInfoViewController
        customerInfoViewController.initializeDataBeforepresentingView(customerSupportElement: element)
        self.navigationController?.pushViewController(customerInfoViewController, animated: false)
    }

    private func checkAndDisplayRiderMarker(participantLocation : RideParticipantLocation?){

        guard let riderRide = liveRideViewModel.rideDetailInfo?.riderRide, let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: riderRide.userId, rideParticipants: liveRideViewModel.rideDetailInfo?.rideParticipants) else {
            return
        }

        var rideParticipantLocation = participantLocation
        if rideParticipantLocation == nil && rideParticipant.status != Ride.RIDE_STATUS_STARTED{
            rideParticipantLocation = RideParticipantLocation(rideId : rideParticipant.riderRideId, userId : rideParticipant.userId, latitude : rideParticipant.startPoint!.latitude, longitude : rideParticipant.startPoint!.longitude, bearing : 0,participantETAInfos: nil)
        }
        guard let rideParticipantLocation = rideParticipantLocation else {
            return
        }

        let rideLocation = CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!)
        var latLongOnRoute = rideLocation
        if let routePathPolyline = liveRideViewModel.rideDetailInfo?.riderRide?.routePathPolyline, !routePathPolyline.isEmpty {
            let nearestLatLong = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: rideLocation, routePath: routePathPolyline)
            if nearestLatLong.0 < 50 {
                latLongOnRoute = nearestLatLong.1
            }
        }
        displayRiderMarkerAtCurrentLocation(rideParticipantLocation: rideParticipantLocation, newLocation: latLongOnRoute,lastLocation: latLongOnRoute, rideParticipant: rideParticipant)
    }


    private func displayRiderMarkerAtCurrentLocation(rideParticipantLocation: RideParticipantLocation, newLocation : CLLocationCoordinate2D,lastLocation : CLLocationCoordinate2D, rideParticipant: RideParticipant){

        guard let riderRide = liveRideViewModel.rideDetailInfo?.riderRide,self.viewMap.delegate != nil,  liveRideViewModel.currentUserRide != nil else {
            return
        }
        if rideParticipant.status == Ride.RIDE_STATUS_STARTED || NSDate().getTimeStamp() > riderRide.startTime {
            handleVehicleLocationChange(rideParticipantLocation: rideParticipantLocation, rideParticipant: rideParticipant, newLocation: newLocation)
        } else {
            setRiderImageAtLocation(rideParticipantLocation: rideParticipantLocation, rideParticipant: rideParticipant, newLocation: newLocation)
        }
    }

    private func setRiderImageAtLocation(rideParticipantLocation : RideParticipantLocation, rideParticipant: RideParticipant, newLocation: CLLocationCoordinate2D) {
        if routeNavigationMarker == nil {
            routeNavigationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!))
        }
        routeNavigationMarker.map = viewMap
        routeNavigationMarker.zIndex = 15
        routeNavigationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        routeNavigationMarker.isFlat = true
        routeNavigationMarker.isTappable = true
        setRiderImage(rideParticipant: rideParticipant)
        updateVehicleOrRiderImageBasedOnLocation(newLocation: newLocation)
    }

    private func handleVehicleLocationChange(rideParticipantLocation : RideParticipantLocation, rideParticipant: RideParticipant, newLocation: CLLocationCoordinate2D) {
        if routeNavigationMarker == nil {
            routeNavigationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!))
        }
        routeNavigationMarker.map = viewMap
        routeNavigationMarker.zIndex = 15
        routeNavigationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        routeNavigationMarker.isFlat = true
        routeNavigationMarker.isTappable = true
        if rideParticipantLocation.bearing != nil && rideParticipantLocation.bearing != 0{
            routeNavigationMarker.rotation = rideParticipantLocation.bearing!
        }
        setVehicleImage()
        updateVehicleOrRiderImageBasedOnLocation(newLocation: newLocation)
    }

    private func setRiderImage(rideParticipant: RideParticipant) {
        ImageCache.getInstance().setImagetoMarker(imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender ?? "U", marker: routeNavigationMarker, isCircularImageRequired: true, imageSize: ImageCache.DIMENTION_SMALL)
    }

    private func setVehicleImage() {
        var vehicleImage : UIImage?
        if liveRideViewModel.taxiRideId != 0 {
            if liveRideViewModel.rideDetailInfo?.taxiShareRide?.shareType == GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI {
                vehicleImage = UIImage(named: "exclusive_taxi_tracking")
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: vehicleImage!, targetSize: CGSize(width: 55,height: 55))
            } else {
                vehicleImage = UIImage(named: "taxi_tracking")
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: vehicleImage!, targetSize: CGSize(width: 55,height: 55))
            }
        }else {
            guard let riderRide = liveRideViewModel.rideDetailInfo?.riderRide else {
                return
            }
            if Vehicle.VEHICLE_TYPE_BIKE == riderRide.vehicleType {
                vehicleImage = UIImage(named: "bike_top")
                routeNavigationMarker.icon = vehicleImage!
            } else {
                vehicleImage = UIImage(named: "new_car")
                routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: vehicleImage!, targetSize: CGSize(width: 55,height: 55))
            }
        }
    }

    private func updateVehicleOrRiderImageBasedOnLocation(newLocation: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({[weak self] () -> Void in
            guard let self = self, let routeNavigationMarker = self.routeNavigationMarker else { return  }
            routeNavigationMarker.position =  newLocation
        })
        CATransaction.commit()

    }

    private func setLocationDetailsMarkerAtLocation(participantETAInfo: ParticipantETAInfo, location: CLLocationCoordinate2D) {

        let riderLocationDetailsInfoWindow = UIView.loadFromNibNamed(nibNamed: "RiderLocationDetails") as! RiderLocationDetails
        riderLocationDetailsInfoWindow.setETAInfo(participantETAInfo: participantETAInfo)
        guard let icon = ViewCustomizationUtils.getImageFromUIView(view: riderLocationDetailsInfoWindow) else {
            return
        }
        if locationUpdateMarker != nil {
            locationUpdateMarker.icon = icon
            locationUpdateMarker.position = location

        }else{
            locationUpdateMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: location, shortIcon: icon, tappable: true, anchor: CGPoint(x: 0.0, y: 1))
            let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: participantETAInfo.lastUpdateTime)
            locationUpdateMarker.title = String(timeDifferenceInSeconds)
            locationUpdateMarker.zIndex = 10
            locationUpdateMarker.isFlat = true

        }
    }


    private func loadRideParticipantMarkers()
    {
        clearRideParticipantElements()
        if !liveRideViewModel.isModerator && liveRideViewModel.currentUserRide?.rideType != Ride.RIDER_RIDE {
            return
        }
        guard let rideParticipants = liveRideViewModel.rideDetailInfo?.rideParticipants else {
            return
        }
        for rideParticipant in rideParticipants{

            if rideParticipant.rider {
                continue
            }
            var participantMarkerElement = rideParticipantMarkers[rideParticipant.userId]
            if participantMarkerElement == nil{
                participantMarkerElement = RideParticipantElements()
            }

            participantMarkerElement!.createOrUpdateRideParticipantElement(viewMap: viewMap,  rideParticipant: rideParticipant)
            rideParticipantMarkers[rideParticipant.userId] = participantMarkerElement
        }
    }
    func clearRideParticipantElements(){
        for participantElememt in rideParticipantMarkers.values {
            participantElememt.removeRideParticipantElement()
        }
    }
     func handleETAForPassenger() {
        liveRideViewModel.validateAndGetETAForPassenger()
         NotificationCenter.default.addObserver(forName: .receivedPassengerETAInfo, object: nil, queue: nil) { (notification) in
             DispatchQueue.main.async {
                 guard let passengerETAInfo = notification.userInfo?["passengerETAInfo"] as? ParticipantETAInfo else {return}
                 if  self.routeNavigationMarker != nil{
                     let location = self.routeNavigationMarker.position
                     self.setLocationDetailsMarkerAtLocation(participantETAInfo: passengerETAInfo, location: location)
                 }
             }
         }
    }

    func handleETAForRider() {

        if let riderLocation = liveRideViewModel.getRiderCurrentLocationBasedOnStatus(){
            displayETAForRider(riderCurrentLocation: riderLocation)
        }
    }

    func displayETAForRider( riderCurrentLocation : RideParticipantLocation) {

        guard let riderETAInfo = liveRideViewModel.validateAndGetETAForRider() else {
//            locationUpdateMarker?.map = nil
//            locationUpdateMarker = nil
            return
        }

        if routeNavigationMarker?.position != nil {
            setLocationDetailsMarkerAtLocation(participantETAInfo: riderETAInfo, location: routeNavigationMarker.position )
        }
    }

    func handleZoomBasedOnStatus() {

        let fullMapView = floatingPanelController.position == .hidden
        guard liveRideViewModel.currentUserRide != nil , viewMap != nil else {
            return
        }
        if self.liveRideViewModel.userInteractedWithMap {
            return
        }

        if let bounds  = liveRideViewModel.getGMSBoundsToFocusBasedOnStatus(){

            var uiEdgeInsets : UIEdgeInsets
            if fullMapView {
                if vehicleView.isHidden {
                     uiEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 60)
                }else{
                    uiEdgeInsets = UIEdgeInsets(top: 40, left: 30, bottom: 30+vehicleView.frame.height, right: 30)
                }
                self.viewMap.padding = uiEdgeInsets
            }

            if let coodinates = bounds.1 {
                if coodinates.count > 2 {
                    var bounds = GMSCoordinateBounds()
                    for coodinate in coodinates {
                        bounds = bounds.includingCoordinate(coodinate)
                    }
                    self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20))
                }else if coodinates.count > 1 {
                    self.viewMap.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: coodinates[0], coordinate: coodinates[1]), withPadding: 20))
                }else {
                    self.viewMap.animate(toLocation: coodinates[0])
                    self.viewMap.animate(toZoom: 16)
                }

            }else if let gmsBounds = bounds.0{
                self.viewMap.animate(with: GMSCameraUpdate.fit(gmsBounds, withPadding: 50))
            }

        }
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setRiderDetailOnFullMapView(rideParticipant: RideParticipant) {
        vehicleView.isHidden = false
        if let riderRide = liveRideViewModel.rideDetailInfo?.riderRide, let vehicleNumber = riderRide.vehicleNumber {
            if riderRide.makeAndCategory == nil || riderRide.makeAndCategory!.isEmpty{
                vehicleNumberLabel.text = vehicleNumber.uppercased()
            }
            else{
                vehicleNumberLabel.text = vehicleNumber.uppercased() + " " + riderRide.makeAndCategory!.capitalizingFirstLetter()
            }
        }
        riderNameLabel.text = rideParticipant.name?.capitalized
        ImageCache.getInstance().setImageToView(imageView: riderImageView, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)
        vehicleNumberLabel.isUserInteractionEnabled = true
        vehicleNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(vehicleNameTapped(_:))))
    }

    @objc func vehicleNameTapped(_ gesture: UITapGestureRecognizer) {
        if let vehicle = LiveRideViewModelUtil.getRiderVehicle(riderRide: liveRideViewModel.rideDetailInfo?.riderRide){
            let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
            vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: vehicle)
            self.navigationController?.pushViewController(vehicleDisplayViewController, animated: false)
        }
    }
}

//MARK: RideUpdateListner delegate
extension LiveRideMapViewController: RideUpdateListener {
    func refreshRideView() {

    }

    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) {
        if let ride = rideDetailInfo.currentUserRide {
            self.rideUpdated(ride: ride)
        }
    }

    func handleUnfreezeRide() { }

    func participantStatusUpdated(rideStatus: RideStatus) {
        AppDelegate.getAppDelegate().log.debug("participantStatusUpdated :\(rideStatus)")
        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()
        guard let ride = liveRideViewModel.currentUserRide else { return }
        let rideStatusObj = RideStatus(ride : ride)
        if !RideViewUtils.isStatusUpdateForCurrentRide(newRideStatus: rideStatus, currentParticipantRide: ride, associatedRiderRide: liveRideViewModel.rideDetailInfo?.riderRide){
            return
        }
        if RideViewUtils.isRedundantStatusUpdate(newRideStatus: rideStatus, currentRideStatus: rideStatusObj){
            AppDelegate.getAppDelegate().log.debug("RedundantStatusUpdate")
        }
        if(Ride.RIDER_RIDE == rideStatus.rideType){
            handleRiderStatusChange(rideStatus: rideStatus)
        }else{
            handlePassengerStatusChange(rideStatus: rideStatus)
        }
        handleEmergencyButtonVisibility()
    }

    func participantRideRescheduled(rideStatus: RideStatus) {
        guard let ride = liveRideViewModel.currentUserRide else { return }
        var updatedRide : Ride?
        if ride.rideType == Ride.RIDER_RIDE {
            updatedRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: ride.rideId)
        }else if ride.rideType == Ride.PASSENGER_RIDE{
            updatedRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: ride.rideId)
        }
        if updatedRide == nil{
            return
        }
        liveRideViewModel.currentUserRide = updatedRide
        liveRideViewModel.getRideDetailInfo { (responseError, error) in

        }
        if liveRideViewModel.currentUserRide == nil  { return }
        displayRideScheduledTime()

        if rideStatus.rideType == Ride.RIDER_RIDE{
            loadRideParticipantMarkers()
        }
        displayRideStatusAndFareDetailsToUser(status: Ride.RIDE_STATUS_SCHEDULED)
        if Ride.PASSENGER_RIDE == ride.rideType{
            if liveRideViewModel.rideDetailInfo?.riderRide != nil {
                handleETAForPassenger()
            }
        }else{
            if liveRideViewModel.rideDetailInfo?.riderRide != nil{
                handleETAForRider()
            }
        }
        self.initializeWalkMarker()

    }

    func participantUpdated(rideParticipant: RideParticipant) {
        if liveRideViewModel.getRiderRideId() == rideParticipant.riderRideId{
            liveRideViewModel.getRideDetailInfo { [weak self] (responseError, error) in
                if responseError != nil || error != nil {
                    self?.onRetrievalFailure(responseError: responseError, error: error)
                }else {
                    self?.refreshMapWithNewData()
                }

            }
        }
    }
}

//MARK: NotificationChangeListener delegate
extension LiveRideMapViewController: NotificationChangeListener {
    func handleNotificationListChange() {
        handleNotificationCountAndDisplay()
    }
}

//MARK: GroupChatMessageListener delegate
extension LiveRideMapViewController: GroupChatMessageListener {
    func newChatMessageRecieved(newMessage: GroupChatMessage) {
        moveToGroupChatView()
    }

    func chatMessagesInitializedFromSever() {}

    func handleException() {}

    private func moveToGroupChatView(){
        let currentRiderRideId = liveRideViewModel.getRiderRideId()
        if currentRiderRideId == 0 {
            return
        }
        let destViewController:GroupChatViewController  = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
        destViewController.initailizeGroupChatView(riderRideID: currentRiderRideId, isFromCentralChat: false)

        if RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller != nil{
            RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller?.dismiss(animated: false, completion: {
                DispatchQueue.main.async(){
                    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                    RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
                }
            })
        }else{
            DispatchQueue.main.async(){
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
            }
        }
    }
}
//MARK: RideParticipantLocationListener delegate
extension LiveRideMapViewController: RideParticipantLocationListener {
    func receiveRideParticipantLocation(rideParticipantLocation: RideParticipantLocation) {

            guard self.viewMap != nil, let riderRide = liveRideViewModel.rideDetailInfo?.riderRide, let rideId = rideParticipantLocation.rideId, riderRide.rideId == rideId  else {
                return
            }
            liveRideViewModel.getRideDetailInfo { (responseError, error) in
            }
            if(rideParticipantLocation.userId == riderRide.userId){
                handleRiderRideLocationChange(rideParticipantLocation: rideParticipantLocation)
            }else{
                self.initializeWalkMarker()
            }

    }
    private func handleRiderRideLocationChange(rideParticipantLocation : RideParticipantLocation){
        RouteDeviationDetector(ride: liveRideViewModel.currentUserRide, riderRide: liveRideViewModel.rideDetailInfo?.riderRide, rideParticipantLocation: rideParticipantLocation, delegate: self).isRouteDeviated()
        checkAndDisplayRiderMarker(participantLocation: rideParticipantLocation)
        displayETAForRider(riderCurrentLocation: rideParticipantLocation)
        handleETAForPassenger()
        handleZoomBasedOnStatus()
        if let rideParticipantLocations = liveRideViewModel.rideDetailInfo?.rideParticipantLocations{
            liveRideCardViewController.handleRideParticipantLocations(rideParticipantLocations: rideParticipantLocations)
        }
    }
}

//MARK: MatchedUsersDataReceiver delegate
extension LiveRideMapViewController {
    func receiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int) {
        if !matchedRiders.isEmpty {
            if liveRideViewModel.isFromSignupFlow{
                self.changeLabelTextAndImage(matchedUserCount: matchedRiders.count)
            }
        }
    }

    func receiveMatchedPassengersList( requestSeqId : Int, matchedPassengers : [MatchedPassenger], currentMatchBucket: Int) {
        if !matchedPassengers.isEmpty {
            if liveRideViewModel.isFromSignupFlow{
                self.changeLabelTextAndImage(matchedUserCount: matchedPassengers.count)
            }
        }
    }

    private func changeLabelTextAndImage(matchedUserCount: Int){
        firstRideAnimationView.animationView.stop()
        firstRideAnimationView.animationView.animation = Animation.named("signup_star")
        UIView.transition(with: firstRideAnimationView.animationView,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.firstRideAnimationView.animationView.play()
            self.firstRideAnimationView.animationView.loopMode = .loop
        }, completion: nil)
        UIView.transition(with: viewFirstRideCreatedInfo,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0xd64361)
        }, completion: nil)
        UIView.transition(with: labelFirstRideInfo1,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.labelFirstRideInfo1.text = "Awesome! Found " + "\(matchedUserCount)" + " rides"
        }, completion: nil)
        UIView.transition(with: labelFirstRideInfo2,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.labelFirstRideInfo2.text = "Redirecting there..."
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.liveRideViewModel.isFromSignupFlow = false
            self.firstRideAnimationView.animationView.stop()
            //            self.liveRideViewModel.moveToInvite(isFromContacts: false)
        }
    }

    func matchingRidersRetrievalFailed(requestSeqId :Int,responseObject : NSDictionary?,error :NSError?) {
    }

    func matchingPassengersRetrievalFailed( requestSeqId : Int,responseObject : NSDictionary?,error :NSError?) {
    }
}
//MARK: ReceiveEtaDelegate

extension LiveRideMapViewController: SelectContactDelegate {
    func selectedContact(contact: Contact) {
        let emergencyContact = EmergencyContactUtils.getEmergencyContactNumberWithName(contact: contact)
        UserDataCache.getInstance()?.updateUserProfileWithTheEmergencyContact(emergencyContact: emergencyContact,viewController : self)
        initiateEmergency()
    }
}

extension LiveRideMapViewController: EmergencyInitiator {
    func emergencyCompleted() {
        buttonEmergency.setImage(UIImage(named: "sos_ride_view"), for: UIControl.State.normal)
        AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
    }
}
//MARK: RideObjectUdpateListener delegate
extension LiveRideMapViewController: RideObjectUdpateListener {
    func rideUpdated(ride: Ride) {
        liveRideViewModel.currentUserRide = ride
        liveRideViewModel.isRideDetailInfoRetrieved = false
        if liveRideViewModel.getRiderRideId() == 0 {
            handleRequestedRide()
        }else{
            handleScheduleRide()
        }
    }
}
//MARK: RideActionDelegate delegate
extension LiveRideMapViewController: RideActionDelegate {
    func handleFreezeRide(freezeRide: Bool) {}

    func rideArchived(ride: Ride) { }

    func handleEditRoute() {
        guard let rideObj = liveRideViewModel.currentUserRide else {
            return
        }
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: rideObj.expectedEndTime, time2: rideObj.startTime)
        let rideRoute = RideRoute(routeId: rideObj.routeId!, overviewPolyline: rideObj.routePathPolyline, distance :rideObj.distance!,duration : Double(duration), waypoints: rideObj.waypoints)
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: rideObj, rideRoute: rideRoute , routeSelectionDelegate: self)
        self.navigationController?.pushViewController(routeSelectionViewController, animated: false)
    }
}
//MARK: RideCancelDelegate delegate
extension LiveRideMapViewController: RideCancelDelegate {
    func rideCancelled() {
        goBackToCallingViewController()
    }
}
extension LiveRideMapViewController: RouteSelectionDelegate {

    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        liveRideViewModel.updateRideRoute(ride: ride, route: route, isRouteDeviated: false)
    }

    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) { }
}
//MARK: MapView delagate
extension LiveRideMapViewController : GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == locationUpdateMarker {
            if let titleInString = marker.title, let title = Int(titleInString), title > 120 {
                MessageDisplay.displayInfoViewAlert(title: Strings.low_network, titleColor: nil, message: Strings.low_network_msg, infoImage: UIImage(named: "wifi_img"), imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil,buttonTitle: Strings.got_it_caps) {
                }
            } else {
                mapView.selectedMarker = nil
            }
        }else if marker == confirmPickPoint{
            self.moveToEditPickupView()
        }else if marker == passengerWalkMarker || marker == passengerWalkETAMarker{
            guard let currentRide = liveRideViewModel.currentUserRide as? PassengerRide, currentRide.pickupLatitude > 0, currentRide.pickupLongitude > 0 else {
                return false
            }
            let endPoint = String(currentRide.pickupLatitude.roundToPlaces(places: 5))+","+String(currentRide.pickupLongitude.roundToPlaces(places: 5))

            let urlString = "https://www.google.com/maps/dir/?api=1&destination=" + endPoint + "&travelmode=walking" + "&dir_action=navigate"
            if let enodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: enodedUrlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast("Can't open Google maps in this device.", point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
            }
        }
        else {
            mapView.selectedMarker = marker
        }
        return true
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        LiveRideViewModel.MAP_ZOOM = position.zoom
    }



    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {

        if gesture{
            if liveRideViewModel.isFromSignupFlow{
                buttonCurrentLoc.isHidden = true
                ButtonCurrentLocWidth.constant = 0
                self.liveRideViewModel.userInteractedWithMap = false
            } else {
                buttonCurrentLoc.isHidden = false
                ButtonCurrentLocWidth.constant = 35
                self.liveRideViewModel.userInteractedWithMap = true
            }
        } else {
            buttonCurrentLoc.isHidden = true
            ButtonCurrentLocWidth.constant = 0
            self.liveRideViewModel.userInteractedWithMap = false

        }
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if liveRideViewModel.currentUserRide == nil {
            return
        }
        if !liveRideViewModel.isMapFullView{
             hideInfoCardViews()
            liveRideViewModel.isMapFullView = true
            floatingPanelController.move(to: .hidden, animated: true)
        } else {
            liveRideViewModel.isMapFullView = false
            self.showHideTaxiPoolIcon()
            showInfoCardViews()
            floatingPanelController.move(to: .half, animated: true)
        }
        mapUtilitiesBottomSpaceConstraint.constant = (floatingPanelController.layout.insetFor(position: floatingPanelController.position) ?? 0) + 5
        handleZoomBasedOnStatus()
    }
    func showInfoCardViews(){
        let animation4 = CATransition()
        animation4.type = .push
        animation4.subtype = .fromBottom
        animation4.duration = 0.5
        topDataView.layer.add(animation4, forKey: nil)
        self.topDataView.isHidden = false
    }

    func hideInfoCardViews(){
        let animation3 = CATransition()
        animation3.type = .push
        animation3.subtype = .fromTop
        animation3.duration = 0.5
        topDataView.layer.add(animation3, forKey: nil)
        self.topDataView.isHidden = true
        if liveRideViewModel.currentUserRide!.rideType == Ride.PASSENGER_RIDE && liveRideViewModel.rideDetailInfo?.riderRide != nil {
            vehicleView.isHidden = false
        } else {
            vehicleView.isHidden = true
        }
    }
}
extension LiveRideMapViewController: PassengerRideUpdateDelegate {
    func passengerRideUpdated(ride: Ride) {
        rideUpdated(ride: ride)
    }
}
extension LiveRideMapViewController {

    func addNotificationObservers(){
        NotificationCenter.default.addObserver(forName: .selectedPassengerChanged, object: nil, queue: nil) { (notification) in
            if let userInfo = notification.userInfo, let selectedPassengerId = userInfo[LiveRideNSNotificationConstants.SELECTED_PASSENGER_ID] as? Double{
                self.liveRideViewModel.selectedPassengerId = selectedPassengerId
                if let rideParticipantMarker = self.rideParticipantMarkers[selectedPassengerId], let rideParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: selectedPassengerId, rideParticipantLocations: self.liveRideViewModel.rideDetailInfo?.rideParticipantLocations) {
                    rideParticipantMarker.handlePassengerCurrentLocation(viewMap: self.viewMap, rideParticipantLocation: rideParticipantLocation)
                }
                self.handleZoomBasedOnStatus()
            }
        }
        NotificationCenter.default.addObserver(forName: .rideModerationStatusChanged, object: nil, queue: nil) { (notification) in
            self.refreshMapWithNewData()
        }

        NotificationCenter.default.addObserver(forName: .rideUpdated, object: nil, queue: nil) { (notification) in
            if let userInfo = notification.userInfo, let ride = userInfo[LiveRideNSNotificationConstants.RIDE] as? Ride {
                self.rideUpdated(ride: ride)
            }
        }

        NotificationCenter.default.addObserver(forName: .passengerPickedUp, object: nil, queue: nil) { [weak self](notification) in
                self?.removeListeners()
        }
    }
}
extension LiveRideMapViewController: FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return LiveRideFloatingPanelLayout()
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
                            self.handleGrabberHandleVisibility()
                            self.floatingPanelController.backdropView.isHidden = false
                            self.floatingPanelController.surfaceView.shadowHidden = false
                        }

                        if targetPosition == .full {
                            self.vehicleView.isHidden = true
                            self.viewMapComponent.isHidden = true
                        } else {
                            self.viewMapComponent.isHidden = false
                            if self.liveRideViewModel.isModerator, let rider = RideViewUtils.getRiderFromRideParticipant(rideParticipants: self.liveRideViewModel.rideDetailInfo?.rideParticipants)  {
                                self.setRiderDetailOnFullMapView(rideParticipant: rider)
                            } else {
                                self.vehicleView.isHidden = true
                            }
                            self.viewMapComponent.isHidden = false

                        }
                        if  targetPosition == .tip && !self.vehicleView.isHidden {
                            self.mapUtilitiesBottomSpaceConstraint.constant = (vc.layout.insetFor(position: targetPosition) ?? 0) + self.vehicleView.frame.height + 5
                        }else{
                            self.mapUtilitiesBottomSpaceConstraint.constant = (vc.layout.insetFor(position: targetPosition) ?? 0) + 5
                        }

        }, completion: nil)
    }

    func handleGrabberHandleVisibility(){
        if self.liveRideViewModel.isAllPassengerPickupCompleted() {
            self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
        }else {
            self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
        }
    }

    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        guard liveRideCardViewController != nil else { return }
        if floatingPanelController.position == .half || floatingPanelController.position == .tip {
            enableControlsAsPerStatus()
            makeMapViewClearAndVisible()
        }else if floatingPanelController.position == .full {
            enableControlsAsPerStatus()
            makeMapViewBlur()
        }else {
            rideActionContainerView.isHidden = true
            makeMapViewClearAndVisible()
        }
    }

    private func makeMapViewBlur(){
        transperentView.backgroundColor = .black
        transperentView.layer.opacity = 0.3
        transperentView.frame = CGRect(x: viewMapContainer.frame.minX, y: viewMapContainer.frame.minY, width: viewMapContainer.frame.width, height: viewMapContainer.frame.height)
        viewMapContainer.addSubview(transperentView)
    }

    private func makeMapViewClearAndVisible(){
        transperentView.removeFromSuperview()
    }
}

class LiveRideFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 75.0 // A top inset from safe area
            case .half: return 250 // A bottom inset from the safe area
            case .tip: return 249 // A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
        }
    }
}
extension LiveRideMapViewController: RouteDeviationDetectorDelegate {
    func routeDeviated(_ deviated: Bool) {
        if routeDeviationInfoViewController == nil {
            if let riderRide = liveRideViewModel.rideDetailInfo?.riderRide, deviated, let ride = liveRideViewModel.rideDetailInfo?.currentUserRide, let rideParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: riderRide.userId, rideParticipantLocations: liveRideViewModel.rideDetailInfo?.rideParticipantLocations) {
                self.routeDeviationInfoViewController = (UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "RouteDeviationInfoViewController") as! RouteDeviationInfoViewController)
                self.routeDeviationInfoViewController!.initialiseData(riderRide: riderRide, rideParticipantLocation: rideParticipantLocation) { (state, rideRoute) in
                    SharedPreferenceHelper.saveRouteDeviationStatus(id: riderRide.rideId, status: state)
                    if state == RouteDeviationDetector.CONFIRMED, let rideRoute = rideRoute {
                        self.liveRideViewModel.updateRideRoute(ride: ride, route: rideRoute, isRouteDeviated: true)
                    }
                    self.routeDeviationInfoViewController = nil
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: self.routeDeviationInfoViewController!)
            }
        }
    }

}
extension LiveRideMapViewController{
    private func moveToEditPickupView() {
        guard let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide, let riderRide = liveRideViewModel.rideDetailInfo?.riderRide else {
            return
        }
        let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickupDropEditViewController") as? PickupDropEditViewController
        object_setClass(pickUpDropViewController, ConfirmCarpoolPickupOrDropPointViewController.self)
        guard let confirmCarpoolPickupOrDropPointViewController = pickUpDropViewController as? ConfirmCarpoolPickupOrDropPointViewController else { return }
        confirmCarpoolPickupOrDropPointViewController.showConfirmPickPointView(matchedUser: MatchedRider(passengerRide: passengerRide),riderRoutePolyline: riderRide.routePathPolyline, delegate: self, passengerRideId: passengerRide.rideId, riderRideId: passengerRide.riderRideId, passengerId: passengerRide.userId, riderId: passengerRide.riderId, noOfSeats: passengerRide.noOfSeats, isFromEditPickup: true, note: passengerRide.pickupNote)
        self.navigationController?.pushViewController(confirmCarpoolPickupOrDropPointViewController, animated: false)
    }
}

extension LiveRideMapViewController : PickUpAndDropSelectionDelegate {
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?) {
        QuickRideProgressSpinner.startSpinner()
        if let userPreferredPickupDrop = userPreferredPickupDrop {
            liveRideViewModel.updateUserPreferredPickupDrop(userPreferredPickupDrop: userPreferredPickupDrop)
        }

        liveRideViewModel.updatePassengerRideWithNewPickup(matchedUser: matchedUser, userPreferredPickupDrop: userPreferredPickupDrop) {
            QuickRideProgressSpinner.stopSpinner()
            NotificationCenter.default.post(name: .passengerChangedPickup, object: nil)
        }

    }
}

extension LiveRideMapViewController {

    func enableControlsAsPerStatus(){
        guard let currentUserRide = liveRideViewModel.currentUserRide else { return }
        let rideStatus = RideStatus(ride : currentUserRide)
        if currentUserRide.rideType == Ride.PASSENGER_RIDE && currentUserRide.status != Ride.RIDE_STATUS_REQUESTED {
            if rideStatus.isCheckInRideAllowed(){
                rideActionContainerView.isHidden = false
                enableCheckinOrPreCheckinButton()
                liveRideCardViewController.tableViewBottomConstraint.constant = 70
            } else if rideStatus.isCheckOutRideAllowed(){
                rideActionContainerView.isHidden = false
                enableCheckoutButton()
                liveRideCardViewController.tableViewBottomConstraint.constant = 70
            }
        } else if currentUserRide.rideType == Ride.RIDER_RIDE {
            if rideStatus.isStartRideAllowed(){
                rideActionContainerView.isHidden = false
                liveRideCardViewController.tableViewBottomConstraint.constant = 70
                enableStartButton()
            } else if rideStatus.isStopRideAllowed() {
                rideActionContainerView.isHidden = false
                enableStopButton()
                liveRideCardViewController.tableViewBottomConstraint.constant = 70
            }
        }else {
            rideActionContainerView.isHidden = true
            liveRideCardViewController.tableViewBottomConstraint.constant = 0
        }
    }

    func enableCheckinOrPreCheckinButton() {
        self.labelRideActionTitle.isUserInteractionEnabled = true
        checkInAnimationView.animationView.animation = Animation.named("slider")
        checkInAnimationView.animationView.play()
        checkInAnimationView.animationView.loopMode = .loop
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0x00B557)
        if let riderRide = liveRideViewModel.rideDetailInfo?.riderRide, riderRide.status == Ride.RIDE_STATUS_STARTED {
            labelRideActionTitle.text = Strings.checkin_action_caps
        }else{
            labelRideActionTitle.text = Strings.pre_checkin_action_caps
        }
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(rideActionSliderSlided(_:))))
    }

    func enableStopButton(){
        if checkInAnimationView.animationView.isAnimationPlaying == false{
            checkInAnimationView.animationView.animation = Animation.named("slider")
            checkInAnimationView.animationView.play()
            checkInAnimationView.animationView.loopMode = .loop
        }
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0xB50000)
        self.labelRideActionTitle.text = Strings.stop_action_caps
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(rideActionSliderSlided(_:))))
        self.labelRideActionTitle.isUserInteractionEnabled = true
    }

    func enableCheckoutButton(){
        if checkInAnimationView.animationView.isAnimationPlaying == false{
            checkInAnimationView.animationView.animation = Animation.named("slider")
            checkInAnimationView.animationView.play()
            checkInAnimationView.animationView.loopMode = .loop
        }
        self.viewRideActionSlider.backgroundColor = UIColor(netHex: 0xB50000)
        self.labelRideActionTitle.text = Strings.checkout_action_caps
        labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(rideActionSliderSlided(_:))))
        labelRideActionTitle.isUserInteractionEnabled = true
        self.labelRideActionTitle.isHidden = false
    }

    private func enableStartButton() {
        checkInAnimationView.animationView.animation = Animation.named("slider")
        checkInAnimationView.animationView.play()
        checkInAnimationView.animationView.loopMode = .loop
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0x00B557)
        self.labelRideActionTitle.text = Strings.start_action_caps
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(rideActionSliderSlided(_:))))
        self.labelRideActionTitle.isUserInteractionEnabled = true
    }

    @objc func rideActionSliderSlided(_ gesture : UIPanGestureRecognizer){
        if (gesture.state == UIGestureRecognizer.State.began) {
            rideActionLabelCenter = gesture.view!.center
            checkInActionSlideArrowCenter = checkInAnimationView.center
        } else if (gesture.state == UIGestureRecognizer.State.changed) {
            let translate = gesture.translation(in: gesture.view)
            gesture.view!.center = CGPoint(x: rideActionLabelCenter.x + translate.x, y: rideActionLabelCenter.y)
            checkInAnimationView.center = CGPoint(x: checkInActionSlideArrowCenter.x + translate.x, y: checkInActionSlideArrowCenter.y)
            if checkInAnimationView.center.x > self.viewRideActionSlider.frame.width{
                checkInAnimationView.center.x = self.viewRideActionSlider.frame.width - 20
                gesture.view!.center.x = checkInAnimationView.center.x - 70
            }
            if gesture.view!.center.x < self.viewRideActionSlider.frame.origin.x{
                gesture.view!.center.x = self.viewRideActionSlider.frame.origin.x + 30
                checkInAnimationView.center.x = gesture.view!.center.x + 70
            }
        } else if (gesture.state == UIGestureRecognizer.State.ended ) {
            let width = self.viewRideActionSlider.frame.width
            if (checkInAnimationView.center.x - checkInActionSlideArrowCenter.x) > width*slideThersoldPercentage{
                gesture.view!.center = self.rideActionLabelCenter
                performRideAction(rideAction: labelRideActionTitle.text)
            }
            checkInAnimationView.center = checkInActionSlideArrowCenter
            labelRideActionTitle.center = rideActionLabelCenter
        }
    }

    func performRideAction(rideAction: String?){
        AppDelegate.getAppDelegate().log.debug("performRideAction()")
        if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE {
            guard let currentUserRide = liveRideViewModel.currentUserRide as? PassengerRide else {
                return
            }

            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast(Strings.DATA_CONNECTION_NOT_AVAILABLE, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                return
            }else if rideAction == Strings.checkin_action_caps || rideAction == Strings.pre_checkin_action_caps {
                if DateUtils.isTargetTimeWithInBoundary(startTime: currentUserRide.pickupTime, boundaryInMins: 60) == false{
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_not_qualified_to_start, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                    return
                }
                RideManagementUtils.startPassengerRide(passengerRideId: currentUserRide.rideId, riderRideId: currentUserRide.riderRideId, rideCompleteAction: self, viewController: nil)
            }else if rideAction == Strings.checkout_action_caps {
                RideManagementUtils.completePassengerRide(riderRideId: currentUserRide.riderRideId, passengerRideId: currentUserRide.rideId, userId: currentUserRide.userId, targetViewController: nil, rideCompletionActionDelegate: self)
            }
        }else {
            guard let currentUserRide = liveRideViewModel.currentUserRide as? RiderRide else {
                return
            }
            if rideAction == Strings.start_action_caps {
                if DateUtils.isTargetTimeWithInBoundary(startTime: currentUserRide.startTime, boundaryInMins: 60) == false{
                    UIApplication.shared.keyWindow?.makeToast(Strings.ride_not_qualified_to_start, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                    return
                }
                RideManagementUtils.startRiderRide(rideId: liveRideViewModel.getRiderRideId(), rideComplteAction: self,viewController: self)
            }else if rideAction == Strings.stop_action_caps {
                let passengerToPickup = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerToPickUp(riderRideId: liveRideViewModel.getRiderRideId())
                if passengerToPickup == nil || passengerToPickup!.isEmpty{

                    RideManagementUtils.completeRiderRide(riderRideId: liveRideViewModel.getRiderRideId(), targetViewController: self, rideActionCompletionDelegate: self)
                } else {
                    let passengerPickUpViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "PassengersToPickupViewController") as! PassengersToPickupViewController
                    passengerPickUpViewController.initializeDataBeforePresenting(riderRideId: currentUserRide.rideId,  ride: currentUserRide, passengerToBePickup: passengerToPickup!, passengerPickupDelegate: self)
                    ViewControllerUtils.addSubView(viewControllerToDisplay: passengerPickUpViewController)
                }
            }
        }
    }
}

extension LiveRideMapViewController : RideActionComplete {
    func rideActionCompleted(status: String) {
        refreshMapWithNewData()
    }

    func rideActionFailed(status: String, error: ResponseError?) {
        ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self)
    }
}

extension LiveRideMapViewController : PassengerPickupDelegate {
    func passengerPickedUp(riderRideId: Double) {
        RideManagementUtils.completeRiderRide(riderRideId: riderRideId, targetViewController: self,rideActionCompletionDelegate: self)
        guard liveRideCardViewController != nil else {
            return
        }
        liveRideCardViewController.liveRideTableView.reloadData()
    }
}
