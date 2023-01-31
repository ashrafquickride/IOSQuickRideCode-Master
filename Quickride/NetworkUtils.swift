//
//  NetworkUtils.swift
//  Quickride
//
//  Created by KNM Rao on 30/09/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import SystemConfiguration
import Alamofire
import CoreTelephony
public class QRReachability{
    public typealias NetworkRecoveryListener = (_ isConnectedToNetwork: Bool) -> Void
    
    
    public static let highlyAvailableHost = "https://www.facebook.com/"
    
    static func isConnectedToNetwork() -> Bool {
        AppDelegate.getAppDelegate().log.debug("isConnectedToNetwork()")
        return NetworkMonitor.shared.isConnected
    }
    
    
    private static func displayNetworkDownCustomErrorAlert(viewController : UIViewController, alertMessage: String) {
        AppDelegate.getAppDelegate().log.debug("displayNetworkDownCustomErrorAlert()")
        DispatchQueue.main.async(execute: { () -> Void in
            
                let netWorkAlert = NetworkErrorDialogue.loadFromNibNamed(nibNamed: "NetworkErrorDialogue") as! NetworkErrorDialogue
                netWorkAlert.initializeDataBeforePresenting(message: Strings.network_issue, actionName: Strings.ok,viewController: viewController, handler: nil)
        
        })
    }
    
    static func  isInternetAvailable(listener : @escaping NetworkRecoveryListener )
    {
        listener(isConnectedToNetwork())
    }
    static func getCellularData() -> String? {
           if #available(iOS 12.0, *) {
              return CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.carrierName
           } else {
               let networkInfo = CTTelephonyNetworkInfo()
               let carrier = networkInfo.subscriberCellularProvider
             return carrier?.carrierName
           }
       }
    
}


public protocol NetworkStatusListener {
    func performNetworkSensitiveOperation(operationCode : Int?)
}

