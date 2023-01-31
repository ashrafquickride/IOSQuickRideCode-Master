//
//  RidePathDisplayViewController.swift
//  Quickride
//
//  Created by KNM Rao on 31/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import GoogleMaps
import Polyline

class RidePathDisplayViewController : UIViewController{
    
    @IBOutlet weak var mapViewContainer: UIView!
    weak var mapView: GMSMapView!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var dropLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!

    var currentUserRidePath,joinedUserRidePath,currentUserRideType :String?
    var currentUserRideId,joinedUserRideId :Double?
    var  pickUp,drop : CLLocationCoordinate2D?
    var isMatchedRouteDrawn = false
    var points : Double?
    
    func initializeDataBeforePresenting(currentUserRidePath : String?,joinedUserRidePath : String?,currentUserRideType : String,currentUserRideId : Double,joinedUserRideId : Double,pickUp :CLLocationCoordinate2D,drop : CLLocationCoordinate2D, points : Double){
        
        self.currentUserRidePath = currentUserRidePath
        self.joinedUserRidePath = joinedUserRidePath
        self.currentUserRideType = currentUserRideType
        self.currentUserRideId = currentUserRideId
        self.joinedUserRideId = joinedUserRideId
        self.pickUp = pickUp
        self.drop = drop
        self.points = points
    }
    
    override func viewDidLoad() {
        mapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        getCurrentUserRidePath()
        getJoinedUserRidePath()
        intializePickUpandDrop()
    }
    
    
    func intializePickUpandDrop()
    {

        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.RidePathView", coordinate: pickUp!) { (location, error) in
            if location != nil
            {
                self.pickUpLabel.text = location!.shortAddress
            }
        }
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.RidePathView", coordinate: drop!) { (location, error) in
            if location != nil
            {
                self.dropLabel.text = location!.shortAddress
            }
        }
        self.fareLabel.text = StringUtils.getPointsInDecimal(points: self.points!) + " " + Strings.pts
    }
    func getCurrentUserRidePath()
    {
        if currentUserRidePath != nil{
            self.drawCurrentUserRoute()
            self.drawMatchedRoute()
        }else{
            QuickRideProgressSpinner.startSpinner()
            RideServicesClient.getRoutePath(rideId: currentUserRideId!, rideType: currentUserRideType!, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.currentUserRidePath = responseObject!["resultData"] as? String
                    self.drawCurrentUserRoute()
                    self.drawMatchedRoute()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
    }
    
    func getJoinedUserRidePath(){
        if joinedUserRidePath != nil {
            self.drawJoinedUserRoute()
            self.drawMatchedRoute()
        }else{
            var joinedUserRideType = Ride.PASSENGER_RIDE
            if currentUserRideType == Ride.PASSENGER_RIDE{
                joinedUserRideType = Ride.RIDER_RIDE
            }
            QuickRideProgressSpinner.startSpinner()
            RideServicesClient.getRoutePath(rideId: joinedUserRideId!, rideType: joinedUserRideType, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.joinedUserRidePath = responseObject!["resultData"] as? String
                    self.drawJoinedUserRoute()
                    self.drawMatchedRoute()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
    }
    
    func drawCurrentUserRoute(){
        AppDelegate.getAppDelegate().log.debug("drawCurrentUserRoute()")
        if currentUserRidePath != nil && currentUserRidePath!.isEmpty == false{
            
            GoogleMapUtils.drawRoute(pathString: currentUserRidePath!, map: mapView, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_5, tappable: false)
            
        }
    }
    
    func drawJoinedUserRoute()
    {
        if joinedUserRidePath != nil && joinedUserRidePath?.isEmpty == false {
            GoogleMapUtils.drawRoute(pathString: joinedUserRidePath!, map: mapView, colorCode: UIColor(netHex : 0x686868), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        }
    }
    
    func drawMatchedRoute()
    {
        if currentUserRidePath == nil || currentUserRidePath!.isEmpty || joinedUserRidePath == nil || joinedUserRidePath!.isEmpty || isMatchedRouteDrawn || mapView == nil{
            return
        }
        isMatchedRouteDrawn = true
        
        var polyline : String?
        if Ride.RIDER_RIDE == currentUserRideType{
            polyline = currentUserRidePath
        }else{
            polyline = joinedUserRidePath
        }
        let route = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp!, dropLatLng: drop!, polyline: polyline!)
        if route.count < 3{
            return
        }
        let overlapPolyline = Polyline(coordinates: route)
        GoogleMapUtils.drawRoute(pathString: overlapPolyline.encodedPolyline, map: mapView, colorCode: UIColor(netHex: 0x356fbe), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        GoogleMapUtils.addMarker(googleMap: mapView, location: pickUp!, shortIcon: UIImage(named: "matched_start")!,tappable: true,anchor :CGPoint(x: 0.5,y: 0.5),zIndex : 8)
        GoogleMapUtils.addMarker(googleMap: mapView, location:drop! , shortIcon: UIImage(named: "matched_end")!,tappable: true,anchor :CGPoint(x: 0.5,y: 0.5),zIndex : 8)
        GoogleMapUtils.addMarker(googleMap: mapView, location: pickUp!, shortIcon: UIImage(named: "matched_pickup_badge")!, tappable: false,anchor :CGPoint(x: 0,y: 1),zIndex : 10)
        GoogleMapUtils.addMarker(googleMap: mapView, location: drop!, shortIcon: UIImage(named: "matched_drop_badge")!, tappable: false,anchor :CGPoint(x: 0,y: 1),zIndex : 10)
        GoogleMapUtils.fitToScreen(route: currentUserRidePath!, map: mapView)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
