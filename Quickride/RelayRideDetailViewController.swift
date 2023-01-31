//
//  RelayRideDetailViewController.swift
//  Quickride
//
//  Created by Vinutha on 17/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline

class RelayRideDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var pickUpTimeLabel: UILabel!
    @IBOutlet weak var pmOrAmLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var routeMatchLabel: UILabel!
    //Walk path
    @IBOutlet weak var stopOverLocationLabel: UILabel!
    @IBOutlet weak var walkDistanceView: UIView!
    @IBOutlet weak var walkingDistanceLabel: UILabel!
    @IBOutlet weak var walkingDistanceAfterRideLabel: UILabel!
    @IBOutlet weak var walkDistanceAfterRideView: UIView!
    @IBOutlet weak var walkingDistance2ndPickup: UILabel!
    //map
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var matchView: UIView!
    @IBOutlet weak var bottomView: UIView!
    //Matches
    @IBOutlet weak var firstUserImageView: UIImageView!
    @IBOutlet weak var firstUserNameLabel: UILabel!
    @IBOutlet weak var firstUserVerificationImageView: UIImageView!
    @IBOutlet weak var firstUserCompanyNameLabel: UILabel!
    @IBOutlet weak var firstUserStarImageView: UIImageView!
    @IBOutlet weak var firstUserRatingLabel: UILabel!
    @IBOutlet weak var firstUserPickUplabel: UILabel!
    @IBOutlet weak var firstUserVehicleImageView: UIImageView!
    @IBOutlet weak var firstUserSeatsStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var firstUserFirstSeatImageView: UIImageView!
    @IBOutlet weak var firstUserSecondSeatImageView: UIImageView!
    @IBOutlet weak var firstUserThirdSeatImageView: UIImageView!
    @IBOutlet weak var firstUserFouthSeatImageView: UIImageView!
    @IBOutlet weak var firstUserFifthSeatImageView: UIImageView!
    @IBOutlet weak var firstUserSixthSeatImageView: UIImageView!
    @IBOutlet weak var firstUserPoolShowingLabel: UILabel!
    @IBOutlet weak var firstUserSeatShowingStackView: UIStackView!
    
    @IBOutlet weak var secondUserImageView: UIImageView!
    @IBOutlet weak var secondUserNameLabel: UILabel!
    @IBOutlet weak var secondUserVerificationImageView: UIImageView!
    @IBOutlet weak var secondUserCompanyNameLabel: UILabel!
    @IBOutlet weak var secondUserStarImageView: UIImageView!
    @IBOutlet weak var secondUserRatingLabel: UILabel!
    @IBOutlet weak var secondUserPickUplabel: UILabel!
    @IBOutlet weak var secondUserVehicleImageView: UIImageView!
    @IBOutlet weak var secondUserSeatsStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var secondUserFirstSeatImageView: UIImageView!
    @IBOutlet weak var secondUserSecondSeatImageView: UIImageView!
    @IBOutlet weak var secondUserThirdSeatImageView: UIImageView!
    @IBOutlet weak var secondUserFouthSeatImageView: UIImageView!
    @IBOutlet weak var secondUserFifthSeatImageView: UIImageView!
    @IBOutlet weak var secondUserSixthSeatImageView: UIImageView!
    @IBOutlet weak var secondUserPoolShowingLabel: UILabel!
    @IBOutlet weak var secondUserSeatShowingStackView: UIStackView!
    
    //MARK: Variables
    private var firstLegPickUpMarker,firstLegDropMarker,secondLegPickUpMarker,secondLegDropMarker, stopOverMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    private var vehicleMarker : GMSMarker!
    var backGroundView: UIView?
    private var relayRideDetailViewModel = RelayRideDetailViewModel()
    
    func initailiseRelayRideDetailView(ride: Ride,relayRideMatchs: [RelayRideMatch],selectedIndex: Int){
        relayRideDetailViewModel = RelayRideDetailViewModel(ride: ride, relayRideMatchs: relayRideMatchs, selectedIndex: selectedIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.addShadow()
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func prepareView(){
        prepareFirstRider()
        prepareSecondRider()
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapContainerView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 40)
        viewMap.delegate = self
        if viewMap == nil{
            return
        }
        viewMap.clear()
        drawFirstLegMatchedUserRoute()
        drawSecondLegMatchedUserRoute()
        drawFirstRideRoute()
        drawSecondRideRoute()
        setStopOverMark()
        checkAndAddRelayViewSwipeGesture()
        setUpTopView()
        drawDottedRouteBetweenFirstDropAndSecondPickup()
    }
    
    private func setUpTopView(){
        let firstLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: firstLegMatchedUser?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        if let time = rideTime?.components(separatedBy: " ").first {
            pickUpTimeLabel.text = time
        }
        if let time = rideTime?.components(separatedBy: " ").last {
           pmOrAmLabel.text = time
        }
        pointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].totalPoints)
        routeMatchLabel.text = String(relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].totalMatchingPercent) + Strings.percentage_symbol
        stopOverLocationLabel.text = (relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].midLocationAddress ?? "") + " " + "(\(relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].timeDeviationInMins) min)"
        
        let startLocation = CLLocation(latitude: relayRideDetailViewModel.ride.startLatitude ,longitude: relayRideDetailViewModel.ride.startLongitude )
        let pickUpLoaction = CLLocation(latitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch?.pickupLocationLatitude ?? 0,longitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch?.pickupLocationLongitude ?? 0)
        let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: relayRideDetailViewModel.ride.routePathPolyline )
        walkingDistanceLabel.text = relayRideDetailViewModel.getDistanceString(distance: startToPickupWalkDistance)
        
        let firstDropLocation = CLLocation(latitude:relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch?.dropLocationLatitude ?? 0,longitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch?.dropLocationLongitude ?? 0)
        let secondPickupLocation = CLLocation(latitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch?.pickupLocationLatitude ?? 0,longitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch?.pickupLocationLongitude ?? 0)
        let dropToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: firstDropLocation, point2: secondPickupLocation, polyline: relayRideDetailViewModel.ride.routePathPolyline )
        walkingDistance2ndPickup.text = relayRideDetailViewModel.getDistanceString(distance: dropToPickupWalkDistance)
        
        let endLocation =  CLLocation(latitude: relayRideDetailViewModel.ride.endLatitude ?? 0, longitude: relayRideDetailViewModel.ride.endLongitude ?? 0)
        let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch?.dropLocationLatitude ?? 0, longitude: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch?.dropLocationLongitude ?? 0), point2: endLocation , polyline: relayRideDetailViewModel.ride.routePathPolyline )
        walkingDistanceAfterRideLabel.text = relayRideDetailViewModel.getDistanceString(distance: dropToEndWalkDistance)
    }
    
    private func prepareFirstRider(){
        let firstLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        relayRideDetailViewModel.numberOfSeatsImageArray = [firstUserFirstSeatImageView,firstUserSecondSeatImageView,firstUserThirdSeatImageView,firstUserFouthSeatImageView,firstUserFifthSeatImageView,firstUserSixthSeatImageView]
        firstUserImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        ImageCache.getInstance().setImageToView(imageView: firstUserImageView, imageUrl: firstLegMatchedUser?.imageURI ?? "", gender: firstLegMatchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        firstUserNameLabel.text = firstLegMatchedUser?.name?.capitalized
        firstUserVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: firstLegMatchedUser?.profileVerificationData)
        firstUserCompanyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: firstLegMatchedUser?.profileVerificationData, companyName: firstLegMatchedUser?.companyName?.capitalized)
        if firstUserCompanyNameLabel.text == Strings.not_verified {
            firstUserCompanyNameLabel.textColor = UIColor.black
        }else{
            firstUserCompanyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if firstLegMatchedUser?.rating ?? 0 > 0.0{
            firstUserRatingLabel.font = UIFont.systemFont(ofSize: 13.0)
            firstUserStarImageView.isHidden = false
            firstUserRatingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            firstUserRatingLabel.text = String(firstLegMatchedUser?.rating ?? 0) + "(\(String(firstLegMatchedUser?.noOfReviews ?? 0)))"
            firstUserRatingLabel.backgroundColor = .clear
            firstUserRatingLabel.layer.cornerRadius = 0.0
        }else{
            firstUserRatingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            firstUserStarImageView.isHidden = true
            firstUserRatingLabel.textColor = .white
            firstUserRatingLabel.text = Strings.new_user_matching_list
            firstUserRatingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            firstUserRatingLabel.layer.cornerRadius = 2.0
            firstUserRatingLabel.layer.masksToBounds = true
        }
        if firstLegMatchedUser?.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            firstUserVehicleImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
            firstUserVehicleImageView.tintColor = .lightGray
            firstUserSeatShowingStackView.isHidden = true
            firstUserSeatsStackViewWidth.constant = 0
            firstUserPoolShowingLabel.isHidden = false
            firstUserPoolShowingLabel.text = "BIKE POOL"
        } else {
            firstUserVehicleImageView.image = UIImage(named: "car_solid")
            let matchedUserAsRider = firstLegMatchedUser
            let capacity = matchedUserAsRider?.capacity
            firstUserSeatShowingStackView.isHidden = false
            firstUserSeatsStackViewWidth.constant = CGFloat((capacity ?? 0)*17)
            firstUserPoolShowingLabel.isHidden = true
            setOccupiedSeats(availableSeats: (matchedUserAsRider?.availableSeats ?? 1), capacity: capacity ?? 1, seatsImageArray: relayRideDetailViewModel.numberOfSeatsImageArray)
        }
        firstUserPickUplabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: firstLegMatchedUser?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int,seatsImageArray: [UIImageView]) {
        for (index, imageView) in seatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seats_not_occupied")
        }
    }
    
    private func prepareSecondRider(){
        let secondLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
        relayRideDetailViewModel.secondRiderSeatsImageArray = [secondUserFirstSeatImageView,secondUserSecondSeatImageView,secondUserThirdSeatImageView,secondUserFouthSeatImageView,secondUserFifthSeatImageView,secondUserSixthSeatImageView]
        secondUserImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped(_:))))
        ImageCache.getInstance().setImageToView(imageView: secondUserImageView, imageUrl: secondLegMatchedUser?.imageURI ?? "", gender: secondLegMatchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        secondUserNameLabel.text = secondLegMatchedUser?.name?.capitalized
        secondUserVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: secondLegMatchedUser?.profileVerificationData)
        secondUserCompanyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: secondLegMatchedUser?.profileVerificationData, companyName: secondLegMatchedUser?.companyName?.capitalized)
        if secondUserCompanyNameLabel.text == Strings.not_verified {
            secondUserCompanyNameLabel.textColor = UIColor.black
        }else{
            secondUserCompanyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if secondLegMatchedUser?.rating ?? 0 > 0.0{
            secondUserRatingLabel.font = UIFont.systemFont(ofSize: 13.0)
            secondUserStarImageView.isHidden = false
            secondUserRatingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            secondUserRatingLabel.text = String(secondLegMatchedUser?.rating ?? 0) + "(\(String(secondLegMatchedUser?.noOfReviews ?? 0)))"
            secondUserRatingLabel.backgroundColor = .clear
            secondUserRatingLabel.layer.cornerRadius = 0.0
        }else{
            secondUserRatingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            secondUserStarImageView.isHidden = true
            secondUserRatingLabel.textColor = .white
            secondUserRatingLabel.text = Strings.new_user_matching_list
            secondUserRatingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            secondUserRatingLabel.layer.cornerRadius = 2.0
            secondUserRatingLabel.layer.masksToBounds = true
        }
        if secondLegMatchedUser?.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            secondUserVehicleImageView.image = UIImage(named: "biking_solid")
            secondUserSeatShowingStackView.isHidden = true
            secondUserSeatsStackViewWidth.constant = 0
            secondUserPoolShowingLabel.isHidden = false
            secondUserPoolShowingLabel.text = "BIKE POOL"
        } else {
            secondUserVehicleImageView.image = UIImage(named: "car_solid")
            let matchedUserAsRider = secondLegMatchedUser
            let capacity = matchedUserAsRider?.capacity
            secondUserSeatShowingStackView.isHidden = false
            secondUserSeatsStackViewWidth.constant = CGFloat((capacity ?? 0)*17)
            secondUserPoolShowingLabel.isHidden = true
            setOccupiedSeats(availableSeats: (matchedUserAsRider?.availableSeats ?? 1), capacity: capacity ?? 1, seatsImageArray: relayRideDetailViewModel.secondRiderSeatsImageArray)
        }
        secondUserPickUplabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: secondLegMatchedUser?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    }
    
    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        naviagteToProfile(relayMatchUser: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch)
    }
    
    @objc private func profileTapped(_ sender:UITapGestureRecognizer) {
        naviagteToProfile(relayMatchUser: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch)
    }
    
    func checkAndAddRelayViewSwipeGesture() {
        if relayRideDetailViewModel.relayRideMatchs.count > 1 {
            matchView.isUserInteractionEnabled = true
            backGroundView = matchView
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            leftSwipe.direction = .left
            backGroundView!.addGestureRecognizer(leftSwipe)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            rightSwipe.direction = .right
            backGroundView!.addGestureRecognizer(rightSwipe)
        }else{
            leftView.isHidden = true
            rightView.isHidden = true
        }
        if relayRideDetailViewModel.selectedIndex == 0{
            leftView.isHidden = true
            
        }else{
            leftView.isHidden = false
        }
        if relayRideDetailViewModel.selectedIndex == relayRideDetailViewModel.relayRideMatchs.count - 1 {
            rightView.isHidden = true
        }else{
            rightView.isHidden = false
        }
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            
            if relayRideDetailViewModel.selectedIndex != relayRideDetailViewModel.relayRideMatchs.count - 1{
                backGroundView!.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
        }else if gesture.direction == .right {
            
            if relayRideDetailViewModel.selectedIndex != 0 {
                backGroundView!.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
        }
        if gesture.direction == .left {
            relayRideDetailViewModel.selectedIndex += 1
            if relayRideDetailViewModel.selectedIndex > relayRideDetailViewModel.relayRideMatchs.count - 1 {
                relayRideDetailViewModel.selectedIndex = relayRideDetailViewModel.relayRideMatchs.count - 1
            }
        }else if gesture.direction == .right {
            relayRideDetailViewModel.selectedIndex -= 1
            if relayRideDetailViewModel.selectedIndex < 0 {
                relayRideDetailViewModel.selectedIndex = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.prepareView()
        })
        
    }
    
    private func naviagteToProfile(relayMatchUser: MatchedUser?){
        guard let matchedUser = relayMatchUser else { return }
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.userid),isRiderProfile: UserRole.Rider,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func joinRelayRideTapped(_ sender: Any) {
        let relayRidesCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RelayRidesCreationViewController") as! RelayRidesCreationViewController
        relayRidesCreationViewController.initializeView(parentRide: relayRideDetailViewModel.ride, relayRideMatch: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex])
        ViewControllerUtils.addSubView(viewControllerToDisplay: relayRidesCreationViewController)
    }
    
    private func drawFirstRideRoute(){
        let firstLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        if viewMap != nil, let matchedUserRoutePathPolyline = firstLegMatchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty {
            let ride = relayRideDetailViewModel.ride
            let rideRoutePathPolyline = ride.routePathPolyline
            let route = Polyline(encodedPolyline: rideRoutePathPolyline)
            if (route.coordinates?.count)! < 2{
                return
            }
            let start = CLLocation(latitude: ride.startLatitude,longitude: ride.startLongitude)
            let end =  CLLocation(latitude: firstLegMatchedUser?.dropLocationLatitude ?? 0, longitude: firstLegMatchedUser?.dropLocationLongitude ?? 0)
            
            let pickUp = CLLocation(latitude: firstLegMatchedUser?.pickupLocationLatitude ?? 0, longitude: firstLegMatchedUser?.pickupLocationLongitude ?? 0)
            let drop = CLLocation(latitude: firstLegMatchedUser?.dropLocationLatitude ?? 0, longitude: firstLegMatchedUser?.dropLocationLongitude ?? 0)
            GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: 0,useCase :"iOS.App."+(ride.rideType ?? "Passenger")+".WalkRoute.RelayRideDetailedRouteView", riderRoutePolyline: matchedUserRoutePathPolyline, passengerRoutePolyline: rideRoutePathPolyline, passengerStart: start, passengerEnd: end, pickup: pickUp, drop: drop, passengerRideDistance: firstLegMatchedUser?.distance ?? 0, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
            })
            drawOverlappingRoute()
        }
    }
    
    private func drawFirstLegMatchedUserRoute(){
        let firstLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        if let matchedUserRoutePathPolyline = firstLegMatchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty, viewMap != nil {
            GoogleMapUtils.drawRoute(pathString: matchedUserRoutePathPolyline, map: viewMap, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
            drawOverlappingRoute()
        }
    }
    
    private func drawOverlappingRoute(){
        let matchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
            let pickUp = CLLocationCoordinate2D(latitude: matchedUser?.pickupLocationLatitude ?? 0, longitude: matchedUser?.pickupLocationLongitude ?? 0)
            let drop = CLLocationCoordinate2D(latitude: matchedUser?.dropLocationLatitude ?? 0, longitude: matchedUser?.dropLocationLongitude ?? 0)
            let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: matchedUser?.routePolyline ?? "")
            if matchedRoute.count < 3{
                return
            }
            setFirstPickUpAndDropMarker(pickUp: pickUp,drop: drop)
            let polyline = Polyline(coordinates: matchedRoute)
            GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
            perform(#selector(drawRoute), with: self, afterDelay: 0.5)
    }
    
    @objc func drawRoute(){
        let matchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
        if let routePolyline = matchedUser?.routePolyline, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }
    
    func setFirstPickUpAndDropMarker(pickUp : CLLocationCoordinate2D, drop : CLLocationCoordinate2D) {
        firstLegPickUpMarker?.map = nil
        firstLegPickUpMarker = nil
        firstLegPickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        firstLegPickUpMarker?.zIndex = 12
        firstLegDropMarker?.map = nil
        firstLegDropMarker = nil
        firstLegDropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: UIImage(named: "relay_drop_icon")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        firstLegDropMarker?.zIndex = 12
    }
    private func setStopOverMark(){
        stopOverMarker?.map = nil
        stopOverMarker = nil
        let firsLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        let stopOver = CLLocationCoordinate2D(latitude: firsLegMatchedUser?.dropLocationLatitude ?? 0, longitude: firsLegMatchedUser?.dropLocationLongitude ?? 0)
        let stopOverMark = UIView.loadFromNibNamed(nibNamed: "StopOverInfoView") as! StopOverInfoView
        stopOverMark.initializeViews(stopOverTime: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].timeDeviationInMins, zoomState: relayRideDetailViewModel.stopOverZoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: stopOverMark)
        stopOverMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: stopOver, shortIcon: icon,tappable: true,anchor :CGPoint(x: 1, y: 1))
        stopOverMarker?.zIndex = GoogleMapUtils.Z_INDEX_10
    }
    
    private func drawSecondRideRoute(){
        let secondLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
        if viewMap != nil, let matchedUserRoutePathPolyline = secondLegMatchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty {
            let ride = relayRideDetailViewModel.ride
            let rideRoutePathPolyline = ride.routePathPolyline
            let route = Polyline(encodedPolyline: rideRoutePathPolyline)
            if (route.coordinates?.count)! < 2{
                return
            }
            let start = CLLocation(latitude: secondLegMatchedUser?.pickupLocationLatitude ?? 0,longitude: secondLegMatchedUser?.pickupLocationLongitude ?? 0)
            let end =  CLLocation(latitude: ride.endLatitude ?? 0, longitude: ride.endLongitude ?? 0)
            
            let pickUp = CLLocation(latitude: secondLegMatchedUser?.pickupLocationLatitude ?? 0, longitude: secondLegMatchedUser?.pickupLocationLongitude ?? 0)
            let drop = CLLocation(latitude: secondLegMatchedUser?.dropLocationLatitude ?? 0, longitude: secondLegMatchedUser?.dropLocationLongitude ?? 0)
            GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: 0,useCase :"iOS.App."+(ride.rideType ?? "Passenger")+".WalkRoute.RelayRideDetailedRouteView", riderRoutePolyline: matchedUserRoutePathPolyline, passengerRoutePolyline: rideRoutePathPolyline, passengerStart: start, passengerEnd: end, pickup: pickUp, drop: drop, passengerRideDistance: secondLegMatchedUser?.distance ?? 0, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
            })
            drawOverlappingRoute()
        }
    }
    
    private func drawSecondLegMatchedUserRoute(){
        let secondLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
        if let matchedUserRoutePathPolyline = secondLegMatchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty, viewMap != nil {
            GoogleMapUtils.drawRoute(pathString: matchedUserRoutePathPolyline, map: viewMap, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
            drawSecondOverlappingRoute()
        }
    }
    
    private func drawSecondOverlappingRoute(){
        let secondLegMatchMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
            let pickUp = CLLocationCoordinate2D(latitude: secondLegMatchMatchedUser?.pickupLocationLatitude ?? 0, longitude: secondLegMatchMatchedUser?.pickupLocationLongitude ?? 0)
            let drop = CLLocationCoordinate2D(latitude: secondLegMatchMatchedUser?.dropLocationLatitude ?? 0, longitude: secondLegMatchMatchedUser?.dropLocationLongitude ?? 0)
            let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: secondLegMatchMatchedUser?.routePolyline ?? "")
            if matchedRoute.count < 3{
                return
            }
            setSecondPickUpAndDropMarker(pickUp: pickUp,drop: drop)
            let polyline = Polyline(coordinates: matchedRoute)
            GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
            perform(#selector(drawRouteAfterDelay), with: self, afterDelay: 0.5)
    }
    
    @objc func drawRouteAfterDelay(){
        let matchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        if let routePolyline = matchedUser?.routePolyline, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }
    func setSecondPickUpAndDropMarker(pickUp : CLLocationCoordinate2D, drop : CLLocationCoordinate2D) {
        secondLegPickUpMarker?.map = nil
        secondLegPickUpMarker = nil
        secondLegPickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        secondLegPickUpMarker?.zIndex = 12
        secondLegDropMarker?.map = nil
        secondLegDropMarker = nil
        secondLegDropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        secondLegDropMarker?.zIndex = 12
    }
}

