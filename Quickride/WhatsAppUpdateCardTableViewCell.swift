//
//  WhatsAppUpdateCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import ObjectMapper

class WhatsAppUpdateCardTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var whatsAppUpdateView: UIView!
    @IBOutlet weak var getUpdatesLabel: UILabel!
    @IBOutlet weak var allowUpdatesLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var whatsappSwitch: UISwitch!
    
    func initialiseWhatsappStatus(){
        if let whatsAppPreferences = UserDataCache.getInstance()?.getLoggedInUserWhatsAppPreferences(), whatsAppPreferences.enableWhatsAppPreferences {
            whatsappSwitch.setOn(true, animated: true)
            iconImage.image = UIImage(named: "whatsapp_icon_small")
        }else{
            whatsappSwitch.setOn(false, animated: true)
            iconImage.image = UIImage(named: "whatsapp_disbale")
        }
    }
    
    @IBAction func switchTapped(_ sender: Any) {
        let whatsAppPreferences = WhatsAppPreferences(userId: Double(QRSessionManager.getInstance()?.getUserId() ?? "") ?? 0,enableWhatsAppPreferences: whatsappSwitch.isOn)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences, viewController: nil, responseHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
                UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
                self.initialiseWhatsappStatus()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        })
    }
    
}
