//
//  PickUpandDropViewController.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 26/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import CoreLocation
import Polyline

protocol PickUpAndDropSelectionDelegate{
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?)
}
protocol TaxiPickupSelectionDelegate {
    func pickupChanged(taxiRide: TaxiRidePassenger)
}
class PickUpandDropViewController: UIViewController, GMSMapViewDelegate {
    
    var pickUpMarker,dropMarker,selectedMarker :GMSMarker?
    
    var matchedRoutePolyline :GMSPolyline?
    var riderRoutePolyline : String?
    var matchedUser:MatchedUser?
    var passengerRideId :Double?
    var riderRideId: Double?
    var passengerId :Double?
    var riderId: Double?
    var noOfSeats = 1
    var riderRideType : String?
    var delegate :PickUpAndDropSelectionDelegate?
    var matchedUserRoute:[CLLocationCoordinate2D]?
    var pickUpLatLngIndex,dropLatLngIndex : Int?
    var markerTapped = false
    var changedPickupPoint,changedDropPoint : CLLocationCoordinate2D?
    var changedPickupAddress,changedDropAddress : String?
    weak var iboMapView: GMSMapView!
    static let MAX_DISTANCE_TO_CONSIDER_NEAR_POINT  = 500.0; //meters
    
    let breakPoint = ImageUtils.RBResizeImage(image: UIImage(named: "circle_with_arrow")!, targetSize: CGSize(width: 25,height: 25))
    
    @IBOutlet weak var iboFrom: UITextField!
    @IBOutlet weak var iboTo: UITextField!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var locationImagePin: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var pickUpDropLocationBackGroundView: UIView!
    
