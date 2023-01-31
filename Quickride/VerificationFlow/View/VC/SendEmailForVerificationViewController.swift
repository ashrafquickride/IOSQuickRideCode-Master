//
//  SendEmailForVerificationViewController.swift
//  Quickride
//
//  Created by Vinutha on 04/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class SendEmailForVerificationViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var sendEmailToLabel: UILabel!
    
    //MARK: Properties
    private var handler: clickActionCompletionHandler?
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        setupUI()
    }
    //MARK: Methods
    func initialiseData(handler: @escaping clickActionCompletionHandler) {
        self.handler = handler
    }
    
    private func setupUI() {
        sendEmailToLabel.text = String(format: Strings.complete_org_verification, arguments: [ConfigurationCache.getObjectClientConfiguration().autoVerificationMail])
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertViewTapped(_:))))
    }
    private func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.emailView.center.y -= self.emailView.bounds.height
            }, completion: nil)
    }
    
    @objc private func dismissAlertViewTapped(_ gesture : UITapGestureRecognizer) {
        removeView(action: nil)
    }
    
    private func removeView(action: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.emailView.center.y += self.emailView.bounds.height
            self.emailView.layoutIfNeeded()
        }) { (value) in
            self.handler?(action)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    //MARK: Actions
    @IBAction func sendEmailClicked(_ sender: UIButton) {
        var contactNumber = ""
        var userName = ""
        if let phoneNumber = UserDataCache.getInstance()?.getUser()?.contactNo, let name = UserDataCache.getInstance()?.getUser()?.userName {
            contactNumber = StringUtils.getStringFromDouble(decimalNumber: phoneNumber)
            userName = name
        }
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: String(format: Strings.verify_profile_subject, arguments: [contactNumber]) , toRecipients: [ConfigurationCache.getObjectClientConfiguration().autoVerificationMail],ccRecipients: [],mailBody: String(format: Strings.verify_profile_mail_body, arguments: [userName]))
    }
}

//MARK: Mail compose delegate
extension SendEmailForVerificationViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
        removeView(action: Strings.success)
    }
}
