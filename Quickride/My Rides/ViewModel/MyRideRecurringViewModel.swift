//
//  MyRideRecurringViewModel.swift
//  Quickride
//
//  Created by Bandish Kumar on 31/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MyRideRecurringViewModel {
    //MARK: Properties
    var regularRide: [RegularRide]?
    var isHomeToOfficeAdress = false
    var isOfficeToHomeAdress = false
    //MARK: Methods
    func getRegularRideDetails() -> [RegularRide]? {
        return regularRide
    }
    
    func getRideStatus(for regularRide: RegularRide) -> Bool {
        switch regularRide.status {
        case Ride.RIDE_STATUS_SCHEDULED: fallthrough
        case Ride.RIDE_STATUS_STARTED: fallthrough
        case Ride.RIDE_STATUS_REQUESTED:
            return true
        default:
            return false
        }
    }
    
    func setRecurringDay(for regularRide: RegularRide) -> [String]{
        var recurringRideDay: [String] = []
        
        if let _ = regularRide.monday  {
            recurringRideDay.append(Strings.mon)
        }
        if let _ = regularRide.tuesday {
            recurringRideDay.append(Strings.tue)
        }
        if let _ = regularRide.wednesday {
            recurringRideDay.append(Strings.wed)
        }
        if let _ = regularRide.thursday {
            recurringRideDay.append(Strings.thu)
        }
        if let _ = regularRide.friday {
            recurringRideDay.append(Strings.fri)
        }
        if let _ = regularRide.saturday {
            recurringRideDay.append(Strings.sat)
        }
        if let _ = regularRide.sunday {
            recurringRideDay.append(Strings.sun)
        }
        return recurringRideDay
    }
    
    func checkHomeAndOfficeAddressForRegularRide() -> (Bool, Bool) {
        var isHomeAndOfficeAvailable = false
        var isOfficeAndHomeAvailable = false
        if let regularRide = regularRide {
            for data in regularRide {
                if data.startAddress == UserDataCache.getInstance()?.getHomeLocation()?.address, data.endAddress == UserDataCache.getInstance()?.getOfficeLocation()?.address, isHomeAndOfficeAvailable == false {
                    isHomeAndOfficeAvailable = true
                    continue
                }
                if data.startAddress == UserDataCache.getInstance()?.getOfficeLocation()?.address, data.endAddress == UserDataCache.getInstance()?.getHomeLocation()?.address, isOfficeAndHomeAvailable == false {
                    isOfficeAndHomeAvailable = true
                    continue
                }
            }
        }
        return (isHomeAndOfficeAvailable, isOfficeAndHomeAvailable)
    }
    
    
    func checkHomeAndOfficeAddressForParticularRide(regularRide: RegularRide) -> Bool {
        if regularRide.startAddress == UserDataCache.getInstance()?.getHomeLocation()?.address, regularRide.endAddress == UserDataCache.getInstance()?.getOfficeLocation()?.address {
            return true
        }
        return false
    }
    
    func checkOfficeAndHomeAddressForParticularRide(regularRide: RegularRide) -> Bool {
        if regularRide.startAddress == UserDataCache.getInstance()?.getOfficeLocation()?.address, regularRide.endAddress == UserDataCache.getInstance()?.getHomeLocation()?.address {
            return true
        }
        return false
    }
    
    func getHomeAndOfficeRegularRideDetails() -> Int {
        let HomeAndOfficeStatus = checkHomeAndOfficeAddressForRegularRide()
        if HomeAndOfficeStatus.0, HomeAndOfficeStatus.1 {
            return 0
        }
        if !HomeAndOfficeStatus.0, !HomeAndOfficeStatus.1 {
            if let _ = regularRide {
                regularRide?.append(RegularRide())
                regularRide?.append(RegularRide())
            }
            return 2
        }
        regularRide?.append(RegularRide())
        return 1
    }
}
