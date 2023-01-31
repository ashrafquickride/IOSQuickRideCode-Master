//
//  VehicleRelatedValidations.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 02/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class VehicleRelatedValidations {
    static func validateFieldsAndReturnErrorMsg(offeredSeats : String , vehicleNumber : String ,vehicleFare : String,makeAndCategory : String , vehicleModel : String, vehicleType : String) -> String? {
        AppDelegate.getAppDelegate().log.debug("validateFieldsAndReturnErrorMsgIfAny()")
        if (Vehicle.isOfferedSeatsValid(offeredSeats: offeredSeats) == false) {
            return Strings.enter_valid_vehicle_capacity
        }
        
        if vehicleNumber.isEmpty || Vehicle.isVehicleNumberValid(selectedNumber: vehicleNumber) == false
        {
            return Strings.enter_valid_vehicle_number
        }
        
        if vehicleFare.isEmpty == true || Vehicle.isVehicleFareValid(selectedFare: vehicleFare) == false {
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            return String(format: Strings.enter_valid_vehicle_fare, arguments: [StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.vehicleMaxFare)])
        }
        if !makeAndCategory.isEmpty, makeAndCategory.count > 70{
            return Strings.makeAndCategory_error
        }
        if (vehicleModel.isEmpty == false && vehicleType == Vehicle.VEHICLE_TYPE_BIKE) {
            if (offeredSeats.isEmpty == true || (Int(offeredSeats) == nil || Int(offeredSeats)! > Vehicle.BIKE_MAX_CAPACITY)) {
                return Strings.bike_capacity_exceeds_max_value
            }
        }
        
        
        return nil
    }
}
