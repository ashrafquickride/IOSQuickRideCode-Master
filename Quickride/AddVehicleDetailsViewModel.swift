//
//  AddVehicleDetailsViewModel.swift
//  Quickride
//
//  Created by Admin on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AddVehicleDetailsViewModel{
    
    var isFromSignUpFlow = true
    
    init(isFromSignUpFlow: Bool) {
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    init(){
    }
    
    func createVehicle(vehicle : Vehicle,viewController : UIViewController,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        ProfileRestClient.createVehicle(params: vehicle.getParamsMap(), targetViewController: viewController, completionHandler: handler)
    }
    
    func updateVehicle(vehicle : Vehicle,viewController : UIViewController,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        ProfileRestClient.updateVehicle(params: vehicle.getParamsMap(), targetViewController: viewController, completionHandler: handler)
    }
    
}
