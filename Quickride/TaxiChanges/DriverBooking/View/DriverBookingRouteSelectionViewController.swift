//
//  DriverBookingRouteSelectionViewController.swift
//  Quickride
//
//  Created by HK on 01/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import CoreLocation

class DriverBookingRouteSelectionViewController: UIViewController {
    
    @IBOutlet weak var tripTypeCollectionView: UICollectionView!
    @IBOutlet weak var enterStartLocationButton: UIButton!
    @IBOutlet weak var endLocationButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var carTypeButton: UIButton!
    @IBOutlet weak private var mapView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    private var viewMap: GMSMapView!
    private var viewModel = DriverBookingRouteSelectionViewModel()
    private var driverRoute: RideRoute?
    private var routeDistanceMarker: GMSMarker?
    private var startMarker :GMSMarker?
    private var endMaker : GMSMarker?
    private var selectedPolyLine : GMSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpUI()
    }
    
    func registerCell() {
        tripTypeCollectionView.register(UINib(nibName: "RideCreationRideTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideCreationRideTypeCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setUpUI() {
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.delegate = self
        viewMap.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        viewMap.animate(toZoom: 16)
        viewMap.isMyLocationEnabled = false
        viewModel.startLocation = UserDataCache.getInstance()?.userCurrentLocation
        moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: viewModel.startLocation?.latitude ?? 0, longitude: viewModel.startLocation?.longitude ?? 0))
        setStartLocation()
        let startTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.startTime, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        timeButton.setTitle(startTime, for: .normal)
        carTypeButton.setTitle(viewModel.carType, for: .normal)
        viewModel.rideTypes[0].selected = true
    }
    private func moveToCoordinate(coordinate : CLLocationCoordinate2D){
        AppDelegate.getAppDelegate().log.debug("moveToCoordinate()")
        let cameraPosition : GMSCameraPosition = GMSCameraPosition(target: coordinate, zoom: viewModel.MAP_ZOOM, bearing: 0, viewingAngle: 0)
        self.viewMap.animate(to: cameraPosition)
    }
    private func setStartLocation(){
        if let startLocation = viewModel.startLocation{
            enterStartLocationButton.setTitle(startLocation.address, for: .normal)
            enterStartLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
        } else {
            enterStartLocationButton.setTitle(Strings.enter_start_location, for: .normal)
            enterStartLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        }
    }
    
    private func setEndLocation() {
        if let endLocation = viewModel.endLocation{
            endLocationButton.setTitle(endLocation.address, for: .normal)
            endLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
        }else{
            endLocationButton.setTitle(Strings.enter_end_location, for: .normal)
            endLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func startLocationBtnPressed(_ sender: UIButton) {
        moveToLocationSelection(locationType:  ChangeLocationViewController.ORIGIN, location: viewModel.startLocation)
    }
    
    @IBAction func endLocationBtnPressed(_ sender: UIButton) {
        moveToLocationSelection(locationType:  ChangeLocationViewController.DESTINATION, location: viewModel.endLocation)
    }
    
    @IBAction func swapBtnPressed(_ sender: UIButton) {
        let temp = viewModel.startLocation
        viewModel.startLocation = viewModel.endLocation
        viewModel.endLocation = temp
        getRoutesAvailable()
    }
    
    @IBAction func currentLocationButtonpressed(_ sender: UIButton) {
        if let currentRideRoute = driverRoute, currentRideRoute.overviewPolyline != nil{
            GoogleMapUtils.fitToScreen(route: currentRideRoute.overviewPolyline!, map: self.viewMap)
        }
        currentLocationButton.isHidden = true
    }
    
    func moveToLocationSelection(locationType : String, location : Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: self, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    
    @IBAction func timeChangeBtnPressed(_ sender: UIButton) {
        let scheduleLater:ScheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.delegate = self
        scheduleLater.minDate = NSDate().timeIntervalSince1970
        scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    @IBAction func carTypeBtnPressed(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("displayVehicleModelAlertController()")
        let carTypes = [Vehicle.VEHICLE_MODEL_HATCHBACK,Vehicle.VEHICLE_MODEL_SEDAN,Vehicle.VEHICLE_MODEL_SUV,Vehicle.VEHICLE_MODEL_PREMIUM]
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for i in 0...carTypes.count-1{
            let action = UIAlertAction(title: "\(carTypes[i])", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.carTypeButton.setTitle(alert.title ?? Vehicle.VEHICLE_MODEL_HATCHBACK, for: .normal)
                self.viewModel.carType = alert.title ?? Vehicle.VEHICLE_MODEL_HATCHBACK
            })
            optionMenu.addAction(action)
        }
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    
    @IBAction func requestDriverButtonPressed(_ sender: UIButton) {
        let driverBookTimeConstraint = ConfigurationCache.getObjectClientConfiguration().driverInstantBookingThresholdTimeInMins
        let driverBookingThersholdTime = DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: driverBookTimeConstraint)
        if driverBookingThersholdTime > viewModel.startTime {
            let changedRideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: driverBookingThersholdTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)!
            let messageString = String(format: Strings.driver_time_popup_message, arguments: ["\(driverBookTimeConstraint)",changedRideTime])
            MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: true, message1: nil, message2: messageString, positiveActnTitle: Strings.confirm_caps, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, viewController: nil) { [weak self] (value) in
                if value == Strings.confirm_caps {
                    self?.viewModel.startTime = driverBookingThersholdTime
                    self?.showDriverBookingPaymentPopUp()
                }
            }
        }else{
            showDriverBookingPaymentPopUp()
        }
    }
    
    private func showDriverBookingPaymentPopUp() {
        if let startLoc = viewModel.startLocation, let endLoc = viewModel.endLocation{
            var tripType = Strings.one_way
            if viewModel.isRoundTrip{
                tripType = Strings.round_trip
            }
            let driverBookingVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "DriverBookingViewController") as! DriverBookingViewController
            driverBookingVC.initialiseData(startLocation: startLoc, endLocation: endLoc, journeyType: tripType, vehicleType: viewModel.carType,startTime: viewModel.startTime) { [weak self] (data) in
                self?.showSucessDrawer()
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: driverBookingVC)
        }else{
            UIApplication.shared.keyWindow?.makeToast(Strings.please_try_again)
        }
    }
    
    private func showSucessDrawer() {
        let driverBookingVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "DriverBookingSucessViewController") as! DriverBookingSucessViewController
        ViewControllerUtils.addSubView(viewControllerToDisplay: driverBookingVC)
    }
}

