//
//  HighAlertNotificationViewController.swift
//  Quickride
//
//  Created by Bandish Kumar on 23/10/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import Polyline

class HighAlertNotificationViewController:  UIViewController {
    //MARK: Outlets
    @IBOutlet weak var alertTypeTitleLabel: UILabel!
    @IBOutlet weak var alertLocationDetailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileVerificationImageView: UIImageView!
    @IBOutlet weak var companyTitleLabel: UILabel!
    @IBOutlet weak var walkPathView: UIView!
    @IBOutlet weak var walkPathFromSourceToPickUpLabel: UILabel!
    @IBOutlet weak var walkPathDropToDestinationLabel: UILabel!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var routeMatchingPercentageLabel: UILabel!
    @IBOutlet weak var rideFareLabel: UILabel!
    @IBOutlet weak var alertCancelButton: UIButton!
    @IBOutlet weak var alertAcceptButton: UIButton!
    @IBOutlet weak var alertDeclineButton: UIButton!
    @IBOutlet weak var liveLocationButton: UIButton!
    @IBOutlet weak var walkPathViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickupWalkPathTimeView: UIView!
    @IBOutlet weak var dropWalkPathTimeView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var carOrBikeIcon: UIImageView!
    @IBOutlet weak var endToDropWalkIcon: UIImageView!
    
    //MARK: Properties
    weak var mapView: GMSMapView!
    private var isOverlappingRouteDrawn = false
    weak var routePathPolyline : GMSPolyline?
    private var pickUpMarker,dropMarker,distanceMarker : GMSMarker?
    private var highAlertViewModel: HighAlertViewModel?
    #if WERIDE
    private let breakPoint = UIImage(named: "circle_with_arrow")!
    #else
    #endif
    
