//
//  GroupsViewAlertController.swift
//  Quickride
//
//  Created by rakesh on 3/8/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias GroupViewAlertControllerActionHandler = (_ result : String) -> Void

class GroupsViewAlertController{
    
    var alertController : UIAlertController?
    var completionHandler : GroupViewAlertControllerActionHandler?
    var viewController :UIViewController?
    
      init(viewController :UIViewController,completionHandler : @escaping GroupViewAlertControllerActionHandler){
       self.viewController = viewController
       self.completionHandler = completionHandler
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
        
      }
    
    func showAlertController(){
        AppDelegate.getAppDelegate().log.debug("showAlertController()")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("addRemoveAlertAction()")
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
    }
    
    func addGroupAlertAction(){
        AppDelegate.getAppDelegate().log.debug("addGroupAlertAction()")
        let addGroupUIAlertAction = UIAlertAction(title: Strings.create_group, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(addGroupUIAlertAction)
    }
    
    func joinGroupAlertAction(){
        AppDelegate.getAppDelegate().log.debug("joinGroupAlertAction()")
        let addGroupUIAlertAction = UIAlertAction(title: Strings.join_group, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(addGroupUIAlertAction)
    }
    
    func deleteGroupMemberAlertAction(){
        AppDelegate.getAppDelegate().log.debug("deleteGroupMemberAlertAction()")
        let deleteGrpMemberAlertAction = UIAlertAction(title: Strings.delete_member, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(deleteGrpMemberAlertAction)
    }
    
    func confirmMembershipToGrpAlertAction(){
    AppDelegate.getAppDelegate().log.debug("confirmMembershipToGrpAlertAction()")
        let confirmMembershipToGrpAlertAction = UIAlertAction(title: Strings.confirm, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(confirmMembershipToGrpAlertAction)

    }
    
    func rejectMembershipToGrpAlertAction(){
        AppDelegate.getAppDelegate().log.debug("rejectMembershipToGrpAlertAction()")
        let rejectMembershipToGrpAlertAction = UIAlertAction(title: Strings.REJECT, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(rejectMembershipToGrpAlertAction)
        
    }

}
