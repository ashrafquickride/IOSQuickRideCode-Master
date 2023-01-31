//
//  TaxiRideEditViewModel.swift
//  Quickride
//
//  Created by Quick Ride on 4/21/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

typealias taxiEditCompletionHandler =  (_ taxiRidePassenger : TaxiRidePassenger) -> Void


class TaxiRideEditViewModel {
    
    
    var taxiRidePassenger: TaxiRidePassenger?
    var selectedViaPointIndex = -1
    var detailEstimatedFare: DetailedEstimateFare?
    var customRoute: RideRoute?
    var newViaPoint : Location?
    var wayPoints = [Location]()
    var userPreferredRoute : UserPreferredRoute?
    var handler: taxiEditCompletionHandler?
    
    var selectedRoute : RideRoute? {
        guard let taxiRidePassenger = taxiRidePassenger else {
            return nil
        }
        if let customRoute = customRoute {
            return customRoute
        }
        guard let routes = detailEstimatedFare?.alternativeRoutes, !routes.isEmpty else { return nil }
        let seleccted = routes.first { route in
            return route.routeId == taxiRidePassenger.routeId
        }
        if let seleccted = seleccted {
            return seleccted
        }else{
            return routes[0]
        }
    }
    var rideRoutes : [RideRoute] {
       
        if let customRoute = customRoute {
            var routes = [RideRoute]()
            routes.append(customRoute)
            return routes
        }else if let routes = detailEstimatedFare?.alternativeRoutes {
            return routes
        }
        return [RideRoute]()
    }
    var startLocation: Location? {
        guard let taxiRidePassenger = taxiRidePassenger else {
            return nil
        }
        if let lat = taxiRidePassenger.startLat, let lng = taxiRidePassenger.startLng, let address = taxiRidePassenger.startAddress {
            return Location(latitude: lat, longitude: lng, shortAddress: address)
        }
        return nil
    }
    var endLocation: Location? {
        guard let taxiRidePassenger = taxiRidePassenger else {
            return nil
        }
        if let lat = taxiRidePassenger.endLat, let lng = taxiRidePassenger.endLng, let address = taxiRidePassenger.endAddress {
            return Location(latitude: lat, longitude: lng, shortAddress: address)
        }
        return nil
    }    
    
    func setData(taxiRidePassenger: TaxiRidePassenger,  handler : @escaping taxiEditCompletionHandler){
        self.taxiRidePassenger = taxiRidePassenger
        self.handler = handler
        if let viaPoints = getWayPointsOfRoute(), viaPoints.count <= 5 {
            self.wayPoints = viaPoints
        }
        self.userPreferredRoute = isUserPreferredRoute(routeId : taxiRidePassenger.routeId ?? 0)
       
    }
    
    
    func isUserPreferredRoute(routeId : Double) -> UserPreferredRoute?{
        let prefRoutes = UserDataCache.getInstance()!.getUserPreferredRoutes()
        for preferredRoute in prefRoutes{
            if let prefRouteId = preferredRoute.routeId, prefRouteId == routeId{
                return preferredRoute
            }
        }
        return nil
    }
    func getWayPointsOfRoute() -> [Location]? {
        if let waypoints = selectedRoute?.waypoints, waypoints.isEmpty == false, waypoints != "null" {
            return Mapper<Location>().mapArray(JSONString: (waypoints))
        }else if let waypoints = taxiRidePassenger?.wayPoints,  waypoints.isEmpty == false, waypoints != "null"{
            return Mapper<Location>().mapArray(JSONString: (waypoints))
        }
        return nil
    }

