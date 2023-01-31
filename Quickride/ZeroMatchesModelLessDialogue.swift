//
//  ZeroMatchesModelLessDialogue.swift
//  Quickride
//
//  Created by Vinutha on 5/16/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class ZeroMatchesModelLessDialogue: UIView {
    
    @IBOutlet weak var modelLessDialogueBackgroundView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var inviteText: UILabel!
    
    func initializeViews(message: String, actionText : String){
        AppDelegate.getAppDelegate().log.debug("initializeViews()")
        modelLessDialogueBackgroundView.layer.cornerRadius = 5.0
        messageLabel.text = message
        inviteText.text = actionText
    }
    
}

