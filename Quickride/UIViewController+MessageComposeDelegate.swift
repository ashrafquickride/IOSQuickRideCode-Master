//
//  UIViewController+MessageComposeDelegate.swift
//  Quickride
//
//  Created by Quick Ride on 7/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

extension UIViewController : MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
           controller.dismiss(animated: false, completion: nil)
       }
}
