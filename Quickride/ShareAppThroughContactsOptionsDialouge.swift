//
//  ShareAppThroughContactsOptionsDialouge.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 24/01/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import MessageUI

class ShareAppThroughContactsOptionsDialouge : ModelViewController
{
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var messageButtonCenterConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var whatAppLabel: UILabel!
   
    @IBOutlet weak var whatAppButton: UIButton!
    
    var message : String = ""
    var contactsToInvite = [Contact]()
    var isWhatAppHidden : Bool = false
    
    func initializeDataBeforePresentingView(contactsToInvite : [Contact], isWhatAppHidden : Bool){
        self.contactsToInvite = contactsToInvite
        self.isWhatAppHidden = isWhatAppHidden
  }
    override func viewDidLoad() {
        super.viewDidLoad()
         definesPresentationContext = true
        message = String(format: Strings.share_and_earn_msg, arguments: [UserDataCache.getInstance()!.getReferralCode(),AppConfiguration.application_link_ios_url,AppConfiguration.application_link_android_url,UserDataCache.getInstance()!.userProfile!.userName!])
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareAppThroughContactsOptionsDialouge.dismissViewClicked(_:))))
        if isWhatAppHidden{
            whatAppButton.isHidden = true
            whatAppLabel.isHidden = true
            messageButtonCenterConstrait.setMultiplier(multiplier: 1)
        }
        else{
            whatAppButton.isHidden = false
            whatAppLabel.isHidden = false
            messageButtonCenterConstrait.setMultiplier(multiplier: 0.6)
        }
      
    }

    @objc func dismissViewClicked(_ sender: UITapGestureRecognizer)
    {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
 
    @IBAction func smsClicked(_ sender: Any)
    {
        self.sendSMSToContacts(contacts: self.contactsToInvite)
    }
    
    func sendSMSToContacts(contacts : [Contact])
    {
        let messageViewConrtoller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            var filteredContacts = [Contact]()
            if contacts.count > 20
            {
                filteredContacts = Array(contacts.prefix(upTo: 20))
            }
            else
            {
                filteredContacts = contacts
            }
            self.contactsToInvite = Array(self.contactsToInvite.dropFirst(filteredContacts.count))
            var contactNos : [String] = [String]()
            for contact in filteredContacts{
                contactNos.append(contact.contactId!)
            }
            messageViewConrtoller.recipients = contactNos
            messageViewConrtoller.messageComposeDelegate = self
            self.present(messageViewConrtoller, animated: false, completion: nil)
        }
    }
    override func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        AppDelegate.getAppDelegate().log.debug("messageComposeViewController()")
        switch result {
        case .cancelled :
            UIApplication.shared.keyWindow?.makeToast( Strings.sending_sms_cancelled)
            controller.dismiss(animated: false, completion: nil)
            
        case .sent :
            controller.dismiss(animated: false, completion: nil)
            self.sendSMSToContacts(contacts: self.contactsToInvite)
            if self.contactsToInvite.isEmpty
            {
                UIApplication.shared.keyWindow?.makeToast( Strings.sms_sent)
                self.view?.removeFromSuperview()
                self.removeFromParent()
            }
        case .failed :
            UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_failed)
            controller.dismiss(animated: false, completion: nil)
            
        }
        if result != MessageComposeResult.sent
        {  
            self.view?.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    
    @IBAction func whatAppClicked(_ sender: Any) {
        let urlStringEncoded = StringUtils.encodeUrlString(urlString: message)
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded)")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            MessageDisplay.displayAlert(messageString: Strings.can_not_find_whatsup, viewController: self,handler: nil)
        }
    }
 
    
    
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
