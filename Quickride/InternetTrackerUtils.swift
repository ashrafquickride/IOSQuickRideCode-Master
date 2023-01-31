//
//  InternetTrackerUtils.swift
//  Quickride
//
//  Created by iDisha on 23/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Reachability

typealias NoConnectionViewDialogueCompletionHandler = (_ isDialogueDisp : Bool)->Void

class InternetTrackerUtils {
    
    var completionHandler : NoConnectionViewDialogueCompletionHandler?
    weak var viewController: UIViewController?
    static var instance : InternetTrackerUtils?
   
    func checkInternetAvailability(viewController: UIViewController, completionHandler : @escaping NoConnectionViewDialogueCompletionHandler){
        self.completionHandler = completionHandler
        self.viewController = viewController
        registerForReachability()
    }
    
    func registerForReachability(){
        let reachability = Reachability()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        if self.viewController == nil {
            return
        }
        if QRReachability.isConnectedToNetwork(){
            for subView in  self.viewController!.view.subviews{
                if let noInternetView = subView as? NoConnectionViewDialogue{
                    noInternetView.removeFromSuperview()
                }
            }
            completionHandler?(true)
        }else{
            let noConnectionView = NoConnectionViewDialogue.loadFromNibNamed(nibNamed: "NoInternetConnectionView", bundle: nil) as! NoConnectionViewDialogue
            noConnectionView.initializeView(errorMessage: Strings.no_internet_connection, image: UIImage(named: "sos_ride_view")!, viewController: viewController!)
            completionHandler?(false)
        }
    }
}
