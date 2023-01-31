//
//  RouteSelectionGuideTwoViewController.swift
//  Quickride
//
//  Created by KNM Rao on 06/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RouteSelectionGuideTwoViewController: UIViewController {
  

  @IBOutlet var locationPinView: UIView!
  
  var listener : RouteCustomizationGuideListener?
  
  func initializeDataBeforePresenting(listener : RouteCustomizationGuideListener){
    self.listener = listener
  }
  
  override func viewDidLoad() {
    ViewCustomizationUtils.addCornerRadiusToView(view: locationPinView, cornerRadius: locationPinView.bounds.size.width/2.0)
  }
  @IBAction func doneAction(_ sender: Any) {
    self.view.removeFromSuperview()
    self.removeFromParent()
    listener?.userSeenSecondGuide()
  }
}
