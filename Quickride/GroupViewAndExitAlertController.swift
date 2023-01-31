//
//  GroupViewAndExitAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/30/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias ViewAndExitActionHandler = (_ result : String) -> Void

class GroupViewAndExitAlertController {
    var alertController : UIAlertController?
    var completionHandler : ViewAndExitActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping ViewAndExitActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func viewAlertAction(){
        let editAlertAction = UIAlertAction(title: Strings.VIEW, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func exitAlertAction(){
        let editAlertAction = UIAlertAction(title: Strings.EXIT, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func addRemoveAlertAction(){
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
        
    }
    func showAlertController(){
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    
}
