//
//  CenterViewController.swift
//  Quickride
//
//  Created by KNM Rao on 06/10/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import UIKit



@objc
protocol CenterViewControllerDelegate {
  optional func toggleLeftPanel()
  optional func collapseSidePanels()
}

class CenterViewController: UIViewController {
  
  var delegate: CenterViewControllerDelegate?
  
  override func viewDidLoad() {
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func showSidePanel(sender: AnyObject) {
    delegate?.toggleLeftPanel?()
  }
}
