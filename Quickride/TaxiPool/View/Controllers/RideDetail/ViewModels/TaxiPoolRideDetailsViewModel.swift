//
//  TaxiPoolRideDetailsViewModel.swift
//  Quickride
//
//  Created by Ashutos on 5/18/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class TaxiPoolRideDetailsViewModel {
    
    var selectedIndex = 0
    var matchedShareTaxi = [MatchedShareTaxi]()
    var analyticNotificationHandlerModel: AnalyticNotificationHandlerModel?
    var taxiInviteEntity: TaxiInviteEntity?
    var ride: Ride?
    var pickupZoomState = ZOOMED_OUT
    var dropZoomState = ZOOMED_OUT
    var isOverlappingRouteDrawn = false
    var pickUpOrDropNavigation: String?
    let MIN_TIME_DIFF_CURRENT_LOCATION = 10
    
    static let ZOOMED_IN = "ZOOMIN"
    static let ZOOMED_OUT = "ZOOMOUT"
    
    func initliseData(selectedIndex: Int?,matchedShareTaxi: [MatchedShareTaxi]?, ride: Ride?,analyticNotificationHandlerModel: AnalyticNotificationHandlerModel?,taxiInviteEntity: TaxiInviteEntity?) {
        self.selectedIndex = selectedIndex ?? 0
        self.matchedShareTaxi = matchedShareTaxi ?? []
        self.ride = ride
        self.analyticNotificationHandlerModel = analyticNotificationHandlerModel
        self.taxiInviteEntity = taxiInviteEntity
    }
    
    func getTaxiRideDetails(completionHandler: @escaping(_ result: Bool)->()) {
        if self.ride == nil {return}
        let passengerRideId = ride?.rideId ?? 0.0
        var taxiShareRideId: Double?
        if taxiInviteEntity != nil {
            taxiShareRideId = taxiInviteEntity?.taxiShareId
        }else{
           taxiShareRideId = analyticNotificationHandlerModel?.taxiShareRideId
        }
        if let taxiRideId = taxiShareRideId {
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getMatchedShareTaxiForAnalyticsNotification(passengerRideId: passengerRideId, taxiRideId: taxiRideId) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject?["resultData"] != nil {
                    let matchedTaxi = Mapper<MatchedShareTaxi>().map(JSONObject: responseObject!["resultData"])
                    self.matchedShareTaxi = [matchedTaxi!]
                    self.selectedIndex = 0
                    completionHandler(true)
                }
            }
        }
    }
    
    func createPassengerRide(completionHandler: @escaping(_ result: Bool)->())  {
        let ride = Ride()
        ride.startAddress = analyticNotificationHandlerModel?.startAddress ?? ""
        ride.endAddress = analyticNotificationHandlerModel?.endAddress ?? ""
        ride.startLatitude = analyticNotificationHandlerModel?.fromLat ?? 0.0
        ride.startLongitude = analyticNotificationHandlerModel?.fromLng ?? 0.0
        ride.endLatitude = analyticNotificationHandlerModel?.toLat ?? 0.0
        ride.endLongitude = analyticNotificationHandlerModel?.toLng ?? 0.0
        ride.rideType = Ride.PASSENGER_RIDE
        ride.startTime = analyticNotificationHandlerModel?.rideStartTime ?? 0.0
        ride.routeId = analyticNotificationHandlerModel?.routeId
        ride.routePathPolyline = analyticNotificationHandlerModel?.routepathPolyline ?? ""
        let passengerRide = PassengerRide(ride: ride)
        passengerRide.noOfSeats = 1
        let createPassengerRideHandler : CreatePassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide,rideRoute: nil, isFromInviteByContact: false, targetViewController: nil, parentRideId: nil,relayLegSeq: nil)
        createPassengerRideHandler.createPassengerRide(handler: { (passengerRide, error) -> Void in
            if passengerRide != nil {
            self.ride = passengerRide
            completionHandler(true)
            }
        })
    }
    
    func creteOrJoinTaxiPoolRide(completionHandler : @escaping taxiPoolJoinCompletionHandler) {
        TaxiPoolRestClient.createOrJoinTaxiRide(passengerRideId: self.ride?.rideId ?? 0.0, taxiRideId: nil, shareType: analyticNotificationHandlerModel?.shareType ?? "") { (data, error) in
            if data != nil {
                let taxiShareRide = Mapper<TaxiShareRide>().map(JSONObject: data!["resultData"])
                completionHandler(taxiShareRide,nil)
            }else {
                 completionHandler(nil,error)
            }
        }
    }
}
