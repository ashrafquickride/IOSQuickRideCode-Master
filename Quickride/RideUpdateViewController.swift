//
//  RideUpdateViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 22/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import Polyline


protocol RideObjectUdpateListener {
    func rideUpdated(ride : Ride)
}

class RideUpdateViewController: UIViewController,GMSMapViewDelegate{
    
    //MARK: Outlets
    @IBOutlet weak var contentView: UIView!
        
    @IBOutlet weak var fromLocationButton: UIButton!
    
    @IBOutlet weak var toLocationButton: UIButton!
    
    @IBOutlet weak var rideScheduleTimeView: UIView!
    
    @IBOutlet weak var scheduleTimeLabel: UILabel!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    
    @IBOutlet weak var vehicleOrNoOfSeatsLabel: UILabel!
    
    @IBOutlet weak var swapButton: CustomUIButton!
    
    @IBOutlet weak var vehicleOrSeatsImage: UIImageView!
    
    @IBOutlet weak var vehicleOrNoOfSeatsView: UIView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var currentLocationMarker: UIImageView!
    
    @IBOutlet weak var fromAndToLocationView: UIView!
    
    @IBOutlet weak var fromAndToLocationViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dateTimeVehicleView: UIView!
    
    @IBOutlet weak var dateTimeVehicleViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var swapButtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gotoCurrentLocation: UIButton!
    
    @IBOutlet weak var vehicleFareLabel: UILabel!
    
    @IBOutlet weak var vehicleNoOfSeatsLabel: UILabel!
    
    //MARK: Propertise
    var startMarker :GMSMarker?
    weak var viewMap: GMSMapView!
    var endMaker : GMSMarker?
    var selectedPolyLine : GMSPolyline?
    var MAP_ZOOM : Float = 15
    var routePolylines = [GMSPolyline]()
    var rideUpdateViewModel = RideUpdateViewModel()
    var routeDistanceMarker: GMSMarker?
    
