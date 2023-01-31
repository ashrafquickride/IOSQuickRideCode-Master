//
//  GoogleMapUtils.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 29/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import Polyline
import ObjectMapper

typealias GoogleMapUtilsCompletionHandler = (_ distance : Double) -> Void

typealias CumalativeTravelDistanceHanlder = (_ distance : CummulativeTravelDistance?) -> Void

public class GoogleMapUtils{

    static let blueColor = UIColor(red: 53/255.0, green: 111/255.0, blue: 190/255.0, alpha: 1.0)
    static let greyColor = UIColor(red: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0)

    public static let POLYLINE_WIDTH_6 : CGFloat = 6
    public static let POLYLINE_WIDTH_7 : CGFloat = 7
    public static let POLYLINE_WIDTH_5 : CGFloat = 5
    public static let POLYLINE_WIDTH_4 : CGFloat = 4
    public static let POLYLINE_WIDTH_1: CGFloat = 1
    public static let POLYLINE_WIDTH_10 : CGFloat = 10
    public static let POLYLINE_WIDTH_2: CGFloat = 2
    public static let MARKER_HALF_OPACITY : Float =  0.5
    public static let MARKER_FULL_OPACITY : Float =  1
    public static let Z_INDEX_10 : Int32 = 15
    public static let Z_INDEX_7 : Int32 = 7
    public static let Z_INDEX_5 : Int32 =  5
    public static let  COUNTRY_NAME_INDIA : String = "India";
    public static let  LATLONG_BOUNDS_RADIUS = 150000.0; // 150 Kms

    public static func drawCurrentUserRoutePathOnMapWithStartAndStop( start :CLLocationCoordinate2D, end :CLLocationCoordinate2D,route : String, map : GMSMapView,  colorCode : UIColor,width:CGFloat, zIndex:Int32) -> GMSPolyline{
        var startIcon,endIcon : UIImage?

        endIcon = UIImage(named: "icon_drop_location_new")!
        startIcon = UIImage(named: "icon_start_location")!
        let startmarker = addMarker(googleMap: map, location: start, shortIcon: startIcon!,tappable: false)
        startmarker.groundAnchor = CGPoint(x: 0.5,y: 0.5)
        let endMarker = addMarker(googleMap: map, location: end, shortIcon: endIcon!,tappable: false)
        endMarker.groundAnchor = CGPoint(x: 0.5,y: 0.5)

        return drawRoute(pathString: route, map: map, colorCode: colorCode, width: width, zIndex: zIndex,tappable: false)
    }

