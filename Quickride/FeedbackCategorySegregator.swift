//
//  FeedbackCategorySegregator.swift
//  Quickride
//
//  Created by Quick Ride on 4/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
struct FeedbackCategorySegregator {
    
    static let CATEGORY_SCHEDULE = "Schedule"
    static let CATEGORY_DRIVER = "Driver & Vehicle"
    static let CATEGORY_SUPPORT = "Support"
    static let CATEGORY_FARE = "Fare"
    static let CATEGORY_OTHER = "Other"
    static let CATEGORY_RIDE_GIVER = "Ride Giver"
    static let CATEGORY_RIDE_TAKER = "Ride Taker"
    static let CATEGORY_APP_ISSUES = "App Related"
    
    static let taxiFeedbackCategoryMap: [String: [String]] = [
        FeedbackCategorySegregator.CATEGORY_SCHEDULE:["Delayed Pickup","Other"],
        FeedbackCategorySegregator.CATEGORY_DRIVER: [ "Driver was rude",
                                                   "Driver didn't take the right route",
                                                   "Unsafe/Rash Driving",
                                                   "Vehicle is not clean",
                                                   "Ac not working / not on",
                                                   "Driver stopped the car in between",
                                                   "Driver asked extra money",
                                                   "Other"],
        FeedbackCategorySegregator.CATEGORY_SUPPORT: ["Didn't answer the call",
                                                      "Didn't get the satisfactory response",
                                                      "Other"],
        FeedbackCategorySegregator.CATEGORY_FARE: ["Fare was high",
                                                   "Fare was not transparent",
                                                      "Other"],
        FeedbackCategorySegregator.CATEGORY_OTHER: ["Other"]
    ]
   static let categoryImageMap : [String : UIImage]  = [FeedbackCategorySegregator.CATEGORY_SCHEDULE: UIImage(named: "feedback_category_schedule")!,
                FeedbackCategorySegregator.CATEGORY_DRIVER: UIImage(named: "feedback_category_driver")!,
                FeedbackCategorySegregator.CATEGORY_SUPPORT: UIImage(named: "feedback_category_support")!,
                FeedbackCategorySegregator.CATEGORY_FARE: UIImage(named: "feedback_category_fare")!,
                FeedbackCategorySegregator.CATEGORY_OTHER: UIImage(named: "feedback_category_other")!,
                FeedbackCategorySegregator.CATEGORY_RIDE_GIVER: UIImage(named: "feedback_category_ride_giver")!,
                FeedbackCategorySegregator.CATEGORY_RIDE_TAKER: UIImage(named: "feedback_category_ride_giver")!,
                FeedbackCategorySegregator.CATEGORY_APP_ISSUES: UIImage(named: "feedback_category_app_related")!]
    
    func segregate(etiquette : [RideEtiquette], rideType: String) -> [String: [RideEtiquette]] {
        var dict = [String: [RideEtiquette]]()
        for item in etiquette {
            guard let category = item.category else {
                continue
            }
            if rideType == Ride.RIDER_RIDE && item.category ==  FeedbackCategorySegregator.CATEGORY_RIDE_GIVER {
                continue
            }
            if rideType == Ride.PASSENGER_RIDE && item.category == FeedbackCategorySegregator.CATEGORY_RIDE_TAKER {
                continue
            }
            if var value = dict[category] {
                value.append(item)
                dict[category] = value
            }else {
                dict[category] = [item]
            }
        }
        if let both = dict["Both"] {
            if rideType == Ride.RIDER_RIDE {
                if var rideTaker = dict[FeedbackCategorySegregator.CATEGORY_RIDE_TAKER] {
                    rideTaker.append(contentsOf: both)
                    dict[FeedbackCategorySegregator.CATEGORY_RIDE_TAKER] = rideTaker
                }
            }else if rideType == Ride.PASSENGER_RIDE{
                if var giver = dict[FeedbackCategorySegregator.CATEGORY_RIDE_GIVER] {
                    giver.append(contentsOf: both)
                    dict[FeedbackCategorySegregator.CATEGORY_RIDE_GIVER] = giver
                }
            }
        }
        dict.removeValue(forKey: "Both")
        return dict
    }
    func sortFeedbackCategories(_ arr : [String]) -> [String]{
        let order = [FeedbackCategorySegregator.CATEGORY_SCHEDULE ,
                            FeedbackCategorySegregator.CATEGORY_DRIVER ,
                            FeedbackCategorySegregator.CATEGORY_RIDE_GIVER ,
                            FeedbackCategorySegregator.CATEGORY_RIDE_TAKER ,
                            FeedbackCategorySegregator.CATEGORY_SUPPORT ,
                            FeedbackCategorySegregator.CATEGORY_FARE ,
                            FeedbackCategorySegregator.CATEGORY_APP_ISSUES,
                            FeedbackCategorySegregator.CATEGORY_OTHER
                            ]
        var sortedArray = [String]()
        for orderItem in order{
            if let index = arr.firstIndex(of: orderItem){
                sortedArray.append(arr[index])
            }
        }
        return sortedArray
    }
    
    
}
