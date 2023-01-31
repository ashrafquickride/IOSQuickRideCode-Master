//
//  BaseRideDetailViewController.swift
//  Quickride
//
//  Created by KNM Rao on 25/05/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper
import Polyline

@objc protocol SelectedUserDelegate  {
    @objc optional func selectedUser(selectedUser : MatchedUser)
    @objc optional func saveRide(ride: Ride)
    @objc optional func notSelected()
    @objc optional func rejectUser(selectedUser : MatchedUser)
}

class BaseRideDetailViewController:UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate,UserSelectedDelegate,PickUpAndDropSelectionDelegate,StartAndEndSelectionDelegate,UICollectionViewDelegate,UICollectionViewDataSource,RouteReceiver{

    @IBOutlet var passengersCollectionView: UICollectionView!
    @IBOutlet var userDetailView: UIView!
    @IBOutlet weak var userDetailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var matchedUserImage: UIImageView!
    @IBOutlet weak var bikeImageOnUserImage: UIImageView!
    @IBOutlet weak var matchedUserName: UILabel!
    @IBOutlet weak var matchedUserPoints: UILabel!
    @IBOutlet weak var matchedUserStartTime: UILabel!
    @IBOutlet var connectedPassengersView: UIView!
    @IBOutlet var fareView: UIView!
    @IBOutlet var changePickupDropButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet var verificationBadge: UIImageView!
    @IBOutlet var companyName: UILabel!
    @IBOutlet var fareLabelHeading: UILabel!
    @IBOutlet weak var joinBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rejectBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var rideStatusLbl: UILabel!
    @IBOutlet weak var walkPathView: UIView!
    @IBOutlet weak var WalkPathViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromLocationWalkIcon: UIImageView!
    @IBOutlet weak var startToPickUpLabel: UILabel!
    @IBOutlet weak var startToPickUpArrow: UIImageView!
    @IBOutlet weak var endToDropArrow: UIImageView!
    @IBOutlet weak var endToDropWalkIcon: UIImageView!
    @IBOutlet weak var endToDropLabel: UILabel!
    @IBOutlet weak var carIcon: UIImageView!
    @IBOutlet weak var contactBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endToDropLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromLocationIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endToDropWalkIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var startToPickUpLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var startToPickUpArrowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endToDropArrowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var UserDetailsTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinButtonLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var routePercentageCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickTimeLabel: UILabel!
    @IBOutlet weak var startTimeView: UIView!
    @IBOutlet weak var chatBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rejectButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTimeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationButton: UIButton!

    var pickUpMarker,dropMarker,distanceMarker,pickUpBadge,dropBadge : GMSMarker?
    weak var viewMap: GMSMapView!
    var matchedUsersList = [MatchedUser]()
    var selectedIndex = 0
    var selectedUserDelegate :SelectedUserDelegate?
    var ride : Ride?
    var isOverlappingRouteDrawn = false
    var showJoinButton : Bool = true
    var showAccpetButton : Bool = false
    var startAndEndChangeRequired : Bool = false
    var guideView : UIView?
    let MIN_TIME_DIFF_CURRENT_LOCATION = 10
    var vehicleMarker : GMSMarker!
    var isRidePartner = false
    var newFare = [Double]()
    var fareChange = [Bool]()
    var changedPickupTime = [Double]()
    var changedDropTime = [Double]()
    var isFromRegularRide : Bool = false
    private var contactOptionsDialogue : ContactOptionsDialouge?
    private var pickupZoomState = ZOOMED_OUT
    private var dropZoomState = ZOOMED_OUT
    private var pickUpOrDropNavigation: String?
    var overlapingRoutePolyline : GMSPolyline?
    
    static let ZOOMED_IN = "ZOOMIN"
    static let ZOOMED_OUT = "ZOOMOUT"
    @objc func ibaTakeToProfile(_ sender: UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("ibaTakeToProfile()")
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as? ProfileDisplayViewController)!
        
