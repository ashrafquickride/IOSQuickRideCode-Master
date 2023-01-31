//
//  AlertViewUtils.swift
//  Quickride
//
//  Created by KNM Rao on 30/09/15.
// Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

public class MessageDisplay {
  
    public static func displayAlert(messageString: String, viewController: UIViewController?,handler : alertControllerActionHandler?) {
    AppDelegate.getAppDelegate().log.debug("displayAlert()")

    let quickRideCustomAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "QuickRideCustomAlertController") as! QuickRideCustomAlertController
    quickRideCustomAlertController.initializeDataBeforePresentingView(title: nil, isDismissViewRequired : true, message1: messageString, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil,linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, handler: { (result) in
      handler?(result)
    })
   
    if let viewController = viewController {
        viewController.view.addSubview(quickRideCustomAlertController.view!)
        viewController.addChild(quickRideCustomAlertController)
    }else{
        let displayViewController  = (ViewControllerUtils.getCenterViewController() as! UINavigationController).topViewController
        displayViewController?.view.addSubview(quickRideCustomAlertController.view)
        displayViewController?.addChild(quickRideCustomAlertController)
    }
    quickRideCustomAlertController.view!.layoutIfNeeded()
  }
    public static func displayAlert(title : String,messageString: String, viewController: UIViewController,handler : alertControllerActionHandler?) {
    
    AppDelegate.getAppDelegate().log.debug("displayAlert()")
    
    let quickRideCustomAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "QuickRideCustomAlertController") as! QuickRideCustomAlertController
        quickRideCustomAlertController.initializeDataBeforePresentingView(title: title, isDismissViewRequired : false, message1: messageString, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : nil,linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, handler: { (result) in
      handler?(result)
    })
    viewController.view.addSubview(quickRideCustomAlertController.view!)
    viewController.addChild(quickRideCustomAlertController)
    
    quickRideCustomAlertController.view!.layoutIfNeeded()
  }
  static func displayAlertWithTextField(title : String,positiveLable : String,negativeLable : String){
    
    let rejectReasonAlert = UIAlertController(title: Strings.do_u_have_reason, message: nil, preferredStyle: .alert)
    rejectReasonAlert.view.tintColor = Colors.alertViewTintColor
    rejectReasonAlert.addTextField(configurationHandler: {
      textField -> Void in
      textField.textColor = UIColor.black
      
      
    })
    rejectReasonAlert.addAction(UIAlertAction(title: Strings.skip, style: .cancel , handler: nil))
    
    rejectReasonAlert.addAction(UIAlertAction(title: Strings.confirm, style: .default , handler: {
      Void -> Void in
      
    }))
  }
  public static func displayErrorAlert(responseError : ResponseError, targetViewController : UIViewController?,handler : alertControllerActionHandler?){
    AppDelegate.getAppDelegate().log.debug("displayErrorAlert()")
    if targetViewController != nil{
      if Thread.isMainThread == true{
        displayAlert(messageString: ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError), viewController: targetViewController!, handler: handler)
      }else{
        DispatchQueue.main.sync(){
            displayAlert(messageString: ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError), viewController: targetViewController!, handler: handler)
        }
      }
    }
  }
  public static func displayErrorAlertWithAction(title: String?, isDismissViewRequired : Bool, message1 : String?,message2 : String?, positiveActnTitle : String?, negativeActionTitle : String?,linkButtonText: String?,viewController: UIViewController?,handler : alertControllerActionHandler?) {
    
    let quickRideCustomAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "QuickRideCustomAlertController") as! QuickRideCustomAlertController
    quickRideCustomAlertController.initializeDataBeforePresentingView(title: title, isDismissViewRequired : isDismissViewRequired, message1: message1, message2: message2, positiveActnTitle: positiveActnTitle,negativeActionTitle : negativeActionTitle,linkButtonText: linkButtonText, msgWithLinkText: nil, isActionButtonRequired: true, handler: handler)
       
    if let viewController = viewController {
        viewController.view.addSubview(quickRideCustomAlertController.view!)
        viewController.addChild(quickRideCustomAlertController)
    }else{
        
        let displayViewController  = (ViewControllerUtils.getCenterViewController() as! UINavigationController).topViewController
        displayViewController?.view.addSubview(quickRideCustomAlertController.view)
        displayViewController?.addChild(quickRideCustomAlertController)
    }
    quickRideCustomAlertController.view!.layoutIfNeeded()
  }
    
    public static func displayInfoDialogue(title: String?, message : String?,viewController: UIViewController?)
    {

        let infoDialogue = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "InfoDialogue") as! InfoDialogue
        infoDialogue.initializeDataBeforePresentingView(title: title, message: message)
        if let viewController = viewController {
            viewController.view.addSubview(infoDialogue.view!)
            viewController.addChild(infoDialogue)
        }else{
             let displayViewController  = (ViewControllerUtils.getCenterViewController() as! UINavigationController).topViewController
            displayViewController?.view.addSubview(infoDialogue.view)
            displayViewController?.addChild(infoDialogue)
        }
        infoDialogue.view!.layoutIfNeeded()
    }
    public static func displayAlertWithAction(title: String?, isDismissViewRequired : Bool, message1 : String?,message2 : String?, positiveActnTitle : String?, negativeActionTitle : String?,linkButtonText: String?,msgWithLinkText:String?, isActionButtonRequired: Bool, viewController: UIViewController?,handler : alertControllerActionHandler?) {
       
        let quickRideCustomAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "QuickRideCustomAlertController") as! QuickRideCustomAlertController
        quickRideCustomAlertController.initializeDataBeforePresentingView(title: title, isDismissViewRequired : isDismissViewRequired, message1: message1, message2: message2, positiveActnTitle: positiveActnTitle,negativeActionTitle : negativeActionTitle,linkButtonText: linkButtonText, msgWithLinkText: msgWithLinkText, isActionButtonRequired: isActionButtonRequired, handler: handler)
        if let viewController = viewController {
            viewController.view.addSubview(quickRideCustomAlertController.view!)
            viewController.addChild(quickRideCustomAlertController)
        }else{
             let displayViewController  = (ViewControllerUtils.getCenterViewController() as! UINavigationController).topViewController
            displayViewController?.view.addSubview(quickRideCustomAlertController.view)
            displayViewController?.addChild(quickRideCustomAlertController)
        }
        quickRideCustomAlertController.view!.layoutIfNeeded()
    }
    
    public static func displayInfoViewAlert(title : String?, titleColor: UIColor?, message : String,infoImage : UIImage?,imageColor : UIColor?,isLinkBtnRequired : Bool,linkTxt : String?,linkImage : UIImage?,buttonTitle: String?,handler : @escaping infoDialogueDisplayActionCompletionHandler){
        let infoDialogue = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "InfoDialogueDisplayView") as! InfoDialogueDisplayView
        infoDialogue.initializeDataBeforePresentingView(title: title, titleColor: titleColor, message: message, infoImage: infoImage, imageColor: imageColor, isLinkBtnRequired: isLinkBtnRequired, linkTxt: linkTxt, linkImage: linkImage, buttonTitle: buttonTitle, handler: handler)
        let displayViewController  = ViewControllerUtils.getCenterViewController()
        
        if displayViewController.navigationController != nil {
            displayViewController.navigationController!.view.addSubview(infoDialogue.view!)
            displayViewController.navigationController!.addChild(infoDialogue)
        }
        else
        {
            displayViewController.view.addSubview(infoDialogue.view)
            displayViewController.addChild(infoDialogue)
        }
        infoDialogue.view!.layoutIfNeeded()
    }
   
}
