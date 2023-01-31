//
//  APayChargeCallbackHandler.swift
//  Quickride
//
//  Created by Admin on 27/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import PWAINSilentPayiOSSDK
protocol ChargeCallSuccessDelegate: class {
    func chargeCallSuccess(response: APayChargeResponse)
}
class AmazonPayChargeCallbackHandler : APayChargeCallbackDelegate {
    
    var delegate:ChargeCallSuccessDelegate?
    
    func onSuccess(_ response: APayChargeResponse!) {
        if response.status == "SUCCESS"{
            delegate?.chargeCallSuccess(response: response)
        }
    }
    func onFailure(_ error: Error!) {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: nil, message2: error.localizedDescription, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
    }
    func onMobileSDKError(_ error: Error!) {
         MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: nil, message2: error.localizedDescription, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
        
    }
    func onNetworkUnavailable() {
         MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: nil, message2: Strings.NetworkConnectionNotAvailable_Msg, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
        
    }
    func onCancel() {
    }
}
