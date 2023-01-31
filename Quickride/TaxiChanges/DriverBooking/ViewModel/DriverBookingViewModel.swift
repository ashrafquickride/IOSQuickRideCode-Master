//
//  DriverBookingViewModel.swift
//  Quickride
//
//  Created by Ashutos on 01/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DriverBookingViewModel {
    
    var startLocation: Location?
    var endLocation: Location?
    var journeyType:String?
    var vehicleType: String?
    var startTime: Double?
    var linkedWalletBalances: [LinkedWalletBalance?] = []
    
    init(startLocation: Location, endLocation: Location,journeyType:String,vehicleType: String,startTime: Double) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.journeyType = journeyType
        self.vehicleType = vehicleType
        self.startTime = startTime
    }
    
    func isWalletLinkedOrQrAccountHasBalance() -> Bool {
        let minDriverBookAmount = ConfigurationCache.getObjectClientConfiguration().driverAdvanceBookingAmount
        if let account = UserDataCache.getInstance()?.userAccount,Int((account.balance ?? 0)) > minDriverBookAmount{
            return true
        }else if  UserDataCache.getInstance()?.getDefaultLinkedWallet() != nil{
            return true
        }else{
            return false
        }
    }
    
    func getDefaultLinkedWalletBalance(walletType: String,completionHandler: @escaping(_ result: Bool)->()) {
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), types: walletType,viewController: nil, handler: { [weak self] (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self?.linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"]) ?? []
                if !(self?.linkedWalletBalances.isEmpty ?? false) {
                    completionHandler(true)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        })
    }
    
    func bookDriver(completionHandler: @escaping(_ result: Bool)->()) {
        guard let startLocation = startLocation, let endLocation = endLocation, let startTime = startTime,let vehicleType = vehicleType,let journeyType = journeyType else {return}
        TaxiPoolRestClient.bookDriver(startTime: startTime, startAddress: startLocation.shortAddress ?? "", startLatitude: startLocation.latitude, startLongitude: startLocation.longitude, endLatitude: endLocation.latitude, endLongitude: endLocation.longitude, endAddress: endLocation.shortAddress ?? "", vehicleType: vehicleType, journeyType: journeyType) {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                completionHandler(true)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
}