//MARK: MapView Delegate
extension RelayRideDetailViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let matchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        if relayRideDetailViewModel.stopOverZoomState == RideDetailMapViewModel.ZOOMED_IN {
            relayRideDetailViewModel.stopOverZoomState = RideDetailMapViewModel.ZOOMED_OUT
            zoomOutToSelectedPoint()
            setStopOverMark()
        } else {
            relayRideDetailViewModel.stopOverZoomState = RideDetailMapViewModel.ZOOMED_IN
            let zoomPoint = CLLocationCoordinate2D(latitude: matchedUser?.pickupLocationLatitude ?? 0, longitude: matchedUser?.pickupLocationLongitude ?? 0)
            zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.pick_up_caps)
            setStopOverMark()
        }
        return true
    }
    
    private func zoomInToSelectedPoint(zoomPoint: CLLocationCoordinate2D, markerType: String) {
            let firsLegMatchedUser = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
            let secondLegMatch = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
            
            let startLat = firsLegMatchedUser?.dropLocationLatitude
            let startLng = firsLegMatchedUser?.dropLocationLongitude
            let endLat = secondLegMatch?.pickupLocationLatitude
            let endLng = secondLegMatch?.pickupLocationLongitude
            
            viewMap.setMinZoom(viewMap.minZoom, maxZoom: 16)
            let uiEdgeInsets = UIEdgeInsets(top: 40, left: 100, bottom: 40, right: 40)
            let routePathToPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat ?? 0, startLong: startLng ?? 0, endLat: endLat ?? 0, endLong: endLng ?? 0, viewMap: viewMap)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToPickUP)!)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            CATransaction.commit()
    }
    
    private func zoomOutToSelectedPoint() {
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch?.routePolyline ?? "")!)
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        CATransaction.commit()
    }
    
    private func drawDottedRouteBetweenFirstDropAndSecondPickup(){
        let firstLegMatch = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].firstLegMatch
        let secondLegMatch = relayRideDetailViewModel.relayRideMatchs[relayRideDetailViewModel.selectedIndex].secondLegMatch
        let drop = CLLocationCoordinate2D(latitude: secondLegMatch?.pickupLocationLatitude ?? 0, longitude: secondLegMatch?.pickupLocationLongitude ?? 0)
        let pickUp = CLLocationCoordinate2D(latitude: firstLegMatch?.dropLocationLatitude ?? 0, longitude: firstLegMatch?.dropLocationLongitude ?? 0)
        let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: relayRideDetailViewModel.ride.routePathPolyline )
        if matchedRoute.count < 3{
            return
        }
        let polyline = Polyline(coordinates: matchedRoute)
        GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0xE20000), width: GoogleMapUtils.POLYLINE_WIDTH_10, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        GoogleMapUtils.createDashedLine(thisPoint: pickUp, nextPoint: drop, color: .white, mapView: viewMap)
        
    }
}
