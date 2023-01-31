//
//  RideDetailMapViewModel.swift
//  Quickride
//
//  Created by Vinutha on 02/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

protocol RoutePathReceiveDelagate  {
    func receiveRoutePath()
}

protocol RideParticipantLocationReceiveDelagate  {
    func receiveRideParticipantLocation(destinationLatLng: CLLocationCoordinate2D, rideParticipantLocation: RideParticipantLocation, riderStartTime: Double)
}

protocol MatchedPassengerRecieverDelegate {
    func recievedMatchedUserSucceded()
}

class RideDetailMapViewModel {

    var ride :Ride?
    var pickupZoomState = ZOOMED_OUT
    var dropZoomState = ZOOMED_OUT
    var pickUpOrDropNavigation: String?
    var routePathReceiveDelagate: RoutePathReceiveDelagate?
    var rideParticipantLocationReceiveDelagate: RideParticipantLocationReceiveDelagate?
    var viewType: DetailViewType?
    var isOverlappingRouteDrawn = false
    var matchedUserList = [MatchedUser]()
    var selectedIndex = 0
    var selectedUserDelegate: SelectedUserDelegate?
    var startAndEndChangeRequired = false
    private var matchedPassengerReciever: MatchedPassengerRecieverDelegate?

    var inviteId : Double?
    var isRideActionViewAdded = false


    let MIN_TIME_DIFF_CURRENT_LOCATION = 10

    static let ZOOMED_IN = "ZOOMIN"
    static let ZOOMED_OUT = "ZOOMOUT"

    func initializeData(ride: Ride?, matchedUserList: [MatchedUser], routePathReceiveDelagate: RoutePathReceiveDelagate?, rideParticipantLocationReceiveDelagate: RideParticipantLocationReceiveDelagate?, viewType: DetailViewType, selectedIndex: Int, startAndEndChangeRequired: Bool, selectedUserDelegate: SelectedUserDelegate?, matchedPassengerReciever: MatchedPassengerRecieverDelegate?,rideInviteId: Double? = nil) {
        self.ride = ride
        self.matchedUserList = matchedUserList
        self.routePathReceiveDelagate = routePathReceiveDelagate
        self.rideParticipantLocationReceiveDelagate = rideParticipantLocationReceiveDelagate
        self.viewType = viewType
        self.selectedIndex = selectedIndex
        self.startAndEndChangeRequired = startAndEndChangeRequired
        self.selectedUserDelegate = selectedUserDelegate
        self.matchedPassengerReciever = matchedPassengerReciever
        self.inviteId = rideInviteId
    }

    func getRoutePath() {
        RideServicesClient.getRoutePath(rideId: matchedUserList[selectedIndex].rideid!, rideType: ride!.rideType!, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.matchedUserList[self.selectedIndex].routePolyline = responseObject!["resultData"] as? String
                self.routePathReceiveDelagate?.receiveRoutePath()
            }
        })
    }

    func getRideParticipantLocation(userId: Double?, riderRideId: Double, startDate: Double, destinationLatLng: CLLocationCoordinate2D, viewController: UIViewController) {
        LocationUpdationServiceClient.getRiderParticipantLocation(rideId: riderRideId, targetViewController: viewController, completionHandler: {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                    let rideParticipantLocation = Mapper<RideParticipantLocation>().map(JSONObject:responseObject!["resultData"])!
                self.rideParticipantLocationReceiveDelagate?.receiveRideParticipantLocation(destinationLatLng: destinationLatLng, rideParticipantLocation: rideParticipantLocation, riderStartTime: startDate)
            } else {
                SharedPreferenceHelper.storeMatchedUserLocation(userId: userId, rideParticipantLocation: nil)
            }
        })
    }

    func getDayOfWeekForRideDate() -> String? {
        if let ride = ride {
            let rideDate = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_dd_MMM_yy)
            let days = DateUtils.getDayOfWeek(today: rideDate)
            switch days {
            case Strings.sun:
                return "Sunday's"
            case Strings.mon:
                return "Monday's"
            case Strings.tue:
                return "Tuesday's"
            case Strings.wed:
                return "Wednesday's"
            case Strings.thu:
                return "Thursday's"
            case Strings.fri:
                return "Friday's"
            case Strings.sat:
                return "Saturday's"
            default:
                return nil
            }
        }
        return nil
    }

    func getTodayAndTomorrowRide() -> String? {
        if let ride = ride {
            let rideDate = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)
            if let date = DateUtils.getDateFromString(date: rideDate, dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss) as Date? {
                let calendar = Calendar.current
                if calendar.isDateInToday(date) {
                    return "Today's"
                } else if calendar.isDateInTomorrow(date) {
                    return "Tomorrow's"
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    func getRideTimeInADay() -> String? {
        if let ride = ride {
            let rideDate = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)
            if let date = DateUtils.getDateFromString(date: rideDate, dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss) as Date? {
                let hour = Calendar.current.component(.hour, from: date)
                switch hour {
                case 00..<12 : return "Morning Ride"
                case 12..<17 : return "Afternoon Ride"
                case 17..<24 : return "Evening Ride"
                default: return nil
                }
            }
        }
        return nil
    }


}
