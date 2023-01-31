//
//  EndorsementListTableViewCellViewModel.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class EndorsementListTableViewCellViewModel {
    
    //MARK: Properties
    var endorsableUser: EndorsableUser?
    var endorsementVerificationInfo: EndorsementVerificationInfo?
    
    //MARK: Initializer
    func initialiseData(endorsableUser: EndorsableUser?, endorsementVerificationInfo: EndorsementVerificationInfo?) {
        self.endorsableUser = endorsableUser
        self.endorsementVerificationInfo = endorsementVerificationInfo
    }
    
    //MARK: Methods
    func requestForEndorsement() {
        var user = endorsableUser
        if user == nil && endorsementVerificationInfo != nil {
            user = EndorsableUser(endorsementVerificationInfo: endorsementVerificationInfo!)
        }
        if let endorsableUser = user {
            QuickRideProgressSpinner.startSpinner()
            ProfileVerificationRestClient.requestForEndorsement(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", endorsableUserObject: endorsableUser.toJSONString()!) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    endorsableUser.endorsementStatus = Strings.initiated
                    UIApplication.shared.keyWindow?.makeToast( Strings.request_sent.lowercased().capitalizingFirstLetter())
                    NotificationCenter.default.post(name: .endoserRequestSucceded, object: self)
                } else {
                    ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: nil, handler: nil)
                }
            }
        }
    }
    
    func getErrorMessageForCall(endorsableUser: EndorsableUser) -> String?{
        if endorsableUser.enableChatAndCall == false {
            return Strings.chat_and_call_disable_msg
        } else if endorsableUser.enableChatAndCall == true && endorsableUser.callSupport == UserProfile.SUPPORT_CALL_NEVER {
            return Strings.no_call_please_msg
        } else {
            return nil
        }
    }
    
    func getErrorMessageForChat(endorsableUser: EndorsableUser) -> String?{
        if endorsableUser.enableChatAndCall == false {
            return Strings.chat_and_call_disable_msg
        }
        return nil
    }
}