    //MARK: Initializer
    func initializeData(notification: UserNotification, notificationHandler: NotificationHandler, rideInvitation: RideInvitation, ride: Ride, matchedUser: MatchedUser?){
        highAlertViewModel = HighAlertViewModel(notification: notification, notificationHandler: notificationHandler, rideInvitation: rideInvitation, ride: ride, matchedUser: matchedUser)
    }
    
    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView = QRMapView.getQRMapView(mapViewContainer: mapContainerView)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 80)
        self.mapView.delegate = self
        self.setupUI()
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HIGH_ALERT_DISPLAYED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "", "rideId": highAlertViewModel?.ride?.rideId], uniqueField: User.FLD_USER_ID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Methods
    private func configureUI() {
        liveLocationButton.isHidden = true
        ViewCustomizationUtils.addCornerRadiusToView(view: alertAcceptButton, cornerRadius: 10)
        ViewCustomizationUtils.addCornerRadiusToView(view: walkPathView, cornerRadius: 5)
        ViewCustomizationUtils.addBorderToView(view: walkPathView, borderWidth: 1.0, color: UIColor(netHex: 0xfcfcfc))
    }
    
    private func setupUI() {
        if let matchedUser = highAlertViewModel?.matchedUser {
            if highAlertViewModel?.rideInvitation?.rideType == Ride.RIDER_RIDE  {
                walkPathViewHeightConstraint.constant = 50
                walkPathView.isHidden = false
                alertTypeTitleLabel.text = "New Ride Invite "
            } else {
                walkPathViewHeightConstraint.constant = 0
                walkPathView.isHidden = true
                alertTypeTitleLabel.text = "New Ride Request"
            }
            userNameLabel.text = matchedUser.name
            companyTitleLabel.text = matchedUser.companyName
            ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: matchedUser.imageURI, gender: matchedUser.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            userProfileVerificationImageView.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser.profileVerificationData)
            pickupTimeLabel.text = highAlertViewModel?.checkAndSetPickupTimeText()
            if matchedUser.newFare != -1{
                rideFareLabel.attributedText = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.newFare),actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.points),textColor: rideFareLabel.textColor)
            }else{
                rideFareLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points)
            }
            highAlertViewModel?.checkAndSetMatchingPercentage()
            routeMatchingPercentageLabel.text = highAlertViewModel?.getMatchedPercentage()
            let startTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate!, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_H_mm)
            alertLocationDetailLabel.text = "Towards " + (matchedUser.dropLocationAddress ?? "") + " | " + (startTime ?? "")
            drawMatchedUserRoute()
            checkChatAndCallOptionAvailableOrNot()
        }
        
    }
    
    private func drawMatchedUserRoute(){
        AppDelegate.getAppDelegate().log.debug("drawMatchedUserRoute()")
        let matchedUser = highAlertViewModel?.matchedUser
        let ride = highAlertViewModel?.ride
        if matchedUser == nil || ride == nil || matchedUser!.routePolyline == nil || matchedUser!.routePolyline!.isEmpty || mapView == nil, ride!.routePathPolyline.isEmpty {
            return
        }
        if matchedUser!.userRole == MatchedUser.PASSENGER || matchedUser!.userRole == MatchedUser.REGULAR_PASSENGER{
            let start = CLLocation(latitude: matchedUser!.fromLocationLatitude!,longitude: matchedUser!.fromLocationLongitude!)
            let end =  CLLocation(latitude: matchedUser!.toLocationLatitude!, longitude: matchedUser!.toLocationLongitude!)
            
            let pickup =  CLLocation(latitude: matchedUser!.pickupLocationLatitude!,longitude: matchedUser!.pickupLocationLongitude!)
            
            let drop =  CLLocation(latitude: matchedUser!.dropLocationLatitude!,longitude: matchedUser!.dropLocationLongitude!)
            GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride!.rideId,useCase: "IOS.App."+ride!.rideType!+".WalkRoute.HighAlertView", riderRoutePolyline: ride!.routePathPolyline,passengerRoutePolyline: matchedUser!.routePolyline!,passengerStart: start,passengerEnd: end, pickup: pickup, drop: drop, passengerRideDistance: matchedUser!.rideDistance, map: mapView, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5,handler: { (cumalativeDistance) in
                self.initializeWalkPathView(cumalativeTravelDistance: cumalativeDistance!)
            })
        }else{
            walkPathView.isHidden = true
            walkPathViewHeightConstraint.constant = 0
            GoogleMapUtils.drawRoute(pathString: matchedUser!.routePolyline!, map: mapView, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        }
        drawOverlappingRoute()
    }
    
    private func initializeWalkPathView(cumalativeTravelDistance : CummulativeTravelDistance) {
        walkPathView.isHidden = false
        walkPathViewHeightConstraint.constant = 50
        if cumalativeTravelDistance.passengerStartToPickup > 0.01 && cumalativeTravelDistance.passengerDropToEnd > 0.01{
            pickupWalkPathTimeView.isHidden = false
            dropWalkPathTimeView.isHidden = false
            walkPathFromSourceToPickUpLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerStartToPickup)
            walkPathDropToDestinationLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            setIconToWalkPathView()
            changeDropWalkIconBasedOnDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
        }else if cumalativeTravelDistance.passengerStartToPickup > 0.01 {
            pickupWalkPathTimeView.isHidden = false
            dropWalkPathTimeView.isHidden = true
            walkPathFromSourceToPickUpLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerStartToPickup)
            setIconToWalkPathView()
        }else if cumalativeTravelDistance.passengerDropToEnd > 0.01{
            pickupWalkPathTimeView.isHidden = true
            dropWalkPathTimeView.isHidden = false
            walkPathDropToDestinationLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            setIconToWalkPathView()
            changeDropWalkIconBasedOnDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
        } else {
            walkPathView.isHidden = true
            walkPathViewHeightConstraint.constant = 0
        }
    }
    
    private func changeDropWalkIconBasedOnDistance(distance : Double){
        if distance > 1.5{
            endToDropWalkIcon.image = UIImage(named : "running")
        }else{
            endToDropWalkIcon.image = UIImage(named : "path")
        }
    }
    
    private func checkChatAndCallOptionAvailableOrNot(){
        if (highAlertViewModel?.matchedUser?.userRole == MatchedUser.RIDER || highAlertViewModel?.matchedUser?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }else if let enableChatAndCall = highAlertViewModel?.matchedUser?.enableChatAndCall, !enableChatAndCall{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }else{
            showCallAndChatOption()
        }
    }
    
    private func showCallAndChatOption(){
        if highAlertViewModel?.matchedUser?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: highAlertViewModel?.matchedUser?.userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                callButton.backgroundColor = UIColor(netHex: 0x2196f3)
            }else{
                callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            }
        }else if highAlertViewModel?.matchedUser?.callSupport == UserProfile.SUPPORT_CALL_ALWAYS{
            callButton.backgroundColor = UIColor(netHex: 0x2196f3)
        }else{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
        chatButton.backgroundColor = UIColor(netHex: 0x19ac4a)
    }
    private func setIconToWalkPathView()
    {
        if let ride = highAlertViewModel?.ride, ride.rideType == Ride.RIDER_RIDE {
            if ride.isKind(of: RiderRide.self) && (ride as! RiderRide).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                carOrBikeIcon.image = UIImage(named : "motorbike")
            }else{
                carOrBikeIcon.image = UIImage(named : "car_new")
            }
        }else{
            if let matchedUser = highAlertViewModel?.matchedUser, matchedUser.userRole == MatchedUser.RIDER, (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE {
                carOrBikeIcon.image = UIImage(named : "motorbike")
            }else{
                carOrBikeIcon.image = UIImage(named : "car_new")
            }
        }
        
    }
    
    private func drawOverlappingRoute(){
        if let matchedUser = highAlertViewModel?.matchedUser, let riderRoutePolyline = matchedUser.routePolyline {
            isOverlappingRouteDrawn = true
            
            let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
            let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
            let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: riderRoutePolyline)
            if matchedRoute.count < 3 {
                return
            }
            setPickUpMarker(pickUp: pickUp)
            setDropMarker(drop: drop)
            setDistanceMarker()
            let polyline = Polyline(coordinates: matchedRoute)
            GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: mapView, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        }
        perform(#selector(drawRouteAfterDelay), with: self, afterDelay: 0.5)
    }
    
    @objc func drawRouteAfterDelay(){
        if let routePloyline = highAlertViewModel?.matchedUser?.routePolyline, mapView != nil{
            GoogleMapUtils.fitToScreen(route: routePloyline,map : mapView)
        }
    }
    
    private func setPickUpMarker(pickUp : CLLocationCoordinate2D){
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.pick_up_caps, markerImage: UIImage(named: "green")!, zoomState: nil)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        pickUpMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: pickUp, shortIcon: icon,tappable: false,anchor :CGPoint(x: 0.25, y: 0.25))
        pickUpMarker?.zIndex = 8
    }
    
    private func setDropMarker(drop : CLLocationCoordinate2D){
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.drop_caps, markerImage: UIImage(named: "drop_icon")!, zoomState: nil)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        dropMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: drop, shortIcon: icon,tappable: false,anchor :CGPoint(x: 0.25, y: 0.25))
        dropMarker?.zIndex = 8
    }
    
    
    private func setDistanceMarker(){
        let distanceInfoView = UIView.loadFromNibNamed(nibNamed: "DistanceInfoView") as! DistanceInfoView
        distanceInfoView.initializeDataBeforePresenting(distance: highAlertViewModel?.matchedUser?.distance)
        let icon = ViewCustomizationUtils.getImageFromView(view: distanceInfoView)
        let path = GMSPath(fromEncodedPath: highAlertViewModel?.matchedUser?.routePolyline ?? "")
        if path != nil && path!.count() != 0{
            distanceMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: false, anchor: CGPoint(x: 1, y: 0.7))
            distanceMarker?.zIndex = 8
        }
    }
    
    //MARK: Actions
    @IBAction func alertCancelButtonTapped(_ sender: UIButton) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HIGH_ALERT_CLOSED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","rideId": highAlertViewModel?.ride?.rideId], uniqueField: User.FLD_USER_ID)
        self.navigationController?.popViewController(animated: false)
        if let notificationHandler = highAlertViewModel?.notificationHandler, let notification = highAlertViewModel?.notification {
            notificationHandler.handleNeutralAction(userNotification: notification, viewController: self)
        }
        
    }
    
    @IBAction func alertAcceptButtonTapped(_ sender: UIButton) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HIGH_ALERT_ACCEPT, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","rideId": highAlertViewModel?.ride?.rideId)
        self.navigationController?.popViewController(animated: false)
        if let notificationHandler = highAlertViewModel?.notificationHandler, let notification = highAlertViewModel?.notification {
            notificationHandler.handlePositiveAction(userNotification: notification, viewController: self)
        }
    }
    
    @IBAction func alertDeclineButtontapped(_ sender: UIButton) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HIGH_ALERT_DECLINE, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","rideId": highAlertViewModel?.ride?.rideId], uniqueField: User.FLD_USER_ID)
        self.navigationController?.popViewController(animated: false)
        if let notificationHandler = highAlertViewModel?.notificationHandler, let notification = highAlertViewModel?.notification {
            notificationHandler.handleNegativeAction(userNotification: notification, viewController: self)
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        if let matchedUser = highAlertViewModel?.matchedUser {
            let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as? ProfileDisplayViewController)!
            
            var vehicle : Vehicle?
            let userRole : UserRole?
            if matchedUser.userRole == MatchedUser.RIDER{
                let matchedRider = matchedUser as! MatchedRider
                vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!,vehicleType: matchedRider.vehicleType, registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity!, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
                vehicle?.imageURI = matchedRider.vehicleImageURI
            }
            if matchedUser.userRole == MatchedUser.RIDER {
                userRole = UserRole.Rider
            }
            else{
                userRole = UserRole.Passenger
            }
            profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.userid!), isRiderProfile: userRole!, rideVehicle: vehicle, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: matchedUser.rideNotes, matchedRiderOnTimeCompliance: matchedUser.userOnTimeComplianceRating, noOfSeats: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profile, animated: false)
        }
    }
    
    
    @IBAction func liveLocationButtonTapped(_ sender: UIButton) {
        if highAlertViewModel?.matchedUser == nil{
            return
        }
        fitToScreenAfterDelay()
    }
    
    func fitToScreenAfterDelay() {
        if let routePloyline = highAlertViewModel?.matchedUser?.routePolyline, mapView != nil{
            GoogleMapUtils.fitToScreen(route: routePloyline,map : mapView)
        }
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        if let callDisableMsg = highAlertViewModel?.getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast(message: callDisableMsg)
            return
        }
        guard let contactNo = highAlertViewModel?.matchedUser?.contactNo, let userId = highAlertViewModel?.matchedUser?.userid else { return }
        AppUtilConnect.callNumber(phoneNumber: contactNo,receiverId: StringUtils.getStringFromDouble(decimalNumber: userId), refId: Strings.high_alert, name: highAlertViewModel?.matchedUser?.name ?? "", targetViewController: self)

    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        if let chatDisableMsg = highAlertViewModel?.getErrorMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast(message: chatDisableMsg)
            return
        }
        guard let userId = highAlertViewModel?.matchedUser?.userid, let name = highAlertViewModel?.matchedUser?.name, let callSupport = highAlertViewModel?.matchedUser?.callSupport, let contactNoStr = highAlertViewModel?.matchedUser?.contactNo, let contactNo =  Double(contactNoStr) else { return }
        let userBasicInfo = UserBasicInfo(userId : userId, gender : highAlertViewModel?.matchedUser?.gender,userName : name, imageUri: highAlertViewModel?.matchedUser?.imageURI, callSupport : callSupport,contactNo: contactNo)
        moveToChatView(userBasicInfo: userBasicInfo)
    }
    
    private func moveToChatView(userBasicInfo: UserBasicInfo){
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : userBasicInfo, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: viewController, animated: false)
    }
    
}


extension HighAlertNotificationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: 90, height: 35))
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(netHex: 0x0066CC)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15.0
        label.textAlignment = NSTextAlignment.center
        label.font = label.font!.withSize(12)
        label.text = Strings.tap_to_edit
        view.addSubview(label)
        let imageView = UIImageView(frame: CGRect(x: 40, y: 33, width: 20, height: 20))
        imageView.image = UIImage(named: "icon_down_blue")
        view.addSubview(imageView)
        return view
    }
}