    public static func fitToScreen(route : String,map : GMSMapView){
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: route)!)
        let cameraUpdate = GMSCameraUpdate.fit(bounds)
        map.moveCamera(cameraUpdate)
    }
    public static func fitToScreen(routes : [GMSPolyline],map : GMSMapView){
        let bounds = GMSCoordinateBounds()
        for route in routes{
            if let path = route.path{
                bounds.includingPath(path)
            }
        }
        let cameraUpdate = GMSCameraUpdate.fit(bounds)
        map.moveCamera(cameraUpdate)
    }
    public static func fitToScreenWithMargins(route : String,map : GMSMapView){
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: route)!)
        let uiEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 160, right: 50)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, with: uiEdgeInsets)
        map.moveCamera(cameraUpdate)
    }
    public static func fitToScreenWithPickupDrops(route : String,map : GMSMapView){
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: route)!)
        let uiEdgeInsets = UIEdgeInsets(top: 50, left: 10, bottom: 10, right: 10)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, with: uiEdgeInsets)
        map.moveCamera(cameraUpdate)
    }

    public static func drawRoute(pathString : String,map : GMSMapView, colorCode : UIColor,width:CGFloat, zIndex:Int32,tappable : Bool) -> GMSPolyline{

        let path: GMSPath = GMSPath(fromEncodedPath: pathString)!
        let routePolyline = GMSPolyline(path: path)

        routePolyline.zIndex = zIndex
        routePolyline.strokeWidth = width
        routePolyline.strokeColor = colorCode
        routePolyline.isTappable = tappable
        routePolyline.map = map
        return routePolyline
    }
    public static func addMarker( googleMap :GMSMapView,  location : CLLocationCoordinate2D,  shortIcon: UIImage, tappable : Bool,anchor : CGPoint) ->GMSMarker{
        let marker  = GMSMarker(position: location)
        marker.position = location
        marker.isFlat = false
        marker.isTappable = tappable
        marker.icon = shortIcon
        marker.map = googleMap
        marker.groundAnchor = anchor

        return marker
    }
    public static func addMarker( googleMap :GMSMapView,  location : CLLocationCoordinate2D,  shortIcon: UIImage, tappable : Bool,anchor : CGPoint,zIndex : Int32) ->GMSMarker{
        let marker  = GMSMarker(position: location)
        marker.position = location
        marker.isFlat = false
        marker.isTappable = tappable
        marker.icon = shortIcon
        marker.map = googleMap
        marker.groundAnchor = anchor
        marker.zIndex = zIndex
        return marker
    }
    public static func addMarker( googleMap :GMSMapView,  location : CLLocationCoordinate2D,  shortIcon: UIImage, tappable : Bool) ->GMSMarker{
        let marker  = GMSMarker(position: location)
        marker.position = location
        marker.isFlat = false
        marker.isTappable = tappable
        marker.icon = shortIcon
        marker.map = googleMap
        marker.zIndex = 10

        return marker
    }

    public static func addMarker( googleMap :GMSMapView,  location : CLLocationCoordinate2D) ->GMSMarker{
        let marker  = GMSMarker(position: location)
        marker.position = location
        marker.isFlat = false

        marker.map = googleMap
        return marker
    }
    public static func isPathTravelled(pathString : String?)-> Bool{
        if pathString == nil{
            return false
        }
        let path: GMSPath = GMSPath(fromEncodedPath: pathString!)!
        if path.count() > 2{
            return true
        }else{
            return false
        }
    }

    public static func createDashedLine(thisPoint: CLLocationCoordinate2D, nextPoint: CLLocationCoordinate2D, color: UIColor,mapView : GMSMapView) {
        let difLat: Double = nextPoint.latitude - thisPoint.latitude
        let difLng: Double = nextPoint.longitude - thisPoint.longitude
        let scale = Double(mapView.camera.zoom * 2)
        let divLat: Double = difLat / scale
        let divLng: Double = difLng / scale
        let tmpOrig = thisPoint
        let singleLinePath = GMSMutablePath()
        for i in 0..<Int(scale) {
            var tmpOri = tmpOrig
            if i > 0 {
                tmpOri = CLLocationCoordinate2DMake(tmpOrig.latitude + (divLat * 0.25), tmpOrig.longitude + (divLng * 0.25))
            }
            singleLinePath.add(tmpOri)
            singleLinePath.add(CLLocationCoordinate2DMake(tmpOrig.latitude + (divLat * 1.0), tmpOrig.longitude + (divLng * 1.0)))
            tmpOri = CLLocationCoordinate2DMake(tmpOrig.latitude + (divLat * 1.0), tmpOrig.longitude + (divLng * 1.0))
        }

        drawdashedRoute(routeString: singleLinePath.encodedPath(),mapView:mapView,color :color,zIndex: Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_4)
    }


    public static func drawdashedRoute(routeString : String,mapView : GMSMapView,color : UIColor,zIndex: Int32, polyLineWidth: CGFloat) -> GMSPolyline{
        let polyline =  drawRoute(pathString: routeString, map: mapView, colorCode: UIColor.white, width: polyLineWidth, zIndex: zIndex, tappable: false)
        let mutablePath = GMSMutablePath(fromEncodedPath: routeString)
        let lengths = [(mutablePath!.length(of: GMSLengthKind.geodesic) / 80)]
        let polys = [polyline]

        let gradColor = GMSStrokeStyle.gradient(from: color, to: color)
        let styles = [gradColor, GMSStrokeStyle.solidColor(UIColor(white: 0, alpha: 0))]

        //Create steps for polyline(dotted polylines)

        for poly: GMSPolyline in polys {
            poly.spans = GMSStyleSpans(poly.path!, styles, lengths as [NSNumber], GMSLengthKind.geodesic)
        }
        return polyline
    }
    static func drawPassengerRouteWithWalkingDistance(rideId : Double, useCase : String,riderRoutePolyline : String,passengerRoutePolyline : String,passengerStart : CLLocation ,passengerEnd : CLLocation,pickup : CLLocation,drop :CLLocation,passengerRideDistance :Double, map : GMSMapView,  colorCode : UIColor, zIndex : Int32,handler : @escaping CumalativeTravelDistanceHanlder){

        let cummulativeTravelDistance = CummulativeTravelDistance()
        let passengerRouteFromStratToPickup = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: passengerStart.coordinate, dropLatLng: pickup.coordinate, polyline: passengerRoutePolyline)
        let startToPickupDistance = passengerStart.distance(from: pickup)
        var startToPickupPath: GMSMutablePath
        if passengerRouteFromStratToPickup.count <= 2 || startToPickupDistance <= 150 {
            startToPickupPath = GMSMutablePath()
            startToPickupPath.add(passengerStart.coordinate)
            startToPickupPath.add(pickup.coordinate)
            cummulativeTravelDistance.passengerStartToPickup = startToPickupDistance/1000
        }else{
            startToPickupPath = GMSMutablePath()
            for latlng in passengerRouteFromStratToPickup {
                startToPickupPath.add(latlng)
            }
            cummulativeTravelDistance.passengerStartToPickup = LocationClientUtils.getDistance(path: passengerRouteFromStratToPickup)/1000
        }

        drawdashedRoute(routeString: startToPickupPath.encodedPath(), mapView: map, color: colorCode,zIndex: Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_4)
        if cummulativeTravelDistance.isCumulativeDistanceRetrieved(){
            handler(cummulativeTravelDistance)
        }

        let passengerRouteFromDropToEnd = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: drop.coordinate, dropLatLng: passengerEnd.coordinate, polyline: passengerRoutePolyline)

        let dropToEndDistance = passengerEnd.distance(from: drop)
        var dropToEndPath: GMSMutablePath
        if passengerRouteFromDropToEnd.count <= 2 || dropToEndDistance <= 150 {

            dropToEndPath = GMSMutablePath()
            dropToEndPath.add(drop.coordinate)
            dropToEndPath.add(passengerEnd.coordinate)
            cummulativeTravelDistance.passengerDropToEnd = dropToEndDistance/1000
        }else{
            dropToEndPath = GMSMutablePath()
            for latlng in passengerRouteFromDropToEnd {
                dropToEndPath.add(latlng)
            }
            cummulativeTravelDistance.passengerDropToEnd = LocationClientUtils.getDistance(path: passengerRouteFromDropToEnd)/1000

        }
        drawdashedRoute(routeString: dropToEndPath.encodedPath(), mapView: map, color: colorCode,zIndex:Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_4)
        if cummulativeTravelDistance.isCumulativeDistanceRetrieved(){
            handler(cummulativeTravelDistance)
        }

    }
    static func drawPassengerRouteWithWalkingdropToEndDistance(rideId : Double, useCase : String,riderRoutePolyline : String,passengerRoutePolyline : String,passengerEnd : CLLocation,drop :CLLocation,passengerRideDistance :Double, map : GMSMapView,  colorCode : UIColor, zIndex : Int32,handler : @escaping CumalativeTravelDistanceHanlder) {
        let cummulativeTravelDistance = CummulativeTravelDistance()
        let passengerRouteFromDropToEnd = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: drop.coordinate, dropLatLng: passengerEnd.coordinate, polyline: passengerRoutePolyline)
        let dropToEndDistance = passengerEnd.distance(from: drop)
        var dropToEndPath: GMSMutablePath
        if passengerRouteFromDropToEnd.count <= 2 || dropToEndDistance <= 150 {
            dropToEndPath = GMSMutablePath()
            dropToEndPath.add(drop.coordinate)
            dropToEndPath.add(passengerEnd.coordinate)
            cummulativeTravelDistance.passengerDropToEnd = dropToEndDistance/1000
        }else{
            dropToEndPath = GMSMutablePath()
            for latlng in passengerRouteFromDropToEnd {
                dropToEndPath.add(latlng)
            }
            cummulativeTravelDistance.passengerDropToEnd = LocationClientUtils.getDistance(path: passengerRouteFromDropToEnd)/1000
        }
        drawdashedRoute(routeString: dropToEndPath.encodedPath(), mapView: map, color: colorCode,zIndex:Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_4)
        if cummulativeTravelDistance.isCumulativeDistanceRetrieved(){
            handler(cummulativeTravelDistance)
        }
    }
    static func getWalkPathForMatchedUser(point1 : CLLocation,point2 : CLLocation ,polyline: String) -> Double {
        let startToPickupDistance = point1.distance(from: point2)
        if startToPickupDistance < 150{
            return startToPickupDistance
        }else{
            let passengerRouteFromStratToPickup = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: point1.coordinate, dropLatLng: point2.coordinate, polyline: polyline)
            return LocationClientUtils.getDistance(path: passengerRouteFromStratToPickup)
        }
    }
    static func drawWalkingPath(rideId : Double , useCase : String ,start : CLLocation,end : CLLocation,map : GMSMapView,colorCode : UIColor,zindex : Int32,handler : @escaping GoogleMapUtilsCompletionHandler){

        MyRoutesCache.getInstance()?.getWalkRoute(rideId: rideId, useCase : useCase, startLatitude: start.coordinate.latitude, startLongitude: start.coordinate.longitude, endLatitude: end.coordinate.latitude, endLongitude: end.coordinate.longitude, routeReceiver: { (route,error) in
            if route != nil{
                drawdashedRoute(routeString: route!.overviewPolyline!, mapView: map, color: colorCode,zIndex: zindex, polyLineWidth: POLYLINE_WIDTH_4)
                handler(route!.distance!)
            }else{
                var route = [CLLocationCoordinate2D]()
                route.append(start.coordinate)
                route.append(end.coordinate)
                let path = GMSMutablePath()
                for latlng in route {
                    path.add(latlng)
                }

                drawdashedRoute(routeString: path.encodedPath(), mapView: map, color: colorCode,zIndex: Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_4)

                handler(start.distance(from: end)/1000)
            }
        })
    }

    static func drawStraightLineFromCurrentLocationToPickUp(start : CLLocation,end : CLLocation,map : GMSMapView,colorCode : UIColor,zindex : Int32) -> GMSPolyline{
        var route = [CLLocationCoordinate2D]()
        route.append(start.coordinate)
        route.append(end.coordinate)
        let path = GMSMutablePath()
        for latlng in route {
            path.add(latlng)
        }
        return drawdashedRoute(routeString: path.encodedPath(), mapView: map, color: colorCode,zIndex: Z_INDEX_10, polyLineWidth: POLYLINE_WIDTH_2)
    }

    static func drawPassengerPathFromPickToDrop(riderRoutePolyline : String, passengerRide :PassengerRide, map : GMSMapView,  colorCode : UIColor, zIndex : Int32) -> GMSPolyline
    {
        let drop =  CLLocation(latitude:passengerRide.dropLatitude,longitude: passengerRide.dropLongitude)
        let startAndEndPolyline = drawRoute(pathString: riderRoutePolyline, map: map, colorCode: UIColor.black, width: POLYLINE_WIDTH_7,zIndex: Z_INDEX_5, tappable: false)

        drawRoute(pathString: passengerRide.pickupAndDropRoutePolyline, map: map, colorCode: UIColor(netHex:0x2F77F2), width: POLYLINE_WIDTH_7, zIndex: Z_INDEX_10, tappable: false)

        addMarker(googleMap: map, location: drop.coordinate, shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false)
        return startAndEndPolyline
    }

    static func drawPassengerPathWithDrop(riderRoutePolyline : String, passengerRide :PassengerRide, map : GMSMapView,  colorCode : UIColor, zIndex : Int32) -> GMSPolyline {
        let startPoint =  CLLocation(latitude:passengerRide.startLatitude,longitude: passengerRide.startLongitude)

        let endPoint =  CLLocation(latitude:passengerRide.endLatitude!,longitude: passengerRide.endLongitude!)

        let startAndEndPolyline = drawRoute(pathString: riderRoutePolyline, map: map, colorCode: UIColor.black, width: POLYLINE_WIDTH_7,zIndex: Z_INDEX_5, tappable: false)

        drawRoute(pathString: passengerRide.pickupAndDropRoutePolyline, map: map, colorCode: UIColor(netHex:0x2F77F2), width: POLYLINE_WIDTH_7, zIndex: Z_INDEX_10, tappable: false)


        addMarker(googleMap: map, location: startPoint.coordinate, shortIcon: UIImage(named: "green")!,tappable: false)

        addMarker(googleMap: map, location: endPoint.coordinate, shortIcon: UIImage(named: "icon_drop_location_new")!,tappable: false)

        return startAndEndPolyline

    }

    static func drawTaxiRoutePathWithDrop(entireRideRoutePolyLine: String, taxiPassengerRide: TaxiRidePassenger, map : GMSMapView,  colorCode : UIColor, zIndex : Int32) -> GMSPolyline {
        let startPoint =  CLLocation(latitude:taxiPassengerRide.startLat ?? 0,longitude: taxiPassengerRide.startLng ?? 0)

        let endPoint =  CLLocation(latitude: taxiPassengerRide.endLat ?? 0,longitude: taxiPassengerRide.endLng ?? 0)

        let startAndEndPolyline = drawRoute(pathString: entireRideRoutePolyLine, map: map, colorCode: UIColor.black, width: POLYLINE_WIDTH_7,zIndex: Z_INDEX_5, tappable: false)

        drawRoute(pathString: taxiPassengerRide.routePolyline ?? "", map: map, colorCode: UIColor(netHex:0x2F77F2), width: POLYLINE_WIDTH_7, zIndex: Z_INDEX_10, tappable: false)

        addMarker(googleMap: map, location: startPoint.coordinate, shortIcon: UIImage(named: "green")!,tappable: false)
        addMarker(googleMap: map, location: endPoint.coordinate, shortIcon: UIImage(named: "icon_drop_location_new")!,tappable: false)
        return startAndEndPolyline
    }

    static func getPolylineBoundsForParticularPoints(startLat: Double, startLong: Double, endLat: Double, endLong: Double, viewMap: GMSMapView) -> String{
        let difLat: Double = endLat - startLat
        let difLng: Double = endLong - startLong
        let scale = Double(viewMap.camera.zoom)
        let tmpOrig = CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
        let singleLinePath = GMSMutablePath()
        for i in 0..<Int(scale) {
            var tmpOri = tmpOrig
            if i > 0 {
                tmpOri = CLLocationCoordinate2DMake(tmpOrig.latitude + (difLat * 0.25), tmpOrig.longitude + (difLng * 0.25))
            }
            singleLinePath.add(tmpOri)
            singleLinePath.add(CLLocationCoordinate2DMake(tmpOrig.latitude + (difLat * 1.0), tmpOrig.longitude + (difLng * 1.0)))
            tmpOri = CLLocationCoordinate2DMake(tmpOrig.latitude + (difLat * 1.0), tmpOrig.longitude + (difLng * 1.0))
        }
        return singleLinePath.encodedPath()
    }

    static func nearestPolylineLocation(toCoordinate coordinate: CLLocationCoordinate2D, polyline: GMSPolyline) -> CLLocationCoordinate2D? {
        var bestDistance = Double.greatestFiniteMagnitude
        var bestPoint = CGPoint(x: CGFloat(coordinate.longitude), y: CGFloat(coordinate.latitude))
        let originPoint = CGPoint(x: CGFloat(coordinate.longitude), y: CGFloat(coordinate.latitude))
        if let polylinePath = polyline.path {
            if polylinePath.count() < UInt(2) {
                // we need at least 2 points: start and end
                return nil
            }
            for index in 0..<polylinePath.count() - 1 {
                let startCoordinate = polylinePath.coordinate(at: index)
                let startPoint = CGPoint(x: CGFloat(startCoordinate.longitude), y: CGFloat(startCoordinate.latitude))
                let endCoordinate = polylinePath.coordinate(at: (index + 1))
                let endPoint = CGPoint(x: CGFloat(endCoordinate.longitude), y: CGFloat(endCoordinate.latitude))
                var distance = 0.0
                let point = nearestPoint(to: originPoint, onLineSegmentPointA: startPoint, pointB: endPoint, distance: &distance)

                if distance < bestDistance {
                    bestDistance = distance
                    bestPoint = point
                }
            }

            return CLLocationCoordinate2DMake(CLLocationDegrees(bestPoint.y), CLLocationDegrees(bestPoint.x))
        }
        return nil
    }

    static func nearestPoint(to origin: CGPoint, onLineSegmentPointA pointA: CGPoint, pointB: CGPoint, distance: inout Double) -> CGPoint {
        let dAP = CGPoint(x: origin.x - pointA.x, y: origin.y - pointA.y)
        let dAB = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        let dot = dAP.x * dAB.x + dAP.y * dAB.y
        let squareLength = dAB.x * dAB.x + dAB.y * dAB.y
        let param = dot / squareLength

        var nearestPoint = origin
        if param < 0 || (pointA.x == pointB.x && pointA.y == pointB.y) {
            nearestPoint.x = pointA.x
            nearestPoint.y = pointA.y
        } else if param > 1 {
            nearestPoint.x = pointB.x
            nearestPoint.y = pointB.y
        } else {
            nearestPoint.x = pointA.x + param * dAB.x
            nearestPoint.y = pointA.y + param * dAB.y
        }

        let dx = origin.x - nearestPoint.x
        let dy = origin.y - nearestPoint.y
        distance = Double(sqrtf(Float(dx * dx + dy * dy)))

        return nearestPoint
    }
}
