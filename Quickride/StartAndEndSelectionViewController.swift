//
//  StartAndEndSelectionViewController.swift
//  Quickride
//
//  Created by KNM Rao on 19/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps

protocol StartAndEndSelectionDelegate{
    func startAndEndChanged(matchedUser : MatchedUser,ride : Ride)
}

class StartAndEndSelectionViewController: UIViewController,MatchedUsersDataReceiver,GMSMapViewDelegate,RouteReceiver {

    @IBOutlet var startLocationAddress: UITextField!
    
    @IBOutlet var endLocationAddress: UITextField!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet var locationSelectionButton: UIButton!
    
    //branding outlets
    @IBOutlet weak var saveBtn: UIButton!
    
    var initialStart, initialEnd : CLLocationCoordinate2D?
    var ride : Ride?
    var matchedPassenger : MatchedUser?
    var delegate :StartAndEndSelectionDelegate?
    var startMarker : GMSMarker?
    var endMarker : GMSMarker?
    var selectedMarker : GMSMarker?
    var rideRoutePolyline : GMSPolyline?
    var markerTapped = false
    weak var mapView: GMSMapView!
    let markerIcon = ImageUtils.RBResizeImage(image: UIImage(named: "circle_with_arrow")!, targetSize: CGSize(width: 25,height: 25))
    
    func initializeDataBeforePresenting(ride : Ride,matchedPassenger : MatchedUser,delegate :StartAndEndSelectionDelegate){
        self.ride = ride
        self.initialStart = CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude)
        self.initialEnd = CLLocationCoordinate2D(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        self.matchedPassenger = matchedPassenger
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        mapView.delegate = self
        initializeStartAndEndLocationDetails()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initilizeMarkersAndRouteOnMap()
    }
    
    func handleBrandingChanges()
    {
        saveBtn.backgroundColor = Colors.feedbackButtonBackGroundColor
    }
    func initilizeMarkersAndRouteOnMap(){
        
        locationSelectionButton.isHidden = true
        
        
        if startMarker == nil{
            startMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: CLLocationCoordinate2D(latitude: ride!.startLatitude, longitude: ride!.startLongitude))
            startMarker?.icon = markerIcon
            startMarker?.isTappable = true
        }else{
            startMarker?.position = CLLocationCoordinate2D(latitude: ride!.startLatitude, longitude: ride!.startLongitude)
        }
        
