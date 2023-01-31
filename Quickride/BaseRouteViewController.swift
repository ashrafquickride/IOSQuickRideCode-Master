//
//  BaseRouteViewController.swift
//  Quickride
//
//  Created by KNM Rao on 15/05/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import ObjectMapper
import SimplZeroClick
import BottomPopup


class BaseRouteViewController: BottomPopupViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ReceiveLocationDelegate, SelectDateDelegate, VehicleDetailsUpdateListener,RideConfigurationDelegate,RouteReceiver,RouteSelectionDelegate,SelectedUserDelegate,UITextFieldDelegate{

    @IBOutlet var toLocationLabel: UIButton!

    @IBOutlet weak var rideScheduleDateView: UIView!

    @IBOutlet weak var rideScheduleTimeLabel: UILabel!

    @IBOutlet weak var MapContainerView: UIView!

    @IBOutlet weak var iboGotoCurrentLoc: UIButton!
    
    @IBOutlet weak var vehicleDetailsOrNoOfSeatsView: UIView!

    @IBOutlet weak var noVehicleView: UIView!

    @IBOutlet var fromLocationLabel: UIButton!

    @IBOutlet weak var scheduleRideButton: UIButton!

    @IBOutlet weak var freeRideOfferView: UIView!

    @IBOutlet weak var freeRideBonusPointLabel: UILabel!

    @IBOutlet weak var freeRideDaysLeftLabel: UILabel!

    @IBOutlet weak var offerIcon: UIImageView!

    @IBOutlet weak var offerCloseMarkView: UIView!

    @IBOutlet weak var cancelImage: UIImageView!

    @IBOutlet weak var RideCreationParentView: UIView!

    @IBOutlet weak var swapButton: CustomUIButton!

    @IBOutlet weak var currentLocationMarker: UIImageView!

    @IBOutlet weak var recurringRideView: UIView!

    @IBOutlet weak var recurringRideViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var createRecurringRideSwitch: UISwitch!

    @IBOutlet weak var recurringRideDaysButton: UIButton!
            
    @IBOutlet weak var promoCodeButton: UIButton!

    // MARK: Variables Declared
    weak var viewMap: GMSMapView!
    var ride:Ride?
    var styles = [GMSStrokeStyle]()
    var lengths = [NSNumber]()
    var polys = [GMSPolyline]()
    var pos = 0.0,step = 0.0
    var timer : Timer?

    var isAttributeDisplayed = false
    var vehicle :Vehicle?
    var startMarker :GMSMarker?
    var endMaker : GMSMarker?
    var selectedPolyLine : GMSPolyline?
    var noOfSeatsSelected : Int = 1
    var MAP_ZOOM : Float = 15
    var isRideCompleted = false
    var locationFromMap = true
    var isReturnRide = false
    var isCurrentLocation = false
    var selectedUser : MatchedUser?
    let passengerIcon = ImageUtils.RBResizeImage(image: UIImage(named: "passenger_marker")!, targetSize: CGSize(width: 20, height: 20))
    let carIcon = ImageUtils.RBResizeImage(image: UIImage(named: "car_marker")!, targetSize: CGSize(width: 20, height: 20))
    let bikeIcon = ImageUtils.RBResizeImage(image: UIImage(named: "bike_marker")!, targetSize: CGSize(width: 25, height: 25))
    let scooterIcon = ImageUtils.RBResizeImage(image: UIImage(named: "scooter")!, targetSize: CGSize(width: 25, height: 25))
    var routePaths = [RideRoute]()

    var routePolylines = [GMSPolyline]()
    var routeDistanceMarker: GMSMarker?
    var selectedRouteId = -1.0
    static var isFromSignUpFlow = false

    static var SHOULD_DISPLAY_RIDE_CREATION_LINK : Bool = false
    static let MIN_MATCHED_OPTIONS_TO_IGNORE_FIND_MATCHING = 5
    static let timeGapForCreateNewRide = 45*60*1000
    var locationUpdateRequested = false
    var rideVehicleConfigurationViewController : RideVehicleConfigurationViewController?
    var isFromRouteOrLocationSelection = false

    static let defaultIndiaLatLngWhenLocationNotFound = CLLocationCoordinate2D(latitude: 21.0000, longitude: 78.0000)
    static let ZOOM_WHEN_LOCATION_NOT_AVAILABLE : Float = 3.0
    var weekdays :[Int : String?] = [Int : String?]()
    var dayType = Ride.ALL_DAYS
    var startTime : Double?
    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    var isRecurringRideRequiredFrom: String?
    var rideTypes = [CommuteSubSegment(name: Strings.find_pool, type: Ride.PASSENGER_RIDE),CommuteSubSegment(name: Strings.offer_pool, type: Ride.RIDER_RIDE)]
    
