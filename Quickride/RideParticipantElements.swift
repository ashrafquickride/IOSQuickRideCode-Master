//
//  RideParticipantElements.swift
//  Quickride
//
//  Created by iDisha on 31/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import Polyline

class RideParticipantElements{
    
    var participantPickupIconMarker: GMSMarker?
    var participantDropIconMarker: GMSMarker?
    var participantCurrentLocationMarker: GMSMarker?
    var routePathPolyline: GMSPolyline?
    
    func removeRideParticipantElement(){
        participantPickupIconMarker?.map = nil
        participantCurrentLocationMarker?.map = nil
        routePathPolyline?.map = nil
        participantDropIconMarker?.map = nil
    }
    static let participantMarkerImageView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
    
    func createOrUpdateRideParticipantElement(viewMap: GMSMapView, rideParticipant: RideParticipant){
        AppDelegate.getAppDelegate().log.debug("Thread name: \(String(describing: Thread.current))")
        
        
        let pickup = CLLocationCoordinate2D(latitude: rideParticipant.startPoint!.latitude, longitude: rideParticipant.startPoint!.longitude)
        self.participantPickupIconMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickup)
        RideParticipantElements.participantMarkerImageView.initializeView(name: rideParticipant.name!, colorCode: UIColor(netHex: 0x656766))
        participantPickupIconMarker!.icon = ViewCustomizationUtils.getImageFromView(view: RideParticipantElements.participantMarkerImageView)
        participantPickupIconMarker!.zIndex = 12
        participantPickupIconMarker!.title = rideParticipant.name!
        participantPickupIconMarker!.isTappable = true
        participantPickupIconMarker!.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
        self.participantPickupIconMarker!.map = viewMap
        
        
        let drop = CLLocationCoordinate2D(latitude: rideParticipant.endPoint!.latitude, longitude: rideParticipant.endPoint!.longitude)
        self.participantDropIconMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop)
        
        RideParticipantElements.participantMarkerImageView.initializeView(name: rideParticipant.name!, colorCode: UIColor(netHex: 0xB50000))
        let icon = ViewCustomizationUtils.getImageFromView(view: RideParticipantElements.participantMarkerImageView)
        participantDropIconMarker!.icon = icon
        participantDropIconMarker!.zIndex = 12
        participantDropIconMarker!.title =  rideParticipant.name!
        participantDropIconMarker!.isTappable = true
        participantDropIconMarker!.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
        self.participantDropIconMarker!.map = viewMap
    }
    
    func handlePassengerCurrentLocation(viewMap: GMSMapView, rideParticipantLocation: RideParticipantLocation) {
        
        removeCurrentLocationToPickupPath()
        guard let pickup = participantPickupIconMarker?.position else{
            return
        }
        
        if NSDate().getTimeStamp() - (rideParticipantLocation.lastUpdateTime ?? 0) < 30000 {
            let pickupLocation = CLLocation(latitude: pickup.latitude, longitude: pickup.longitude)
            let currentLocation = CLLocation(latitude: rideParticipantLocation.latitude ?? 0, longitude: rideParticipantLocation.longitude ?? 0)
            let distanceFromCurrentToPickup = pickupLocation.distance(from: currentLocation)
            if distanceFromCurrentToPickup > 300 {
                
                routePathPolyline = GoogleMapUtils.drawStraightLineFromCurrentLocationToPickUp(start: currentLocation, end: pickupLocation, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zindex: GoogleMapUtils.Z_INDEX_10)
                participantCurrentLocationMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: currentLocation.coordinate, shortIcon: ImageUtils.RBResizeImage(image: UIImage(named: "green")!, targetSize: CGSize(width: 25, height: 25)), tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            }
        }
    }
    func removeCurrentLocationToPickupPath() {
        participantCurrentLocationMarker?.map = nil
        participantCurrentLocationMarker = nil
        routePathPolyline?.map = nil
        routePathPolyline = nil
        
    }
}