    func initializeDataBeforePresentingView(ride : Ride, riderRide: RiderRide?, listener : RideObjectUdpateListener?){
        rideUpdateViewModel.initializeData(ride: ride, riderRide: riderRide, listener: listener)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        initializeControlsBasedOnStatusToPassengerRide()
        contentView.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true, cornerRadius: 10.0)
        initializeRideTimeAndSeatsOrVehicle()
        handleVisibiltyOfTimeAndVehicleView()
        addUiTapGesutereToViews()
        currentLocationMarker.isHidden = true
        gotoCurrentLocation.isHidden = true
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        viewMap.delegate = self
        extractRouteAndDisplay()
        setMapViewPadding()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if rideUpdateViewModel.rideVehicleConfigurationViewController != nil{
            rideUpdateViewModel.rideVehicleConfigurationViewController!.displayView()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Methods
    private func addUiTapGesutereToViews(){
        rideScheduleTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(selectScheduleTime(_:))))
        vehicleOrNoOfSeatsView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(changeVehicleOrSeats(_:))))
    }
    
    private func initializeRideTimeAndSeatsOrVehicle(){
        let time = rideUpdateViewModel.ride?.startTime
        scheduleTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa)
        if rideUpdateViewModel.ride?.rideType == Ride.PASSENGER_RIDE{
            initializeNoOfSeats()
        }else{
            initializeRiderVehicle()
        }
    }
    
    private func handleVisibiltyOfTimeAndVehicleView(){
        if rideUpdateViewModel.checkTimeDateVehicleVisibility(){
            dateTimeVehicleView.isHidden = true
            dateTimeVehicleViewHeightConstraint.constant = 0
        }else{
            dateTimeVehicleView.isHidden = false
            dateTimeVehicleViewHeightConstraint.constant = 40
        }
    }
    
    private func setMapViewPadding() {
        self.viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 0)
    }
    
    private func extractRouteAndDisplay()  {
        guard let ride = rideUpdateViewModel.ride else { return }
        if ride.isKind(of: PassengerRide.self) && rideUpdateViewModel.riderRide != nil{
            displayJoinedRoute()
            let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.expectedEndTime, time2: ride.startTime)

            let rideRoute = RideRoute(routeId: ride.routeId!,overviewPolyline : ride.routePathPolyline,distance :ride.distance!,duration : Double(duration), waypoints : ride.waypoints)
            rideUpdateViewModel.routes.removeAll()
            rideUpdateViewModel.routes.append(rideRoute)
        }else{
            rideUpdateViewModel.selectedRouteId = ride.routeId ?? -1
            MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App."+ride.rideType!+".AllRoutes.RideUpdateView", rideId: ride.rideId, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, weightedRoutes: false, routeReceiver: self)
        }
        
    }
    
    private func displayJoinedRoute(){
        viewMap.clear()
        selectedPolyLine = GoogleMapUtils.drawRoute(pathString: rideUpdateViewModel.riderRide!.routePathPolyline, map: viewMap, colorCode: UIColor(netHex:0x686868), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        guard let ride = rideUpdateViewModel.ride else { return }
        let start = CLLocation(latitude: ride.startLatitude,longitude: ride.startLongitude)
        let end =  CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        let pickup =  CLLocation(latitude:(ride as! PassengerRide).pickupLatitude,longitude: (ride as! PassengerRide).pickupLongitude)
        let drop =  CLLocation(latitude:(ride as! PassengerRide).dropLatitude,longitude: (ride as! PassengerRide).dropLongitude)
        GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride.rideId,useCase : "iOS.App."+ride.rideType!+".WalkRoute.RideUpdateView", riderRoutePolyline: rideUpdateViewModel.riderRide!.routePathPolyline,passengerRoutePolyline: ride.routePathPolyline,passengerStart: start,passengerEnd: end,  pickup :pickup ,drop : drop, passengerRideDistance: ride.distance!, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
        })
        checkEditRouteAndHandle()
        drawOverlappingRoute(pickUp: pickup.coordinate,drop: drop.coordinate)
        perform(#selector(RideUpdateViewController.fitToScreenAfterDelay), with: self, afterDelay: 0.5)
    }
    
    @objc func fitToScreenAfterDelay(){
        if selectedPolyLine != nil && rideUpdateViewModel.ride!.routePathPolyline.isEmpty == false{
            GoogleMapUtils.fitToScreen(route: rideUpdateViewModel.ride!.routePathPolyline, map: viewMap)
        }
    }
    
    private func initializeNoOfSeats(){
        vehicleOrSeatsImage.image = UIImage(named: "ic_seat")
        vehicleOrNoOfSeatsLabel.text = String((rideUpdateViewModel.ride as! PassengerRide).noOfSeats)+" "+Strings.seat_s
    }
    
    private func initializeRiderVehicle(){
        rideUpdateViewModel.prepareVehicle()
        setVehicleDetails(currentVehicle: rideUpdateViewModel.vehicle!)
    }
    
    private func setVehicleDetails(currentVehicle: Vehicle){
        if currentVehicle.registrationNumber.isEmpty{
            vehicleOrNoOfSeatsLabel.text = currentVehicle.vehicleModel
            vehicleNoOfSeatsLabel.text = ""
            vehicleFareLabel.text = ""
        }else{
            let registerNumber = currentVehicle.registrationNumber
            vehicleOrNoOfSeatsLabel.text = String(registerNumber.suffix(4))
            vehicleFareLabel.text = String(format: Strings.points_per_km, arguments: [String(currentVehicle.fare)])
            if currentVehicle.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
                vehicleNoOfSeatsLabel.text = String(format: Strings.multi_seat, arguments: [String(currentVehicle.capacity)])
            }else{
                vehicleNoOfSeatsLabel.text = ""
            }
        }
        if Strings.hatchBack == currentVehicle.vehicleModel{
            vehicleOrSeatsImage.image = UIImage(named: "hatchback_small")
        }else if Strings.sedan == currentVehicle.vehicleModel{
            vehicleOrSeatsImage.image = UIImage(named: "sedan_small")
        }else if Strings.suv == currentVehicle.vehicleModel{
            vehicleOrSeatsImage.image = UIImage(named: "suv_small")
        }else if Strings.premium == currentVehicle.vehicleModel{
            vehicleOrSeatsImage.image = UIImage(named: "premium_small")
        }else if Vehicle.BIKE_MODEL_SCOOTER == currentVehicle.vehicleModel{
            vehicleOrSeatsImage.image = UIImage(named: "scooter")
        }else{
            vehicleOrSeatsImage.image = UIImage(named: "bike_small")
        }
    }
    
    @objc func changeVehicleOrSeats(_ gesture: UITapGestureRecognizer){
        if rideUpdateViewModel.ride!.rideType == Ride.PASSENGER_RIDE{
            let seatsSelectionViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "NumberOfSeatsSelector") as! SeatsSelectionViewController
            seatsSelectionViewController.initializeDataBeforePresenting(handler: { [weak self] (seats) in
                self?.numberSelected(number: seats)
                }, seatsSelected: (rideUpdateViewModel.ride as! PassengerRide).noOfSeats)
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: seatsSelectionViewController, animated: false, completion: nil)
        }else if rideUpdateViewModel.ride!.rideType == Ride.RIDER_RIDE{
            if UserDataCache.getInstance()?.uservehicles.count == 0 {
                let newRideVehicleConfigurationViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "NewRideVehicleConfigurationViewController") as! NewRideVehicleConfigurationViewController
                newRideVehicleConfigurationViewController.initializeDataBeforePresenting(viewController: self, vehicle: rideUpdateViewModel.vehicle!.copy() as! Vehicle, ride: rideUpdateViewModel.ride as? RiderRide, rideConfigurationDelegate: self)
                
                ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: newRideVehicleConfigurationViewController, animated: false, completion: nil)
            }else{
                let rideVehicleConfigurationViewController = UIStoryboard(name: "MapView",bundle: nil).instantiateViewController(withIdentifier: "RideVehicleConfigurationViewController") as! RideVehicleConfigurationViewController
                self.rideUpdateViewModel.rideVehicleConfigurationViewController = rideVehicleConfigurationViewController
                rideVehicleConfigurationViewController.initializeDataBeforePresenting(vehicle : rideUpdateViewModel.vehicle!.copy() as! Vehicle,rideConfigurationDelegate : self, dismissHandler: {
                    self.rideUpdateViewModel.rideVehicleConfigurationViewController = nil
                })
                ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: rideVehicleConfigurationViewController, animated: false, completion: nil)
            }
            
        }
    }
    
    @objc func selectScheduleTime( _ getsture: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectDateTimeViewController :ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        var datePickerMode : UIDatePicker.Mode?
        if Ride.RIDER_RIDE == rideUpdateViewModel.ride?.rideType{
            if (rideUpdateViewModel.ride as! RiderRide).noOfPassengers < 1{
                datePickerMode = UIDatePicker.Mode.dateAndTime
            }else{
                datePickerMode = UIDatePicker.Mode.time
            }
        }else{
            datePickerMode = UIDatePicker.Mode.dateAndTime
        }
        selectDateTimeViewController.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970/1000,maxDate: nil, defaultDate: (rideUpdateViewModel.ride?.startTime)!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: datePickerMode, datePickerTitle: nil, handler: nil)
        selectDateTimeViewController.modalPresentationStyle = .overCurrentContext
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: selectDateTimeViewController, animated: false, completion: nil)
    }
    
    private func initializeControlsBasedOnStatusToPassengerRide(){
        if let passengerRide = rideUpdateViewModel.ride as? PassengerRide, rideUpdateViewModel.isPickupDropEditEnable() {
            fromLocationButton.setTitle(passengerRide.pickupAddress, for: .normal)
            toLocationButton.setTitle(passengerRide.dropAddress, for: .normal)
        } else {
            fromLocationButton.setTitle(rideUpdateViewModel.ride?.startAddress, for: .normal)
            toLocationButton.setTitle(rideUpdateViewModel.ride?.endAddress, for: .normal)
        }
        
        checkStatusAndEnableStartAndEndLocationSelection()
    }
    
    private func checkStatusAndEnableStartAndEndLocationSelection(){
        if rideUpdateViewModel.checkFromAndToAddressVisibility(){
            fromAndToLocationView.isHidden = false
            fromAndToLocationViewHeightConstraint.constant = 85
        }else{
            fromAndToLocationView.isHidden = true
            fromAndToLocationViewHeightConstraint.constant = 0
        }
    }
    
    private func checkEditRouteAndHandle(){
        if let passengerRide = rideUpdateViewModel.ride as? PassengerRide{
            if rideUpdateViewModel.isPickupDropEditEnable()  {
                if rideUpdateViewModel.riderRide != nil && passengerRide.status != Ride.RIDE_STATUS_STARTED {
                    fromLocationButton.isEnabled = true
                    toLocationButton.isEnabled = true
                } else if rideUpdateViewModel.riderRide != nil && passengerRide.status == Ride.RIDE_STATUS_STARTED {
                    fromLocationButton.isEnabled = false
                    toLocationButton.isEnabled = true
                } else if passengerRide.status == Ride.RIDE_STATUS_REQUESTED{
                    fromLocationButton.isEnabled = false
                    toLocationButton.isEnabled = false
                    if let route = rideUpdateViewModel.currentRideRoute{
                    displayTimeAndDistanceInfoView(routePathData: route, backgroundColor: UIColor(netHex: 0x007AFF), zIndex: GoogleMapUtils.Z_INDEX_10)
                    }
                }else if passengerRide.rideType == Ride.RIDER_RIDE && (rideUpdateViewModel.ride as! RiderRide).noOfPassengers == 0{
                    fromLocationButton.isEnabled = false
                    toLocationButton.isEnabled = false
                    if let route = rideUpdateViewModel.currentRideRoute{
                        displayTimeAndDistanceInfoView(routePathData: route, backgroundColor: UIColor(netHex: 0x007AFF), zIndex: GoogleMapUtils.Z_INDEX_10)
                    }
                    
                }else{
                    fromLocationButton.isEnabled = false
                    toLocationButton.isEnabled = false
                }
            }else{
                if let route = rideUpdateViewModel.currentRideRoute{
                displayTimeAndDistanceInfoView(routePathData: route, backgroundColor: UIColor(netHex: 0x007AFF), zIndex: GoogleMapUtils.Z_INDEX_10)
                }
            }
            
        }else if let riderRide = rideUpdateViewModel.ride as? RiderRide {
            if riderRide.noOfPassengers == 0 && (riderRide.status == Ride.RIDE_STATUS_SCHEDULED || riderRide.status == Ride.RIDE_STATUS_DELAYED) {
                if let route = rideUpdateViewModel.currentRideRoute{
                displayTimeAndDistanceInfoView(routePathData: route, backgroundColor: UIColor(netHex: 0x007AFF), zIndex: GoogleMapUtils.Z_INDEX_10)
                }
            }
        }
        
       
    }
    
    
    func handleChangePickupDrop(isFromEditPickup: Bool)  {
        let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickupDropEditViewController") as? PickupDropEditViewController
        object_setClass(pickUpDropViewController, ConfirmCarpoolPickupOrDropPointViewController.self)
        guard let confirmCarpoolPickupOrDropPointViewController = pickUpDropViewController as? ConfirmCarpoolPickupOrDropPointViewController else { return }
        
        if let passengerRide = rideUpdateViewModel.ride as? PassengerRide {
            let riderRideId = passengerRide.riderRideId
            let passengerRideId = rideUpdateViewModel.ride?.rideId
            let passengerId = rideUpdateViewModel.ride?.userId
            let riderId = passengerRide.riderId
            let noOfSeats = passengerRide.noOfSeats
            let riderRoutePolyline = rideUpdateViewModel.riderRide?.routePathPolyline
            
            confirmCarpoolPickupOrDropPointViewController.showConfirmPickPointView(matchedUser: MatchedRider(passengerRide: passengerRide),riderRoutePolyline: riderRoutePolyline!, delegate: self,passengerRideId :passengerRideId,riderRideId: riderRideId,passengerId: passengerId,riderId: riderId,noOfSeats: noOfSeats, isFromEditPickup: isFromEditPickup, note: passengerRide.pickupNote)
            self.navigationController?.pushViewController(confirmCarpoolPickupOrDropPointViewController, animated: false)
        }
    }
    
    @IBAction func fromLocationTapped(_ sender: Any) {
        guard let ride = rideUpdateViewModel.ride else { return }
        if rideUpdateViewModel.isPickupDropEditEnable() {
            handleChangePickupDrop(isFromEditPickup: true)
        }else{
            let location = Location(latitude: ride.startLatitude, longitude: ride.startLongitude, shortAddress: ride.startAddress)
            moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: location)
        }
        
    }
    
    @IBAction func toLocationTapped(_ sender: Any) {
        guard let ride = rideUpdateViewModel.ride else { return }
        if rideUpdateViewModel.isPickupDropEditEnable() {
            handleChangePickupDrop(isFromEditPickup: false)
        }else{
            let location = Location(latitude: ride.endLatitude!,longitude: ride.endLongitude!,shortAddress: ride.endAddress)
            moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: location)
        }
    }
    
    private func moveToLocationSelection(locationType : String, location : Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let changeLocationVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: self, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    
    private func clearRouteData(){
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
        rideUpdateViewModel.routes.removeAll()
        for polyline in routePolylines{
            polyline.map = nil
        }
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        currentLocationMarker.isHidden = false
        routePolylines.removeAll()
        rideUpdateViewModel.ride?.distance = 0
    }
    
    
    private func drawAllPossibleRoutesWithSelectedRoute(){
        AppDelegate.getAppDelegate().log.debug("drawAllPossibleRoutesWithSelectedRoute()")
        viewMap.clear()
        for polyline in routePolylines{
            polyline.map = nil
        }
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        routePolylines.removeAll()
        let routes = rideUpdateViewModel.routes
        for route in routes {
            if rideUpdateViewModel.selectedRouteId == route.routeId{
                drawUserRoute(rideRoute: route)
                checkEditRouteAndHandle()
            }else{
                let selectedPolyLine = GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!, map: viewMap, colorCode: UIColor(netHex: 0x767676), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_5, tappable: true)
                selectedPolyLine.userData = route.routeId
                routePolylines.append(selectedPolyLine)
            }
        }
        perform(#selector(RideUpdateViewController.fitToScreenAfterDelay), with: self, afterDelay: 0.5)
    }
    
    private func drawUserRoute(rideRoute : RideRoute){
        prepareStartAndEndMarkers()
        selectedPolyLine = GoogleMapUtils.drawRoute(pathString: rideRoute.overviewPolyline!, map: viewMap, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        rideUpdateViewModel.ride!.routePathPolyline = rideRoute.overviewPolyline!
        let polyline = GoogleMapUtils.drawRoute(pathString: rideRoute.overviewPolyline!, map: viewMap, colorCode: UIColor(netHex: 0x005BA4), width: GoogleMapUtils.POLYLINE_WIDTH_5, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
        routePolylines.append(polyline)
        selectedPolyLine?.userData = rideRoute.routeId
        routePolylines.append(selectedPolyLine!)
        currentLocationMarker.isHidden = true
        rideUpdateViewModel.ride?.distance = rideRoute.distance
        rideUpdateViewModel.ride?.routeId = rideRoute.routeId
    }
    
    private func prepareStartAndEndMarkers(){
        guard let ride = rideUpdateViewModel.ride else { return }
        startMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: ride.startLatitude,longitude : ride.startLongitude), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        startMarker?.zIndex = 12
        endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: ride.endLatitude!,longitude : ride.endLongitude!), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        endMaker?.zIndex = 12
    }
    
    private func moveToCoordinate(coordinate : CLLocationCoordinate2D){
        AppDelegate.getAppDelegate().log.debug("moveToCoordinate()")
        let cameraPosition : GMSCameraPosition = GMSCameraPosition(target: coordinate, zoom: MAP_ZOOM , bearing: 0, viewingAngle: 0)
        self.viewMap.animate(to: cameraPosition)
    }
    
    private func numberSelected(number : Int) {
        (rideUpdateViewModel.ride as! PassengerRide).noOfSeats = number
        vehicleOrNoOfSeatsLabel.text = String(number)+" "+Strings.seats
        vehicleFareLabel.text = ""
        vehicleNoOfSeatsLabel.text = ""
    }
    
    @IBAction func swapButtonTapped(_ sender: Any){
        guard let ride = rideUpdateViewModel.ride else { return }
        let tempString = ride.startAddress
        ride.startAddress = ride.endAddress
        setStartLocation()
        ride.endAddress = tempString
        setEndLocation()
        
        var tempDouble = ride.startLatitude
        ride.startLatitude = ride.endLatitude!
        ride.endLatitude = tempDouble
        
        tempDouble = ride.startLongitude
        ride.startLongitude = ride.endLongitude!
        ride.endLongitude = tempDouble
        rideUpdateViewModel.selectedRouteId = -1
        rideUpdateViewModel.getMostFavourableRoute(listener: self)
    }
    
    private func setStartLocation(){
        if rideUpdateViewModel.ride!.startAddress.isEmpty == true{
            fromLocationButton.setTitle(Strings.enter_start_location, for: .normal)
        }else{
            fromLocationButton.setTitle(rideUpdateViewModel.ride!.startAddress, for: .normal)
        }
    }
    
    private func setEndLocation(){
        if rideUpdateViewModel.ride!.endAddress.isEmpty == true{
            toLocationButton.setTitle(Strings.enter_end_location, for: .normal)
        }else{
            toLocationButton.setTitle(rideUpdateViewModel.ride!.endAddress, for: .normal)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func updateRideClicked(_ sender: Any) {
        rideUpdateViewModel.upadteEditedRide(fromAddrees: fromLocationButton.titleLabel?.text, toAddress: toLocationButton.titleLabel?.text, viewController: self)
    }
    
    private func drawOverlappingRoute(pickUp : CLLocationCoordinate2D, drop : CLLocationCoordinate2D){
        let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: rideUpdateViewModel.riderRide!.routePathPolyline)
        if matchedRoute.count < 3{
            return
        }
        let polyline = Polyline(coordinates: matchedRoute)
        GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x1e90ff), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        let pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: UIImage(named: "matched_start")!,tappable: true,anchor : CGPoint(x: 0.5, y: 0.5))
        pickUpMarker.zIndex = 8
        let dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location:drop , shortIcon: UIImage(named: "matched_end")!,tappable: true,anchor :CGPoint(x: 0.5, y: 0.5))
        dropMarker.zIndex = 8
        
        let pickUpBadge =  GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: UIImage(named: "matched_pickup_badge")!, tappable: false,anchor :CGPoint(x: 0, y: 1))
        pickUpBadge.zIndex = 10
        let dropBadge = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: UIImage(named: "matched_drop_badge")!, tappable: false,anchor :CGPoint(x: 0, y: 1))
        dropBadge.zIndex = 10
    }
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        if selectedPolyLine != nil && rideUpdateViewModel.ride!.routePathPolyline.isEmpty == false{
            GoogleMapUtils.fitToScreen(route: rideUpdateViewModel.ride!.routePathPolyline, map: viewMap)
        }
    }
    
    private func displayTimeAndDistanceInfoView(routePathData : RideRoute,backgroundColor : UIColor,zIndex:Int32){
        let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "RouteTimeAndChangeRouteInfoView") as! RouteTimeAndChangeRouteInfoView
        routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!, duration: routePathData.duration)
        routeTimeAndChangeRouteInfoView.addShadow()
        let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView)
        let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
        if path != nil && path!.count() != 0{
            routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: zIndex)
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        AppDelegate.getAppDelegate().log.debug("changeRouteClicked")
        if let rideRoute = rideUpdateViewModel.currentRideRoute{
            let selectRouteFromMapViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
            selectRouteFromMapViewController.initializeDataBeforePresenting(ride: rideUpdateViewModel.ride!, rideRoute: rideRoute,routeSelectionDelegate: self)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectRouteFromMapViewController, animated: false)
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            gotoCurrentLocation.isHidden = false
        }else{
            gotoCurrentLocation.isHidden = true
        }
        
    }
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        AppDelegate.getAppDelegate().log.debug("didTapOverlay")
        
        guard let polyline = overlay as? GMSPolyline,let routeId = polyline.userData as? Double else{
            return
        }
        if rideUpdateViewModel.selectedRouteId == routeId{
            return
        }
        rideUpdateViewModel.selectedRouteId  = routeId
        drawAllPossibleRoutesWithSelectedRoute()
    }
        
}

