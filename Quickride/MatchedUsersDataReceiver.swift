//
//  MatchedUsersDataReceiver.swift
//  Quickride
//
//  Created by KNM Rao on 25/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol MatchedUsersDataReceiver
{
    func receiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int)
    func receiveMatchedPassengersList( requestSeqId: Int, matchedPassengers : [MatchedPassenger],currentMatchBucket : Int)
    func matchingRidersRetrievalFailed( requestSeqId : Int,responseObject :NSDictionary?,error : NSError?)
    func matchingPassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?)
    func receiveInactiveMatchedPassengers(requestSeqId: Int, matchedPassengers : [MatchedPassenger],currentMatchBucket : Int)
    func receiveInactiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int)
}
extension MatchedUsersDataReceiver{
    func receiveInactiveMatchedPassengers(requestSeqId: Int, matchedPassengers : [MatchedPassenger],currentMatchBucket : Int){}
    func receiveInactiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int){}
}

protocol FavouriteUsersDataReceiver
{
    func receiveFavouriteRidersList(requestSeqId : Int, matchedRiders : [MatchedRider])
    func receiveFavouritePassengersList( requestSeqId: Int, matchedPassengers : [MatchedPassenger])
    func matchingFavouriteRidersRetrievalFailed( requestSeqId : Int,responseObject :NSDictionary?,error : NSError?)
    func matchingFavouritePassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?)
}
protocol TaxiMatchedRidersDataReceiver {
    func receiveMatchedRidersList(matchedRiders: [MatchedRider])
    func matchingRidersRetrievalFailed(responseObject :NSDictionary?,error : NSError?)
}