    func initializeDataBeforePresenting(ride : Ride){
        self.ride = ride
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
         definesPresentationContext = true
        DeviceUniqueIDProxy().checkAndUpdateUniqueDeviceID()
        RideCreationParentView.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: freeRideOfferView, cornerRadius: 10)
        freeRideOfferView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRouteViewController.moveToFreeRidePointsGuidelines(_:))))
        handleImageColorChange()
        offerCloseMarkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRouteViewController.closeBtnTapped(_:))))
        view.autoresizesSubviews  = false
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: MapContainerView)
        setMapViewPadding()
        self.viewMap.delegate = self
        self.viewMap.isMyLocationEnabled = false
        rideScheduleDateView.isUserInteractionEnabled = true
        rideScheduleDateView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(BaseRouteViewController.selectScheduleTime(_:))))
        if let ride = ride{
            if ride.startAddress.isEmpty{
                ride.startAddress = UserDataCache.getInstance()?.userCurrentLocation?.completeAddress ?? ""
                ride.startLatitude = UserDataCache.getInstance()?.userCurrentLocation?.latitude ?? 0
                ride.startLongitude = UserDataCache.getInstance()?.userCurrentLocation?.longitude ?? 0
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude))
                }
                iboGotoCurrentLoc.isHidden = true
            }
            if ride.startTime == 0 || ride.startTime < NSDate().timeIntervalSince1970*1000{
                ride.startTime = NSDate().timeIntervalSince1970*1000
            }
            rideScheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: ride.startTime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
            initializeViewWhenRidePresent()
        }
    
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(BaseRouteViewController.updateToCurrentTime), userInfo: nil, repeats: true)
        RideViewUtils.displaySubscriptionDialogueBasedOnStatus()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.checkAndUpdateGoogleAdvertiserId()
        setRideTypes()
        handleRideTypeViewComponents()
        if ride?.startLatitude != nil,
           ride?.startLongitude != nil,
           ride?.endLatitude != nil,
           ride?.endLongitude != nil{
            currentLocationMarker.isHidden = true
        } else {
            currentLocationMarker.isHidden = false
        }
    }
    func setRideTypes(){
        for index in 0..<rideTypes.count {
            rideTypes[index].selected = rideTypes[index].type == ride?.rideType
        }
    }
    func handleImageColorChange(){
        offerIcon.image = offerIcon.image!.withRenderingMode(.alwaysTemplate)
        offerIcon.tintColor = UIColor.white
        cancelImage.image = cancelImage.image!.withRenderingMode(.alwaysTemplate)
        cancelImage.tintColor = UIColor(netHex:0xd81b60)
    }

    func initializeViewWhenRidePresent() {
        setStartLocation()
        setEndLocation()
        if ride!.routeId != nil && ride!.routeId != 0{
            RoutePathServiceClient.getRideRoute(routeId: ride!.routeId!,startLatitude: ride?.startLatitude ?? 0, startLongitude: ride?.startLongitude ?? 0, endLatitude: ride?.endLatitude ?? 0, endLongitude: ride?.endLongitude ?? 0, waypoints: ride?.waypoints ?? "", overviewPolyline: ride?.routePathPolyline ?? "", travelMode: Ride.DRIVING, useCase: "iOS.App."+(ride?.rideType ?? "Passenger")+".GetRoute.RideCreationView", viewController: self, completionHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let route = Mapper<RideRoute>().map(JSONObject: responseObject!["resultData"]),route.overviewPolyline != nil{
                        self.routePaths.removeAll()
                        self.routePaths.append(route)
                        self.selectedRouteId = route.routeId!
                        self.drawAllPossibleRoutesWithSelectedRoute()
                    }else{
                        self.getRoutesAvailable()
                    }

                }else{
                    self.getRoutesAvailable()
                }
            })
        }else{
            getRoutesAvailable()
        }

        var currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        if currentUserVehicle == nil{
            currentUserVehicle = Vehicle.getDeFaultVehicle()
        }
        vehicle = currentUserVehicle?.copy() as? Vehicle
        let userId = QRSessionManager.getInstance()?.getUserId()
        if userId?.isEmpty == false{
            ride!.userId = Double(userId!)!
        }
        initializeMatchingOptionsAsPerRecentRideType()
    }

   
    
    
    //MARK: Reload self view controller when same view controller selected without popping

    func setMapViewPadding() {
        self.viewMap.padding = UIEdgeInsets(top: 40, left: 10, bottom: 40, right: 10)
        self.viewMap.animate(toZoom: 16)
    }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        self.navigationController?.isNavigationBarHidden = true
        isAttributeDisplayed = UserDataCache.isBannerDisplayed
        if !isAttributeDisplayed {
            displayFirstRideBonusOffer()
        }

        displayNoConnectionDialogue()
        setPromoCodeButton()
        if ContainerTabBarViewController.fromPopRooController{
            ContainerTabBarViewController.fromPopRooController = false
            return
        }
        if(vehicle == nil){
            var currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
            if currentUserVehicle == nil{
                currentUserVehicle = Vehicle.getDeFaultVehicle()
            }
            vehicle = currentUserVehicle?.copy() as? Vehicle
        }
        vehicleAndNoOfSeatsBasedOnRideType()
        displayUpdateApplicationIfRequired()
        updateToCurrentTime()

        if rideVehicleConfigurationViewController != nil{
            rideVehicleConfigurationViewController!.displayView()
        }
        viewMap.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: self.MapContainerView.frame.height - 40)
    }

    func scheduleBtnColorChange(){
        if self.fromLocationLabel.currentTitle == Strings.enter_start_location || self.toLocationLabel.currentTitle == Strings.enter_end_location{
            scheduleRideButton.isUserInteractionEnabled = false
            CustomExtensionUtility.changeBtnColor(sender: self.scheduleRideButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        }
        else{
            scheduleRideButton.isUserInteractionEnabled = true
            CustomExtensionUtility.changeBtnColor(sender: self.scheduleRideButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        }
    }
    func displayNoConnectionDialogue(){
        InternetTrackerUtils().checkInternetAvailability(viewController: self) { (value) in
        }
    }
    @objc func updateToCurrentTime(){

        if (ride?.startTime ?? 0)  < NSDate().getTimeStamp(){
            ride?.startTime = NSDate().getTimeStamp()
            rideScheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        }
    }

    func displayOffersIfApplicable()
    {
        let configurationCache = ConfigurationCache.getInstance()
        if configurationCache == nil {
            isAttributeDisplayed = true
            return
        }
        let offersList = ConfigurationCache.getOfferList()
        if offersList.isEmpty
        {
            isAttributeDisplayed = true
            return
        }
        UserDataCache.getInstance()!.updateEntityDisplayStatus(key: UserDataCache.OFFER, status: true)
        var appLevelOfferList = [Offer]()
        for offer in offersList
        {
            if (offer.displayType == Strings.displaytype_both || offer.displayType == Strings.displaytype_app_level)
            {
                appLevelOfferList.append(offer)
            }
        }
        if appLevelOfferList.isEmpty
        {
            return
        }
        let offer = getOfferToDisplay(offers : appLevelOfferList)
        displayOfferDialogue(offer: offer)

    }
    func getOfferToDisplay(offers : [Offer]) -> Offer
    {
        for offer in offers{
            if SharedPreferenceHelper.getOfferDisplayStatus(offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id)) == false
            {

                return offer
            }
        }

        for offer in offers
        {
            SharedPreferenceHelper.setOfferDisplayStatus(flag: false, offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id))
        }
        return offers[0]
    }
    func displayOfferDialogue(offer : Offer)
    {
        if offer.inAppOffersImageUri != nil{
            self.isAttributeDisplayed = true
            ImageCache.getInstance().getImageFromCache(imageUrl: offer.inAppOffersImageUri!, imageSize: ImageCache.ORIGINAL_IMAGE, handler: { (image, imageURI) in
             if image != nil{
                let alertDisplayView = AlertDisplayView.loadFromNibNamed(nibNamed: "AlertDisplayView",bundle: nil) as! AlertDisplayView
                alertDisplayView.initializeViews(title: nil, message: nil, image: nil,viewController: self, actionTitle: nil, offer: offer, offerImage: image, backgroundColor: nil, x: 15 , y: 100, handler: nil)
                SharedPreferenceHelper.setOfferDisplayStatus(flag: true, offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id))
                }else{
                    self.isAttributeDisplayed = false
                    self.displayEntity()
                }
            })
        }
        else
        {
            SharedPreferenceHelper.setOfferDisplayStatus(flag: true, offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id))
        }
    }


    func vehicleAndNoOfSeatsBasedOnRideType(){
        if ride == nil
        {
            return
        }
        if ride?.rideType == Ride.RIDER_RIDE{
            if vehicle == nil{
                var currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
                if currentUserVehicle == nil{
                    currentUserVehicle = Vehicle.getDeFaultVehicle()
                }
                vehicle = currentUserVehicle?.copy() as? Vehicle
            }
            self.vehicleConfigured(vehicle: vehicle!)
            let userId = QRSessionManager.getInstance()?.getUserId()
            if userId?.isEmpty == false{
                ride!.userId = Double(userId!)!
            }
        }else{
            numberSelected(number: self.noOfSeatsSelected)
        }
    }

    func findPassengersSelected()
    {
        ride!.rideType = Ride.RIDER_RIDE
        self.vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
                       if self.vehicle!.vehicleId == 0 || self.vehicle!.registrationNumber.isEmpty == true
                       {
                       noVehicleView.isHidden = false
                       vehicleDetailsOrNoOfSeatsView.isHidden = true
                   } else {
                       noVehicleView.isHidden = true
                       vehicleDetailsOrNoOfSeatsView.isHidden = false
                   setVehicleDetails()
               }
        drawAllPossibleRoutesWithSelectedRoute()
    }

    func findRidersSelected()
    {
        ride!.rideType = Ride.PASSENGER_RIDE
        numberSelected(number : noOfSeatsSelected)
        noVehicleView.isHidden = true
        vehicleDetailsOrNoOfSeatsView.isHidden = false
    }

    @objc func vehicleDetailsOrNoOfSeatsViewTapped(_ sender : UITapGestureRecognizer){

        if ride!.rideType == Ride.PASSENGER_RIDE{

            let seatsSelectionViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "NumberOfSeatsSelector") as! SeatsSelectionViewController
            seatsSelectionViewController.initializeDataBeforePresenting(handler: { (seats) in
                 self.numberSelected(number: seats)
            }, seatsSelected: noOfSeatsSelected)
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: seatsSelectionViewController, animated: false, completion: nil)
        }else if ride!.rideType == Ride.RIDER_RIDE{

            if UserDataCache.getInstance()?.uservehicles.count == 0 {

                let newRideVehicleConfigurationViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "NewRideVehicleConfigurationViewController") as! NewRideVehicleConfigurationViewController
                newRideVehicleConfigurationViewController.initializeDataBeforePresenting(viewController: self, vehicle: vehicle!, ride: nil, rideConfigurationDelegate: self)

                ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: newRideVehicleConfigurationViewController, animated: false, completion: nil)

            }else{

                let rideVehicleConfigurationViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "RideVehicleConfigurationViewController") as! RideVehicleConfigurationViewController
                rideVehicleConfigurationViewController.initializeDataBeforePresenting(vehicle : vehicle!,rideConfigurationDelegate : self, dismissHandler: {
                    self.rideVehicleConfigurationViewController = nil
                })
                ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: rideVehicleConfigurationViewController, animated: false, completion: nil)
            }

        }
    }

    override  func viewDidAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewDidAppear()")
        ContainerTabBarViewController.indexToSelect = 1
        if QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus != UserSessionStatus.Guest && UserDataCache.SUBSCRIPTION_STATUS == false && !isFromRouteOrLocationSelection
        {
            self.displayEntity()
        }
        isFromRouteOrLocationSelection = false
        swapButton.changeBackgroundColorBasedOnSelection()
        iboGotoCurrentLoc.addTarget(self, action:#selector(BaseRouteViewController.HoldButton(_:)), for: UIControl.Event.touchDown)
        iboGotoCurrentLoc.addTarget(self, action:#selector(BaseRouteViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        self.GotoCurrentLocation(1)
    }

    func displayEntity()
    {
        if UserDataCache.getInstance() == nil{
            return
        }
        if ContainerTabBarViewController.isRideCompleted
        {
            ContainerTabBarViewController.isRideCompleted = false

        }
        else if !isAttributeDisplayed
        {

            if let pendingBills = UserDataCache.getInstance()?.pendingLinkedWalletTransactions,pendingBills.count > 0,!UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.PENDING_LINKED_WALLET_TRANSACTIONS){

                openPendingLinkedWalletTransactionViewController(pendingLinkedWalletTransactions: pendingBills)

            }else if !UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.RIDE_ASSURED_INCENTIVE){

                getRideAssuredIncentive()

            }else if !UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.UNVERIFIED_ALERT_DIALOGUE)
            {
                BaseRouteViewController.isFromSignUpFlow = false
                if UserDataCache.getInstance()?.userProfile != nil && UserDataCache.getInstance()?.userProfile?.verificationStatus == 0
                {
                    displayUnverifiedUserAlert()
                }
                UserDataCache.getInstance()!.updateEntityDisplayStatus(key: UserDataCache.UNVERIFIED_ALERT_DIALOGUE, status: true)
                if !isAttributeDisplayed{
                    displayEntity()
                }
            }
            
            else if !UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.OFFER) && !BaseRouteViewController.isFromSignUpFlow
            {
                displayOffersIfApplicable()
                if !isAttributeDisplayed{
                    displayEntity()
                }
            }
        }

    }

    func displayUnverifiedUserAlert()
    {
        let lastDisplayedTime = SharedPreferenceHelper.getUnVerifiedUserAlertDisplayedTime()
        if lastDisplayedTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayedTime!) < 24*60
        {
            return
        }
        let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()
        if profileVerificationData == nil{
            return
        }
        else{
            self.isAttributeDisplayed = true
            var clientConfig = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfig == nil{
                clientConfig = ClientConfigurtion()
            }
            if !profileVerificationData!.emailVerified && !profileVerificationData!.imageVerified && !clientConfig!.disableImageVerification{
                let alertDisplayView = AlertDisplayView.loadFromNibNamed(nibNamed: "AlertDisplayView",bundle: nil) as! AlertDisplayView
                alertDisplayView.initializeViews(title: Strings.profile_verification_pending, message: Strings.verify_profile, image: UIImage(named: "not_verify_icon"),viewController: self, actionTitle: Strings.verify_now, offer: nil, offerImage: nil, backgroundColor: UIColor(netHex: 0xCE3838), x: 15, y: 100, handler: {(result) in
                    self.moveToProfileEditViewController()
                })
                SharedPreferenceHelper.setUnVerifiedUserAlertDisplayTime(time: NSDate())
            }
            else if !profileVerificationData!.imageVerified && !clientConfig!.disableImageVerification{
                let alertDisplayView = AlertDisplayView.loadFromNibNamed(nibNamed: "AlertDisplayView",bundle: nil) as! AlertDisplayView
                alertDisplayView.initializeViews(title: Strings.profile_picture_missing, message: Strings.add_profile_picture_and_get_profile_verification, image: UIImage(named: "unknown_profile_icon"),viewController: self, actionTitle: Strings.add_now, offer: nil, offerImage: nil, backgroundColor: UIColor(netHex: 0x6887FE), x: 15, y: 100, handler: {(result) in
                    let profileDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard,bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileDisplayViewController) as! ProfileDisplayViewController
                    profileDisplayViewController.displayActionButton = true
                    let profileEditViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard,bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
                    profileEditViewController.initializeView(setProfileImage: true, setDesignation: false)
                    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
                    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileEditViewController, animated: false)
                })
                SharedPreferenceHelper.setUnVerifiedUserAlertDisplayTime(time: NSDate())
            }
            else if !profileVerificationData!.emailVerified{

                let alertDisplayView = AlertDisplayView.loadFromNibNamed(nibNamed: "AlertDisplayView",bundle: nil) as! AlertDisplayView
                alertDisplayView.initializeViews(title: Strings.verify_email, message: Strings.verify_email_and_get_profile_verification, image: UIImage(named: "email_icon_large"),viewController: self, actionTitle: Strings.verify_now, offer: nil, offerImage: nil, backgroundColor: UIColor(netHex: 0xCF853B), x: 15, y: 100, handler: {(result) in
                    if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.userProfile != nil && UserDataCache.getInstance()!.userProfile!.email != nil && !UserDataCache.getInstance()!.userProfile!.email!.isEmpty && UserDataCache.getInstance()!.userProfile!.companyName != nil && !UserDataCache.getInstance()!.userProfile!.companyName!.isEmpty{
                        let vc = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard,bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileDisplayViewController) as! ProfileDisplayViewController
                        vc.displayActionButton = true
                        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: vc, animated: false)
                    }
                    else{
                        self.moveToProfileEditViewController()
                    }
                })
                SharedPreferenceHelper.setUnVerifiedUserAlertDisplayTime(time: NSDate())
            }
        }
    }

    func moveToProfileEditViewController(){
        let profileDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard,bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileDisplayViewController) as! ProfileDisplayViewController
        profileDisplayViewController.displayActionButton = true
        let profileEditViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard,bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileEditViewController, animated: false)
    }
    func vehicleConfigurationConfirmed(vehicle: Vehicle) {
        self.vehicleConfigured(vehicle: vehicle)
    }

    func vehicleConfigured(vehicle: Vehicle){
        self.vehicle = vehicle
        setVehicleDetails()
        drawAllPossibleRoutesWithSelectedRoute()
    }
    func setVehicleDetails()
    {
        var vehicleModel = ""
        var vehicleModelImage :UIImage?

        if self.vehicle!.vehicleId == 0 || vehicle!.registrationNumber.isEmpty{
            vehicleModel = self.vehicle?.vehicleModel ?? ""
            noVehicleView.isHidden = false
            vehicleDetailsOrNoOfSeatsView.isHidden = true
        }else{
            noVehicleView.isHidden = true
            vehicleDetailsOrNoOfSeatsView.isHidden = false
            vehicleModel = self.vehicle?.registrationNumber ?? ""
            vehicleModel = String(vehicleModel.suffix(4))
        }
        var vehicleFare = ""
        if let fare = vehicle?.fare{
            vehicleFare = String(format: Strings.points_per_km, arguments: [String(fare)])
        }
        var vehicleCapacity = ""
        if vehicle?.vehicleType == Vehicle.VEHICLE_TYPE_CAR,let capacity = vehicle?.capacity{
            vehicleModelImage = UIImage(named: "vehicle_type_car_grey")
            vehicleCapacity = String(format: Strings.multi_seat, arguments: [String(capacity)])
        }else{
            vehicleModelImage = UIImage(named: "vehicle_type_bike_grey")
        }
        setVehicleModelText(vehicleModel: vehicleModel, vehicleCapacity: vehicleCapacity, vehicleFare: vehicleFare, image: vehicleModelImage!)
    }

    func numberSelected(number : Int) {
        self.noOfSeatsSelected = number
        drawAllPossibleRoutesWithSelectedRoute()
    }


    @IBAction func fromLocationTapped(_ sender: Any) {
        if ride!.startAddress.isEmpty == true{
            moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location:nil,alreadySelectedLocation: Location(latitude: ride?.endLatitude ?? 0,longitude: ride?.endLongitude ?? 0,shortAddress: ride?.endAddress))
        }else{
            moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: Location(latitude: ride!.startLatitude,longitude: ride!.startLongitude,shortAddress: ride!.startAddress),alreadySelectedLocation: Location(latitude: ride?.endLatitude ?? 0,longitude: ride?.endLongitude ?? 0,shortAddress: ride?.endAddress))
        }
    }

    @IBAction func toLocationTapped(_ sender: Any) {
        if ride!.endAddress.isEmpty == true{
            moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location:nil,alreadySelectedLocation: Location(latitude: ride?.startLatitude ?? 0,longitude: ride?.startLongitude ?? 0,shortAddress: ride?.startAddress))
        }else{
            moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: Location(latitude: ride!.endLatitude!,longitude: ride!.endLongitude!,shortAddress: ride!.endAddress),alreadySelectedLocation: Location(latitude: ride?.startLatitude ?? 0,longitude: ride?.startLongitude ?? 0,shortAddress: ride?.startAddress))
        }
    }
    func VehicleDetailsUpdated()
    {
        vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        setVehicleDetails()
        createRide()
    }

    @IBAction func schedulRideClicked(_ sender: Any) {
            createRide()
    
    }
    
   
    @objc func selectScheduleTime(_ getsture: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        
        scheduleLater.delegate = self
        scheduleLater.minDate = NSDate().timeIntervalSince1970
        scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime
        
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    func getTime(date: Double) {
        AppDelegate.getAppDelegate().log.debug("getTime")
        
        ride!.startTime = date*1000
        rideScheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: date), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        getTimeForWeekDay()
        drawAllPossibleRoutesWithSelectedRoute()
        
    }
    func getSelectedRoute() -> RideRoute?{

        for route in routePaths {

            if route.routeId == selectedRouteId{
                return route
            }
        }
        if routePaths.count == 1{
            return routePaths[0]
        }
        return nil
    }
    

    @IBAction func GotoCurrentLocation(_ sender: Any) {
        if let currentRideRoute = getSelectedRoute(), currentRideRoute.overviewPolyline != nil{
            GoogleMapUtils.fitToScreen(route: currentRideRoute.overviewPolyline!, map: self.viewMap)
        }else {
            if let startLatitude = ride?.startLatitude, let startLongitude = ride?.startLongitude {
            let location = CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
                moveToCoordinate(coordinate: location)
            }
        }
        iboGotoCurrentLoc.isHidden = true
    }
    
    @IBAction func ibaSwapAddress(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("ibaSwapAddress()")
        if isRecurringRideRequiredFrom == RegularRideCreationViewController.HOME_TO_OFFICE{
            isRecurringRideRequiredFrom = RegularRideCreationViewController.OFFICE_TO_HOME
        }else if isRecurringRideRequiredFrom == RegularRideCreationViewController.OFFICE_TO_HOME{
            isRecurringRideRequiredFrom = RegularRideCreationViewController.HOME_TO_OFFICE
        }
        let tempString = ride!.startAddress
        ride!.startAddress = ride!.endAddress
        ride!.endAddress = tempString

        var tempDouble = ride!.startLatitude
        ride!.startLatitude = ride!.endLatitude!
        ride!.endLatitude = tempDouble

        tempDouble = ride!.startLongitude
        ride!.startLongitude = ride!.endLongitude!
        ride!.endLongitude = tempDouble
        setStartLocation()
        setEndLocation()
        getRoutesAvailable()

    }
    
    
    func moveToLocationSelection(){
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let changeLocationVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController")as! ChangeLocationViewController
        changeLocationVC.receiveLocationDelegate = self
        changeLocationVC.requestedLocationType = ChangeLocationViewController.DESTINATION
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

    func getUserTypeIcon(userType : String,vehicleType : String?)->UIImage{
        if userType == MatchedUser.PASSENGER{
            return passengerIcon
        }else if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            return bikeIcon
        }else{
            return carIcon
        }
    }

    func selectedUser(selectedUser: MatchedUser) {
        self.selectedUser = selectedUser
        createRide()
    }

    func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: self, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

    // MARK: Protocol Delegate Functions implemented

    func receiveSelectedRoute(ride : Ride?,route : RideRoute){
        isFromRouteOrLocationSelection = true
        clearRouteData()
        routePaths.append(route)
        selectedRouteId = route.routeId ?? -1
        drawAllPossibleRoutesWithSelectedRoute()

    }

    func getRoutesAvailable(){

        clearRouteData()
        if ride != nil && ride!.startLatitude != 0 && ride!.startLongitude != 0 && ride!.endLatitude != 0 && ride!.endLongitude != 0
        {
            MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App."+(ride!.rideType ?? "Passenger")+".AllRoutes.RideCreationView", rideId: ride!.rideId, startLatitude: ride!.startLatitude, startLongitude: ride!.startLongitude, endLatitude: ride!.endLatitude!, endLongitude: ride!.endLongitude!, weightedRoutes: false, routeReceiver: self)
        }
    }
    func handleUserPreferredRoute() {
        if ride != nil && ride!.startLatitude != 0 && ride!.startLongitude != 0 && ride!.endLatitude != 0 && ride!.endLongitude != 0{
            let userPreferredRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: ride!.startLatitude, startLongitude: ride!.startLongitude, endLatitude: ride!.endLatitude!, endLongitude: ride!.endLongitude!)

            if userPreferredRoute != nil
            {
                if let route = userPreferredRoute!.rideRoute{
                    routePaths.append(route)
                    self.selectedRouteId = route.routeId ?? -1
                    MyRoutesCache.getInstance()?.saveUserRoute(route: route, key: nil)

                }else{
                    getRideRouteUsingPreferredRoute(userPrefRoute: userPreferredRoute!)
                }
            }
        }
    }

    // MARK: Protocol Delegate Functions implemented
    func receiveRoute(rideRoute:[RideRoute], alternative: Bool){
        clearRouteData()
        if rideRoute.isEmpty == true{
            routePaths.removeAll()
        }else{
            currentLocationMarker.isHidden = true
            routePaths = MyRoutesCache.cleanupRoutes(routes: rideRoute)
            for route in routePaths{
                if route.routeType == RoutePathData.ROUTE_TYPE_MAIN || route.routeType == RoutePathData.ROUTE_TYPE_DEFAULT{
                    selectedRouteId = route.routeId!
                    break
                }
            }
            if selectedRouteId == -1{
                selectedRouteId = routePaths[0].routeId!
            }
            handleUserPreferredRoute()
            drawAllPossibleRoutesWithSelectedRoute()
        }
    }


    func getRideRouteUsingPreferredRoute(userPrefRoute : UserPreferredRoute){
        MyRoutesCache.getInstance()?.getUserRoute(routeId: userPrefRoute.routeId!,startLatitude: userPrefRoute.fromLatitude ?? 0, startLongitude: userPrefRoute.fromLongitude ?? 0, endLatitude: userPrefRoute.toLatitude ?? 0, endLongitude: userPrefRoute.toLongitude ?? 0, waypoints: userPrefRoute.rideRoute?.waypoints, overviewPolyline: userPrefRoute.rideRoute?.overviewPolyline, travelMode: Ride.DRIVING, useCase: "iOS.App."+(ride?.rideType ?? "Passenger")+".GetRoute.RideCreationView",handler: { (route) in
            self.routePaths.append(route)
            self.selectedRouteId = route.routeId ?? -1
            self.drawAllPossibleRoutesWithSelectedRoute()
            userPrefRoute.rideRoute = route
            UserDataCache.getInstance()?.updateUserPreferredRoute(userPreferredRoute: userPrefRoute)
        })
    }


    func drawAllPossibleRoutesWithSelectedRoute(){
        
        AppDelegate.getAppDelegate().log.debug("drawAllPossibleRoutesWithSelectedRoute()")
        
        if ride == nil || ride!.endLatitude == nil || ride!.endLongitude == nil{
            return
        }
        
        for polyline in routePolylines{
            polyline.map = nil
        }
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        routePolylines.removeAll()
        
        for route in routePaths {
            if route.routeId! == selectedRouteId && route.overviewPolyline != nil{
                self.ride!.distance = route.distance
                drawUserRoute(rideRoute: route)
                displayTimeAndDistanceInfoView(routePathData: route)
            }else{
                let polyline = GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!, map: viewMap, colorCode: UIColor(netHex: 0x767676), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
                polyline.userData = route.routeId
                routePolylines.append(polyline)
            }
        }
        
    }
   
    func displayTimeAndDistanceInfoView(routePathData : RideRoute){
        
        let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "RouteTimeAndChangeRouteInfoView") as! RouteTimeAndChangeRouteInfoView
        routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!, duration: routePathData.duration)
        routeTimeAndChangeRouteInfoView.addShadow()
        let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView)
        let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
        routeDistanceMarker?.map = nil
        if path != nil && path!.count() != 0{
            routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
        }
        
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
      AppDelegate.getAppDelegate().log.debug("changeRouteClicked")
        if let rideRoute = getSelectedRoute(){
            let selectRouteFromMapViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
            selectRouteFromMapViewController.initializeDataBeforePresenting(ride: ride!, rideRoute: rideRoute,routeSelectionDelegate: self)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectRouteFromMapViewController, animated: false)
        }
        return nil
    }
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        AppDelegate.getAppDelegate().log.debug("didTapOverlay")
        guard let polyline = overlay as? GMSPolyline,let routeId = polyline.userData as? Double else{
            return
        }
        if selectedRouteId == routeId{
            return
        }
        self.selectedRouteId = routeId
        drawAllPossibleRoutesWithSelectedRoute()

    }

    // MARK: Protocol Delegate Functions implemented
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {

        AppDelegate.getAppDelegate().log.debug("receiveRouteFailed")

        clearRouteData()
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route_due_to_network, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/3), title: nil, image: nil, completion: nil)
            
        }else{
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
        }
        moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: ride!.startLatitude, longitude: ride!.startLongitude))
    }

    func drawUserRoute(rideRoute : RideRoute )
    {
        guard let overViewPolyline = rideRoute.overviewPolyline else{
            return
        }
        prepareStartAndEndMarkers()
        selectedPolyLine = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: viewMap, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        selectedPolyLine!.userData = rideRoute.routeId
        routePolylines.append(selectedPolyLine!)
        let polyline = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: viewMap, colorCode: UIColor(netHex: 0x005BA4), width: GoogleMapUtils.POLYLINE_WIDTH_10, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
        routePolylines.append(polyline)
        GoogleMapUtils.fitToScreen(route: overViewPolyline, map: self.viewMap)
        
    }
    func prepareStartAndEndMarkers(){}
    func getMinMaxFare(){}

    func clearRouteData(){
        routePaths.removeAll()
        if(selectedPolyLine != nil){
            selectedPolyLine?.map = nil
            selectedPolyLine = nil
        }
        if startMarker != nil{
            startMarker?.map = nil
            startMarker = nil
        }
        if endMaker != nil{
            endMaker?.map = nil
            endMaker = nil
        }
        for polyline in routePolylines{
            polyline.map = nil
        }
        routePolylines.removeAll()
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        selectedRouteId = -1
        ride?.distance = 0
    }



    func getRiderRide() -> RiderRide?{
        var riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: BillViewController.COMPLETED_RIDE_ID!)
        if (riderRide == nil)
        {
            riderRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: BillViewController.COMPLETED_RIDE_ID!)

        }
        return riderRide
    }
    func getPassengerRide() -> PassengerRide?{
        var passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: BillViewController.COMPLETED_RIDE_ID!)
        if(passengerRide == nil)
        {
            passengerRide = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: BillViewController.COMPLETED_RIDE_ID!)
        }
        return passengerRide
    }

    func displayUpdateApplicationIfRequired(){

        if isAttributeDisplayed{
            return
        }
        AppDelegate.getAppDelegate().log.debug("displayUpdateApplicationIfRequired()")
        let configurationCache = ConfigurationCache.getInstance()
        if configurationCache == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        let updateStatus = ConfigurationCache.getInstance()!.appUpgradeStatus
        if updateStatus == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        if updateStatus == User.UPDATE_REQUIRED{
            isAttributeDisplayed = true
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : false, message1: Strings.upgrade_version, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : nil,linkButtonText : nil,viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }else if updateStatus == User.UPDATE_AVAILABLE {
            isAttributeDisplayed = true
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : true, message1: Strings.new_version_available, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : Strings.later_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }
    }
    func moveToAppStore(){
        AppDelegate.getAppDelegate().log.debug("moveToAppStore()")
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {

            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)

        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.please_upgrade_from_app_store, duration: 3.0, position: .center)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        timer?.invalidate()
        UserDataCache.isBannerDisplayed = true
    }


    func createRide(){
        AppDelegate.getAppDelegate().log.debug("createRide()")
        if ride!.startTime < NSDate().timeIntervalSince1970*1000{
            ride!.startTime = NSDate().timeIntervalSince1970*1000
        }

        if ride!.rideType == Ride.RIDER_RIDE{
            if RideValidationUtils.validatePreconditionsForCreatingRide(ride: ride!, vehicle: vehicle, fromLocation: fromLocationLabel.titleLabel?.text, toLocation: toLocationLabel.titleLabel?.text, viewController: self) == true {
                return
            }
            if self.vehicle == nil{
               self.vehicle  = UserDataCache.getInstance()!.getCurrentUserVehicle()
            }

            if self.vehicle!.vehicleId == 0 || self.vehicle!.registrationNumber.isEmpty == true
            {
                displayVehicleConfigurationDialog()
                return
            }
            let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: ride!)
            if redundantRide != nil{
                let timeDifference = ride!.startTime - redundantRide!.startTime
                if timeDifference < Double(BaseRouteViewController.timeGapForCreateNewRide){
                    RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: self)
                }else{
                    displayRedundentRideAlert(newRide: ride!, ride: redundantRide!,viewController: self)
                }
               return
            }
            let duplicateRide = MyActiveRidesCache.singleCacheInstance?.checkForDuplicateRideOnSameDay(ride: ride!)

            if duplicateRide == nil
            {
                createRiderRide(ride: ride!)
            }
            else
            {
                displayDuplicatedRideForSameDayAlertDialog(newRide: ride!, duplicateRide: duplicateRide!)

            }

        }
        else{
            if RideValidationUtils.validatePreconditionsForCreatingRide(ride: ride!, vehicle: vehicle, fromLocation: fromLocationLabel.titleLabel?.text, toLocation: toLocationLabel.titleLabel?.text, viewController: self) == true {
                return
            }
            let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: ride!)
            if redundantRide != nil{
                let timeDifference = ride!.startTime - redundantRide!.startTime
                if timeDifference < Double(BaseRouteViewController.timeGapForCreateNewRide){
                    RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: self)
                }else{
                    displayRedundentRideAlert(newRide: ride!, ride: redundantRide!, viewController: self)
                }
                return
            }
            let duplicateRide = MyActiveRidesCache.singleCacheInstance?.checkForDuplicateRideOnSameDay(ride: ride!)
        

            if duplicateRide == nil
            {

                createPassengerRide(ride: ride!)
            }
            else
            {
                
               
                
                displayDuplicatedRideForSameDayAlertDialog(newRide: ride!, duplicateRide: duplicateRide!)
            }
        }
    }
    func displayRedundentRideAlert(newRide: Ride, ride: Ride, viewController : UIViewController){
        AppDelegate.getAppDelegate().log.debug("displayRedundentRideAlert()")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.ride_duplication_alert, message2: nil, positiveActnTitle: Strings.view_caps, negativeActionTitle: Strings.createNew_caps, linkButtonText: nil, viewController: viewController, handler: { (result) -> Void in
            if result == Strings.view_caps{
                let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
                mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false, relaySecondLegRide: nil,requiredToShowRelayRide: "")
                let myRides = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
                self.navigationController?.popViewController(animated: false)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: myRides, animated: false)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
            }else if result == Strings.createNew_caps{
                if ride.rideType == Ride.RIDER_RIDE{
                    self.createRiderRide(ride: newRide)
                }else{
                    self.createPassengerRide(ride: newRide)
                }
            }
        })
    }


    func createPassengerRide(ride: Ride){
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: self, handler: {(result) in
            self.continueCreatingPassengerRide(ride: ride)
        })
    }
    
    func continueCreatingPassengerRide(ride: Ride){
        if self.selectedRouteId != -1{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5 , execute: {

                self.continueCreatePassengerRide(ride: ride)
            })
        }else{
            self.continueCreatePassengerRide(ride: ride)
        }
    }
    
    func continueCreatePassengerRide(ride: Ride){
      
        if RideValidationUtils.validateRideDistance(ride:ride){
            let message = String(format: Strings.ride_distance_alert, arguments: [RideValidationUtils.MAXIMUM_DISTANCE_TO_CREATE_RIDE_IN_KM])
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: message, message2: nil, positiveActnTitle: Strings.update_caps, negativeActionTitle: Strings.confirm_caps, linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.confirm_caps == result{
                    self.completePassengerRideCreation(ride: ride)
                }
            })
        }
        else{
            self.completePassengerRideCreation(ride: ride)
        }
    }
    func completePassengerRideCreation(ride : Ride){
        let passengerRide = PassengerRide(ride: ride)
        passengerRide.noOfSeats = noOfSeatsSelected
         let currentRideRoute = getSelectedRoute()
        if createRecurringRideSwitch.isOn{
            createPassengerRecurringRide(regularPassengerRide: RegularPassengerRide(passengerRide: passengerRide), rideRoute: currentRideRoute)
        }
        let createPassengerRideHandler : CreatePassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide,rideRoute: currentRideRoute, isFromInviteByContact: false, targetViewController: self, parentRideId: nil,relayLegSeq: nil)
        createPassengerRideHandler.createPassengerRide(handler: { [weak self](passengerRide, error) -> Void in
            if error != nil{
                MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: self,handler: nil)
                self?.ride?.promocode = nil
            }else{
                self?.generateSimplData()
                FaceBookEventsLoggingUtils.logFindRideEvent(contentType: "", contentData: "find_ride", contentId: "", searchString: "", success: true)
                if self?.selectedUser != nil && self?.selectedUser!.userRole == MatchedUser.RIDER{
                    self?.sendInviteToselectedRider(passengerRide: passengerRide!)
                }else{
                    self?.moveToRideView(ride: passengerRide!)
                }
            }
        })
    }

    func generateSimplData(){

        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let email = userProfile?.email == nil ?
            userProfile?.emailForCommunication == nil ? "" : userProfile?.emailForCommunication
            : userProfile?.email

        if UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL{
            let user = GSUser(phoneNumber: String(UserDataCache.getInstance()!.currentUser!.phoneNumber), email: email!)
             GSManager.shared().generateFingerprint(for: user) { (payload) in
                guard payload != nil else {
                    return
                }

                AccountRestClient.setSimplData(userId: (QRSessionManager.getInstance()?.getUserId())!, simplData: payload!, viewController: self, handler: { (response, error) in
                    if response != nil{

                    }
                })
            }
        }
    }

    func sendInviteToselectedRider(passengerRide : PassengerRide){
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(selectedUser as! MatchedRider)
        InviteRiderHandler(passengerRide: passengerRide, selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: self).inviteSelectedRiders { (error,nserror) in
            self.moveToRideView(ride: passengerRide)
        }
    }
    var accountUtils :  AccountUtils?
    func createRiderRide(ride: Ride){
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: self, handler: {(result) in
            self.continueCreatingRiderRide(ride: ride)
        })
    }
    
    func continueCreatingRiderRide(ride: Ride){
        if self.selectedRouteId != -1{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.continueCreateRiderRide(ride: ride)

            })

        }else{
            self.continueCreateRiderRide(ride: ride)
        }
    }
    
    func continueCreateRiderRide(ride: Ride){
        
        if RideValidationUtils.validateRideDistance(ride:ride){
            let message = String(format: Strings.ride_distance_alert, arguments: [RideValidationUtils.MAXIMUM_DISTANCE_TO_CREATE_RIDE_IN_KM])
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: message, message2: nil, positiveActnTitle: Strings.update_caps, negativeActionTitle: Strings.confirm_caps, linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.confirm_caps == result{
                    self.completeRiderRideCreation(ride: ride)
                }
            })
        }
        else{
            self.completeRiderRideCreation(ride: ride)
        }

    }

    func fillAndGetRiderRideValues(ride: Ride) -> RiderRide{
        let riderRide = RiderRide(ride: ride)
        riderRide.availableSeats = vehicle!.capacity
        riderRide.capacity = vehicle!.capacity
        riderRide.vehicleModel = vehicle!.vehicleModel
        riderRide.vehicleType = vehicle!.vehicleType
        riderRide.vehicleNumber = vehicle!.registrationNumber
        riderRide.farePerKm = vehicle!.fare
        riderRide.additionalFacilities = vehicle!.additionalFacilities
        riderRide.makeAndCategory = vehicle!.makeAndCategory
        riderRide.vehicleId = vehicle!.vehicleId
        riderRide.vehicleImageURI = vehicle!.imageURI
        riderRide.riderHasHelmet = vehicle!.riderHasHelmet
        return riderRide
    }

    func completeRiderRideCreation(ride: Ride){
        let riderRide = fillAndGetRiderRideValues(ride: ride)
        let currentRideRoute = getSelectedRoute()
        if createRecurringRideSwitch.isOn{
            createRiderRecurringRide(regularRiderRide: RegularRiderRide(riderRide: riderRide), rideRoute: currentRideRoute)
        }
        let createRiderRideHandler : CreateRiderRideHandler = CreateRiderRideHandler(ride: riderRide,rideRoute :currentRideRoute, isFromInviteByContact: false, targetViewController: self)
        createRiderRideHandler.createRiderRide(handler: { (riderRide, error) -> Void in
            if error != nil{
                QuickRideProgressSpinner.stopSpinner()
                MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: self,handler: nil)
                self.ride?.promocode = nil
            }else{
                FaceBookEventsLoggingUtils.logOfferRideEvent(contentData: "offer_ride", contentId: "", contentType: "", currency: "", price: 0)
                if self.selectedUser != nil && self.selectedUser!.userRole == MatchedUser.PASSENGER{
                    self.sendInviteToSelectedPassenger(riderRide: riderRide!)

                }else{
                    self.moveToRideView(ride: riderRide!)
                }
            }
        })
    }
    func sendInviteToSelectedPassenger(riderRide : RiderRide){
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(selectedUser as! MatchedPassenger)
        InviteSelectedPassengersAsyncTask(riderRide: riderRide, selectedUsers: selectedPassengers, viewController: self, displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
            self.moveToRideView(ride: riderRide)
        }).invitePassengersFromMatches()
    }
    func moveToRideView(ride :Ride){
        AppDelegate.getAppDelegate().log.debug("moveToRideView()")
        QuickRideProgressSpinner.stopSpinner()
        let liveRideMapViewController = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        liveRideMapViewController.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false, relaySecondLegRide: nil,requiredToShowRelayRide: "")
        let myRides = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: ride, isFromCanceRide: false, isFromRideCreation: true)
        self.navigationController?.pushViewController(myRides, animated: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: liveRideMapViewController, animated: false)
        self.navigationController?.pushViewController(sendInviteBaseViewController, animated: false)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 4)
    }
    
    func inviteSentToPassengers(riderRide : RiderRide){
        moveToRideView(ride: riderRide)
    }
    func displayDuplicatedRideForSameDayAlertDialog( newRide : Ride, duplicateRide : Ride)
    {
        let myalertview =  UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "DuplicateRideViewController") as! DuplicateRideViewController

         myalertview.displayErrorAlertWithAction(message: String(format: Strings.ride_duplicate_alert, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: duplicateRide.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)!]), positiveActnTitle: Strings.reschedule_caps, negativeActionTitle : Strings.createNew_caps, handler: { (result) in
            
            if result == Strings.createNew_caps{
                if newRide.rideType == Ride.RIDER_RIDE{
                    self.createRiderRide(ride: newRide)
                }else{
                    self.createPassengerRide(ride: newRide)
                }
            }
            else if result == Strings.reschedule_caps{
                RescheduleRide(ride: duplicateRide, viewController: self,moveToRideView: true).rescheduleRide()
            }
        })
       
        myalertview.modalPresentationStyle = .overFullScreen
        self.present(myalertview, animated: false, completion: nil)
    }
    


    func displayVehicleConfigurationDialog(){
        let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
        vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false, rideConfigurationDelegate: nil,vehicle : nil,listener : self)
        self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
    }

    func checkAndUpdatePrimaryRegion(location :Location){

        if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.currentUser != nil && (UserDataCache.getInstance()!.currentUser!.primaryRegion == nil || UserDataCache.getInstance()!.currentUser!.primaryRegion!.isEmpty){

            self.updatePrimaryRegionToDB(location: location)

        }
    }

    func updatePrimaryRegionToDB(location : Location){
        if location.state != nil{
            UserRestClient.updateUserPrimaryRegion(userId: UserDataCache.getInstance()!.currentUser!.phoneNumber, primaryRegion: location.state!, primaryLat: location.latitude, primaryLong: location.longitude, country: location.country, state: location.state, city: location.city, streetName: location.streetName, areaName: location.areaName, address: location.completeAddress, viewContrller: self, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.currentUser != nil && (UserDataCache.getInstance()!.currentUser!.primaryRegion == nil || UserDataCache.getInstance()!.currentUser!.primaryRegion!.isEmpty){
                        UserDataCache.getInstance()!.currentUser!.primaryAreaLat = location.latitude
                        UserDataCache.getInstance()!.currentUser!.primaryAreaLng = location.latitude
                        UserDataCache.getInstance()!.currentUser!.primaryArea = location.shortAddress
                        UserDataCache.getInstance()?.currentUser!.primaryRegion = location.state
                    }
                }
            })
        }
    }

    func updateRecentLocationOfUser(userPrimaryAreaInfo : UserPrimaryAreaInfo){
        let lastUpdatedTime = SharedPreferenceHelper.getRecentLocationUpdatedTime()
        if lastUpdatedTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastUpdatedTime!) < 24*60
        {
            return
        }
        SharedPreferenceHelper.setRecentLocationUpdatedTime(time: NSDate())
        UserRestClient.updateUserRecentLocation(userId: UserDataCache.getInstance()?.currentUser?.phoneNumber, locationInfo: userPrimaryAreaInfo.toJSONString(), viewContrller: self) { (responseObject, error) in
            if responseObject == nil || (responseObject != nil && responseObject!["result"] as! String == "FAILURE"){
                SharedPreferenceHelper.setRecentLocationUpdatedTime(time: nil)// if failed to update retry again
            }
        }
    }

    

    
  // MARK: Protocol Delegate Functions implemented

    func receiveSelectedLocation(location: Location, requestLocationType: String) {

        AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        isFromRouteOrLocationSelection = true
        isCurrentLocation = false
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
    }
    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.ORIGIN{

            ride!.startLatitude = location.latitude
            ride!.startLongitude = location.longitude
            ride!.startAddress = location.completeAddress!
            self.setStartLocation()
            checkForStartAndEndLocations(latitude: location.latitude, longitude: location.longitude)

            checkAndUpdatePrimaryRegion(location: location)
            self.locationFromMap = false
            moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }else{
            ride!.endLatitude = location.latitude
            ride!.endLongitude = location.longitude
            ride!.endAddress = location.completeAddress!
            self.setEndLocation()
        }
        getRoutesAvailable()
    }
    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
    }

    func moveToCoordinate(coordinate : CLLocationCoordinate2D){
        AppDelegate.getAppDelegate().log.debug("Current Location" + String(coordinate.latitude) + "," + String(coordinate.longitude))
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16))
    }
    

    func checkForStartAndEndLocations( latitude : Double, longitude : Double){
        AppDelegate.getAppDelegate().log.debug("checkForStartAndEndLocations()")
        let userDataCache = UserDataCache.sharedInstance
        if userDataCache == nil {
            return
        }
        let homeLocation = userDataCache!.getHomeLocation()
        if homeLocation != nil{
            if LocationClientUtils.getDistance(fromLatitude: homeLocation!.latitude!, fromLongitude: homeLocation!.longitude!, toLatitude: latitude, toLongitude: longitude) < 1000{
                let officeLocation = userDataCache!.getOfficeLocation()
                if officeLocation != nil{
                    setDestinationFromFavouriteLocation(favLocation: userDataCache!.getOfficeLocation())
                    if LocationClientUtils.getDistance(fromLatitude: homeLocation!.latitude!, fromLongitude: homeLocation!.longitude!, toLatitude: latitude, toLongitude: longitude) < 200{
                        setSourceFromFavouriteLocation(favLocation: userDataCache!.getHomeLocation())
                    }
                    getRoutesAvailable()
                }
                return
            }
        }
        let officeLocation = userDataCache!.getOfficeLocation()
        if officeLocation != nil{
            if LocationClientUtils.getDistance(fromLatitude: officeLocation!.latitude!, fromLongitude: officeLocation!.longitude!, toLatitude: latitude, toLongitude: longitude) < 1000{
                setDestinationFromFavouriteLocation(favLocation: userDataCache!.getHomeLocation())
                if LocationClientUtils.getDistance(fromLatitude: officeLocation!.latitude!, fromLongitude: officeLocation!.longitude!, toLatitude: latitude, toLongitude: longitude) < 200{
                    setSourceFromFavouriteLocation(favLocation: userDataCache!.getOfficeLocation())
                }
                getRoutesAvailable()
                return
            }
        }
    }
    func setDestinationFromFavouriteLocation(favLocation : UserFavouriteLocation?){
        AppDelegate.getAppDelegate().log.debug("setDestinationFromFavouriteLocation()")
        if favLocation != nil{

            ride!.endLatitude = favLocation!.latitude
            ride!.endLongitude = favLocation!.longitude
            ride!.endAddress = favLocation!.address!
            self.setEndLocation()
            self.locationFromMap = false
        }
    }
    func setSourceFromFavouriteLocation(favLocation : UserFavouriteLocation?){
        AppDelegate.getAppDelegate().log.debug("setSourceFromFavouriteLocation()")
        if favLocation != nil{

            ride!.startLatitude = favLocation!.latitude!
            ride!.startLongitude = favLocation!.longitude!
            ride!.startAddress = favLocation!.address!
            self.setStartLocation()
            self.locationFromMap = false
        }
    }
    func onFailed(responseObject: NSDictionary?, error: NSError?) {
    }
    func notSelected() {
        selectedUser = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }


    @objc func guestDialogueViewTapped(_ sender : UITapGestureRecognizer){
        let signupViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
        self.navigationController?.pushViewController(signupViewController, animated: false)
    }
    func getDifferenceBtwTwoDays(freeRideExpiryDate : Double) -> Int{

       return  DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: freeRideExpiryDate/1000))
    }

    func getExpiryDate(expiryTime : Double) -> String{

        return DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: (expiryTime)/1000), dateFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)!
    }
    func displayFirstRideBonusOffer(){


        let freeRideCoupon = RideManagementUtils.checkWhetherFreeRideCouponIsPresent()

        if freeRideCoupon != nil && freeRideCoupon!.activationTime != nil && freeRideCoupon!.expiryTime != nil && !(UserDataCache.getInstance()?.getEntityDisplayStatus(key: UserDataCache.FREE_RIDE_OFFER_DAILOGUE))!{

            let difference = getDifferenceBtwTwoDays(freeRideExpiryDate: freeRideCoupon!.expiryTime!)
            if difference < 0{
                self.freeRideOfferView.isHidden = false
                self.freeRideBonusPointLabel.text = String(format: Strings.you_have_free_ride_points, arguments: [StringUtils.getPointsInDecimal(points: (freeRideCoupon!.maxFreeRidePoints))])
                self.freeRideDaysLeftLabel.text = String(format: Strings.utilize_free_ride_points, arguments: [getExpiryDate(expiryTime: freeRideCoupon!.expiryTime!)])
                self.isAttributeDisplayed = true
                self.offerCloseMarkView.isHidden = false
            }else{
                self.isAttributeDisplayed = false
                self.freeRideOfferView.isHidden = true
                self.offerCloseMarkView.isHidden = true
            }
          }else{
                self.isAttributeDisplayed = false
                self.freeRideOfferView.isHidden = true
                self.offerCloseMarkView.isHidden = true
         }
    }

    
    @objc func moveToFreeRidePointsGuidelines(_ sender: UITapGestureRecognizer){
        let freeRideInfoDialogue = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "FreeRideInfoDialogue") as! FreeRideInfoDialogue
        self.navigationController?.view.addSubview(freeRideInfoDialogue.view)
        self.navigationController?.addChild(freeRideInfoDialogue)
        freeRideInfoDialogue.view!.layoutIfNeeded()

    }

    @objc func HoldButton(_ sender: UIButton){
         sender.backgroundColor = UIColor.lightGray
    }

    @objc func HoldRelease(_ sender: UIButton){
        sender.backgroundColor = UIColor.white
    }

    @objc func closeBtnTapped(_ sender: UITapGestureRecognizer) {
        UserDataCache.getInstance()!.updateEntityDisplayStatus(key: UserDataCache.FREE_RIDE_OFFER_DAILOGUE, status: true)
        freeRideOfferView.isHidden = true
        isAttributeDisplayed = false
        offerCloseMarkView.isHidden = true
    }

    func getRideAssuredIncentive(){
        let rideAssuredIncentive = SharedPreferenceHelper.getRideAssuredIncentive()

        if rideAssuredIncentive == nil{
            getRideAssuredIncentiveFromServer()
            return
        }
        let lastFetchedDate = NSDate(timeIntervalSince1970: rideAssuredIncentive!.lastFetchedTime/1000)
        if rideAssuredIncentive!.status == RideAssuredIncentive.INCENTIVE_STATUS_ACTIVE || DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastFetchedDate) > 24*60{
            getRideAssuredIncentiveFromServer()
            return
        }
        self.displayRideAssuredIncentiveOfferDialogueIfApplicable(rideAssuredIncentive: rideAssuredIncentive!)
        UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.RIDE_ASSURED_INCENTIVE, status: true)
        if !isAttributeDisplayed{
            displayEntity()
        }
    }

    func getRideAssuredIncentiveFromServer(){
        AccountRestClient.getRideAsurredIncentiveIfApplicable(userId: (QRSessionManager.getInstance()?.getUserId())!, viewController: self) { (responseObject, error) in

            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                var rideAssuredIncentive : RideAssuredIncentive?

                if responseObject!["resultData"] != nil{
                    rideAssuredIncentive = Mapper<RideAssuredIncentive>().map(JSONObject: responseObject!["resultData"])
                }else{
                    rideAssuredIncentive = RideAssuredIncentive()
                }
                rideAssuredIncentive!.lastFetchedTime = NSDate().getTimeStamp()
                SharedPreferenceHelper.storeRideAssuredIncentive(rideAssuredIncentive: rideAssuredIncentive)
                self.displayRideAssuredIncentiveOfferDialogueIfApplicable(rideAssuredIncentive: rideAssuredIncentive!)
            }
            UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.RIDE_ASSURED_INCENTIVE, status: true)
            if !self.isAttributeDisplayed{
                self.displayEntity()
            }
        }
    }



    func displayRideAssuredIncentiveOfferDialogueIfApplicable(rideAssuredIncentive : RideAssuredIncentive){
        if rideAssuredIncentive.userId == 0{
            isAttributeDisplayed = false
            return
        }
        let lastDisplayTime = SharedPreferenceHelper.getRideAssuredIncentiveDialogueDisplaytime()
        let displayCount = SharedPreferenceHelper.getRideAssuredIncentiveDisplayCount()
        if lastDisplayTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayTime!) < 24*60 && displayCount >= 2{
            isAttributeDisplayed = false
            return
        }
        if displayCount >= 2{
            SharedPreferenceHelper.setRideAssuredIncentiveDisplayCount(count: 0)
        }


        if rideAssuredIncentive.status == RideAssuredIncentive.INCENTIVE_STATUS_OPEN{
            isAttributeDisplayed = true
            let rideAssuredIncentiveOfferDisplayDialogue = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAssuredIncentiveOfferDisplayView") as! RideAssuredIncentiveOfferDisplayView
            rideAssuredIncentiveOfferDisplayDialogue.initializeDataBeforePresenting(rideAssuredIncentive: rideAssuredIncentive)
            self.view.addSubview(rideAssuredIncentiveOfferDisplayDialogue.view)
            self.addChild(rideAssuredIncentiveOfferDisplayDialogue)
            rideAssuredIncentiveOfferDisplayDialogue.view!.layoutIfNeeded()
            SharedPreferenceHelper.setRideAssuredIncentiveDialogueDisplaytime(time: NSDate())
            SharedPreferenceHelper.setRideAssuredIncentiveDisplayCount(count: displayCount + 1)
        }
    }
 func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {

        clearRouteData()
        if preferredRoute.fromLocation != nil{
            self.ride!.startLatitude = preferredRoute.fromLatitude!
            self.ride!.startLongitude = preferredRoute.fromLongitude!
            self.ride!.startAddress = preferredRoute.fromLocation!
            setStartLocation()
        }
        if preferredRoute.toLocation != nil{
            self.ride!.endLatitude = preferredRoute.toLatitude!
            self.ride!.endLongitude = preferredRoute.toLongitude!
            self.ride!.endAddress = preferredRoute.toLocation!
            setEndLocation()
        }

        if let rideRoute = MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId) {
            routePaths.removeAll()
            routePaths.append(rideRoute)
            selectedRouteId = rideRoute.routeId ?? -1
            drawAllPossibleRoutesWithSelectedRoute()
        }else{
            getRoutesAvailable()
        }

    }


    func checkAndUpdateGoogleAdvertiserId(){
        let googleAdvertisingId = UserDataCache.getInstance()?.currentUser?.googleAdvertisingId
        if googleAdvertisingId == nil{
            if let idfa = AppDelegate.getAppDelegate().getIDFA(){
                UserRestClient.updateGoogleAdvertiserId(userId: (QRSessionManager.getInstance()?.getUserId())!, googleAdvertisingId: idfa, viewController: self) { (responseObject, error) in
                }
            }
        }
    }

    func openPendingLinkedWalletTransactionViewController(pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]){
        let pendingLinkedWalletTransactionVC = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PendingUPILinkedWalletTransactionViewController") as! PendingUPILinkedWalletTransactionViewController
        pendingLinkedWalletTransactionVC.initializeDataBeforePresenting(pendingLinkedWalletTransactions: pendingLinkedWalletTransactions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: pendingLinkedWalletTransactionVC)

        UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.PENDING_LINKED_WALLET_TRANSACTIONS, status: true)
        isAttributeDisplayed = true
    }

    // Mark: Implementation is in RouteViewController
    func  handleRideTypeViewComponents() {}

    func initializeMatchingOptionsAsPerRecentRideType(){}

    func setVehicleModelText(vehicleModel : String, vehicleCapacity: String, vehicleFare: String, image : UIImage){}

    func setStartLocation(){}

    func setEndLocation(){}


    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            iboGotoCurrentLoc.isHidden = false
        }else{
            iboGotoCurrentLoc.isHidden = true
        }