//MARK: SelectDateDelegate
extension RideUpdateViewController: SelectDateDelegate{
    func getTime(date: Double) {
        rideUpdateViewModel.ride!.startTime = date*1000
        scheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: date), format: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa)
    }
}

//MARK: ReceiveLocationDelegate
extension RideUpdateViewController:  ReceiveLocationDelegate{
    func receiveSelectedLocation(location : Location,requestLocationType : String){
        guard let ride = rideUpdateViewModel.ride else { return }
        rideUpdateViewModel.selectedRouteId = -1
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            ride.startLatitude = location.latitude
            ride.startLongitude = location.longitude
            ride.startAddress = location.shortAddress!
            self.setStartLocation()
            moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }else{
            ride.endLatitude = location.latitude
            ride.endLongitude = location.longitude
            ride.endAddress = location.shortAddress!
            self.setEndLocation()
        }
        ride.waypoints = nil
        rideUpdateViewModel.getMostFavourableRoute(listener: self)
    }
    func locationSelectionCancelled(requestLocationType : String){
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
    }
}

//MARK: RouteSelectionDelegate
extension RideUpdateViewController: RouteSelectionDelegate{
    func receiveSelectedRoute(ride : Ride?,route : RideRoute){
        clearRouteData()
        rideUpdateViewModel.routes.removeAll()
        rideUpdateViewModel.routes.append(route)
        rideUpdateViewModel.selectedRouteId = route.routeId ?? -1
        drawAllPossibleRoutesWithSelectedRoute()
    }
    func recieveSelectedPreferredRoute(ride : Ride?, preferredRoute : UserPreferredRoute) {
       
        clearRouteData()
        if preferredRoute.fromLocation != nil{
            rideUpdateViewModel.ride!.startLatitude = preferredRoute.fromLatitude!
            rideUpdateViewModel.ride!.startLongitude = preferredRoute.fromLongitude!
            rideUpdateViewModel.ride!.startAddress = preferredRoute.fromLocation!
            setStartLocation()
        }
        if preferredRoute.toLocation != nil{
            rideUpdateViewModel.ride!.endLatitude = preferredRoute.toLatitude!
            rideUpdateViewModel.ride!.endLongitude = preferredRoute.toLongitude!
            rideUpdateViewModel.ride!.endAddress = preferredRoute.toLocation!
            setEndLocation()
        }

        if let rideRoute = MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId) {
            rideUpdateViewModel.routes.removeAll()
            rideUpdateViewModel.routes.append(rideRoute)
            rideUpdateViewModel.selectedRouteId = rideRoute.routeId ?? -1
            drawAllPossibleRoutesWithSelectedRoute()
        }else{
            rideUpdateViewModel.getMostFavourableRoute(listener: self)
        }
    }
}

