//
//  TaxiPoolInvitationCache.swift
//  Quickride
//
//  Created by Ashutos on 9/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias invitedPassengerDetailsCompletionHandler = (_ invites: [TaxiInviteEntity]?, _ responseError: NSError?) -> Void


class TaxiPoolInvitationCache {
    
    var totalInvitations = [Double: [TaxiInviteEntity]]()
    
    static let TAXI_INVITE_STATUS_OPEN = "OPEN"
    static let TAXI_INVITE_STATUS_CANCEL = "CANCELLED"
    static let TAXI_INVITE_STATUS_ACCEPTED = "ACCEPTED"
    static let TAXI_INVITE_STATUS_REJECTED = "REJECTED"
    static let TAXI_INVITE_STATUS_JOINED_OTHER = "JOINED_OTHER"
    static let TAXI_INVITE_STATUS_JOINED_SAME = "JOINED_SAME"
    
    static var singleRideInviteInstance : TaxiPoolInvitationCache?
    static func getInstance() -> TaxiPoolInvitationCache{
        if singleRideInviteInstance == nil {
            singleRideInviteInstance = TaxiPoolInvitationCache()
        }
        return singleRideInviteInstance!
    }
    
    func invitationReceived() {
        NotificationCenter.default.post(name: .taxiInvitationReceived, object: nil)
    }
    
    func getAllInvitesForRide(rideId: Double, handler: @escaping invitedPassengerDetailsCompletionHandler) {
        if totalInvitations.keys.contains(rideId) {
            handler(totalInvitations[rideId],nil)
        }else{
            getAllTaxiPoolInvite(rideId: rideId, handler: handler)
        }
    }
    
    func getAllTaxiPoolInvite(rideId: Double, handler: @escaping invitedPassengerDetailsCompletionHandler) {
        TaxiPoolRestClient.getAllTaxiInvitesForTheRide(rideId: rideId) { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let invitePassengerData = Mapper<TaxiInviteEntity>().mapArray(JSONObject: responseObject?["resultData"])!
                if invitePassengerData != [] {
                    let openInviteData = self?.getAllOpenInvitationForRide(allInvitesForRide: invitePassengerData)
                    self?.totalInvitations[rideId] = openInviteData
                }
                handler(self?.totalInvitations[rideId],nil)
            }
        }
    }
    
    private func getAllOpenInvitationForRide(allInvitesForRide: [TaxiInviteEntity]) -> [TaxiInviteEntity] {
        var finalInviteData = [TaxiInviteEntity]()
        for data in allInvitesForRide{
            if data.status == TaxiPoolInvitationCache.TAXI_INVITE_STATUS_OPEN{
                finalInviteData.append(data)
            }
        }
        return finalInviteData
    }
    
    func insertNewInvitationToCache(rideId: Double, rideInviteData: TaxiInviteEntity) {
        if totalInvitations.keys.contains(rideId) {
            var allInvites = totalInvitations[rideId]
            if allInvites?.isEmpty ?? true {
                totalInvitations[rideId] = [rideInviteData]
            }else{
                for (index, data) in allInvites!.enumerated() {
                    if data.invitingUserId == rideInviteData.invitingUserId {
                        allInvites?.insert(rideInviteData, at: index)
                         totalInvitations[rideId] = allInvites
                        return
                    }
                }
                allInvites?.append(rideInviteData)
                totalInvitations[rideId] = allInvites
            }
        }else{
            totalInvitations[rideId] = [rideInviteData]
        }
    }
    
    func removeAnInvitationFromLocal(rideId: Double,invitationId: String) {
        if totalInvitations.keys.contains(rideId) {
            var allInvites = totalInvitations[rideId]
            var indexToRemove: Int?
            for (index, data) in allInvites!.enumerated() {
                if data.id == invitationId {
                    indexToRemove = index
                    break
                }
            }
            if let index = indexToRemove{
                allInvites?.remove(at: index)
                totalInvitations[rideId] = allInvites
            }
        }
    }
}