        var vehicle : Vehicle?
        let userRole : UserRole?
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
            let matchedRider = matchedUsersList[selectedIndex] as! MatchedRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!,vehicleType: matchedRider.vehicleType, registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity!, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }else if matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
            let matchedRider = matchedUsersList[selectedIndex] as! MatchedRegularRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!, vehicleType: matchedRider.vehicleType,registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity, fare : matchedRider.fare, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
            userRole = UserRole.Rider
        }
        else{
            userRole = UserRole.Passenger
        }
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUsersList[selectedIndex].userid!),isRiderProfile: userRole!, rideVehicle: vehicle,userSelectionDelegate: self,displayAction: showJoinButton, isFromRideDetailView : true, rideNotes:matchedUsersList[selectedIndex].rideNotes, matchedRiderOnTimeCompliance: matchedUsersList[selectedIndex].userOnTimeComplianceRating, noOfSeats: nil, isSafeKeeper: matchedUsersList[selectedIndex].hasSafeKeeperBadge)
        self.navigationController?.pushViewController(profile, animated: false)
    }
    
    @IBAction func moveToCurrentRidePath(_ sender: Any) {
        if self.matchedUsersList[selectedIndex].routePolyline == nil || viewMap == nil{
            return
        }
        navigationButton.isHidden = true
        if pickupZoomState == BaseRideDetailViewController.ZOOMED_IN {
            pickupZoomState = BaseRideDetailViewController.ZOOMED_OUT
            let pickUp = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
            setPickUpMarker(pickUp: pickUp, zoomState: pickupZoomState)
        }
        if dropZoomState == BaseRideDetailViewController.ZOOMED_IN {
            dropZoomState = BaseRideDetailViewController.ZOOMED_OUT
            let drop = CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].dropLocationLatitude!, longitude: matchedUsersList[selectedIndex].dropLocationLongitude!)
            setDropMarker(drop: drop, zoomState: dropZoomState)
        }
        GoogleMapUtils.fitToScreen(route: self.matchedUsersList[selectedIndex].routePolyline!,map : viewMap)
    }
    func initializeDataBeforePresenting(matchedUsersList: [MatchedUser],selectedIndex : Int,ride : Ride,selectedUserDelegate :SelectedUserDelegate?,showJoinButton : Bool,showAcceptButton : Bool,startAndEndChangeRequired : Bool, isFromRegularRide: Bool){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.matchedUsersList = matchedUsersList
        self.selectedIndex = selectedIndex
        self.selectedUserDelegate = selectedUserDelegate
        self.ride = ride
        self.showJoinButton = showJoinButton
        self.showAccpetButton = showAcceptButton
        self.startAndEndChangeRequired = startAndEndChangeRequired
        self.isFromRegularRide = isFromRegularRide
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if self.contactOptionsDialogue != nil{
            contactOptionsDialogue!.displayView()
        }
    }

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        
        for matchedUser in matchedUsersList{
            newFare.append(matchedUser.newFare)
            fareChange.append( matchedUser.fareChange)
            changedPickupTime.append(0)
            changedDropTime.append(0)
        }
     
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapContainerView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 40)
        viewMap.delegate = self
        
       checkAndSetPickUpAndDropAddress()
      
        if ride!.routePathPolyline.isEmpty == true{
            var endLatitude = ride!.endLatitude
            var endLongitude = ride!.endLongitude
            if endLatitude == 0 && endLongitude == 0{
                endLatitude = matchedUsersList[selectedIndex].toLocationLatitude
                endLongitude = matchedUsersList[selectedIndex].toLocationLongitude
            }
            MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App."+(ride?.rideType ?? "Passenger")+".MainRoute.DetailedRouteView", rideId: ride!.rideId, startLatitude: ride!.startLatitude, startLongitude: ride!.startLongitude, endLatitude: endLatitude!, endLongitude: endLongitude!, wayPoints: nil, routeReceiver: self)

        }
        if matchedUsersList[selectedIndex].routePolyline == nil || matchedUsersList[selectedIndex].routePolyline!.isEmpty == true{
            var rideType : String?
            if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
                rideType = Ride.RIDER_RIDE
            }else if matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER{
                rideType = Ride.PASSENGER_RIDE
            }else if matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
                rideType = Ride.REGULAR_RIDER_RIDE
            }else if matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_PASSENGER{
                rideType = Ride.REGULAR_PASSENGER_RIDE
            }
            if rideType == nil{
                return
            }
            RideServicesClient.getRoutePath(rideId: matchedUsersList[selectedIndex].rideid!, rideType: rideType!, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.matchedUsersList[self.selectedIndex].routePolyline = responseObject!["resultData"] as? String
                    self.drawCurrentUserRoute()
                    self.drawMatchedUserRoute()
                }
            })
            
        }
     
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    func checkAndSetPickUpAndDropAddress(){
        if matchedUsersList[selectedIndex].pickupLocationAddress == nil{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.RouteDetailView", coordinate: CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].pickupLocationLatitude!, longitude: matchedUsersList[selectedIndex].pickupLocationLongitude!), handler: { (location, error) in
                if location != nil{
                    if self.viewMap == nil{
                        return
                    }
                    self.matchedUsersList[self.selectedIndex].pickupLocationAddress = location!.shortAddress
                    self.setPickUpMarker(pickUp: CLLocationCoordinate2D(latitude: (self.matchedUsersList[self.selectedIndex].pickupLocationLatitude)!, longitude: (self.matchedUsersList[self.selectedIndex].pickupLocationLongitude)!), zoomState: BaseRideDetailViewController.ZOOMED_OUT)
                }
            })
        }
        if matchedUsersList[selectedIndex].dropLocationAddress == nil{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.RouteDetailView", coordinate: CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].dropLocationLatitude!, longitude: matchedUsersList[selectedIndex].dropLocationLongitude!), handler: { (location, error) in
                if location != nil{
                    if self.viewMap == nil{
                        return
                    }
                    self.matchedUsersList[self.selectedIndex].dropLocationAddress = location!.shortAddress
                    self.setDropMarker(drop: CLLocationCoordinate2D(latitude: (self.matchedUsersList[self.selectedIndex].dropLocationLatitude)!, longitude: (self.matchedUsersList[self.selectedIndex].dropLocationLongitude)!), zoomState: BaseRideDetailViewController.ZOOMED_OUT)
                }
            })
        }
    }

    func drawRouteOnMap(){
        if viewMap == nil{
            return
        }
        viewMap.clear()
        isOverlappingRouteDrawn = false
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        drawOverlappingRoute()
        checkForRidePresentLocation()
    }
    func checkAndSetPointsText(){
        if newFare[selectedIndex] != -1{
            matchedUserPoints.attributedText = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: newFare[selectedIndex]),actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUsersList[selectedIndex].points!),textColor: matchedUserPoints.textColor)
        }else{
            matchedUserPoints.text = StringUtils.getStringFromDouble(decimalNumber: matchedUsersList[selectedIndex].points!)
        }
    }
 
    func checkAndSetActionButtonTitle(){
        if showJoinButton == false{
            
            joinButton.isHidden = true
            rejectButton.isHidden = true
            handleJoinButtonHeight(height: 0)
        }
        else{
            joinButton.isHidden = false
            if MatchedUser.RIDER == matchedUsersList[selectedIndex].userRole ||
                MatchedUser.REGULAR_RIDER == matchedUsersList[selectedIndex].userRole{
                handleJoinButtonVisibility(title: Strings.JOIN_CAPS)
            }else{
                handleJoinButtonVisibility(title: Strings.OFFER_RIDE_CAPS)
            }
            
            handleJoinButtonHeight(height: 40)
            
        }
        if showAccpetButton{
            handleJoinButtonVisibility(title: Strings.ACCEPT_CAPS)
            handleJoinButtonHeight(height: 40)
            
        }
        
        if ride != nil {
            var invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUsersList[selectedIndex].rideid!)
            if invite == nil{
                invite = NotificationStore.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUsersList[selectedIndex].rideid!)
            }
            if !isFromRegularRide{
                if invite != nil && newFare[selectedIndex] == invite!.newFare
                {
                    handleJoinButtonVisibility(title: Strings.ACCEPT_CAPS)
                }
            }
        }
        setGradient()
    }
    func handleJoinButtonVisibility(title : String)
    {
        if title == Strings.ACCEPT_CAPS
        {
            joinButton.setTitle(title, for: .normal)
            rejectButton.isHidden = false
            if chatButton.isHidden{
               contactBtnWidthConstraint.constant = 0
                chatButton.bounds.size.width = 0
                joinButtonLeadingSpaceConstraint.constant = 0
               joinBtnWidthConstraint.constant = (userDetailView.frame.width/2) - 20
                joinButton.bounds.size.width = (userDetailView.frame.width/2) - 20
               rejectBtnWidthConstraint.constant = (userDetailView.frame.width/2) - 20
               rejectButton.bounds.size.width = (userDetailView.frame.width/2) - 20
            }else{
                contactBtnWidthConstraint.constant = (userDetailView.frame.width/3) - 20
                joinBtnWidthConstraint.constant = (userDetailView.frame.width/3) - 20
                rejectBtnWidthConstraint.constant = (userDetailView.frame.width/3) - 20
                chatButton.bounds.size.width = (userDetailView.frame.width/3) - 20
                joinButton.bounds.size.width = (userDetailView.frame.width/3) - 20
                rejectButton.bounds.size.width = (userDetailView.frame.width/3) - 20
            }
         }
        else
        {
            joinButton.setTitle(title, for: .normal)
            rejectButton.isHidden = true
            if chatButton.isHidden{
                contactBtnWidthConstraint.constant = 0
                joinButtonLeadingSpaceConstraint.constant = 0
                joinBtnWidthConstraint.constant = userDetailView.frame.width - 35
                chatButton.bounds.size.width = 0
                joinButton.bounds.size.width = userDetailView.frame.width - 35
              }else{
                contactBtnWidthConstraint.constant = (userDetailView.frame.width/2) - 20
                joinButtonLeadingSpaceConstraint.constant = 12
                joinBtnWidthConstraint.constant = (userDetailView.frame.width/2) - 20
                chatButton.bounds.size.width = (userDetailView.frame.width/2) - 20
                joinButton.bounds.size.width = (userDetailView.frame.width/2) - 20
                rejectButton.bounds.size.width = 0

            }
            rejectBtnWidthConstraint.constant = 0
        }
    }
    
    func setGradient(){
        CustomExtensionUtility.changeBtnColor(sender: self.joinButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: self.rejectButton, color1: UIColor.white, color2: UIColor.white)
        CustomExtensionUtility.changeBtnColor(sender: self.chatButton, color1: UIColor.white, color2: UIColor.white)
    }
    func handleJoinButtonHeight(height : Int){}
    
    @objc func fareChangeTapped(_ gesture : UITapGestureRecognizer){
        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        var noOfSeats = 1
        var rideFarePerKm = 0.0
        if ride!.isKind(of: PassengerRide.classForCoder()){
            noOfSeats = (ride as! PassengerRide).noOfSeats
            rideFarePerKm = (matchedUsersList[selectedIndex] as! MatchedRider).fare ?? 0.0
        }else if matchedUsersList[selectedIndex].isKind(of: MatchedPassenger.classForCoder()){
            noOfSeats = (matchedUsersList[selectedIndex] as! MatchedPassenger).requiredSeats
            rideFarePerKm = (ride as! RiderRide).farePerKm
        }

        fareChangeViewController.initializeDataBeforePresenting(rideType: ride!.rideType!,actualFare : matchedUsersList[selectedIndex].points!,distance: matchedUsersList[selectedIndex].distance!,selectedSeats: noOfSeats, farePerKm: rideFarePerKm) { (actualFare, requestedFare) in
            
            self.newFare[self.selectedIndex] = requestedFare
            self.fareChange[self.selectedIndex] = true
            
            self.checkAndSetPointsText()
            self.matchedUsersList[self.selectedIndex].newFare = requestedFare
            self.matchedUsersList[self.selectedIndex].fareChange = true
            
            if self.ride!.rideType! == Ride.RIDER_RIDE
            {
                if requestedFare <= actualFare{
                    self.showAccpetButton = true
                }
            }else{
                if requestedFare >= actualFare
                {
                    self.showAccpetButton = true
                }
            }
            self.checkAndSetActionButtonTitle()
            self.joinClicked()
        }
        self.navigationController?.view.addSubview(fareChangeViewController.view)
        self.navigationController?.addChild(fareChangeViewController)
    }
    
    func checkAndSetPickupTimeText(matchedUser : MatchedUser,ride : Ride?){
        var pickupTimeString = String()
        var pickupTime = matchedUser.pickupTime
        
        if(matchedUser.userRole == MatchedUser.PASSENGER && matchedUser.passengerReachTimeTopickup != nil && matchedUser.passengerReachTimeTopickup != 0){
            pickupTimeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.passengerReachTimeTopickup!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }else{
            
            var invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUser.rideid!)
            if invite == nil{
                invite = NotificationStore.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUser.rideid!)
            }
            if invite != nil && invite!.pickupTime != nil{
                if invite!.pickupTime! > pickupTime!{
                    matchedUser.pickupTime = invite?.pickupTime
                    matchedUser.dropTime = invite?.dropTime
                    pickupTime = invite?.pickupTime
                }
            }
            
            
            pickupTimeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
        pickTimeLabel.text = pickupTimeString
    }
    
    func checkAndDisplayMatchedPassengers(){
        passengersCollectionView.isHidden = true
        connectedPassengersView.isHidden = true
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 40)
        setMatchedUserDetailsHeight()
        
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
            let matchedRider = matchedUsersList[selectedIndex] as! MatchedRider
             if matchedRider.capacity! - matchedRider.availableSeats! <= 0{
                    return
                }
            
             viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 320, right: 40)
           if matchedRider.joinedPassengers != nil{
            
                self.connectedPassengersView.isHidden = false
                self.passengersCollectionView.isHidden = false
                self.setMatchedUserDetailsHeight()
                self.passengersCollectionView.delegate = self
                self.passengersCollectionView.dataSource = self
                self.passengersCollectionView.reloadData()
                
            }else{
                RideServicesClient.getAlreadyJoinedPassengersOfRide(riderRideId: matchedRider.rideid!, viewController: self, handler: { (responseObject, error) in
                    if responseObject != nil && responseObject![HttpUtils.RESULT] as! String == HttpUtils.RESPONSE_SUCCESS{
                        (self.matchedUsersList[self.selectedIndex] as! MatchedRider).joinedPassengers = Mapper<UserBasicInfo>().mapArray(JSONObject: responseObject![HttpUtils.RESULT_DATA])
                        if (self.matchedUsersList[self.selectedIndex] as! MatchedRider).joinedPassengers?.isEmpty == false{
                            self.connectedPassengersView.isHidden = false
                            self.passengersCollectionView.isHidden = false
                            self.setMatchedUserDetailsHeight()
                            self.passengersCollectionView.delegate = self
                            self.passengersCollectionView.dataSource = self
                            self.passengersCollectionView.reloadData()
                        }
                    }
                })
            }
        }
    }
    func setMatchedUserDetailsHeight(){}
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userBasicInfo = (matchedUsersList[selectedIndex] as! MatchedRider).joinedPassengers![indexPath.row]
        let userRole: UserRole?
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
            userRole = UserRole.Rider
        }
        else{
            userRole = UserRole.Passenger
        }
        let vc  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: userBasicInfo.userId),isRiderProfile: userRole!,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! RiderAndPassengerCollectionViewCell
        let userBasicInfo = (matchedUsersList[selectedIndex] as! MatchedRider).joinedPassengers![indexPath.row]
      
        cell.lblName.text = userBasicInfo.name!
        ImageCache.getInstance().setImageToView(imageView: cell.imgProfilePic, imageUrl: userBasicInfo.imageURI, gender: userBasicInfo.gender!,imageSize: ImageCache.DIMENTION_TINY)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER && (matchedUsersList[selectedIndex] as! MatchedRider).joinedPassengers != nil{
            return (matchedUsersList[selectedIndex] as! MatchedRider).joinedPassengers!.count
        }
        return 0
    }
    func checkAndDisplayGuideLineScreen(){
        if SharedPreferenceHelper.getDisplayChangeLocationGuideLineView() == false{
            return
        }
        if self.showAccpetButton {
            var description,title : String?
            if Ride.RIDER_RIDE == ride!.rideType{
                title = Strings.change_start_end
                description = Strings.same_start + " " + matchedUsersList[selectedIndex].name! + Strings.same_location
            }else{
                title = Strings.change_pick_drop
                description = Strings.same_pickup + " " + matchedUsersList[selectedIndex].name! + Strings.same_location
            }
            let changeLocationGuideLineViewController = UIStoryboard(name: "PickUpandDrop", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationGuideLineViewController") as! ChangeLocationGuideLineViewController
            changeLocationGuideLineViewController.initializeDataBeforePresenting(title: title!, description: description!)
            guideView = changeLocationGuideLineViewController.view
            guideView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRideDetailViewController.dismiss(_:))))
            UIApplication.shared.keyWindow?.addSubview(changeLocationGuideLineViewController.view!)
        }
    }
    @objc func dismiss(_ gesture : UITapGestureRecognizer){
        SharedPreferenceHelper.setDisplayChangeLocationGuideLineView(status: false)
        guideView?.removeFromSuperview()
    }
    func drawMatchedUserRoute(){
        AppDelegate.getAppDelegate().log.debug("drawMatchedUserRoute()")
        if matchedUsersList[selectedIndex].routePolyline == nil || matchedUsersList[selectedIndex].routePolyline!.isEmpty == true || viewMap == nil{
            return
        }
        if matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_PASSENGER{
            if ride!.routePathPolyline.isEmpty == true{
                return
            }
            let start = CLLocation(latitude:matchedUsersList[selectedIndex].fromLocationLatitude!,longitude: matchedUsersList[selectedIndex].fromLocationLongitude!)
            let end =  CLLocation(latitude: matchedUsersList[selectedIndex].toLocationLatitude!, longitude: matchedUsersList[selectedIndex].toLocationLongitude!)
            
            let pickup =  CLLocation(latitude:matchedUsersList[selectedIndex].pickupLocationLatitude!,longitude: matchedUsersList[selectedIndex].pickupLocationLongitude!)
            
            let drop =  CLLocation(latitude:matchedUsersList[selectedIndex].dropLocationLatitude!,longitude: matchedUsersList[selectedIndex].dropLocationLongitude!)
            GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride!.rideId,useCase: "IOS.App."+ride!.rideType!+".WalkRoute.DetailedRouteView", riderRoutePolyline: ride!.routePathPolyline,passengerRoutePolyline:matchedUsersList[selectedIndex].routePolyline!,passengerStart: start,passengerEnd: end, pickup: pickup, drop: drop, passengerRideDistance: matchedUsersList[selectedIndex].rideDistance, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5,handler: { (cumalativeDistance) in
                    self.initializeWalkPathView(cumalativeTravelDistance: cumalativeDistance!)
                 })
           
        }else{
            GoogleMapUtils.drawRoute(pathString: matchedUsersList[selectedIndex].routePolyline!, map: viewMap, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        }
        
        drawOverlappingRoute()
        
    }
    func drawOverlappingRoute(){
        if matchedUsersList[selectedIndex].routePolyline == nil || matchedUsersList[selectedIndex].routePolyline?.isEmpty  == true || ride?.routePathPolyline == nil || ride?.routePathPolyline.isEmpty == true || isOverlappingRouteDrawn || viewMap == nil{
            return
        }
        isOverlappingRouteDrawn = true
        var riderRoutePolyline : String?
        if matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_PASSENGER{
            riderRoutePolyline = ride!.routePathPolyline
        }else{
            riderRoutePolyline = matchedUsersList[selectedIndex].routePolyline!
        }
        let pickUp = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
        let drop = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].dropLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].dropLocationLongitude)!)
        let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: riderRoutePolyline!)
        if matchedRoute.count < 3{
            return
        }

        setPickUpMarker(pickUp: pickUp, zoomState: BaseRideDetailViewController.ZOOMED_OUT)
        setDropMarker(drop: drop, zoomState: BaseRideDetailViewController.ZOOMED_OUT)
        setDistanceMarker()
        let polyline = Polyline(coordinates: matchedRoute)
        GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        handleMatchedPickuAndDropBadges()
        changePickupDropButton.isEnabled = true
        perform(#selector(BaseRideDetailViewController.drawRouteAfterDelay), with: self, afterDelay: 0.5)
    }
    @objc func drawRouteAfterDelay(){
        if self.matchedUsersList[selectedIndex].routePolyline != nil && viewMap != nil && pickupZoomState == BaseRideDetailViewController.ZOOMED_OUT && dropZoomState == BaseRideDetailViewController.ZOOMED_OUT {
           GoogleMapUtils.fitToScreen(route: self.matchedUsersList[selectedIndex].routePolyline!,map : viewMap)
        }
      
    }

    func setPickUpMarker(pickUp : CLLocationCoordinate2D, zoomState: String) {
        pickUpMarker?.map = nil
        pickUpMarker = nil
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.pick_up_caps, markerImage: UIImage(named: "green")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.18, y: 0.25))
        pickUpMarker?.zIndex = 8
        pickUpMarker?.title = Strings.pick_up_caps
    }
    
    func checkAndSetPickupTimeText() -> String{
        var pickupTimeString = String()
        var pickupTime = matchedUsersList[selectedIndex].pickupTime
        if(matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER && matchedUsersList[selectedIndex].passengerReachTimeTopickup != nil && matchedUsersList[selectedIndex].passengerReachTimeTopickup != 0){
            pickupTimeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUsersList[selectedIndex].passengerReachTimeTopickup, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }else{
            
            var invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUsersList[selectedIndex].rideid!)
            if invite == nil{
                invite = NotificationStore.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: ride!.rideId, rideType: ride!.rideType!, matchedUserRideId: matchedUsersList[selectedIndex].rideid!)
            }
            if invite != nil && invite!.pickupTime != nil{
                if invite!.pickupTime! > pickupTime!{
                    matchedUsersList[selectedIndex].pickupTime = invite?.pickupTime
                    matchedUsersList[selectedIndex].dropTime = invite?.dropTime
                    pickupTime = invite?.pickupTime
                }
            }
            
            
            pickupTimeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
        return pickupTimeString
    }
    
    
    func getPickUpAddress() -> String{
        if matchedUsersList[selectedIndex].pickupLocationAddress != nil{
            return matchedUsersList[selectedIndex].pickupLocationAddress!
        }else{
          return matchedUsersList[selectedIndex].fromLocationAddress!
        }
   }

    func setDropMarker(drop : CLLocationCoordinate2D, zoomState: String) {
        dropMarker?.map = nil
        dropMarker = nil
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.drop_caps, markerImage: UIImage(named: "drop_icon")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.25, y: 0.25))
        dropMarker?.zIndex = 8
        dropMarker?.title = Strings.drop_caps
    }

    func getDropAddress() -> String{
        if matchedUsersList[selectedIndex].dropLocationAddress != nil{
            return matchedUsersList[selectedIndex].dropLocationAddress!
        }else{
            return matchedUsersList[selectedIndex].toLocationAddress!
        }
    }
    
    func setDistanceMarker(){
        let distanceInfoView = UIView.loadFromNibNamed(nibNamed: "DistanceInfoView") as! DistanceInfoView
        distanceInfoView.initializeDataBeforePresenting(distance: matchedUsersList[selectedIndex].distance)
        let icon = ViewCustomizationUtils.getImageFromView(view: distanceInfoView)
        let path = GMSPath(fromEncodedPath: ride!.routePathPolyline)
        if path != nil && path!.count() != 0{
            distanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: false, anchor: CGPoint(x: 1, y: 0.7),zIndex: 8)
        }
    }
    
    func handleMatchedPickuAndDropBadges(){}
    
    @IBAction func changePickupDropAction(_ sender: Any) {
        
        if ride == nil{
            return
        }
        if startAndEndChangeRequired{
            AppDelegate.getAppDelegate().log.debug("changeStartAndEndAction()")
            let startEndLocationViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "StartAndEndSelectionViewController") as! StartAndEndSelectionViewController
            startEndLocationViewController.initializeDataBeforePresenting(ride: ride?.copy() as! Ride, matchedPassenger: matchedUsersList[selectedIndex], delegate: self)
            self.navigationController?.pushViewController(startEndLocationViewController, animated: false)
        }else{
            AppDelegate.getAppDelegate().log.debug("changePickUpDropAction()")
            let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickUpandDropViewController") as! PickUpandDropViewController
            var riderRideId,passengerRideId,passengerId,riderId : Double?
            var noOfSeats = 1
            if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
                riderRideId = matchedUsersList[selectedIndex].rideid
                riderId = matchedUsersList[selectedIndex].userid
                passengerRideId = ride!.rideId
                passengerId = ride!.userId
                if ride!.isKind(of:  PassengerRide.classForCoder()){
                    noOfSeats = (self.ride as! PassengerRide).noOfSeats
                }
            }else{
                riderRideId = ride?.rideId
                riderId = ride!.userId
                passengerRideId = matchedUsersList[selectedIndex].rideid
                passengerId = matchedUsersList[selectedIndex].userid
                if matchedUsersList[selectedIndex].isKind(of: MatchedPassenger.classForCoder()){
                    noOfSeats = (matchedUsersList[selectedIndex] as! MatchedPassenger).requiredSeats
                }
            }
            var riderRoutePolyline : String?
            var riderRideType : String?
            if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
                riderRoutePolyline = matchedUsersList[selectedIndex].routePolyline
                riderRideType = Ride.RIDER_RIDE
            }else if matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
                riderRoutePolyline = matchedUsersList[selectedIndex].routePolyline
                riderRideType = Ride.REGULAR_RIDER_RIDE
            }else if ride!.rideType == Ride.RIDER_RIDE{
                riderRoutePolyline = ride?.routePathPolyline
                riderRideType = Ride.RIDER_RIDE
            }else{
                riderRoutePolyline = ride?.routePathPolyline
                riderRideType = Ride.REGULAR_RIDER_RIDE
            }
            if riderRoutePolyline == nil{
                return
            }
            pickUpDropViewController.initializeDataBeforePresenting(matchedUser: matchedUsersList[selectedIndex],riderRoutePolyline: riderRoutePolyline!,riderRideType :riderRideType!, delegate: self,passengerRideId :passengerRideId,riderRideId: riderRideId,passengerId: passengerId,riderId: riderId,noOfSeats: noOfSeats)
            self.navigationController?.pushViewController(pickUpDropViewController, animated: false)
            
        }
        
    }
    
    func getMatchingRouteCoordinates()-> Polyline{
        var riderRoutePolyline : String?
        if matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_PASSENGER{
            riderRoutePolyline = ride!.routePathPolyline
        }else{
            riderRoutePolyline = matchedUsersList[selectedIndex].routePolyline!
        }
        let pickUp = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
        let drop = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].dropLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].dropLocationLongitude)!)
        let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: riderRoutePolyline!)
        
        return Polyline(coordinates: matchedRoute)
    }
    
    func checkAndSetMatchingPercentage(matchedUser : MatchedUser, ride : Ride) {
        if (matchedUser.matchPercentage! <= 0 )&&(ride.distance! > 0.0){
            
            matchedUser.matchPercentage = Int((matchedUser.distance!/ride.distance!)*100)
            if matchedUser.matchPercentage! > 100
            {
                matchedUser.matchPercentage = 100
            }
        }
    }
    func drawCurrentUserRoute(){
        AppDelegate.getAppDelegate().log.debug("drawCurrentUserRoute()")
        if viewMap != nil && ride?.routePathPolyline != nil && ride?.routePathPolyline.isEmpty == false && matchedUsersList[selectedIndex].routePolyline != nil && matchedUsersList[selectedIndex].routePolyline?.isEmpty == false{
            let route = Polyline(encodedPolyline: ride!.routePathPolyline)
            if (route.coordinates?.count)! < 2{
                return
            }
            
            if matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_PASSENGER || ride!.distance == nil{
                GoogleMapUtils.drawRoute(pathString: ride!.routePathPolyline, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_5, tappable: false)
            }else{
                let start = CLLocation(latitude:ride!.startLatitude,longitude: ride!.startLongitude)
                let end =  CLLocation(latitude: ride!.endLatitude!, longitude: ride!.endLongitude!)
                
                let pickUp = CLLocation(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
                let drop = CLLocation(latitude: (matchedUsersList[selectedIndex].dropLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].dropLocationLongitude)!)
                GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride!.rideId,useCase :"iOS.App."+(ride!.rideType ?? "Passenger")+".WalkRoute.DetailedRouteView", riderRoutePolyline: matchedUsersList[selectedIndex].routePolyline!,passengerRoutePolyline:ride!.routePathPolyline,passengerStart: start,passengerEnd: end, pickup: pickUp, drop: drop, passengerRideDistance: ride!.distance!, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
                    self.initializeWalkPathView(cumalativeTravelDistance: cumalativeDistance!)
                    })
               
              
            }
            
            drawOverlappingRoute()
        }
    }
    
    func initializeWalkPathView(cumalativeTravelDistance : CummulativeTravelDistance){
        
        if cumalativeTravelDistance.passengerStartToPickup > 0.01 && cumalativeTravelDistance.passengerDropToEnd > 0.01{
            walkPathView.isHidden = false
            endToDropArrow.isHidden = false
            endToDropWalkIcon.isHidden = false
            endToDropLabel.isHidden = false
            fromLocationWalkIcon.isHidden = false
            startToPickUpArrow.isHidden = false
            startToPickUpLabel.isHidden = false
            setIconToWalkPathView()
            changeDropWalkIconBasedOnDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            endToDropArrowWidthConstraint.constant = 8
            endToDropWalkIconWidthConstraint.constant = 12
            endToDropLblWidthConstraint.constant = 50
            fromLocationIconWidthConstraint.constant = 12
            startToPickUpArrowWidthConstraint.constant = 8
            startToPickUpLblWidthConstraint.constant = 50
            WalkPathViewWidthConstraint.constant = 240
            routePercentageCenterXConstraint.constant = 20
            startToPickUpLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerStartToPickup)
            endToDropLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            
        }else if cumalativeTravelDistance.passengerStartToPickup > 0.01{
            walkPathView.isHidden = false
            endToDropArrow.isHidden = true
            endToDropWalkIcon.isHidden = true
            endToDropLabel.isHidden = true
            fromLocationWalkIcon.isHidden = false
            startToPickUpArrow.isHidden = false
            startToPickUpLabel.isHidden = false
            setIconToWalkPathView()
            endToDropArrowWidthConstraint.constant = 0
            endToDropWalkIconWidthConstraint.constant = 0
            endToDropLblWidthConstraint.constant = 0
            fromLocationIconWidthConstraint.constant = 12
            startToPickUpArrowWidthConstraint.constant = 8
            startToPickUpLblWidthConstraint.constant = 50
             routePercentageCenterXConstraint.constant = 10
            WalkPathViewWidthConstraint.constant = 210
            startToPickUpLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerStartToPickup)
            
            
        }else if cumalativeTravelDistance.passengerDropToEnd > 0.01{
            walkPathView.isHidden = false
            endToDropArrow.isHidden = false
            endToDropWalkIcon.isHidden = false
            endToDropLabel.isHidden = false
            fromLocationWalkIcon.isHidden = true
            startToPickUpArrow.isHidden = true
            startToPickUpLabel.isHidden = true
            setIconToWalkPathView()
            changeDropWalkIconBasedOnDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            endToDropArrowWidthConstraint.constant = 8
            endToDropWalkIconWidthConstraint.constant = 12
            endToDropLblWidthConstraint.constant = 50
            fromLocationIconWidthConstraint.constant = 0
            startToPickUpArrowWidthConstraint.constant = 0
            startToPickUpLblWidthConstraint.constant = 0
            routePercentageCenterXConstraint.constant = 10
            WalkPathViewWidthConstraint.constant = 210
            endToDropLabel.text = CummulativeTravelDistance.getReadableDistance(distance: cumalativeTravelDistance.passengerDropToEnd)
            
        }else{
            walkPathView.isHidden = true
        }
    }
    
    func changeDropWalkIconBasedOnDistance(distance : Double){
        if distance > 1.5{
            endToDropWalkIcon.image = UIImage(named : "running")
        }else{
            endToDropWalkIcon.image = UIImage(named : "path")
        }
    }
    
    func setIconToWalkPathView()
    {
        if ride != nil && ride!.rideType == Ride.RIDER_RIDE{
            if ride!.isKind(of: RiderRide.self) && (ride as! RiderRide).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                carIcon.image = UIImage(named : "motorbike")
            }else{
                carIcon.image = UIImage(named : "car_new")
            }
        }else{
            if self.matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER && (self.matchedUsersList[selectedIndex] as! MatchedRider).vehicleType ==  Vehicle.VEHICLE_TYPE_BIKE{
                 carIcon.image = UIImage(named : "motorbike")
            }else{
                 carIcon.image = UIImage(named : "car_new")
            }
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillDisappear()")
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func checkForRidePresentLocation(){
        AppDelegate.getAppDelegate().log.debug("checkForRidePresentLocation()")
        
        if matchedUsersList[selectedIndex].userRole != MatchedUser.RIDER{
            return
        }
        
        var startDate,riderRideId : Double?
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER{
            startDate = matchedUsersList[selectedIndex].startDate
            riderRideId = matchedUsersList[selectedIndex].rideid
        }else{
            startDate = ride!.startTime
            riderRideId = ride!.rideId
        }
        if startDate == nil || riderRideId == nil{
            return
        }
        
        if NSDate().getTimeStamp() > startDate!{
            LocationUpdationServiceClient.getRiderParticipantLocation(rideId: riderRideId!, targetViewController: self, completionHandler: {(responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                    if self.viewMap == nil{
                        return
                    }
                    let rideParticipantLocation = Mapper<RideParticipantLocation>().map(JSONObject:responseObject!["resultData"])!
                    self.setVehicleImageAtLocation(newLocation: rideParticipantLocation , matchedRider: self.matchedUsersList[self.selectedIndex], lastUpdateTime: rideParticipantLocation.lastUpdateTime)
                    self.receiveRideParticipantLocation(rideParticipantLocation: rideParticipantLocation,riderStartTime: startDate!)
                }
            })
        }
    }
    func receiveRideParticipantLocation(rideParticipantLocation: RideParticipantLocation,riderStartTime : Double) {
        if self.viewMap == nil {return}
        if ride == nil{return}
        let currentRiderLocation = CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!)
        let passengerPickupLocation = CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].pickupLocationLatitude!, longitude: matchedUsersList[selectedIndex].pickupLocationLongitude!)
        var startTime = NSDate().getTimeStamp()
        if startTime < riderStartTime{
            startTime = riderStartTime
        }

        if let googleAPIConfiguration = ConfigurationCache.getInstance()?.getGoogleAPIConfiguration(),googleAPIConfiguration.readETABeforeRideJoin{
             let origins = [currentRiderLocation]
             let destinations = [currentRiderLocation]
            RoutePathServiceClient.getRouteDurationAndDistanceInTraffic(rideId: ride!.rideId, useCase: "iOS.App.Passenger.Eta.DetailedRouteView", origins: origins, destinations: destinations, startTime: startTime) { (responseObject, error) in
                if let response = responseObject,response["result"] as? String == "SUCCESS", let routeMetricsList = Mapper<RouteMetrics>().mapArray(JSONObject: response["resultData"]),  !routeMetricsList.isEmpty{

                    let routeMetrics = routeMetricsList[0]

                   let pickUpTime = startTime+Double(routeMetrics.journeyDurationInTraffic*60*1000)
                     let diffBPickupTimes = pickUpTime - self.matchedUsersList[self.selectedIndex].pickupTime!
                     self.matchedUsersList[self.selectedIndex].pickupTime = pickUpTime
                     self.matchedUsersList[self.selectedIndex].dropTime = self.matchedUsersList[self.selectedIndex].dropTime! + diffBPickupTimes
                     self.checkAndSetPickupTimeText(matchedUser: self.matchedUsersList[self.selectedIndex], ride: self.ride)
                     if self.viewMap != nil{
                         self.viewMap.clear()
                         self.isOverlappingRouteDrawn = false
                         self.drawCurrentUserRoute()
                         self.drawMatchedUserRoute()
                         self.drawOverlappingRoute()
                         self.setVehicleImageAtLocation(newLocation: rideParticipantLocation , matchedRider: self.matchedUsersList[self.selectedIndex], lastUpdateTime: rideParticipantLocation.lastUpdateTime)
                     }

                     self.matchedUsersList[self.selectedIndex].pickupTimeRecalculationRequired = false
                }
            }
        }else{
            let pickUpTime = startTime+Double(self.matchedUsersList[self.selectedIndex].pickupTime! - self.matchedUsersList[self.selectedIndex].startDate!)
            let diffBPickupTimes = pickUpTime - self.matchedUsersList[self.selectedIndex].pickupTime!
            self.matchedUsersList[self.selectedIndex].pickupTime = pickUpTime
            self.matchedUsersList[self.selectedIndex].dropTime = self.matchedUsersList[self.selectedIndex].dropTime! + diffBPickupTimes
            self.checkAndSetPickupTimeText(matchedUser: self.matchedUsersList[self.selectedIndex], ride: self.ride)
            if self.viewMap != nil{
                self.viewMap.clear()
                self.isOverlappingRouteDrawn = false
                self.drawCurrentUserRoute()
                self.drawMatchedUserRoute()
                self.drawOverlappingRoute()
                self.setVehicleImageAtLocation(newLocation: rideParticipantLocation , matchedRider: self.matchedUsersList[self.selectedIndex], lastUpdateTime: rideParticipantLocation.lastUpdateTime)
            }
        }
    }
    
    
    
    func setVehicleImageAtLocation(newLocation : RideParticipantLocation,matchedRider : MatchedUser,lastUpdateTime: Double?){
        AppDelegate.getAppDelegate().log.debug("setVehicleImageAtLocation()")
        if matchedRider.userRole != MatchedUser.RIDER{
            return
        }
        if self.vehicleMarker != nil{
            vehicleMarker.map = nil
            vehicleMarker = nil
        }
        self.vehicleMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: newLocation.latitude!,longitude: newLocation.longitude!))
        if newLocation.bearing != nil{
            self.vehicleMarker.rotation = newLocation.bearing!
        }
        self.vehicleMarker.zIndex = 10
        if (matchedRider as! MatchedRider).vehicleType ==  Vehicle.VEHICLE_TYPE_BIKE{
            self.vehicleMarker.icon = UIImage(named: "bike_top")
        }else{
            self.vehicleMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "new_car")!, targetSize: CGSize(width: 55,height: 55))
        }
        self.vehicleMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.3)
        self.vehicleMarker.map = viewMap
        setTitleToRouteNavigationMarker(lastUpdateTime: lastUpdateTime )
    }
    
    func setTitleToRouteNavigationMarker(lastUpdateTime : Double?) {
        
        if vehicleMarker == nil || vehicleMarker.map == nil || viewMap == nil{
            return
        }
        var title = String()
        
        if  (matchedUsersList[selectedIndex] as! MatchedRider).vehicleNumber != nil{
            title  = title + ((matchedUsersList[selectedIndex] as! MatchedRider).vehicleNumber)!
        }
        if lastUpdateTime != nil{
            title = title + " ,@" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: lastUpdateTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }else{
            title = title + " ,@" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
        vehicleMarker.title = title
    }
    
    func joinClicked() {
        
        if SharedPreferenceHelper.getShortSignReqStatus() && UserDataCache.getInstance()?.getLoggedInUserProfile()?.imageURI == nil{
            let profilePicUpdateViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfilePicUpdateViewController") as! ProfilePicUpdateViewController
            profilePicUpdateViewController.initializeDataBeforePresenting {
                self.inviteUser()
            }
           ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: profilePicUpdateViewController, animated: false, completion: nil)
        }else{
            self.inviteUser()
        }
     }
    
    func inviteUser(){
        ViewControllerUtils.finishViewController(viewController: self)
        if ride?.routePathPolyline != nil{
            selectedUserDelegate?.saveRide?(ride: ride!)
        }
        matchedUsersList[selectedIndex].newFare = newFare[selectedIndex]
        matchedUsersList[selectedIndex].fareChange = fareChange[selectedIndex]
        if changedPickupTime[selectedIndex] != 0 && changedDropTime[selectedIndex] != 0{
            matchedUsersList[selectedIndex].pickupTime = changedPickupTime[selectedIndex]
            matchedUsersList[selectedIndex].dropTime = changedDropTime[selectedIndex]
        }
        
        selectedUserDelegate?.selectedUser?(selectedUser: matchedUsersList[selectedIndex])
        
        selectedUserDelegate = nil
        removeVehicleMarker()
    }
    
    @IBAction func joinButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("joinButtonClicked()")
        joinClicked()
        
    }
    
    @IBAction func rejectButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        ViewControllerUtils.finishViewController(viewController: self)
        selectedUserDelegate?.rejectUser?(selectedUser: matchedUsersList[selectedIndex])
        selectedUserDelegate = nil
        removeVehicleMarker()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("backButtonClicked()")
         if ride?.routePathPolyline != nil{
            selectedUserDelegate?.saveRide?(ride: ride!)
        }
        selectedUserDelegate?.notSelected?()
        removeVehicleMarker()
        ViewControllerUtils.finishViewController(viewController: self)
  }
    
    func removeVehicleMarker(){
        if viewMap == nil{
            return
        }
        viewMap.clear()
        if vehicleMarker != nil{
            vehicleMarker.map = nil
            vehicleMarker = nil
        }
        viewMap = nil
    }
    
    @IBAction func chatButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        var isRideStarted = false
        
        if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER && Ride.RIDE_STATUS_STARTED == (matchedUsersList[selectedIndex] as! MatchedRider).rideStatus && matchedUsersList[selectedIndex].callSupport == UserProfile.SUPPORT_CALL_ALWAYS{
           isRideStarted = true
        }else{
           isRideStarted = false
        }
        guard let matchedUserId = matchedUsersList[selectedIndex].userid, let userName = matchedUsersList[selectedIndex].name, let contactNo = matchedUsersList[selectedIndex].contactNo else { return }
        
        UserDataCache.getInstance()?.storeUserContactNo(userId: String(matchedUserId), contactNo:contactNo)
        
        let userBasicInfo = UserBasicInfo(userId: matchedUserId, gender: matchedUsersList[selectedIndex].gender, userName: userName, imageUri: matchedUsersList[selectedIndex].imageURI, callSupport: matchedUsersList[selectedIndex].callSupport, contactNo: Double(matchedUsersList[selectedIndex].contactNo!))
        
        if checkAndEnableCallOption(callSupport: matchedUsersList[selectedIndex].callSupport) == false{
            moveToChatView(presentConatctUserBasicInfo: userBasicInfo, isRideStarted: isRideStarted)
        }
        else{
            let viewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ContactOptionsDialouge") as! ContactOptionsDialouge
            viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : userBasicInfo,supportCall: UserProfile.isCallSupportAfterJoined(callSupport: matchedUsersList[selectedIndex].callSupport, enableChatAndCall: matchedUsersList[selectedIndex].enableChatAndCall), delegate: nil, isRideStarted: isRideStarted, dismissDelegate: { [weak self] in
                guard let self = `self` else { return }
                self.contactOptionsDialogue = nil
            })
            self.contactOptionsDialogue = viewController
            self.navigationController?.view.addSubview(viewController.view)
            self.navigationController?.addChild(viewController)
        }
    }
    func userSelected() {
        AppDelegate.getAppDelegate().log.debug("userSelected()")
        self.navigationController?.popViewController(animated: false)
        if ride?.routePathPolyline != nil{
            selectedUserDelegate?.saveRide?(ride: ride!)
        }
        selectedUserDelegate?.selectedUser?(selectedUser: matchedUsersList[selectedIndex])
    }
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?) {
        AppDelegate.getAppDelegate().log.debug("pickUpAndDropChanged()")
        if viewMap == nil{
            return
        }
        self.matchedUsersList[selectedIndex] = matchedUser
        viewMap.clear()
        isOverlappingRouteDrawn = false
        matchedUser.newFare = -1
        fareChange[selectedIndex] = false
        matchedUser.fareChange = false
        
        matchedUserPoints.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!)
        setMatchedPercentage()
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        drawOverlappingRoute()
        setWidthToRideDetailViews()
        checkAndSetActionButtonTitle()
        
    }
    func setWidthToRideDetailViews() {
        
    }
    func setMatchedPercentage() {
        
    }
    
    func setVerificationLabel(){
        AppDelegate.getAppDelegate().log.debug("setVerificationLabel()")
        
        verificationBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUsersList[selectedIndex].profileVerificationData)
        companyName.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUsersList[selectedIndex].profileVerificationData, companyName: matchedUsersList[selectedIndex].companyName)
    }
    func startAndEndChanged(matchedUser: MatchedUser, ride: Ride) {
        AppDelegate.getAppDelegate().log.debug("startAndEndChanged() \(matchedUser) and \(ride)")
        self.matchedUsersList[selectedIndex] = matchedUser
        self.ride = ride
        if viewMap == nil{
            return
        }
        viewMap.clear()
        isOverlappingRouteDrawn = false
        newFare[selectedIndex] = -1
        matchedUser.newFare = -1
        fareChange[selectedIndex] = false
        matchedUser.fareChange = false
        
        matchedUserPoints.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!)
     
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        drawOverlappingRoute()
    }
    
    
    func moveToChatView(presentConatctUserBasicInfo: UserBasicInfo, isRideStarted: Bool){
        
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : presentConatctUserBasicInfo,isRideStarted: isRideStarted, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func userNotSelected(){
        
    }
    func checkForRideStatusStartedAndSetStatusLabel(){
        AppDelegate.getAppDelegate().log.debug("checkForRideStatusStartedAndSetStatusLabel()")
        if MatchedUser.RIDER == matchedUsersList[selectedIndex].userRole && Ride.RIDE_STATUS_STARTED == (matchedUsersList[selectedIndex] as! MatchedRider).rideStatus{
            rideStatusLbl.isHidden = false
            rideStatusLbl.text = Ride.RIDE_STATUS_STARTED
        }else{
            rideStatusLbl.isHidden = true
        }
    }
    
    func checkAndEnableCallOption(callSupport : String) -> Bool
    {
        if(UserProfile.SUPPORT_CALL_NEVER == callSupport)
        {
            return false
        }
        else if(UserProfile.SUPPORT_CALL_ALWAYS == callSupport)
        {
            return true
        }
        else{
            if self.isRidePartner == true
            {
                return true
            }
            else
            {
                return false
            }
        }
    }

    func adjustZoom(){}
    func receiveRoute(rideRoute:[RideRoute]){
        if rideRoute.isEmpty && ride != nil{
            return
        }
        self.ride?.routePathPolyline = rideRoute[0].overviewPolyline!
        self.drawCurrentUserRoute()
        self.drawMatchedUserRoute()
    }
    func receiveRouteFailed(responseObject :NSDictionary?,error: NSError?){

    }
    
    @IBAction func navigationButtonTapped(_ sender: UIButton) {
        if matchedUsersList[selectedIndex].userRole == Ride.PASSENGER_RIDE || matchedUsersList[selectedIndex].userRole == Ride.REGULAR_PASSENGER_RIDE {
            return
        }
        if ride == nil {
            return
        }
        let matchedUser = matchedUsersList[selectedIndex]
        var startPoint: String?
        var endPoint: String?
        if pickUpOrDropNavigation == Strings.pick_up_caps {
            startPoint = String(ride!.startLatitude.roundToPlaces(places: 5))+","+String(ride!.startLongitude.roundToPlaces(places: 5))
            endPoint = String(matchedUser.pickupLocationLatitude!.roundToPlaces(places: 5))+","+String(matchedUser.pickupLocationLongitude!.roundToPlaces(places: 5))
        } else {
            startPoint = String(ride!.endLatitude!.roundToPlaces(places: 5))+","+String(ride!.endLongitude!.roundToPlaces(places: 5))
            endPoint = String(matchedUser.dropLocationLatitude!.roundToPlaces(places: 5))+","+String(matchedUser.dropLocationLongitude!.roundToPlaces(places: 5))
        }
        var urlString = "https://www.google.com/maps/dir/?api=1&origin=" + startPoint!
        urlString = urlString + "&destination=" + endPoint! + "&travelmode=" + "walking"
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast(message: "Can't use Google maps in this device.", duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.title == Strings.pick_up_caps {
            if pickupZoomState == BaseRideDetailViewController.ZOOMED_IN {
                self.navigationButton.isHidden = true
                pickupZoomState = BaseRideDetailViewController.ZOOMED_OUT
                zoomOutToSelectedPoint()
                let pickUp = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
                setPickUpMarker(pickUp: pickUp, zoomState: BaseRideDetailViewController.ZOOMED_OUT)
            } else {
                if matchedUsersList[selectedIndex].userRole != Ride.PASSENGER_RIDE && matchedUsersList[selectedIndex].userRole != Ride.REGULAR_PASSENGER_RIDE {
                    self.navigationButton.isHidden = false
                    pickUpOrDropNavigation = Strings.pick_up_caps
                }
                pickupZoomState = BaseRideDetailViewController.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].pickupLocationLatitude!, longitude: matchedUsersList[selectedIndex].pickupLocationLongitude!)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.pick_up_caps)
                let pickUp = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].pickupLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].pickupLocationLongitude)!)
                setPickUpMarker(pickUp: pickUp, zoomState: BaseRideDetailViewController.ZOOMED_IN)
            }
        }
        if marker.title == Strings.drop_caps {
            if dropZoomState == BaseRideDetailViewController.ZOOMED_IN {
                self.navigationButton.isHidden = true
                dropZoomState = BaseRideDetailViewController.ZOOMED_OUT
                let drop = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].dropLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].dropLocationLongitude)!)
                setDropMarker(drop: drop, zoomState: BaseRideDetailViewController.ZOOMED_OUT)
                zoomOutToSelectedPoint()
            } else {
                if matchedUsersList[selectedIndex].userRole != Ride.PASSENGER_RIDE && matchedUsersList[selectedIndex].userRole != Ride.REGULAR_PASSENGER_RIDE {
                    self.navigationButton.isHidden = false
                    pickUpOrDropNavigation = Strings.drop_caps
                }
                dropZoomState = BaseRideDetailViewController.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedUsersList[selectedIndex].dropLocationLatitude!, longitude: matchedUsersList[selectedIndex].dropLocationLongitude!)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.drop_caps)
                let drop = CLLocationCoordinate2D(latitude: (matchedUsersList[selectedIndex].dropLocationLatitude)!, longitude: (matchedUsersList[selectedIndex].dropLocationLongitude)!)
                setDropMarker(drop: drop, zoomState: BaseRideDetailViewController.ZOOMED_IN)
            }
        }
        return true
    }
    
    private func zoomInToSelectedPoint(zoomPoint: CLLocationCoordinate2D, markerType: String) {
        guard let rideObj = ride else { return }
        let matchedUser = matchedUsersList[selectedIndex]
        if matchedUser.userRole == Ride.PASSENGER_RIDE || matchedUsersList[selectedIndex].userRole == Ride.REGULAR_PASSENGER_RIDE {
            let cameraPosition = GMSCameraPosition.camera(withTarget: zoomPoint, zoom: 16.0)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            self.viewMap.animate(to: cameraPosition)
            CATransaction.commit()
            
        } else {
            var startLat: Double?
            var startLng: Double?
            var endLat: Double?
            var endLng: Double?
            if markerType == Strings.pick_up_caps {
                startLat = rideObj.startLatitude
                startLng = rideObj.startLongitude
                endLat = matchedUser.pickupLocationLatitude
                endLng = matchedUser.pickupLocationLongitude
            } else {
                startLat = rideObj.endLatitude
                startLng = rideObj.endLongitude
                endLat = matchedUser.dropLocationLatitude
                endLng = matchedUser.dropLocationLongitude
            }
            viewMap.setMinZoom(viewMap.minZoom, maxZoom: 16)
            let uiEdgeInsets = UIEdgeInsets(top: 40, left: 100, bottom: 40, right: 40)
            let routePathToPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat!, startLong: startLng!, endLat: endLat!, endLong: endLng!, viewMap: viewMap)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToPickUP)!)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            CATransaction.commit()
        }
    }
    
    private func zoomOutToSelectedPoint() {
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: self.matchedUsersList[selectedIndex].routePolyline!)!)
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        CATransaction.commit()
    }
}
