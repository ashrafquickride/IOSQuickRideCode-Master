//
//  JoinMyRideDetailViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline

class JoinMyRideDetailViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var farePerkmLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var vehicleTypeImage: UIImageView!
    
    @IBOutlet weak var startLocButton: UIButton!
    @IBOutlet weak var dropLocButton: UIButton!
    
    //MARK: Variables
    private var viewModel = JoinMyRideDetailViewModel()
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    
    func initialiseJoinMyRideView(ride: Ride, matchedUser: MatchedUser){
        viewModel = JoinMyRideDetailViewModel(ride: ride, matchedUser: matchedUser)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 40, left: 20, bottom: 320, right: 20)
        viewMap.delegate = self
        drawRouteOnMap()
        setUpMatchedRiderDetails()
        setStartLocation()
        setEndLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRouteMatrics), name: .receivedRouteMatrics, object: nil)
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func receivedRouteMatrics(_ notification: Notification){
        startTimeLabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.matchedUser?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        viewMap.clear()
        drawMatchedUserRoute()
        drawCurrentUserRoute()
    }
    
    private func drawRouteOnMap() {
        viewMap.clear()
        drawMatchedUserRoute()
        let start = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.fromLocationLatitude ?? 0,longitude: viewModel.matchedUser?.fromLocationLongitude ?? 0)
        let end =  CLLocationCoordinate2D(latitude: viewModel.matchedUser?.toLocationLatitude ?? 0, longitude: viewModel.matchedUser?.toLocationLongitude ?? 0)
        setPickUpMarker(pickUp: start, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
        setDropMarker(drop: end, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
        if let routePolyline = viewModel.matchedUser?.routePolyline, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }
    
    private func drawMatchedUserRoute(){
        if let matchedUserRoutePathPolyline = viewModel.matchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty, mapView != nil {
            GoogleMapUtils.drawRoute(pathString: matchedUserRoutePathPolyline, map: viewMap, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        }
    }
    
    private func drawCurrentUserRoute(){
        if let ride = viewModel.ride, viewMap != nil, let matchedUserRoutePathPolyline = viewModel.matchedUser?.routePolyline, !matchedUserRoutePathPolyline.isEmpty {
            let route = Polyline(encodedPolyline: matchedUserRoutePathPolyline)
            if (route.coordinates?.count)! < 2{
                return
            }
            let start = CLLocation(latitude: ride.startLatitude,longitude: ride.startLongitude)
            let end =  CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
            
            let pickUp = CLLocation(latitude: viewModel.matchedUser?.pickupLocationLatitude ?? 0, longitude: viewModel.matchedUser?.pickupLocationLongitude ?? 0)
            let drop = CLLocation(latitude:viewModel.matchedUser?.dropLocationLatitude ?? 0, longitude: viewModel.matchedUser?.dropLocationLongitude ?? 0)
            GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride.rideId,useCase :"iOS.App."+(ride.rideType ?? "Passenger")+".WalkRoute.DetailedRouteView", riderRoutePolyline: matchedUserRoutePathPolyline, passengerRoutePolyline: matchedUserRoutePathPolyline, passengerStart: start, passengerEnd: end, pickup: pickUp, drop: drop, passengerRideDistance: viewModel.matchedUser?.distance ?? 0, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
            })
        }
        drawOverlappingRoute()
    }
    
    private func drawOverlappingRoute(){
        if let ride = viewModel.ride,let matchedUser = viewModel.matchedUser{
            var riderRoutePolyline : String?
            if matchedUser.userRole == MatchedUser.PASSENGER || matchedUser.userRole == MatchedUser.REGULAR_PASSENGER{
                riderRoutePolyline = ride.routePathPolyline
            }else{
                riderRoutePolyline = matchedUser.routePolyline!
            }
            let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
            let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
            let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: riderRoutePolyline!)
            if matchedRoute.count < 3{
                return
            }
            setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
            setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
            let polyline = Polyline(coordinates: matchedRoute)
            GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
            perform(#selector(drawRouteAfterDelay), with: self, afterDelay: 0.5)
        }
    }
    
    @objc func drawRouteAfterDelay(){
        if let routePolyline = viewModel.matchedUser?.routePolyline, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }
    
    private func setUpMatchedRiderDetails(){
        nameLabel.text = viewModel.matchedUser?.name?.capitalized
        ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: viewModel.matchedUser?.imageURI ?? "", gender: viewModel.matchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        verificationImage.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: viewModel.matchedUser?.profileVerificationData)
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: viewModel.matchedUser?.profileVerificationData, companyName: viewModel.matchedUser?.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if viewModel.matchedUser?.rating ?? 0 > 0.0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(viewModel.matchedUser?.rating ?? 0) + "(\(String(viewModel.matchedUser?.noOfReviews ?? 0)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            starImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 2.0
            ratingLabel.layer.masksToBounds = true
        }
        startTimeLabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.matchedUser?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        farePerkmLabel.text = StringUtils.getStringFromDouble(decimalNumber: (viewModel.matchedUser as? MatchedRider)?.fare) + "pts/km"
        if (viewModel.matchedUser as? MatchedRider)?.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            vehicleTypeImage.image = UIImage(named: "vehicle_type_bike_grey")
        }else{
            vehicleTypeImage.image = UIImage(named: "vehicle_type_car_grey")
        }
    }
    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        guard let matchedUser = viewModel.matchedUser else { return }
        let profileVc = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        profileVc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.userid),isRiderProfile: UserRole.Rider , rideVehicle: nil,userSelectionDelegate: nil,displayAction: true, isFromRideDetailView : false, rideNotes: matchedUser.rideNotes, matchedRiderOnTimeCompliance: matchedUser.userOnTimeComplianceRating, noOfSeats: 0, isSafeKeeper: viewModel.matchedUser?.hasSafeKeeperBadge ?? false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileVc, animated: false)
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
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func joinButtonTapped(_ sender: Any) {
        viewModel.createRideAndJoin()
    }
}
//MARK: GMSMapViewDelegate
extension JoinMyRideDetailViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.title == Strings.pick_up_caps {
            if viewModel.pickupZoomState == RideDetailMapViewModel.ZOOMED_IN {
                viewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                let pickUp = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.pickupLocationLatitude ?? 0, longitude: viewModel.matchedUser?.pickupLocationLongitude ?? 0)
                setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
            } else {
                viewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.pickupLocationLatitude ?? 0, longitude: viewModel.matchedUser?.pickupLocationLongitude ?? 0)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.pick_up_caps)
                let pickUp = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.pickupLocationLatitude ?? 0, longitude: viewModel.matchedUser?.pickupLocationLongitude ?? 0)
                setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_IN)
            }
        }
        if marker.title == Strings.drop_caps {
            if viewModel.dropZoomState == RideDetailMapViewModel.ZOOMED_IN {
                viewModel.dropZoomState = RideDetailMapViewModel.ZOOMED_OUT
                let drop = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.dropLocationLatitude ?? 0, longitude: viewModel.matchedUser?.dropLocationLongitude ?? 0)
                setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_OUT)
                zoomOutToSelectedPoint()
            } else {
                viewModel.dropZoomState = RideDetailMapViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.dropLocationLatitude ?? 0, longitude: viewModel.matchedUser?.dropLocationLongitude ?? 0)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.drop_caps)
                let drop = CLLocationCoordinate2D(latitude: viewModel.matchedUser?.dropLocationLatitude ?? 0, longitude: viewModel.matchedUser?.dropLocationLongitude ?? 0)
                setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_IN)
            }
        }
        return true
    }
    
    private func zoomInToSelectedPoint(zoomPoint: CLLocationCoordinate2D, markerType: String) {
        if let rideObj = viewModel.ride {
            var startLat: Double?
            var startLng: Double?
            var endLat: Double?
            var endLng: Double?
            if markerType == Strings.pick_up_caps {
                startLat = rideObj.startLatitude
                startLng = rideObj.startLongitude
                endLat = viewModel.matchedUser?.pickupLocationLatitude
                endLng = viewModel.matchedUser?.pickupLocationLongitude
            } else {
                startLat = rideObj.endLatitude
                startLng = rideObj.endLongitude
                endLat = viewModel.matchedUser?.dropLocationLatitude
                endLng = viewModel.matchedUser?.dropLocationLongitude
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
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: viewModel.matchedUser?.routePolyline ?? "")!)
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        CATransaction.commit()
    }
}
//MARK: for Different location
extension JoinMyRideDetailViewController{
    @IBAction func dropLocationTapped(_ sender: Any) {
        moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: nil)
    }
    
    @IBAction func startLoactionTapped(_ sender: Any) {
        moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: nil)
    }
    
    private func moveToLocationSelection(locationType : String, location : Location?) {
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    func setStartLocation(){
        AppDelegate.getAppDelegate().log.debug("setStartLocation()")
        if viewModel.ride?.startAddress.isEmpty == true{
            startLocButton.setTitle(Strings.enter_start_location, for: .normal)
            startLocButton.setTitleColor(UIColor.lightGray, for: .normal)
        }else{
            startLocButton.setTitle(viewModel.ride?.startAddress, for: .normal)
            startLocButton.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
        }
    }
    func setEndLocation(){
        AppDelegate.getAppDelegate().log.debug("setEndLocation()")
        if viewModel.ride?.endAddress.isEmpty == true{
            dropLocButton.setTitle(Strings.enter_end_location, for: .normal)
            dropLocButton.setTitleColor(UIColor.lightGray, for: .normal)
        }else{
            dropLocButton.setTitle(viewModel.ride?.endAddress, for: .normal)
            dropLocButton.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
        }
    }
}
//MARK: ReceiveLocationDelegate
extension JoinMyRideDetailViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            viewModel.ride?.startAddress = location.shortAddress ?? ""
            viewModel.ride?.startLatitude = location.latitude
            viewModel.ride?.startLongitude = location.longitude
            setStartLocation()
            viewModel.getNearestPicupPointForPassenger()
        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            viewModel.ride?.endAddress = location.shortAddress ?? ""
            viewModel.ride?.endLatitude = location.latitude
            viewModel.ride?.endLongitude = location.longitude
            setEndLocation()
            viewModel.getNearestDropPointForPassenger()
        }
    }
    
    func locationSelectionCancelled(requestLocationType: String) {
    }
}
