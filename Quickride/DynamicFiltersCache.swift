//
//  DynamicFiltersCache.swift
//  Quickride
//
//  Created by QuickRideMac on 1/25/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class DynamicFiltersCache
{
    static let singleInstance = DynamicFiltersCache()
    static let VEHICLE_CRITERIA = "VEHICLE_CRITERIA"
    static let PREFERRED_VEHICLE_CAR = "Car"
    static let PREFERRED_VEHICLE_BIKE = "Bike"
    static let PREFERRED_ALL = "ALL"
    
    static let USERS_CRITERIA = "USERS_CRITERIA"
    static let PREFERRED_USERS_VERIFIED = "Verified"
    
    static let PARTNERS_CRITERIA = "PARTNERS_CRITERIA"
    static let FAVOURITE_PARTNERS = "FAVOURITE_PARTNERS"
    
    static let EXISTANCE_CRITERIA = "EXISTANCE_CRITERIA"
    static let ACTIVE_USERS = "ACTIVE_USERS"
    
    static let MINIMUM_RATING_CRITERIA = "MINIMUM_RATING_CRITERIA"
    
    static let ROUTE_POINT_CRITERIA = "ROUTE_POINT_CRITERIA"
    static let VIA_START_POINT = "VIA_START_POINT"
    static let VIA_END_POINT = "VIA_END_POINT"
    
    static let TIME_RANGE_CRITERIA = "TIME_RANGE_CRITERIA"
    static let timeRangeList = ["15 Min","30 Min","45 Min","1 hr","1.5 hr","2 hr"]
    
    static let GENDER_CRITERIA = "GENDER_CRITERIA"
    static let PREFERRED_GENDER_M = "M"
    static let PREFERRED_GENDER_FM = "F"
    
    static let ROUTE_MATCH_CRITERIA = "ROUTE_MATCH_CRITERIA"
    
    static let SORT_CRITERIA = "SORT_CRITERIA"
    static let SORT_AS_RECOMMENDED = "SORT_AS_RECOMMENDED"
    static let SORT_ROUTE_PERCENTAGE_DESCENDING = "ROUTE_PERCENTAGE_DESCENDING"
    static let SORT_RIDETAKERS_ROUTE_PERCENTAGE_DESCENDING = "RIDETAKERS_ROUTE_PERCENTAGE_DESCENDING"
    static let SORT_POINTS_ASCENDING = "POINTS_ASCENDING"
    static let SORT_POINTS_DESCENDING = "POINTS_DESCENDING"
    static let SORT_PICK_UP_TIME_IN_ASCENDING = "PICK_UP_TIME_IN_ASCENDING"
    static let SORT_PICK_UP_TIME_IN_DESCENDING = "PICK_UP_TIME_IN_DESCENDING"
    static let SORT_BASED_ON_LAST_RESPONSE = "BASED_ON_LAST_RESPONSE"
    static let SORT_BASED_ON_PICKUP_POINT_DISTANCE = "SORT_BASED_ON_PICKUP_POINT_DISTANCE"

    var dynamicFiltersStatusBasedOnRide =  [Double : [String : String]]()


    static func getInstance() -> DynamicFiltersCache {
        return singleInstance
    }
    
    func updateDynamicFiltersStatus( rideId : Double,dynamicStatus : [String:String], rideType: String){
        dynamicFiltersStatusBasedOnRide[rideId] = dynamicStatus
        SharedPreferenceHelper.saveSortAndFilterStatus(rideId: rideId, status: dynamicStatus,rideType: rideType)
    }

    func getDynamicFiltersStatusForRide(rideId : Double,rideType: String) -> [String : String]? {
        if let status = dynamicFiltersStatusBasedOnRide[rideId]{
           return status
        }else{
            return SharedPreferenceHelper.getSortAndFilterStatus(rideId: rideId,rideType: rideType)
        }
    }
    
    func sortAndFilterMatchingListForRide(matchedUsers : [MatchedUser], rideType : String, rideId : Double) -> [MatchedUser]{
        var ride: Ride?
        if rideType == Ride.RIDER_RIDE{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId)
        }else{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId)
        }
        var matchedUsers = matchedUsers
        guard let status = getDynamicFiltersStatusForRide(rideId: rideId, rideType: rideType) else { return matchedUsers }
        
        var optimizedMatchedUsersList = [MatchedUser]()
        
        //MARK: Favourite partners
        if status[DynamicFiltersCache.PARTNERS_CRITERIA] == DynamicFiltersCache.FAVOURITE_PARTNERS{
            for matchedUser in matchedUsers{
                if let userId = matchedUser.userid, let userDataCache = UserDataCache.getInstance(), userDataCache.isFavouritePartner(userId: userId){
                    optimizedMatchedUsersList.append(matchedUser)
                }
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        //MARK: Minimum Rating
        if let value = status[DynamicFiltersCache.MINIMUM_RATING_CRITERIA], let minRating = Double(value){
            for matchedUser in matchedUsers{
                if let rating = matchedUser.rating, rating >= minRating{
                    optimizedMatchedUsersList.append(matchedUser)
                }
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        //MARK: Active Users
        if status[DynamicFiltersCache.EXISTANCE_CRITERIA] == DynamicFiltersCache.ACTIVE_USERS{
            for matchedUser in matchedUsers{
                let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedUser.lastResponseTime, time2: NSDate().getTimeStamp())
                if (timeDiff/60) <= 24{
                   optimizedMatchedUsersList.append(matchedUser)
                }
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        //MARK: Route match via time range
        if let value = status[DynamicFiltersCache.TIME_RANGE_CRITERIA]{
            for matchedUser in matchedUsers{
                let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedUser.pickupTime, time2: ride?.startTime)
                if let timeRange = Int(value), timeDiff <= timeRange{
                  optimizedMatchedUsersList.append(matchedUser)
                }
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        //MARK: Route match via point
        if let value = status[DynamicFiltersCache.ROUTE_POINT_CRITERIA]{
            if value == DynamicFiltersCache.VIA_START_POINT{
                for matchedUser in matchedUsers{
                    let distance = LocationClientUtils.getDistance(fromLatitude: ride?.startLatitude ?? 0, fromLongitude: ride?.startLongitude ?? 0, toLatitude: matchedUser.pickupLocationLatitude ?? 0, toLongitude: matchedUser.pickupLocationLongitude ?? 0)
                    if distance < 500{
                        optimizedMatchedUsersList.append(matchedUser)
                    }
                }
            }else if value == DynamicFiltersCache.VIA_END_POINT{
                for matchedUser in matchedUsers{
                    let distance = LocationClientUtils.getDistance(fromLatitude: ride?.endLatitude ?? 0, fromLongitude: ride?.endLongitude ?? 0, toLatitude: matchedUser.dropLocationLatitude ?? 0, toLongitude: matchedUser.dropLocationLongitude ?? 0)
                    if distance < 500{
                        optimizedMatchedUsersList.append(matchedUser)
                    }
                }
            }else if value == DynamicFiltersCache.PREFERRED_ALL{
               optimizedMatchedUsersList = matchedUsers
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        //MARK: Vehicle
        if let value = status[DynamicFiltersCache.VEHICLE_CRITERIA]{
            switch value {
            case DynamicFiltersCache.PREFERRED_VEHICLE_CAR:
                for matchedUser in matchedUsers{
                    if matchedUser.userRole == MatchedUser.RIDER{
                        let vehicleType = (matchedUser as! MatchedRider).vehicleType
                        if Vehicle.VEHICLE_TYPE_CAR == vehicleType{
                            optimizedMatchedUsersList.append(matchedUser)
                        }
                    }
                }
                break
            case DynamicFiltersCache.PREFERRED_VEHICLE_BIKE:
                for matchedUser in matchedUsers{
                    if matchedUser.userRole == MatchedUser.RIDER{
                        let vehicleType = (matchedUser as! MatchedRider).vehicleType
                        if Vehicle.VEHICLE_TYPE_BIKE == vehicleType{
                            optimizedMatchedUsersList.append(matchedUser)
                        }
                    }
                }
                break
            case DynamicFiltersCache.PREFERRED_ALL:
                optimizedMatchedUsersList = matchedUsers
                break
            default:
                break
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        //VERICATION STATUS
        if let value = status[DynamicFiltersCache.USERS_CRITERIA]{
            switch value {
            case DynamicFiltersCache.PREFERRED_USERS_VERIFIED:
                for matchedUser in matchedUsers{
                    if matchedUser.verificationStatus{
                        optimizedMatchedUsersList.append(matchedUser)
                    }
                }
                break
            case DynamicFiltersCache.PREFERRED_ALL:
                optimizedMatchedUsersList = matchedUsers
                break
            default:
                break
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        // GENDER SELECTION
        if let value = status[DynamicFiltersCache.GENDER_CRITERIA]{
            switch value {
            case DynamicFiltersCache.PREFERRED_GENDER_M:
                for matchedUser in matchedUsers
                {
                    if matchedUser.gender == User.USER_GENDER_MALE{
                        optimizedMatchedUsersList.append(matchedUser)
                    }
                }
                break
            case DynamicFiltersCache.PREFERRED_GENDER_FM:
                for matchedUser in matchedUsers
                {
                    if matchedUser.gender == User.USER_GENDER_FEMALE{
                        optimizedMatchedUsersList.append(matchedUser)
                    }
                }
                break
            case DynamicFiltersCache.PREFERRED_ALL:
                optimizedMatchedUsersList = matchedUsers
                break
            default:
                break
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        // ROUTE MATCH
        if let value =  status[DynamicFiltersCache.ROUTE_MATCH_CRITERIA]{
            for matchedUser in matchedUsers{
                if let routeMatchPer = Int(value), matchedUser.matchPercentage! >= routeMatchPer {
                    optimizedMatchedUsersList.append(matchedUser)
                }
            }
            matchedUsers = optimizedMatchedUsersList
            optimizedMatchedUsersList.removeAll()
        }
        
        // SORT OPTION
        if let value = status[DynamicFiltersCache.SORT_CRITERIA]{
            switch value {
            case DynamicFiltersCache.SORT_BASED_ON_LAST_RESPONSE:
                matchedUsers.sort(by: {$0.lastResponseTime > $1.lastResponseTime})
            case DynamicFiltersCache.SORT_ROUTE_PERCENTAGE_DESCENDING:
                matchedUsers.sort(by: { $0.matchPercentage! > $1.matchPercentage!})
                break
            case DynamicFiltersCache.SORT_RIDETAKERS_ROUTE_PERCENTAGE_DESCENDING:
                matchedUsers.sort(by: { $0.matchPercentageOnMatchingUserRoute > $1.matchPercentageOnMatchingUserRoute})
                break
            case DynamicFiltersCache.SORT_POINTS_ASCENDING:
                if rideType == Ride.RIDER_RIDE{
                    matchedUsers.sort(by: { $0.points! > $1.points!})
                }else{
                    matchedUsers.sort(by: { $0.points! < $1.points!})
                }
                break
            case DynamicFiltersCache.SORT_POINTS_DESCENDING:
                matchedUsers.sort(by: { $0.points! > $1.points!})
                break
            case DynamicFiltersCache.SORT_PICK_UP_TIME_IN_ASCENDING:
                if rideType == Ride.RIDER_RIDE{
                    matchedUsers.sort(by: { $0.passengerReachTimeTopickup! < $1.passengerReachTimeTopickup!})
                }else{
                    matchedUsers.sort(by: { $0.pickupTime! < $1.pickupTime!})
                }
                break
            case DynamicFiltersCache.SORT_PICK_UP_TIME_IN_DESCENDING:
                if rideType == Ride.RIDER_RIDE{
                    matchedUsers.sort(by: { $0.passengerReachTimeTopickup! > $1.passengerReachTimeTopickup!})
                }else{
                    matchedUsers.sort(by: { $0.pickupTime! > $1.pickupTime!})
                }
                
                break
            case DynamicFiltersCache.SORT_BASED_ON_PICKUP_POINT_DISTANCE:
                for matchedUser in matchedUsers{
                    matchedUser.walkingDistance = LocationClientUtils.getDistance(fromLatitude: ride?.startLatitude ?? 0, fromLongitude: ride?.startLongitude ?? 0, toLatitude: matchedUser.pickupLocationLatitude ?? 0, toLongitude: matchedUser.pickupLocationLongitude ?? 0)
                }
                matchedUsers.sort(by: { $0.walkingDistance! < $1.walkingDistance!})
                break
            default:
                break
            }
        }
        return matchedUsers
    }
    
    func getApplyedFiltersToCurrentRide(filterStatus: [String : String]?) -> Int{
        guard let status = filterStatus else { return 0 }
        var applyedFilters = 0
        if status[DynamicFiltersCache.ROUTE_POINT_CRITERIA] == DynamicFiltersCache.VIA_START_POINT || status[DynamicFiltersCache.ROUTE_POINT_CRITERIA] == DynamicFiltersCache.VIA_END_POINT{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.USERS_CRITERIA] == DynamicFiltersCache.PREFERRED_USERS_VERIFIED{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.EXISTANCE_CRITERIA] == DynamicFiltersCache.ACTIVE_USERS{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.PARTNERS_CRITERIA] == DynamicFiltersCache.FAVOURITE_PARTNERS{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.VEHICLE_CRITERIA] == DynamicFiltersCache.PREFERRED_VEHICLE_CAR || status[DynamicFiltersCache.VEHICLE_CRITERIA] == DynamicFiltersCache.PREFERRED_VEHICLE_BIKE{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.MINIMUM_RATING_CRITERIA] != nil{
            applyedFilters += 1
        }
        if status[DynamicFiltersCache.GENDER_CRITERIA] == UserDataCache.getInstance()?.getCurrentUserGender(){
           applyedFilters += 1
        }
        return applyedFilters
    }
}
