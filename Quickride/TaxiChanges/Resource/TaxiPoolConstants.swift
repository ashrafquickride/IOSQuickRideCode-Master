//
//  TaxiPoolConstants.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class TaxiPoolConstants {
    
    
    
    public static let SHARE_TYPE_EXCLUSIVE = "Exclusive";
    public static let SHARE_TYPE_ANY_SHARING = "AnySharing";

    public static let TAXI_VEHICLE_CATEGORY_HATCH_BACK = "Hatchback";
    public static let TAXI_VEHICLE_CATEGORY_SEDAN = "Sedan";
    public static let TAXI_VEHICLE_CATEGORY_SUV = "SUV";
    public static let TAXI_VEHICLE_CATEGORY_CROSS_OVER = "CrossOver";// 5 seat SUVs like Creta/Brezza
    public static let TAXI_VEHICLE_CATEGORY_SUV_LUXURY = "SUV_LUXURY";
    public static let TAXI_VEHICLE_CATEGORY_TT = "TT";// Tempo traveller
    public static let TAXI_VEHICLE_CATEGORY_ANY = "ANY";
    public static let TAXI_VEHICLE_CATEGORY_BIKE = "Bike";
    public static let TAXI_VEHICLE_CATEGORY_AUTO = "Auto";

    public static let PAYMENT_MODE_WALLET = "Wallet";
    public static let PAYMENT_MODE_CASH = "Cash";
    public static let PAYMENT_MODE_WALLET_AND_CASH = "WalletAndCash";

    public static let FARE_TYPE_FIXED = "FIXED";
    public static let FARE_TYPE_FLEXIBLE = "FLEXIBLE";

    public static let TRIP_TYPE_OUTSTATION = "Outstation";
    public static let TRIP_TYPE_LOCAL = "Local";
    public static let TRIP_TYPE_RENTAL = "Rental";
    public static let TRIP_TYPE_DRIVER_REQUEST = "DriverRequest";
    
    public static let TAXI_TYPE_CAR = "Car";
    public static let TAXI_TYPE_BIKE = "Bike";
    public static let TAXI_TYPE_AUTO = "Auto";
    
    
    public static let SHARE_TYPE_ONE_TO_THREE = "OneToThreeSharing"
    public static let SHARE_TYPE_TWO_TO_THREE = "TwoToThreeSharing"
    public static let SHARE_TYPE_ONE_TO_TWO = "OneToTwoSharing"
    public static let SHARE_TYPE_TWO_SHARING = "TwoSharing"
    public static let SHARE_TYPE_THREE_SHARING = "ThreeSharing"
    public static let SHARE_TYPE_FOUR_SHARING = "FourSharing"
    

    
    public static let JOURNEY_TYPE_ONE_WAY = "OneWay"
    public static let JOURNEY_TYPE_ROUND_TRIP = "RoundTrip"
    
    public static let ROUTE_CATEGORY_CITY_TO_CITY = "city_to_city_taxi"
    public static let ROUTE_CATEGORY_CITY_TO_AIRPORT = "city_to_airport_taxi"
    public static let ROUTE_CATEGORY_AIRPORT_TO_CITY = "airport_to_city_taxi"
    public static let ROUTE_CATEGORY_OUTSTATION = "outstation_taxi"
    
    static let CANCELLED_BY_PARTNER = "PARTNER"
    static let CANCELLED_BY_CUSTOMER = "CUSTOMER"
    static let CANCELLED_BY_SYSTEM = "SYSTEM"
    static let CANCELLED_BY_OPERATOR = "OPERATOR"
    
    static let PENALIZED_TO_PARTNER = "PARTNER"
    static let PENALIZED_TO_CUSTOMER = "CUSTOMER"
    static let PENALIZED_TO_NONE = "NONE"
    
    public static let SCHEDULE_RETURN_TRIP = "SCHEDULE_RETURN_TRIP"
    public static let UPDATE_TRIP = "UPDATE_TRIP"
    public static let Taxi = "Taxi"
}
