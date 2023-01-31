//
//  PendingDueHelpViewController.swift
//  Quickride
//
//  Created by HK on 15/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class PendingDueHelpViewController: UIViewController {

    @IBOutlet weak var supoortContactNumberLabel: UILabel!
    @IBOutlet weak var supportMailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        supoortContactNumberLabel.text = clientConfiguration.callQuickRideForSupport
        supportMailLabel.text = AppConfiguration.support_email
    }

    @IBAction func mailButtonTapped(_ sender: Any) {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController:  self, subject: "", toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func contactButtonTapped(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        AppUtilConnect.callSupportNumber(phoneNumber: clientConfiguration.callQuickRideForSupport, targetViewController: self)
    }
}
//MARK: OUtlets
extension PendingDueHelpViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
