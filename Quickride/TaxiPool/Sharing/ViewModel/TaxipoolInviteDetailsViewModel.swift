//
//  TaxipoolInviteDetailsViewModel.swift
//  Quickride
//
//  Created by HK on 20/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxipoolInviteDetailsViewModel{
    
    var taxiInvite: TaxiPoolInvite?
    init() {}
    var invitedUserDetails: UserBasicInfo?
    var matchedTaxiRideGroup: MatchedTaxiRideGroup?
    var isFromJoinMyRide = false
    
    init(taxiInvite: TaxiPoolInvite,matchedTaxiRideGroup: MatchedTaxiRideGroup,isFromJoinMyRide: Bool) {
        self.taxiInvite = taxiInvite
        self.matchedTaxiRideGroup = matchedTaxiRideGroup
        self.isFromJoinMyRide = isFromJoinMyRide
    }
    
    func getInvtedUserDetails(complitionHandler: @escaping(_ result: Bool) -> ()){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: Double(taxiInvite?.invitingUserId ?? 0), handler: { [weak self] (userBasicInfo, responseError, error) in
            if let basicInfo = userBasicInfo{
                self?.invitedUserDetails = basicInfo
                complitionHandler(true)
            }else{
                complitionHandler(false)
            }
        })
    }
    
    func acceptTaxipoolInvite(complitionHandler: @escaping(_ taxiPassengerId: Double?) -> ()){
        guard let matchedTaxiRideGroup = matchedTaxiRideGroup,let taxiInvite = taxiInvite else { return }
        let startLocation = Location(latitude: matchedTaxiRideGroup.pickupLat, longitude: matchedTaxiRideGroup.pickupLng, shortAddress: matchedTaxiRideGroup.pickupAddress)
        let endLocation = Location(latitude: matchedTaxiRideGroup.dropLat, longitude: matchedTaxiRideGroup.dropLng, shortAddress: matchedTaxiRideGroup.dropAddress)
        let vehicleDetail = FareForVehicleClass(taxiType: TaxiPoolConstants.TAXI_TYPE_CAR, fixedFareId: taxiInvite.fixedFareRefId ?? matchedTaxiRideGroup.fixedFareRefId ?? "", vehicleClass: TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_ANY, selectedMaxFare: taxiInvite.maxFare, shareType: TaxiPoolConstants.SHARE_TYPE_ANY_SHARING)
        let createTaxiDetails = CreateTaxiPoolHandler(startLocation: startLocation, endLocation: endLocation, tripType: TaxiPoolConstants.TRIP_TYPE_LOCAL, routeId: nil, startTime: Double(matchedTaxiRideGroup.pickupTimeMs), selectedVehicleDetails: vehicleDetail, endTime: nil, journeyType: TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY, advancePercentageForOutstation: nil, refRequestId: Double(taxiInvite.invitedRideId), viewController: ViewControllerUtils.getCenterViewController(),couponCode: nil, paymentMode: nil,taxiGroupId: Double(taxiInvite.taxiRideGroupId),refInviteId: taxiInvite.id, commuteContactNo: nil, commutePassengerName: nil)
        QuickRideProgressSpinner.startSpinner()
        createTaxiDetails.createTaxiPool { (data, error) in
            QuickRideProgressSpinner.stopSpinner()
            if let data = data,let taxiRidePassenger = data.taxiRidePassenger {
                TaxiRideDetailsCache.getInstance().setTaxiRideDetailsToCache(rideId: taxiRidePassenger.id ?? 0, taxiRidePassengerDetails: data)
                MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)
                complitionHandler(taxiRidePassenger.id)
            }
        }
    }
    
    func rejectTaxipoolInvite(complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
        TaxiSharingRestClient.rejectInvite(inviteId: taxiInvite?.id ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                MyActiveTaxiRideCache.getInstance().removeTaxiIncomingInvite(inviteId: self.taxiInvite?.id ?? "")
                complitionHandler(nil,nil)
            }else{
                complitionHandler(responseObject,error)
            }
        }
    }
}
