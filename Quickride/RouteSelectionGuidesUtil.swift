//
//  RouteSelectionGuidesUtil.swift
//  Quickride
//
//  Created by KNM Rao on 06/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol RouteCustomizationGuideListener{
  func userSeenFirstGuide()
  func userSeenSecondGuide()
}

class RouteSelectionGuidesUtil : RouteCustomizationGuideListener {
  var viewController : UIViewController?
  func checkAndDisplayUserGuide(viewController :UIViewController){
    self.viewController = viewController
    displayGuideScreenOne()
  }
  func displayGuideScreenOne(){
    let routeSelectionGuideOneViewController = UIStoryboard(name: "RouteSelection",bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionGuideOneViewController") as! RouteSelectionGuideOneViewController
    routeSelectionGuideOneViewController.initializeDataBeforePresenting(listener: self)
    ViewControllerUtils.addSubView(viewControllerToDisplay: routeSelectionGuideOneViewController)
    routeSelectionGuideOneViewController.view!.layoutIfNeeded()
  }
  func displayGuideScreenTwo(){
    let routeSelectionGuideTwoViewController = UIStoryboard(name: "RouteSelection",bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionGuideTwoViewController") as! RouteSelectionGuideTwoViewController
    routeSelectionGuideTwoViewController.initializeDataBeforePresenting(listener: self)
    ViewControllerUtils.addSubView(viewControllerToDisplay: routeSelectionGuideTwoViewController)
    routeSelectionGuideTwoViewController.view!.layoutIfNeeded()
  }
  
  func userSeenFirstGuide(){
    displayGuideScreenTwo()
  }
  func userSeenSecondGuide(){
    SharedPreferenceHelper.storeRouteSelectionGuideStatus(flag: true)
  }
}
