//
//  MyRideDetailTableViewCellModel.swift
//  Quickride
//
//  Created by Bandish Kumar on 14/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol MyRideDetailTableViewCellModelDelegate: class {
    func receiveMatchedRiderDetails(matchedUser: [MatchedUser])
    func receivedMatchedTaxiDetails(matchedTaxi: [MatchedShareTaxi])
}

class MyRideDetailTableViewCellModel {
    
    //MARK: Properties
    var rideParticipantsObject = [RideParticipant]()
    var ride: Ride?
    weak var delegate: MyRideDetailTableViewCellModelDelegate?
    var joinedRideParticipant = [RideParticipant]() //this will store all ride participants of ride which has been accepted
     //MARK: Methods
    func getIncomingInvitesForRide(ride: Ride) -> [Double: RideInvitation] {
        var incomingRideInvites = [Double: RideInvitation]()
        self.ride = ride
        let invites = RideInviteCache.getInstance().getReceivedInvitationsOfRide(rideId: ride.rideId, rideType: ride.rideType ?? "")
        for rideInvite in invites {
            if checkWhetherThisInviteISAlreadyPartOfRide(rideInvite: rideInvite) == false, checkForDuplicateIncomingInvite(rideInvite: rideInvite, incomingRideInvites: incomingRideInvites) == false {
                incomingRideInvites[rideInvite.rideInvitationId] = rideInvite
            }
        }
        return incomingRideInvites
    }
    
    func getOutGoingInvitesForRide(ride: Ride) -> [RideInvitation] {
        var outGoingRideInvites = [RideInvitation]()
        let invites = RideInviteCache.getInstance().getInvitationsForRide(rideId: ride.rideId, rideType:  ride.rideType ?? "")
        for invite in invites {
            if checkWhetherThisInviteISAlreadyPartOfRide(rideInvite: invite) == false && checkForDuplicateOutGoingInvite(rideInvite: invite, outGoingInvites: invites) == false {
                outGoingRideInvites.append(invite)
            }
        }
        return outGoingRideInvites
    }
    
    func checkWhetherThisInviteISAlreadyPartOfRide(rideInvite : RideInvitation) -> Bool{
        if let ride = ride, ride.rideType == Ride.RIDER_RIDE {
            let rideParticipant =  RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideInvite.passengerId, rideParticipants: rideParticipantsObject)
            if rideParticipant != nil{
                RideInviteCache.getInstance().removeInvitation(id: rideInvite.rideInvitationId)
                return true
            }
        }
        return false
    }
    
    func checkForDuplicateIncomingInvite(rideInvite: RideInvitation, incomingRideInvites: [Double: RideInvitation]) -> Bool{
        if let ride = ride, ride.rideType == Ride.RIDER_RIDE {
            for incomingInvite in incomingRideInvites{
                if incomingInvite.1.passenegerRideId == rideInvite.passenegerRideId {
                    RideInviteCache.getInstance().removeInvitation(id: rideInvite.rideInvitationId)
                    return true
                }
            }
        } else {
            for incomingInvite in incomingRideInvites{
                if incomingInvite.1.rideId == rideInvite.rideId{
                    RideInviteCache.getInstance().removeInvitation(id: rideInvite.rideInvitationId)
                    return true
                }
            }
        }
        return false
    }
    
    func checkForDuplicateOutGoingInvite(rideInvite: RideInvitation, outGoingInvites: [RideInvitation]) -> Bool{
        if let ride = ride, ride.rideType == Ride.RIDER_RIDE {
            for outGoingInvite in outGoingInvites{
                if outGoingInvite.rideInvitationId != rideInvite.rideInvitationId, outGoingInvite.passenegerRideId == rideInvite.passenegerRideId, outGoingInvite.passengerId == rideInvite.passengerId {
                    RideInviteCache.getInstance().removeInvitation(id: rideInvite.rideInvitationId)
                    return true
                }
            }
        } else {
            for outGoingInvite in outGoingInvites{
                if outGoingInvite.rideInvitationId != rideInvite.rideInvitationId, outGoingInvite.rideId == rideInvite.rideId, outGoingInvite.riderId == rideInvite.riderId {
                    RideInviteCache.getInstance().removeInvitation(id: rideInvite.rideInvitationId)
                    return true
                }
            }
        }
        return false
    }
    
    func getMatchedRides(ride: Ride,viewController : UIViewController) {
           if Ride.RIDER_RIDE == ride.rideType || Ride.REGULAR_RIDER_RIDE == ride.rideType{
            MatchedUsersCache.getInstance().getAllMatchedPassengers(ride: ride, rideRoute: nil, overviewPolyline: ride.routePathPolyline, capacity: (ride as? RiderRide)?.availableSeats ?? 1, fare: (ride as? RiderRide)?.farePerKm ?? 3.0, requestSeqId: 0,displaySpinner: false, dataReceiver: self)
           } else {
            MatchedUsersCache.getInstance().getAllMatchedRiders(ride: ride, rideRoute: nil, overviewPolyline: ride.routePathPolyline, noOfSeats: (ride  as? PassengerRide)?.noOfSeats ?? 1, requestSeqId: 0,displaySpinner: false, dataReceiver: self)
           }
       }
    


}
//MARK: MatchedTaxiPoolDataREceiver
//
//extension MyRideDetailTableViewCellModel: MatchedShareTaxiDataReceiver {
//    func receiveMatchedTaxiList(matchedShareTaxi: [MatchedShareTaxi], minMaxFareDetailsForNewCard: [GetTaxiShareMinMaxFare]) {
//         delegate?.receivedMatchedTaxiDetails(matchedTaxi: matchedShareTaxi)
//    }
//
//    func matchingTaxiRetrievalFailed(responseObject: NSDictionary?, error: NSError?) {}
//}

//MARK: MatchedUsersDataReceiver
extension MyRideDetailTableViewCellModel: MatchedUsersDataReceiver {
    
    func receiveMatchedRidersList(requestSeqId: Int, matchedRiders: [MatchedRider], currentMatchBucket: Int) {
        delegate?.receiveMatchedRiderDetails(matchedUser: matchedRiders)
    }
    
    func receiveMatchedPassengersList(requestSeqId: Int, matchedPassengers : [MatchedPassenger], currentMatchBucket : Int){
        delegate?.receiveMatchedRiderDetails(matchedUser: matchedPassengers)
    }
    
    func matchingPassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?) {
        delegate?.receiveMatchedRiderDetails(matchedUser: [MatchedUser]())
    }
    func matchingRidersRetrievalFailed(requestSeqId: Int, responseObject: NSDictionary?, error: NSError?) {
        delegate?.receiveMatchedRiderDetails(matchedUser: [MatchedUser]())
    }
}
