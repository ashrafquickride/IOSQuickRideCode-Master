//
//  RideDetailViewModel.swift
//  Quickride
//
//  Created by Vinutha on 02/03/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

protocol RoutePathReceiveDelagate  {
    func receiveRoutePath()
}

protocol RideParticipantLocationReceiveDelagate  {
    func receiveRideParticipantLocation(rideParticipantLocation: RideParticipantLocation, riderStartTime: Double)
}

class RideDetailViewModel {

    var notification: UserNotification?
    var notificationHandler: NotificationHandler?
    var rideInvitation: RideInvitation?
    var matchedUser : MatchedUser?
    var ride :Ride?
    var pickupZoomState = ZOOMED_OUT
    var dropZoomState = ZOOMED_OUT
    var pickUpOrDropNavigation: String?
    var routePathReceiveDelagate: RoutePathReceiveDelagate?
    var rideParticipantLocationReceiveDelagate: RideParticipantLocationReceiveDelagate?
    var viewType: DetailViewType?
    var isOverlappingRouteDrawn = false
    
    let MIN_TIME_DIFF_CURRENT_LOCATION = 10
    
    static let ZOOMED_IN = "ZOOMIN"
    static let ZOOMED_OUT = "ZOOMOUT"
    
    func initializeData(notification: UserNotification?, notificationHandler: NotificationHandler?, rideInvitation: RideInvitation?, ride: Ride?, matchedUser: MatchedUser, routePathReceiveDelagate: RoutePathReceiveDelagate?, rideParticipantLocationReceiveDelagate: RideParticipantLocationReceiveDelagate?, viewType: DetailViewType) {
        self.notification = notification
        self.notificationHandler = notificationHandler
        self.rideInvitation = rideInvitation
        self.ride = ride
        self.matchedUser = matchedUser
        self.routePathReceiveDelagate = routePathReceiveDelagate
        self.rideParticipantLocationReceiveDelagate = rideParticipantLocationReceiveDelagate
        self.viewType = viewType
    }
    
    func getRoutePath() {
        RideServicesClient.getRoutePath(rideId: matchedUser!.rideid!, rideType: ride!.rideType!, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.matchedUser!.routePolyline = responseObject!["resultData"] as? String
                self.routePathReceiveDelagate?.receiveRoutePath()
            }
        })
    }
    
    func getRideParticipantLocation(riderRideId: Double, startDate: Double, viewController: UIViewController) {
        LocationUpdationServiceClient.getRiderParticipantLocation(rideId: riderRideId, targetViewController: viewController, completionHandler: {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                let rideParticipantLocation = Mapper<RideParticipantLocation>().map(JSONObject:responseObject!["resultData"])!
                self.rideParticipantLocationReceiveDelagate?.receiveRideParticipantLocation(rideParticipantLocation: rideParticipantLocation, riderStartTime: startDate)
            }
        })
    }
}