//MArk Draw route and polylines
extension DriverBookingRouteSelectionViewController {
    private func drawSelectedRoute() {
        AppDelegate.getAppDelegate().log.debug("drawSelectedRoute()")
        if viewModel.startLocation == nil || viewModel.endLocation == nil || viewModel.startLocation?.latitude == nil || viewModel.startLocation?.longitude == nil || viewModel.endLocation?.latitude == nil || viewModel.endLocation?.longitude == nil { return }
        if let route = driverRoute, route.overviewPolyline != nil{
            self.viewModel.distance = route.distance!
            drawUserRoute(rideRoute: route)
            displayTimeAndDistanceInfoView(routePathData: route)
            currentLocationButton.isHidden = false
        }
    }
    
    func drawUserRoute(rideRoute : RideRoute) {
        guard let overViewPolyline = rideRoute.overviewPolyline else{
            return
        }
        prepareStartAndEndMarkers()
        selectedPolyLine = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: viewMap, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        selectedPolyLine?.userData = rideRoute.routeId
        GoogleMapUtils.fitToScreen(route: overViewPolyline, map: viewMap)
        
    }
    
    private func prepareStartAndEndMarkers(){
        startMarker?.map = nil
        startMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: viewModel.startLocation?.latitude ?? 0, longitude: viewModel.startLocation?.longitude ?? 0), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        startMarker?.zIndex = 12
        endMaker?.map = nil
        endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: viewModel.endLocation?.latitude ?? 0 ,longitude : viewModel.endLocation?.longitude ?? 0), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        endMaker?.zIndex = 12
    }
    
    func getRoutesAvailable() {
        clearRouteData()
        if viewModel.startLocation != nil && viewModel.endLocation != nil && viewModel.startLocation?.latitude != 0 && viewModel.startLocation?.longitude != 0 && viewModel.endLocation?.latitude != 0 && viewModel.endLocation?.longitude != 0{
            QuickRideProgressSpinner.startSpinner()
            MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App.Passenger.AllRoutes.RideCreationView", rideId: 0, startLatitude: viewModel.startLocation?.latitude ?? 0, startLongitude: viewModel.startLocation?.longitude ?? 0, endLatitude: viewModel.endLocation?.latitude ?? 0, endLongitude: viewModel.endLocation?.longitude ?? 0, weightedRoutes: false, routeReceiver: self)
        }
    }
    
    private func displayTimeAndDistanceInfoView(routePathData : RideRoute){
        let distanceInfoView = UIView.loadFromNibNamed(nibNamed: "DistanceInfoView") as! DistanceInfoView
        distanceInfoView.initializeDataBeforePresenting(distance: routePathData.distance!)
        distanceInfoView.addShadow()
        let icon = ViewCustomizationUtils.getImageFromView(view: distanceInfoView)
        let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
        routeDistanceMarker?.map = nil
        if path != nil && path!.count() != 0 {
            routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: false, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
        }
    }
    
    private func clearRouteData(){
        driverRoute = nil
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
        routeDistanceMarker?.map = nil
        routeDistanceMarker = nil
        viewModel.selectedRouteId = -1
        viewModel.distance = 0
    }
}
extension DriverBookingRouteSelectionViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        guard let route = driverRoute else { return }
        if gesture{
            currentLocationButton.isHidden = false
        }else{
            currentLocationButton.isHidden = true
        }
    }
}
extension DriverBookingRouteSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.rideTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideCreationRideTypeCollectionViewCell", for: indexPath) as! RideCreationRideTypeCollectionViewCell
        let item = viewModel.rideTypes[indexPath.row]
        cell.rideTypeLabel.text = item.name
        if item.selected{
            cell.rideTypeLabel.textColor = UIColor(netHex: 0x00B557)
            cell.bottomSeparatorView.backgroundColor = UIColor(netHex: 0x00B557)
        }else{
            cell.rideTypeLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            cell.bottomSeparatorView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        return cell
    }
}

