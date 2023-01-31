//
//  ConversationContactCell.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ConversationContactCell : UITableViewCell{
    
    @IBOutlet weak var quickrideBadge: UIImageView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var messageStatusImage: UIImageView!
    
    @IBOutlet weak var lastMsgLabel: UILabel!
    
    @IBOutlet weak var contactNameBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var statusImageWidthConstraint: NSLayoutConstraint!
    
    func initializeViews(contact : Contact, fromBlockedUsers : Bool){
        AppDelegate.getAppDelegate().log.debug("contact: \(contact) \(fromBlockedUsers)")
        self.contactName.text = contact.contactName
        contactNameBottomSpaceConstraint.constant = 13
        if fromBlockedUsers{
            self.callButton.isHidden = true
        }
    }
}