        if endMarker == nil{
            endMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: CLLocationCoordinate2D(latitude: ride!.endLatitude!, longitude: ride!.endLongitude!))
            endMarker?.icon = markerIcon
            endMarker?.isTappable = true
            mapView.selectedMarker = endMarker
        }else{
            endMarker?.position = CLLocationCoordinate2D(latitude: ride!.endLatitude!, longitude: ride!.endLongitude!)
        }
        rideRoutePolyline?.map = nil
        rideRoutePolyline = GoogleMapUtils.drawRoute(pathString: ride!.routePathPolyline, map: mapView, colorCode: UIColor(netHex : 0x686868), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        
        self.perform(#selector(StartAndEndSelectionViewController.drawPath), with: nil, afterDelay: 0.5)
    }
    @objc func drawPath(){
        GoogleMapUtils.fitToScreen(route: ride!.routePathPolyline, map: mapView)
    }
    func initializeStartAndEndLocationDetails(){
        
        startLocationAddress.text =  ride?.startAddress
        endLocationAddress.text = ride?.endAddress
    }
    
    func locationSelectionCompleted() {
        if selectedMarker == nil{
            return
        }
        QuickRideProgressSpinner.startSpinner()
        locationSelectionButton.isHidden = true
        selectedMarker?.opacity = 1.0
        
        selectedMarker?.position =  mapView.camera.target
        if selectedMarker! == startMarker {
            ride?.startLatitude = selectedMarker!.position.latitude
            ride?.startLongitude = selectedMarker!.position.longitude
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.StartAndEndView", coordinate: selectedMarker!.position, handler: { (location,error) -> Void in
                if location == nil{
                    UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                }else{
                    self.ride?.startAddress = location!.shortAddress!
                    self.startLocationAddress.text = location!.shortAddress
                }
            })
        }else if selectedMarker == endMarker{
            
            ride?.endLatitude = selectedMarker?.position.latitude
            ride?.endLongitude = selectedMarker?.position.longitude
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.StartAndEndView", coordinate: selectedMarker!.position, handler: { (location,error) -> Void in
                if location == nil{
                    UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                }else{
                    self.ride?.endAddress = location!.shortAddress!
                    self.endLocationAddress.text = location!.shortAddress
                }
                
            })
        }
        MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App."+(ride!.rideType ?? "Passenger")+".MainRoute.StartAndEndView", rideId: ride!.rideId, startLatitude: ride!.startLatitude, startLongitude: ride!.startLongitude, endLatitude: ride!.endLatitude!, endLongitude: ride!.endLongitude!, wayPoints: nil, routeReceiver: self,saveCustomRoute: false)

    }
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        QuickRideProgressSpinner.stopSpinner()
        if rideRoute.isEmpty{
            return
        }
        self.ride?.routePathPolyline = rideRoute[0].overviewPolyline!
        self.initilizeMarkersAndRouteOnMap()
    }
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        QuickRideProgressSpinner.stopSpinner()
        ErrorProcessUtils.handleError(responseObject : responseObject, error: error, viewController: self, handler: nil)

    }
    
    @IBAction func startOrEndSelectionDoneAction(_ sender: Any) {
        
        locationSelectionCompleted()
    }
    
    func saveStartAndEndChanges() {
        let vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        MatchedUsersCache.getInstance().getAllMatchedPassengers(ride: ride!, rideRoute: nil, overviewPolyline: ride?.routePathPolyline, capacity: vehicle!.capacity, fare: vehicle!.fare, requestSeqId: 1,displaySpinner: false, dataReceiver: self)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        
        if locationSelectionButton.isHidden{
            saveStartAndEndChanges()
        }else{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.save_caps == result{
                    self.locationSelectionCompleted()
                    self.saveStartAndEndChanges()
                }
                else{
                    self.saveStartAndEndChanges()
                    
                }
            })
        }
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if self.locationSelectionButton.isHidden == false || initialStart?.latitude != ride?.startLatitude ||
            initialStart?.longitude != ride?.startLongitude ||
            initialEnd?.latitude != ride?.endLatitude ||
            initialEnd?.longitude != ride?.endLongitude{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.save_caps == result{
                    if self.locationSelectionButton.isHidden == false{
                        self.locationSelectionCompleted()
                    }
                    self.saveStartAndEndChanges()
                }
                else{
                    self.navigationController?.popViewController(animated: false)
                }
            })
        }else{
           self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool{
        AppDelegate.getAppDelegate().log.debug("mapView()")
        markerTapped = true
        if selectedMarker != nil && selectedMarker?.opacity == 0.0 && marker == selectedMarker{
            selectedMarker?.opacity = 1.0
        }
        selectedMarker = marker
        selectedMarker?.opacity = 0.0
        mapView.animate(toLocation: marker.position)
        UIApplication.shared.keyWindow?.makeToast( Strings.move_map_and_tap_to_confim)
        locationSelectionButton.isHidden = false
        return false
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if locationSelectionButton.isHidden == false{
            locationSelectionButton.isHidden = true
            selectedMarker?.opacity = 1.0
        }
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if markerTapped {
            return nil
        }
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
    func receiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int){
        
    }
    func receiveMatchedPassengersList( requestSeqId: Int, matchedPassengers : [MatchedPassenger],currentMatchBucket : Int){
        var matchedPassengerNow : MatchedPassenger?
        for passenger in matchedPassengers{
            if isInvitedUser(matchedUser: passenger){
                matchedPassengerNow = passenger
            }
        }
        if matchedPassengerNow == nil{
            UIApplication.shared.keyWindow?.makeToast( self.matchedPassenger!.name!+Strings.ride_no_longer_matching)
           
            self.navigationController?.popViewController(animated: false)
        }else{
            matchedPassenger = matchedPassengerNow
            self.navigationController?.popViewController(animated: false)
            self.delegate?.startAndEndChanged(matchedUser: self.matchedPassenger!, ride: self.ride!)
        }
    }
    func matchingRidersRetrievalFailed( requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        
    }
    func matchingPassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        ErrorProcessUtils.handleError(responseObject : responseObject, error: error, viewController: self, handler: nil)
    }
    
    func isInvitedUser( matchedUser : MatchedUser) -> Bool{
        
        if matchedUser.userid == matchedPassenger?.userid && matchedUser.rideid == matchedPassenger?.rideid{
            return true
        }else{
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
