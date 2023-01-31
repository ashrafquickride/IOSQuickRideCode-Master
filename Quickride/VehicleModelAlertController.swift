//
//  VehicleModelAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 30/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class VehicleModelAlertController {
    
    typealias selectedVehicleCompletionHandler = (_ vehicle: Vehicle?) -> Void
    var viewController :UIViewController?
    var showTaxi : Bool?
    var vehicleType : String?
  init(viewController :UIViewController,vehicleType : String,showTaxi : Bool){
        self.viewController = viewController
        self.showTaxi = showTaxi
        self.vehicleType = vehicleType
    }
  init(){
    
  }
  
    func displayVehicleModelAlertController(handler : @escaping selectedVehicleCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("displayVehicleModelAlertController()")
      
      var carTypes = [String]()
      if Vehicle.VEHICLE_TYPE_BIKE == vehicleType{
         carTypes = [Vehicle.BIKE_MODEL_SPORTS,Vehicle.BIKE_MODEL_SCOOTER,Vehicle.BIKE_MODEL_REGULAR,Vehicle.BIKE_MODEL_CRUISE]
      }else{
        carTypes = [Vehicle.VEHICLE_MODEL_HATCHBACK,Vehicle.VEHICLE_MODEL_SEDAN,Vehicle.VEHICLE_MODEL_SUV,Vehicle.VEHICLE_MODEL_PREMIUM]
        
      }
      
      
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for i in 0...carTypes.count-1{
          
            let action = UIAlertAction(title: "\(carTypes[i])", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                handler(self.getVehicleObjectForModel(vehicleModel: alert.title!,vehicleType: self.vehicleType!))
            })
            
            optionMenu.addAction(action)
        }
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        
        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.viewController!.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
  func getVehicleObjectForModel(vehicleModel : String?,vehicleType : String) -> Vehicle{
      AppDelegate.getAppDelegate().log.debug("getVehicleObjectForModel()")
    let vehicle = Vehicle()
    
    var defaultClientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    
    if  defaultClientConfiguration == nil{
        defaultClientConfiguration = ClientConfigurtion()
    }
    if vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
        vehicle.vehicleModel = Vehicle.BIKE_MODEL_REGULAR
        vehicle.fare = defaultClientConfiguration!.bikeDefaultFare!
        vehicle.capacity = defaultClientConfiguration!.bikeDefaultCapacity!
    }else{
        vehicle.vehicleModel = Vehicle.VEHICLE_MODEL_HATCHBACK
        vehicle.fare = defaultClientConfiguration!.carDefaultFare
    }
    if vehicleModel != nil{
        vehicle.vehicleModel = vehicleModel!
    }
    if vehicleType == Vehicle.VEHICLE_TYPE_CAR{
        switch vehicle.vehicleModel{
        case Vehicle.VEHICLE_MODEL_HATCHBACK:
            vehicle.capacity = defaultClientConfiguration!.hatchBackCarDefaultCapacity
            break
        case Vehicle.VEHICLE_MODEL_SEDAN:
            vehicle.capacity = defaultClientConfiguration!.sedanCarDefaultCapacity
            break
        case Vehicle.VEHICLE_MODEL_SUV:
            vehicle.capacity = defaultClientConfiguration!.suvCarDefaultCapacity
            break
        case Vehicle.VEHICLE_MODEL_PREMIUM:
            vehicle.capacity = defaultClientConfiguration!.premiumCarDefaultCapacity
            break
        default:
            vehicle.capacity = defaultClientConfiguration!.carDefaultCapacity
            break
            
        }
    }
    return vehicle
    }
}
