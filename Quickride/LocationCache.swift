//
//  LocationCache.swift
//  Quickride
//
//  Created by KNM Rao on 03/01/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation

class LocationCache {
    
    static var singleCacheInstance : LocationCache?
    let queue = DispatchQueue(label: "locationCache.queue")
    private static let DECIMAL_PLACES = 3
    var lastRecentLocation : CLLocation?
    var locationCache = [String : Location]()
    var pendingRequests = [String: [LocationNameCompletionHandler]]()
    
    static func createCacheInstance() {
        singleCacheInstance = LocationCache()
    }
    static func getCacheInstance() -> LocationCache{
        return singleCacheInstance!
    }

    func getLocationInfoForLatLng(useCase : String,coordinate:CLLocationCoordinate2D,handler : @escaping LocationNameCompletionHandler ) {
    AppDelegate.getAppDelegate().log.debug("getLocationInfoForLatLng() with \(coordinate)")
        let key = getCacheKey(coordinate: coordinate)
        var location = locationCache[key]
        if location != nil{
            handler(location,nil)
            LocationCoreDataHelper.updateRecentUsedTime(id: location!.id, date: NSDate().getTimeStamp())
            return
        }
        location = LocationCoreDataHelper.getLocationInfo(latitude: roundDecimal(value: coordinate.latitude), longitude: roundDecimal(value:coordinate.longitude))
        if location != nil{
            handler(location,nil)
            locationCache[key] = location
            LocationCoreDataHelper.updateRecentUsedTime(id: location!.id, date: NSDate().getTimeStamp())
            return
        }
        queue.sync{
            var listeners = pendingRequests[key]
            if listeners != nil{
                listeners?.append(handler)
                pendingRequests[key] = listeners
                return
            }
            listeners = [LocationNameCompletionHandler]()
            listeners?.append(handler)
            pendingRequests[key] = listeners
        }

        MapUtils.getLocationInfo(useCase: useCase, coordinate: coordinate) { (location, error) in
            let key = self.getCacheKey(coordinate: coordinate)
            self.handleResponseFromGoogle(location: location, error: error, key: key)
        }
    }
    func getLocationInfoForAddress(useCase : String,address:String,placeId : String?,handler : @escaping LocationNameCompletionHandler ) {
        AppDelegate.getAppDelegate().log.debug("getLocationInfoForLatLng() with \(address)")
        let key = address
        var location = locationCache[key]
        if location != nil{
            handler(location,nil)
            RoutePathServiceClient.updateUsageCount(address: address) { responseObject, error in
                
            }
            LocationCoreDataHelper.updateRecentUsedTime(id: location!.id, date: NSDate().getTimeStamp())
            return
        }
        location = LocationCoreDataHelper.getLocationInfo(address: address)
        if location != nil{
            handler(location,nil)
            locationCache[key] = location
            RoutePathServiceClient.updateUsageCount(address: address) { responseObject, error in
                
            }
            LocationCoreDataHelper.updateRecentUsedTime(id: location!.id, date: NSDate().getTimeStamp())
            return
        }
        queue.sync{
            var listeners = pendingRequests[key]
            if listeners != nil{
                listeners?.append(handler)
                pendingRequests[key] = listeners
                return
            }
            listeners = [LocationNameCompletionHandler]()
            listeners?.append(handler)
            pendingRequests[key] = listeners
        }

        MapUtils.getUserLocationInfo(useCase: useCase, address : address, placeId: placeId) { (location, error) in
            self.handleResponseFromGoogle(location: location, error: error, key: address)
        }
    }

    private func handleResponseFromGoogle(location : Location?, error : NSError?,key :String){
        if location != nil{
            location!.id = NSDate().getTimeStamp()
            self.locationCache[key] = location
            LocationCoreDataHelper.saveLocationInfo(location: location!)
            self.queue.sync{
                let listeners = self.pendingRequests[key]
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if listeners != nil{
                    for listener in listeners!{
                        listener(location,nil)
                    }
                }
            })
                self.pendingRequests[key] = nil
            }
        }else{
            self.queue.sync{
                let listeners = self.pendingRequests[key]
                if listeners != nil{
                    for listener in listeners!{
                        listener(nil,error)
                    }
                }
                self.pendingRequests[key] = nil
            }
        }
        
    }
    
    func getRecentLocationOfUser() -> CLLocation?{
        if lastRecentLocation?.coordinate.latitude == 0 || lastRecentLocation?.coordinate.longitude == 0{
            return nil
        }
        
        return lastRecentLocation
    }
    
    func putRecentLocationOfUser(location : CLLocation?){
        guard let coordinate = location?.coordinate, coordinate.latitude > 0, coordinate.longitude > 0 else {
            return
        }
        SharedPreferenceHelper.saveLastLocation(latLng: LatLng(lat: coordinate.latitude, long: coordinate.longitude))
        lastRecentLocation = location
    }
    
    private func getCacheKey(coordinate: CLLocationCoordinate2D) -> String{
        
        return roundDecimalToString(value: coordinate.latitude)+","+roundDecimalToString(value: coordinate.longitude)
    }
    private func roundDecimalToString(value : Double) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = LocationCache.DECIMAL_PLACES
        return formatter.string(from: NSNumber(value: value))!
        
    }
    private func roundDecimal(value : Double) -> Double{
        
        if let value = Double(roundDecimalToString(value: value)){
            return value
        }else{
            return 0.0
        }
    }
    func getLoactionInfoForLatLngFromCacheAndGeoCoder(coordinate:CLLocationCoordinate2D,handler : @escaping LocationNameCompletionHandler){
        let key = getCacheKey(coordinate: coordinate)
        var location = locationCache[key]
        if location != nil{
            handler(location,nil)
            return
        }
        location = LocationCoreDataHelper.getLocationInfo(latitude: roundDecimal(value: coordinate.latitude), longitude: roundDecimal(value:coordinate.longitude))
        if location != nil{
            handler(location,nil)
            locationCache[key] = location
            return
        }
        queue.sync{
            var listeners = pendingRequests[key]
            if listeners != nil{
                listeners?.append(handler)
                pendingRequests[key] = listeners
                return
            }
            listeners = [LocationNameCompletionHandler]()
            listeners?.append(handler)
            pendingRequests[key] = listeners
        }
        MapUtils.getLocationInfoFromGeoCoder(coordinate: coordinate, handler: { (location, error) in
            if location != nil{
                let key = self.getCacheKey(coordinate: coordinate)
                self.handleResponseFromGoogle(location: location, error: error, key: key)
            }
        })
    }
}
