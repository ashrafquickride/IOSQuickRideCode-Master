//
//  RouteSelectionGuideOneViewController.swift
//  Quickride
//
//  Created by KNM Rao on 06/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RouteSelectionGuideOneViewController: UIViewController {
  
  
  
  @IBOutlet var searchIcon: UIImageView!
  var listener : RouteCustomizationGuideListener?
  
  func initializeDataBeforePresenting(listener : RouteCustomizationGuideListener){
    self.listener = listener
  }
  override func viewDidLoad() {
    
    let image = UIImage(named: "search_icon")!.withRenderingMode(.alwaysTemplate)
    searchIcon.image = image
    searchIcon.tintColor = UIColor(netHex :0x1E90FF)
  }
  
  @IBAction func nextButtonAction(_ sender: Any) {
    self.view.removeFromSuperview()
    self.removeFromParent()
    listener?.userSeenFirstGuide()
  }
}
