//
//  EndorseCofirmationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorseCofirmationViewModel {

    //MARK: Properties
    var endorsementRequestNotifcationData = EndorsementRequestNotificationData()
    var notication: UserNotification?
    
    //MARK: Initializer
    func initializeData(endorsementRequestNotiifcationData: EndorsementRequestNotificationData, notication: UserNotification) {
        self.notication = notication
        self.endorsementRequestNotifcationData = endorsementRequestNotiifcationData
    }

    //MARK: Methods
    func acceptEndorsementRequest(viewController: UIViewController) {
        QuickRideProgressSpinner.startSpinner()
        ProfileVerificationRestClient.acceptEndorsementRequest(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", requestorUserId: endorsementRequestNotifcationData.userId ?? "0") { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                NotificationCenter.default.post(name: .endorsementRequestAccepted, object: nil)
                NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: self.notication!)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
}
