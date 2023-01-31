//
//  MapUtils.swift
//  Quickride
//
//  Created by KNM Rao on 26/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

typealias LocationNameCompletionHandler = (_ location :Location?,_ error : NSError?) -> Void

class MapUtils {
    
    static let GEO_CODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"

    static func getLocationInfo(useCase : String,coordinate:CLLocationCoordinate2D,handler : @escaping LocationNameCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(coordinate)")
        if coordinate.latitude == 51.17889991879489 && coordinate.longitude == -1.8263999372720716 {
            return
        }
        getLocationInfoFromGeoCoder(coordinate: coordinate, handler: { (location, error) in
            if location != nil{
                return handler(location, nil)
            }else{

                RoutePathServiceClient.getLocationInfoForLatLng(useCase: useCase, latitude: coordinate.latitude, longitude: coordinate.longitude) { (responseObject, error) in
                    AppDelegate.getAppDelegate().log.debug("\(String(describing: responseObject)) \(String(describing: error))")
                    
                    if let status = responseObject?["result"] as? String{
                        if status == "SUCCESS"{
                            let location = Mapper<Location>().map(JSONObject: responseObject!["resultData"])
                            return handler(location, nil)
                        }
                    }
                    return handler(nil, QuickRideErrors.LocationNotAvailableError)
                }
            }
        })
    }
    public static func getUserLocationInfo(useCase : String,address : String,placeId : String?,handler : @escaping LocationNameCompletionHandler){


        RoutePathServiceClient.getLocationInfoForAddress(useCase: useCase, address: address, placeId: placeId, completionhandler: { (responseObject, error) in
            AppDelegate.getAppDelegate().log.debug("\(String(describing: responseObject)) \(String(describing: error))")
            
            if let status = responseObject?["result"] as? String{
                if status == "SUCCESS"{
                    let location = Mapper<Location>().map(JSONObject: responseObject!["resultData"])
                    return handler(location, nil)
                }
            }
            if error != nil {
                return handler(nil, error)

            }else{
                return handler(nil, QuickRideErrors.LocationNotAvailableError)

            }
        })
    }
   
    private static func handleResponseFromGeocoder(_ response: GMSReverseGeocodeResponse?) -> (Location?,NSError?) {
        if response == nil{
            return (nil, QuickRideErrors.LocationNotAvailableError)
        }
        
        let address = response?.results()?[0]
        if address == nil || address!.lines == nil {
            return (nil, QuickRideErrors.LocationNotAvailableError)
        }
        let addressName = getAddressFromGeoAddress(address: address!)
        let locationName = self.getLocationNameFromGeoAddress(address: address!)
        
        var country : String?
        if address!.country != nil{
            country = address!.country!
        }
        var state : String?
        if address!.administrativeArea != nil{
            state = address!.administrativeArea!
        }else{
            state = getStateNameFromGeoAddress(address: address!)
        }
        var city : String?
        if address!.locality != nil{
            city = address!.locality
        }
        var areaName : String?
        if address!.subLocality  != nil{
            areaName = address!.subLocality!
        }
        var streetName : String?
        if address!.thoroughfare != nil{
            streetName = address!.thoroughfare!
        }
        
        let location = Location(id: 0, latitude: address!.coordinate.latitude, longitude: address!.coordinate.longitude, shortAddress: locationName, completeAddress: addressName, country: country, state: state, city: city, areaName: areaName, streetName: streetName)
        return (location,nil)
    }
    
    static func getLocationInfoFromGeoCoder(coordinate:CLLocationCoordinate2D, handler : @escaping LocationNameCompletionHandler ) {
        
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (response, error) in
            AppDelegate.getAppDelegate().log.debug("Response : \(String(describing: response)), Error : \(String(describing: error))")
            
            let result = handleResponseFromGeocoder(response)
            if result.0 != nil{
                result.0!.latitude = coordinate.latitude
                result.0!.longitude = coordinate.longitude
            }
            handler(result.0,result.1)
        }
    }
    
    private static func getLocationNameFromGeoAddress(address : GMSAddress) -> String{
        
        let addressName = address.lines!.joined(separator: ", ")
        var addressComponents = addressName.components(separatedBy: ", ")
        if addressComponents.count > 3{
            addressComponents.removeLast()
            while addressComponents.count > 3{
                addressComponents.removeFirst()
            }
        }
        return addressComponents.joined(separator: ", ")
    }
    static func getAddressFromGeoAddress(address : GMSAddress) -> String{
        return address.lines!.joined(separator: ", ")
    }
    static func getStateNameFromGeoAddress (address : GMSAddress) -> String{
        
        return address.lines!.last!
    }
    public static func getLocationNameFromFormatedAddress(addressName : String) -> String{
        
        var addressComponents = addressName.components(separatedBy: ", ")
        if addressComponents.count > 3{
            addressComponents.removeLast()
            while addressComponents.count > 3{
                addressComponents.removeFirst()
            }
        }
        return addressComponents.joined(separator: ", ")
    }
}