    @IBAction func ibaSave(_ sender: Any) {
        if locationImagePin.isHidden{
            savePickupAndDropChanges()
        }else{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.save_caps == result{
                    self.locationSelectionompleted()
                    self.savePickupAndDropChanges()
                }
                else{
                    self.savePickupAndDropChanges()
                }
            })
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if locationImagePin.isHidden == false || changedPickupPoint != nil || changedDropPoint != nil{
            
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.save_caps == result{
                    if self.locationImagePin.isHidden == false{
                        self.locationSelectionompleted()
                    }
                    self.savePickupAndDropChanges()
                }
                else{
                    self.navigationController?.popViewController(animated: false)
                }
            })
        }else{
            self.navigationController?.popViewController(animated: false)
        }
        
        
    }
    func initializeDataBeforePresenting(matchedUser: MatchedUser,riderRoutePolyline : String,riderRideType : String,delegate : PickUpAndDropSelectionDelegate, passengerRideId :Double?,riderRideId : Double?,passengerId :Double?,riderId : Double?,noOfSeats : Int){
        self.matchedUser = matchedUser
        self.riderRoutePolyline = riderRoutePolyline
        self.passengerRideId = passengerRideId
        self.riderRideId = riderRideId
        self.passengerId = passengerId
        self.riderId = riderId
        self.riderRideType = riderRideType
        self.delegate = delegate
        self.noOfSeats = noOfSeats
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        
        let polyLine = Polyline(encodedPolyline: riderRoutePolyline!)
        matchedUserRoute = polyLine.coordinates
        iboFrom.text = matchedUser?.pickupLocationAddress
        iboTo.text = matchedUser?.dropLocationAddress
        
        GoogleMapUtils.drawRoute(pathString: riderRoutePolyline!, map: iboMapView, colorCode: UIColor(netHex:0x686868), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        drawMatchedRoute()
        
        locationImagePin.isHidden = true
        perform(#selector(PickUpandDropViewController.fitToScreen), with: self, afterDelay: 0.5)
    }
    
    
    
    func drawMatchedRoute() {
        AppDelegate.getAppDelegate().log.debug("drawMatchedRoute()")
        let pickUp:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (matchedUser?.pickupLocationLatitude)!,longitude: (matchedUser?.pickupLocationLongitude)!);
        let drop:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (matchedUser?.dropLocationLatitude)!,longitude: (matchedUser?.dropLocationLongitude)!)
        pickUpLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: pickUp, route: matchedUserRoute!)
        dropLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: drop, route: matchedUserRoute!)
        let matchedRoute = LocationClientUtils.getMatchedRoute(startLatLngIndex: pickUpLatLngIndex!, endLatLngIndex: dropLatLngIndex!, route: matchedUserRoute!)
        
        matchedRoutePolyline =  GoogleMapUtils.drawRoute(pathString: Polyline(coordinates: matchedRoute).encodedPolyline, map: iboMapView, colorCode: UIColor(netHex: 0x356fbe), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        
        
        if( matchedRoute.count < 3){
            return
        }
        
        pickUpMarker = GMSMarker()
        pickUpMarker?.position = matchedUserRoute![pickUpLatLngIndex!]
        pickUpMarker?.icon = breakPoint
        //pickUpMarker?.title = "Tap To Edit"
        
        pickUpMarker?.map = iboMapView
        iboMapView.selectedMarker = pickUpMarker
        dropMarker = GMSMarker()
        dropMarker?.position = matchedUserRoute![dropLatLngIndex!]
        dropMarker?.icon = breakPoint
        //dropMarker?.title = "Tap to edit"
        dropMarker?.map = iboMapView
        iboMapView.selectedMarker = dropMarker
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if locationImagePin.isHidden == false{
            locationImagePin.isHidden = true
            selectedMarker?.opacity = 1.0
        }
    }
    @objc func fitToScreen(){
        let bounds = GMSCoordinateBounds(path: matchedRoutePolyline!.path!)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding:  50.0)
        iboMapView.moveCamera(cameraUpdate)
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
    
    func locationSelectionompleted() {
        AppDelegate.getAppDelegate().log.debug("locationSelectAction()")
        locationImagePin.isHidden = true
        selectedMarker?.opacity = 1.0
        
        selectedMarker?.position =  iboMapView.camera.target
        if selectedMarker! == pickUpMarker {
            pickUpLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: (selectedMarker?.position)!, route: matchedUserRoute!)
            let pickupPoint:CLLocationCoordinate2D = matchedUserRoute![pickUpLatLngIndex!]
            
            let route:[CLLocationCoordinate2D] =  LocationClientUtils.getMatchedRoute(startLatLngIndex: pickUpLatLngIndex!, endLatLngIndex: dropLatLngIndex!, route: matchedUserRoute!)
            if(route.isEmpty == true){ return }
            
            changedPickupPoint = pickupPoint
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.PickupDropView", coordinate: pickupPoint, handler: { (location,error) -> Void in
                if error != nil{
                    ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
                }else if location == nil{
                    UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                }else{
                    self.changedPickupAddress = location!.shortAddress
                    self.iboFrom.text = location!.shortAddress
                }
            })
            
            pickUpMarker?.position = pickupPoint
            let poly = Polyline(coordinates: route)
            matchedRoutePolyline?.path = GMSPath(fromEncodedPath: poly.encodedPolyline)
            
        }else if selectedMarker == dropMarker{
            
            dropLatLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: (selectedMarker?.position)!, route: matchedUserRoute!)
            let dropPoint:CLLocationCoordinate2D = matchedUserRoute![dropLatLngIndex!]
            
            let route:[CLLocationCoordinate2D] =  LocationClientUtils.getMatchedRoute(startLatLngIndex: pickUpLatLngIndex!, endLatLngIndex: dropLatLngIndex!, route: matchedUserRoute!)
            if(route.isEmpty == true){ return }
            
            changedDropPoint = dropPoint
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.PickupDropView", coordinate: dropPoint, handler: { (location,error) -> Void in
                if error != nil{
                    ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
                }else if location == nil{
                    UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                }else{
                    self.changedDropAddress = location!.shortAddress
                    self.iboTo.text = location!.shortAddress
                }
                
            })
            
            dropMarker?.position = dropPoint
            let poly = Polyline(coordinates: route)
            matchedRoutePolyline?.path = GMSPath(fromEncodedPath: poly.encodedPolyline)
        }
    }
    
    @IBAction func locationSelectAction(_ sender: Any) {
        locationSelectionompleted()
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool{
        AppDelegate.getAppDelegate().log.debug("mapView()")
        markerTapped = true
        if selectedMarker != nil && selectedMarker?.opacity == 0.0 && marker == selectedMarker{
            selectedMarker?.opacity = 1.0
        }
        selectedMarker = marker
        selectedMarker?.opacity = 0.0
        iboMapView.animate(toLocation: marker.position)
        UIApplication.shared.keyWindow?.makeToast( Strings.move_map_and_tap_to_confim)
        locationImagePin.isHidden = false
        return false
    }
    func savePickupAndDropChanges() {
        if self.changedPickupPoint != nil{
            self.matchedUser!.pickupLocationLatitude = self.changedPickupPoint!.latitude
            self.matchedUser!.pickupLocationLongitude = self.changedPickupPoint?.longitude
        }
        if self.changedPickupAddress != nil{
            self.matchedUser?.pickupLocationAddress = self.changedPickupAddress
        }
        if self.changedDropPoint != nil{
            self.matchedUser!.dropLocationLatitude = self.changedDropPoint!.latitude
            self.matchedUser!.dropLocationLongitude = self.changedDropPoint!.longitude
        }
        if self.changedDropAddress != nil{
            self.matchedUser!.dropLocationAddress = self.changedDropAddress
        }
        if self.passengerRideId != nil && self.riderRideId != nil {
            QuickRideProgressSpinner.startSpinner()
            
            let rideMatchMetricsForNewPickupDropTask = RideMatchMetricsForNewPickupDropTask(riderRideId: self.riderRideId!, passengerRideId: self.passengerRideId!,riderId: self.riderId!,passengerId: self.passengerId!, pickupLat: self.matchedUser!.pickupLocationLatitude!, pickupLng: self.matchedUser!.pickupLocationLongitude!, dropLat: self.matchedUser!.dropLocationLatitude!, dropLng: self.matchedUser!.dropLocationLongitude!, noOfSeats: self.noOfSeats, viewController: self)
            rideMatchMetricsForNewPickupDropTask.getRideMatchMetricsForNewPickupDrop { (rideMatchMetrics,responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if rideMatchMetrics != nil{
                    
                    self.matchedUser!.distance = rideMatchMetrics!.distanceOnRiderRoute
                    if(self.matchedUser!.userRole == MatchedUser.PASSENGER){
                        self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnRiderRoute
                        self.matchedUser!.matchPercentageOnMatchingUserRoute = rideMatchMetrics!.matchPercentOnPassengerRoute

                    }else if(self.self.matchedUser!.userRole == MatchedUser.RIDER){
                        self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnPassengerRoute
                        self.matchedUser!.matchPercentageOnMatchingUserRoute = rideMatchMetrics!.matchPercentOnRiderRoute
                        
                    }else{
                        self.matchedUser!.matchPercentage = rideMatchMetrics!.matchPercentOnRiderRoute

                    }
                    if self.matchedUser!.ridePassId == 0{
                      self.matchedUser!.points = rideMatchMetrics!.points
                    }
                    self.matchedUser!.pickupTime = rideMatchMetrics!.pickUpTime
                    self.matchedUser!.dropTime = rideMatchMetrics!.dropTime
                }
                self.delegate?.pickUpAndDropChanged(matchedUser: self.matchedUser!, userPreferredPickupDrop: nil)

                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
        super.didReceiveMemoryWarning()
    }
}