extension DriverBookingRouteSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            viewModel.isRoundTrip = false
        }else{
            viewModel.isRoundTrip = true
        }
        viewModel.rideTypes[0].selected = viewModel.isRoundTrip ? false : true
        viewModel.rideTypes[1].selected = viewModel.isRoundTrip ? true : false
        tripTypeCollectionView.reloadData()
    }
}
extension DriverBookingRouteSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.tripTypeCollectionView.frame.width/2, height: self.tripTypeCollectionView.frame.height)
    }
}
extension DriverBookingRouteSelectionViewController: SelectDateDelegate {
    func getTime(date: Double) {
        AppDelegate.getAppDelegate().log.debug("getTime")
        viewModel.startTime = date*1000
        let startTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date*1000, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        timeButton.setTitle(startTime, for: .normal)
    }
}
//MARK: Location selection delegates
extension DriverBookingRouteSelectionViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
    }
    
    func locationSelectionCancelled(requestLocationType: String) {}
    
    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            if let endLocation = viewModel.endLocation{
                let distance = LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: endLocation.latitude, toLongitude: endLocation.longitude)
                if distance < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES{
                    UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                    return
                }
            }
            viewModel.startLocation = location
            moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            setStartLocation()
        }else{
            if let startLocation = viewModel.startLocation{
                let distance = LocationClientUtils.getDistance(fromLatitude: startLocation.latitude, fromLongitude: startLocation.longitude, toLatitude: location.latitude, toLongitude: location.longitude)
                if distance < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES{
                    UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                    return
                }
            }
            viewModel.endLocation = location
            setEndLocation()
        }
        viewModel.selectedRouteId = 0.0
        getRoutesAvailable()
    }
}
//MARK: Location selection delegates
extension DriverBookingRouteSelectionViewController: RouteSelectionDelegate {
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {}
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        if preferredRoute.fromLocation != nil{
            viewModel.startLocation?.latitude = preferredRoute.fromLatitude!
            viewModel.startLocation?.longitude = preferredRoute.fromLongitude!
            viewModel.startLocation?.address = preferredRoute.fromLocation!
            setStartLocation()
        }
        if preferredRoute.toLocation != nil{
            viewModel.endLocation?.latitude = preferredRoute.toLatitude!
            viewModel.endLocation?.longitude = preferredRoute.toLongitude!
            viewModel.endLocation?.address = preferredRoute.toLocation!
            setEndLocation()
        }
    }
}
//MARK: Location selection delegates
extension DriverBookingRouteSelectionViewController: RouteReceiver {
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        QuickRideProgressSpinner.stopSpinner()
        if !rideRoute.isEmpty{
            let routePaths = MyRoutesCache.cleanupRoutes(routes: rideRoute)
            for route in routePaths{
                if route.routeType == RoutePathData.ROUTE_TYPE_MAIN || route.routeType == RoutePathData.ROUTE_TYPE_DEFAULT{
                    viewModel.selectedRouteId = route.routeId!
                    driverRoute = route
                    break
                }
            }
            if viewModel.selectedRouteId == -1{
                viewModel.selectedRouteId = routePaths[0].routeId!
                driverRoute = routePaths[0]
            }
            drawSelectedRoute()
        }
    }
    
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        AppDelegate.getAppDelegate().log.debug("receiveRouteFailed")
        QuickRideProgressSpinner.stopSpinner()
        clearRouteData()
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route_due_to_network, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/3), title: nil, image: nil, completion: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast(Strings.not_able_to_get_route, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
        }
        moveToCoordinate(coordinate: CLLocationCoordinate2D(latitude: viewModel.startLocation?.latitude ?? 0, longitude: viewModel.startLocation?.longitude ?? 0))
    }
}
