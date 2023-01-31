//
//  APayAuthorizeCallbackHandler.swift
//  Quickride
//
//  Created by Admin on 27/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import PWAINSilentPayiOSSDK

protocol AuthorizeSuccessDelegate: class {
    func authorizationSuccess(response:APayAuthorizationResponse)
}

class AmazonPayAuthorizeCallbackHandler : APayAuthorizeCallbackDelegate {
    
    
    var delegate:AuthorizeSuccessDelegate?
    
    func onSuccess(_ response: APayAuthorizationResponse!) {
        if delegate != nil{
            delegate?.authorizationSuccess(response: response);
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
    
    func onCancel(_ error: Error!) {
       UIApplication.shared.keyWindow?.makeToast( Strings.transaction_cancelled, duration: 2.0)
    }
}
