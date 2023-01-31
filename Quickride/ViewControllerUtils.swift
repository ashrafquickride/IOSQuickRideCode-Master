    //
//  ViewControllerUtils.swift
//  Quickride
//
//  Created by KNM Rao on 02/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

public class ViewControllerUtils {
  
  public static func displayViewController(currentViewController: UIViewController?, viewControllerToBeDisplayed : UIViewController, animated : Bool) {
    AppDelegate.getAppDelegate().log.debug("displayViewController()")
    
    
    if (currentViewController == nil || currentViewController?.navigationController == nil) {
      // Find the presented VC...
        if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
            if let index =  navController.viewControllers.firstIndex(where: {$0.classForCoder == viewControllerToBeDisplayed.classForCoder}) {
                navController.viewControllers.remove(at: index)
            }
            navController.pushViewController(viewControllerToBeDisplayed, animated: false)
            return
        }
      let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
       
      var containerViewController = appDelegate.window?.rootViewController as? ContainerTabBarViewController
      if containerViewController == nil{
        containerViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as? ContainerTabBarViewController
         let centerNavigationController = UINavigationController(rootViewController: containerViewController!)
        AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
        containerViewController?.setNavigationBar()
      }
      let centerViewController = containerViewController!.centerNavigationController
        if let index = centerViewController?.viewControllers.firstIndex(where: {$0.classForCoder == viewControllerToBeDisplayed.classForCoder}) {
            centerViewController?.viewControllers.remove(at: index)
        }
        centerViewController?.pushViewController(viewControllerToBeDisplayed, animated: false)
    }else {
        if (currentViewController?.navigationController != nil) {
            if let index =  currentViewController?.navigationController?.viewControllers.firstIndex(where: {$0.classForCoder == viewControllerToBeDisplayed.classForCoder}) {
                currentViewController?.navigationController?.viewControllers.remove(at: index)
            }
            currentViewController?.navigationController?.pushViewController(viewControllerToBeDisplayed, animated: false)
        }
      else {
        currentViewController?.present(viewControllerToBeDisplayed, animated: animated, completion: nil)
      }
    }
  }
  
  static func getCenterViewController() -> UIViewController{
    AppDelegate.getAppDelegate().log.debug("getCenterViewController()")
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.window!.rootViewController!
  }
  public static func presentViewController( currentViewController: UIViewController?, viewControllerToBeDisplayed : UIViewController, animated : Bool, completion: (() -> Void)?) {
    var viewController = currentViewController
    AppDelegate.getAppDelegate().log.debug("presentViewController()")
    if viewController == nil{
      
      let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
      viewController = appDelegate.window?.rootViewController
    }
    if Thread.isMainThread == true{
        viewController?.present(viewControllerToBeDisplayed, animated: animated, completion: completion)
      
    }else{
        DispatchQueue.main.sync(){
            viewController?.present(viewControllerToBeDisplayed, animated: animated, completion: completion)
        
      }
    }
    
  }
  
  public static func makeContainerViewController(){
    AppDelegate.getAppDelegate().log.debug("makeContainerViewController()")
    let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
    let centerNavigationController = UINavigationController(rootViewController: routeViewController)
    AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
    
  }

    static func finishViewController(viewController : UIViewController?){
      AppDelegate.getAppDelegate().log.debug("finishViewController()")
        if viewController == nil{
            return
        }
        if viewController!.navigationController != nil{
            viewController?.navigationController?.popViewController(animated: false)
        }else{
            viewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    static func addSubView(viewControllerToDisplay: UIViewController) {
        if ViewControllerUtils.getCenterViewController().navigationController != nil{
            ViewControllerUtils.getCenterViewController().view.addSubview(viewControllerToDisplay.view)
            ViewControllerUtils.getCenterViewController().addChild(viewControllerToDisplay)
        }else if let navigationCOntroller = ViewControllerUtils.getCenterViewController() as? UINavigationController,
                 let displayViewController  = navigationCOntroller.topViewController {
            displayViewController.view.addSubview(viewControllerToDisplay.view)
            displayViewController.addChild(viewControllerToDisplay)
        }else{
            ViewControllerUtils.getCenterViewController().view.addSubview(viewControllerToDisplay.view)
            ViewControllerUtils.getCenterViewController().addChild(viewControllerToDisplay)
        }
        viewControllerToDisplay.view.layoutIfNeeded()
    }
}