//        iboGotoCurrentLoc.isHidden = false
//        if gesture && !routePaths.isEmpty{
//            if !routePaths.isEmpty {
//                currentLocationMarker.isHidden = false
//            }
//        }else{
//          iboGotoCurrentLoc.isHidden = true
//        }

    }

    func checkRecurringRideEnableAndDisableStatus(){
        createRecurringRideSwitch.setOn(false, animated: false)
        recurringRideDaysButton.setTitle(Strings.create_rec_ride, for: .normal)
//        let activeRides = MyRegularRidesCache.getInstance().getActiveRegularRiderRides().count + MyRegularRidesCache.getInstance().getActiveRegularPassengerRides().count
//        if activeRides >= 2{
//            createRecurringRideSwitch.setOn(false, animated: false)
//            recurringRideDaysButton.setTitle(Strings.create_rec_ride, for: .normal)
//        }else{
//            getTimeForWeekDay()
//            createRecurringRideSwitch.setOn(true, animated: false)
//            recurringRideDaysButton.setTitle(self.prepareStringForRecurringRideBasedOnDays(), for: .normal)
//        }
        dayType = Ride.ALL_DAYS
    }

    func createRiderRecurringRide(regularRiderRide: RegularRiderRide, rideRoute: RideRoute?){
        let regularRiderRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularRiderRide, weekdays: weekdays) as! RegularRiderRide
        regularRiderRide.fromDate = getReccuringRideFromDate()
        regularRiderRide.dayType = self.dayType
        RecurringRideUtils().continueCreatingRegularRiderRide(regularRiderRide: regularRiderRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: nil)
    }

    func createPassengerRecurringRide(regularPassengerRide: RegularPassengerRide, rideRoute: RideRoute?){
        let regularPassengerRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularPassengerRide, weekdays: weekdays) as! RegularPassengerRide
        regularPassengerRide.fromDate = getReccuringRideFromDate()
        regularPassengerRide.dayType = self.dayType
        RecurringRideUtils().continueCreatingRegularPassengerRide(regularPassengerRide: regularPassengerRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: nil)
    }

    func checkCurrentRideIsValidForRecurringRide(ride: Ride) -> Bool{
        let regularRide : RegularRide?
        if ride.rideType == Ride.RIDER_RIDE{
            regularRide = RegularRiderRide(ride: ride)
        }else{
            regularRide = RegularPassengerRide(ride: ride)
        }
        if RecurringRideUtils().isValidDistance(ride: ride){
            return false
        }else if MyRegularRidesCache.getInstance().checkForDuplicate(regularRide: regularRide!){
            return false
        }else{
            return true
        }
    }
    func getReccuringRideFromDate() -> Double{
        var fromDate : NSDate?
        if let time = startTime,let date = DateUtils.getNSDateFromTimeStamp(timeStamp: time){
            fromDate = date.addDays(daysToAdd: 1)
            if date.isLessThanDate(dateToCompare: NSDate()){
                fromDate = NSDate()
            }
            return fromDate?.getTimeStamp() ?? time
        }else{
            return NSDate().getTimeStamp()
        }
    }
    
    func getTimeForWeekDay(){
        startTime = ride?.startTime
        for index in 0...6{
            getTimeForEachDay(weekDayIndex: index)
        }
    }
    func getTimeForEachDay(weekDayIndex: Int){
        if weekDayIndex == 5 || weekDayIndex == 6{
            weekdays[weekDayIndex] = nil
        }else{
            weekdays[weekDayIndex] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride?.startTime, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
        }
    }
    func prepareStringForRecurringRideBasedOnDays() -> String{
        var daysString = ""
        for index in 0...6{
            if weekdays[index] != nil && index == 0{
                daysString = Strings.mon
            }else if weekdays[index] != nil && index == 1{
               daysString += ", "+Strings.tue
            }else if weekdays[index] != nil && index == 2{
                daysString += ", "+Strings.wed
            }else if weekdays[index] != nil && index == 3{
                daysString += ", "+Strings.thu
            }else if weekdays[index] != nil && index == 4{
                daysString += ", "+Strings.fri
            }else if weekdays[index] != nil && index == 5{
                daysString += ", "+Strings.sat
            }else if weekdays[index] != nil && index == 6{
                daysString += ", "+Strings.sun
            }
        }
        return daysString
    }

    @IBAction func promocodeClicked(_ sender: UIButton) {
        applyPromoCode()
    }

    private func applyPromoCode()
    {

        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView

        applyPromoCodeView!.initializeDataBeforePresentingView(title: Strings.apply_promo_code, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: ride?.promocode, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.promo_code_hint, promoCodeAppliedMsg: String(format: Strings.promo_code_applied, arguments: [ride?.promocode ?? ""]), handler: { (text, result) in
            if Strings.apply_caps == result{
                if text != nil {
                    self.verifyPromoCode(promoCode : text!)
                }
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
    }

    private func verifyPromoCode(promoCode : String){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.applyProcode(promoCode: promoCode ,userId: QRSessionManager.getInstance()?.getUserId() ?? "0", uiViewController: self, completionHandler: { [weak self] responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            guard let self = `self` else{
                return
            }
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                self.ride!.promocode = promoCode
                self.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.promo_code_applied, arguments: [promoCode]))
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                self.ride!.promocode = nil
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]) {
                    self.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
                } else {
                    self.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
                }
            } else{
                self.ride!.promocode = nil
                self.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
            }
            self.setPromoCodeButton()
        })
    }
    private func setPromoCodeButton(){
        if ride?.promocode != nil {
            self.promoCodeButton.setImage(UIImage(named: "applied_promo_icon"), for: .normal)
            self.promoCodeButton.backgroundColor = UIColor(netHex: 0x007AFF)
        } else {
            self.promoCodeButton.setImage(UIImage(named: "promo_code_icon"), for: .normal)
            self.promoCodeButton.backgroundColor = UIColor.white
        }
    }
 @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

