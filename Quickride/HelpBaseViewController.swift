//
//  HelpBaseViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 16/05/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI
import UIKit

class HelpBaseViewController: UIViewController,MFMailComposeViewControllerDelegate
{
  @IBOutlet weak var versionNumber: UILabel!
  
  var clientConfiguration : ClientConfigurtion?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      versionNumber.text = Strings.version+" "+version
    }
    clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    
    if clientConfiguration == nil{
        clientConfiguration = ClientConfigurtion()
    }
  }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
  }
  
}