    func isViaPointEditSession() -> Bool{
        return newViaPoint != nil
    }
    func disableViaPointEdit() {
        newViaPoint = nil
        selectedViaPointIndex = -1
        foundLoopsInRoute = false
        
    }
    
    
    var foundLoopsInRoute = false
    func saveViaPoint(){
        guard let viaPoint = newViaPoint, let taxiRidePassenger = taxiRidePassenger, let startLocation = startLocation, let endLocation = endLocation else {
            return
        }
        
        var temp = [Location](wayPoints)
        if selectedViaPointIndex != -1{
            temp.remove(at: selectedViaPointIndex)
            temp.insert(viaPoint, at: selectedViaPointIndex)
        }else{
            temp.append(viaPoint)
        }
        MyRoutesCache.getInstance()?.getEditedRoute(useCase: "iOS.App.CustomRoute.TaxiRideEditView", rideId: taxiRidePassenger.id!, startLatitude: startLocation.latitude, startLongitude: startLocation.longitude, endLatitude: endLocation.latitude, endLongitude: endLocation.longitude, wayPoints: temp.toJSONString() ?? "", handler: { rideRoute, responseError, error in
            guard let rideRoute = rideRoute else {
                var userInfo = [String : Any]()
                userInfo["responseError"] = responseError
                userInfo["nsError"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
                return
            }
            
            if !self.foundLoopsInRoute && LocationClientUtils.isRouteContainLoops(polyline: rideRoute.overviewPolyline!){
                self.foundLoopsInRoute = true
                var userInfo = [String : Any]()
                userInfo["route"] = rideRoute
                NotificationCenter.default.post(name: .routeContainLoops, object: self, userInfo: userInfo)
                return
            }
            self.selectedViaPointIndex = -1
            self.newViaPoint = nil
            self.wayPoints = temp
            self.foundLoopsInRoute = false
            var rideRoutes = [rideRoute]
            self.receiveRoute(rideRoute: rideRoutes, alternative: false)
            
        })
    }
    func viaPointSelected(index: Int){
        if index < wayPoints.count{
            selectedViaPointIndex = index
            newViaPoint = wayPoints[index]
        }
    }
    
    func viaPointRemoved(index : Int){
        if index >= wayPoints.count {
            return
        }
        foundLoopsInRoute = false
        wayPoints.remove(at: index)
        newViaPoint = nil
        getRoutes()
    }
    
    func getRoutes(){
        QuickRideProgressSpinner.startSpinner()
        if !wayPoints.isEmpty{
            let viaPoints = LocationClientUtils.simplifyWayPoints(wayPoints: wayPoints)
            let wayPointsString = viaPoints?.toJSONString()
            MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App.CustomRoute.TaxiRideEditView", rideId: 0 ,startLatitude: taxiRidePassenger?.startLat ?? 0, startLongitude: taxiRidePassenger?.startLng ?? 0, endLatitude: taxiRidePassenger?.endLat ?? 0, endLongitude: taxiRidePassenger?.endLng ?? 0 ,wayPoints: wayPointsString, routeReceiver : self,saveCustomRoute: false)
        }else{
            getEstimatedFare()
        }
        
    }
    func getEstimatedFare(selectedRouteId: Double? = nil) {
        guard let taxiRidePassenger = taxiRidePassenger else {
            return
        }
        var routes = detailEstimatedFare?.alternativeRoutes
        TaxiUtils.getAvailableVehicleClass(startTime: taxiRidePassenger.startTimeMs!, startAddress: taxiRidePassenger.startAddress!, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: selectedRouteId) { [weak self] result, responseError, error in
            
            guard  let detailEstimatedFare = result else {
                var userInfo = [String : Any]()
                userInfo["responseError"] = responseError
                userInfo["nsError"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
                return
            }
            self?.detailEstimatedFare = detailEstimatedFare
            if selectedRouteId != nil {
                NotificationCenter.default.post(name: .routeReceived, object: self)
                return
            }
            self?.customRoute = nil
            if detailEstimatedFare.alternativeRoutes.isEmpty{
                MyRoutesCache.getInstance()?.getUserRoutes(useCase: "iOS.App.Taxi.AllRoutes.TaxiRideEditView", rideId: taxiRidePassenger.id!, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, weightedRoutes: true, routeReceiver: self!)
                return
            }
            
            routes = detailEstimatedFare.alternativeRoutes
            if !detailEstimatedFare.fareForTaxis.isEmpty && !detailEstimatedFare.fareForTaxis[0].fares.isEmpty{
                let fareforVehicle = detailEstimatedFare.fareForTaxis[0].fares[0]
                if let routeIdStr = fareforVehicle.routeId,
                   let routeId = Double(routeIdStr), routeId != 0,
                   let polyline = fareforVehicle.overviewPolyline {
                    
                    let route = RideRoute(routeId: routeId, overviewPolyline: polyline, distance: fareforVehicle.distance , duration: Double(fareforVehicle.timeDuration ), waypoints: nil, routeType: nil, fromLatitude: taxiRidePassenger.startLat!, fromLongitude: taxiRidePassenger.startLng!, toLatitude: taxiRidePassenger.endLat!, toLongitude: taxiRidePassenger.endLng!)
                    routes?.append(route)
                }
            }
            
            if let routes = routes{
                self?.receiveRoute(rideRoute: routes, alternative: true)
            }
        }
    }
    func rideDetailsChanged() -> Bool{
        guard let edited = taxiRidePassenger, let original = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: edited.id!) else {
            return false
        }
        return startChanged(original: original, edited: edited) || endChanged(original: original, edited: edited) || pickupTimeChanged(original: original, edited: edited) || routeChanged(original: original, edited: edited)
    }
    func startChanged(original: TaxiRidePassenger, edited: TaxiRidePassenger) -> Bool{
        return original.startLat != edited.startLat ||
        original.startLng != edited.startLng
    }
    func endChanged(original: TaxiRidePassenger, edited: TaxiRidePassenger) -> Bool{
        return original.endLat != edited.endLat ||
        original.endLng != edited.endLng
    }
    func routeChanged(original: TaxiRidePassenger, edited: TaxiRidePassenger) -> Bool{
        return original.routeId != edited.routeId
    }
    func pickupTimeChanged(original: TaxiRidePassenger, edited: TaxiRidePassenger) -> Bool{
        return original.pickupTimeMs != edited.pickupTimeMs
    }
    
    func isRouteDistanceIncreasedByThreshold() -> Bool{
        let distanceChange = calculateDistanceChangeInNewRoute()
        if let distance = taxiRidePassenger?.distance {
            return distanceChange > 1 && distanceChange > Int(0.15*distance)
        }
        return false
    }
    func calculateDistanceChangeInNewRoute() -> Int {
        if let newRouteDistance = selectedRoute?.distance,let mainRouteDistance = taxiRidePassenger?.distance{
            return Int(newRouteDistance - mainRouteDistance)
        }
        return 0
    }
    func getSuggestingNameForRoute(startLocation: Location?,endLocation: Location?, wayPoints: [Location]?) -> String{
        var routeName =  startLocation?.address?.prefix(4)
        if let wayPoints = wayPoints {
            for waypoint in wayPoints {
                if let address = waypoint.address {
                    routeName = (routeName ?? "") + "-" + String(address.prefix(4))
                }
            }
        }
        let routeFinalName = (routeName ?? "") + "-" + (endLocation?.address?.prefix(4) ?? "")
        return String(routeFinalName)
    }
    func updateStartLocation(location: Location) -> Void {
        self.taxiRidePassenger?.startLat = location.latitude
        self.taxiRidePassenger?.startLng = location.longitude
        if let address = location.completeAddress {
            self.taxiRidePassenger?.startAddress = address
        }else{
            self.taxiRidePassenger?.startAddress = location.shortAddress
        }
        
    }
    func updateEndLocation(location: Location) -> Void {
        self.taxiRidePassenger?.endLat = location.latitude
        self.taxiRidePassenger?.endLng = location.longitude
        if let address = location.completeAddress {
            self.taxiRidePassenger?.endAddress = address
        }else{
            self.taxiRidePassenger?.endAddress = location.shortAddress
        }
    }
    func getAvailableVehicleClass(handler : @escaping(_ result: FareForVehicleClass?)->()){
        guard let taxiRidePassenger = taxiRidePassenger, let start = self.startLocation, let end = self.endLocation, let startAddress = start.address, let endAddress = end.address, let routeId = taxiRidePassenger.routeId, let pickupTime = taxiRidePassenger.pickupTimeMs, let vehicleCategory = taxiRidePassenger.taxiVehicleCategory else { return }
        
        TaxiUtils.getAvailableVehicleClass(startTime: pickupTime, startAddress: startAddress, startLatitude: start.latitude, startLongitude: start.longitude, endLatitude: end.latitude, endLongitude: end.longitude, endAddress: endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: routeId) { detailedEstimatedFare, responseError, error in
            if let detailedEstimatedFare = detailedEstimatedFare, let fareForVehicle = TaxiUtils.checkSelectedVehicleTypeIsAvailableOrNot(detailedEstimateFares: detailedEstimatedFare, taxiVehicleCategory: vehicleCategory) {
                handler(fareForVehicle)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseError"] = responseError
                userInfo["nsError"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            }
        }
    }
    func updateTaxiTrip(fixedFareId: String, complition: @escaping(_ result: Bool)->()){
       
        guard let edited = taxiRidePassenger, let original = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: edited.id!) else { return  }
        let pickupTime = pickupTimeChanged(original: original, edited: edited) ? edited.pickupTimeMs : nil
        
        let startChanged = startChanged(original: original, edited: edited)
        let startLat = startChanged ? edited.startLat : nil
        let startLng = startChanged ? edited.startLng : nil
        let startAddress = startChanged ? edited.startAddress : nil
        
        let endChanged = endChanged(original: original, edited: edited)
        let endLat = endChanged ? edited.endLat : nil
        let endLng = endChanged ? edited.endLng : nil
        let endAddress = endChanged ? edited.endAddress : nil
        
        let routeId = routeChanged(original: original, edited: edited) ? edited.routeId : nil
        
        TaxiPoolRestClient.updateTaxiTrip(startTime: pickupTime,expectedEndTime: nil, endLatitude: endLat, endLongitude: endLng, endAddress: endAddress, fixedfareID: fixedFareId, taxiRidePassengerId: taxiRidePassenger?.id ?? 0,startLatitude: startLat ,startLongitude: startLng,startAddress: startAddress,pickupNote: nil, selectedRouteId: routeId){ (responseObject, error) in
            
            let result = RestResponseParser<TaxiRidePassengerDetails>().parse(responseObject: responseObject, error: error)
            if let taxiRidePassengerDetails = result.0{
                TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiRidePassengerDetails)
                self.handler?(taxiRidePassengerDetails.taxiRidePassenger!)
                complition(true)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseError"] = result.1
                userInfo["error"] = result.2
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    func handleViaPointSelection(viaPoint : CLLocationCoordinate2D, handler : @escaping (_ location : Location) -> Void){
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.TaxiRideEditView", coordinate: viaPoint, handler: { (location, error) in
            if let location = location {
                
                self.newViaPoint = location
                self.newViaPoint?.latitude = viaPoint.latitude
                self.newViaPoint?.longitude = viaPoint.longitude
                handler(location)
            }else{
                let latLngLocation = Location(latitude: viaPoint.latitude, longitude: viaPoint.longitude, shortAddress: nil)
                self.newViaPoint = latLngLocation
                handler(latLngLocation)
            }
        })
    }
    func getAddressForViaPoint(latitude: Double, longitude: Double) -> Location? {
        if wayPoints.isEmpty {
            return nil
        }
        return wayPoints.first { element in
            return element.latitude == latitude && element.longitude == longitude
        }
    }
   
   
}
extension TaxiRideEditViewModel : RouteReceiver{
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        if rideRoute.isEmpty{
            return
        }
        if !alternative {
            customRoute = rideRoute[0]
            taxiRidePassenger?.routeId = customRoute?.routeId
            detailEstimatedFare = nil
            getEstimatedFare(selectedRouteId: taxiRidePassenger?.routeId)
        }else{
            customRoute = nil
            let found = rideRoute.first { route in
                return route.routeId == taxiRidePassenger?.routeId
            }
            if found == nil && wayPoints.isEmpty {
                taxiRidePassenger?.routeId = rideRoute[0].routeId
            }
            detailEstimatedFare?.alternativeRoutes = rideRoute
            NotificationCenter.default.post(name: .routeReceived, object: self)
        }
        
    }
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        AppDelegate.getAppDelegate().log.error("response : \(String(describing: responseObject)), nsError : \(String(describing: error))")
        let result = RestResponseParser<RideRoute>().parse(responseObject: responseObject, error: error)
        var userInfo = [String : Any]()
        userInfo["responseError"] = result.1
        userInfo["nsError"] = result.2
        NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
    }
    func getNoOfTolls() -> Int {
        if let detailEstimatedFare = self.detailEstimatedFare, !detailEstimatedFare.fareForTaxis.isEmpty,
           !detailEstimatedFare.fareForTaxis[0].fares.isEmpty,
           let tollsInfo = detailEstimatedFare.fareForTaxis[0].fares[0].appliedTollsForTaxiTrip, let noOfTolls = Mapper<AppliedTollsForTheTaxiTrip>().mapArray(JSONString: tollsInfo) {
            return noOfTolls.count
        }
        return 0
    }
}

