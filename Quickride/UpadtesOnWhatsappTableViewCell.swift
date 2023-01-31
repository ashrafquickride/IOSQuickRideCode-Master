//
//  UpadtesOnWhatsappTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class UpadtesOnWhatsappTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var allowButton: QRCustomButton!
    @IBOutlet weak var allowButtonTopconstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func allowButtonTapped(_ sender: Any) {
        let whatsAppPreferences = WhatsAppPreferences(userId: Double(UserDataCache.getInstance()?.userId ?? "") ?? 0,enableWhatsAppPreferences: true)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences, viewController: nil, responseHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
                UIApplication.shared.keyWindow?.makeToast(Strings.preference_changes_saved)
                self.titleLabel.text = Strings.whatsapp_enable_message
                self.infoLabel.text = Strings.whatsapp_enable_message_info
                self.allowButton.isHidden = true
                self.allowButtonTopconstraint.constant = 0
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        })
    }
}
