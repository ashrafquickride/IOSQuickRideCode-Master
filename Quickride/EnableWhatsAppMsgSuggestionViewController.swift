//
//  EnableWhatsAppMsgSuggestionViewController.swift
//  Quickride
//
//  Created by Halesh on 08/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
typealias whatsAppPreferenceRecieveHandler = (_ enableWhatsAppMessages: Bool) -> Void

class EnableWhatsAppMsgSuggestionViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    
    var handler : whatsAppPreferenceRecieveHandler?
    
    func initializeDataInView(handler : whatsAppPreferenceRecieveHandler?){
        self.handler = handler
    }
    override func viewDidLoad() {
    backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EnableWhatsAppMsgSuggestionViewController.backGroundViewTapped(_:))))
    }
    
    @IBAction func AllowBtnTapped(_ sender: Any){
        let whatsAppPreferences = WhatsAppPreferences(userId: Double(QRSessionManager.getInstance()!.getUserId())!,enableWhatsAppPreferences: true)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences, viewController: self, responseHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
                UIApplication.shared.keyWindow?.makeToast( Strings.preference_changes_saved)
                self.handler!(true) 
                self.view.removeFromSuperview()
                self.removeFromParent()
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    @objc func backGroundViewTapped(_ sender : UITapGestureRecognizer){
        self.removeSuperView()
    }
    @IBAction func LaterBtnTapped(_ sender: Any) {
        self.removeSuperView()
    }
    
    func removeSuperView(){
        self.handler!(false)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
