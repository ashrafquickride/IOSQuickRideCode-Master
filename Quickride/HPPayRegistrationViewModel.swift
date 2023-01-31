//
//  HPPayRegistrationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 03/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
protocol HPPayRegistrationViewModelDelegate {
    func handleSucessResponse()
    func handleFailureResponse(responseObject: NSDictionary?,error : NSError?)
}

class HPPayRegistrationViewModel{
    
    //Variables
    var fuelCardRegistrationReceiver : fuelCardRegistrationReceiver?
    var acceptedTermsAndConditions = false
    
    func initailizeData(fuelCardRegistrationReceiver: @escaping fuelCardRegistrationReceiver){
        self.fuelCardRegistrationReceiver = fuelCardRegistrationReceiver
    }
    func registerHpPayForUser(userId: String,mobileNo: String,salutation: String, firstName: String,lastName: String, dob: String,delegate: HPPayRegistrationViewModelDelegate){
        AccountRestClient.registerHPPay(userId: userId, mobileNo: mobileNo, salutation: salutation, firstName: firstName, lastName: lastName, dob: dob) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                delegate.handleSucessResponse()
            }else{
                delegate.handleFailureResponse(responseObject: responseObject, error: error)
            }
        }
    }
}