//MARK: RideConfigurationDelegate
extension RideUpdateViewController: RideConfigurationDelegate{
    func vehicleConfigurationConfirmed(vehicle : Vehicle){
        rideUpdateViewModel.vehicle = vehicle
        setVehicleDetails(currentVehicle: vehicle)
    }
}

//MARK: RouteReceiver
extension RideUpdateViewController: RouteReceiver{
    func receiveRoute(rideRoute:[RideRoute], alternative: Bool){
        guard let ride = rideUpdateViewModel.ride else {
            return
        }
        clearRouteData()
        var routes = MyRoutesCache.cleanupRoutes(routes: rideRoute)
        
        if let prefRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!),let route = prefRoute.rideRoute{
            routes.append(route)
            
        }else{
            var contains = false
            var defaultRouteId : Double = -1
            for route in routes {
                if route.routeId == rideUpdateViewModel.selectedRouteId {
                    contains = true
                }
                if route.routeType == RoutePathData.ROUTE_TYPE_MAIN || route.routeType == RoutePathData.ROUTE_TYPE_DEFAULT{
                    defaultRouteId = route.routeId!
                }
                
            }
            if !contains{
                if rideUpdateViewModel.selectedRouteId == rideUpdateViewModel.ride?.routeId {
                    if let ride = rideUpdateViewModel.ride{
                        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride.expectedEndTime, time2: ride.startTime)
                        let rideRoute = RideRoute(routeId: ride.routeId!,overviewPolyline : ride.routePathPolyline,distance :ride.distance!,duration : Double(duration), waypoints : ride.waypoints)
                        routes.append(rideRoute)
                    }else{
                        rideUpdateViewModel.selectedRouteId = defaultRouteId
                    }
                }else{
                    rideUpdateViewModel.selectedRouteId = defaultRouteId
                }
                
            }
        }
        
        rideUpdateViewModel.routes = routes
        drawAllPossibleRoutesWithSelectedRoute()
    }
    func receiveRouteFailed(responseObject :NSDictionary?,error: NSError?){
        clearRouteData()
        if QRReachability.isConnectedToNetwork(){
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route_due_to_network, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-260), title: nil, image: nil, completion: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-260), title: nil, image: nil, completion: nil)
        }
        moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: rideUpdateViewModel.ride!.startLatitude, longitude: rideUpdateViewModel.ride!.startLongitude))
    }
}

//MARK: PickUpAndDropSelectionDelegate
extension RideUpdateViewController: PickUpAndDropSelectionDelegate{
    func pickUpAndDropChanged(matchedUser : MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?){
        rideUpdateViewModel.updatePickUpAndDropPoint(matchedUser: matchedUser, userPreferredPickupDrop: userPreferredPickupDrop)
        displayJoinedRoute()
        initializeControlsBasedOnStatusToPassengerRide()
    }
}

//MARK: ReceiveLocationDelegate
extension RideUpdateViewController: VehicleDetailsUpdateListener{
    func VehicleDetailsUpdated(){
        rideUpdateViewModel.vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        setVehicleDetails(currentVehicle: rideUpdateViewModel.vehicle!)
    }
}
