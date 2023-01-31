//
//  PersonalChatTableViewReceiveCell.swift
//  Quickride
//
//  Created by Halesh on 16/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PersonalChatTableViewReceiveCell: ChatTableViewReceiveCell{
    
    var conversationMessage: ConversationMessage?
    
    func initializeReceivedData(conversationMessage: ConversationMessage, viewController: UIViewController){
        self.viewController = viewController
        self.conversationMessage = conversationMessage
        
        if(conversationMessage.latitude != 0 && conversationMessage.longitude != 0){
            lblMessage.textColor = UIColor(netHex: 0x2191F3)
            showOnMapLabel.isHidden = false
            showOnMapLblHeight.constant = 15
            showOnMapTopConstraint.constant = 10
            chatViewBackground.isUserInteractionEnabled = true
            showOnMapLabel.isUserInteractionEnabled = true
            chatViewBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PersonalChatTableViewReceiveCell.showLocationOnMap(_:))))
            showOnMapLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PersonalChatTableViewReceiveCell.showLocationOnMap(_:))))
        }else{
            lblMessage.textColor = UIColor.black
            showOnMapLabel.isHidden = true
            showOnMapLblHeight.constant = 0
            showOnMapTopConstraint.constant = 3
        }
        lblMessage.text = conversationMessage.message
        lblMessage.preferredMaxLayoutWidth = viewController.view.frame.width - 120
        lblTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: conversationMessage.time!,timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
        if conversationMessage.msgStatus != ConversationMessage.MSG_STATUS_READ{
            let messageAckSenderTask = MessageAckSenderTask(conversationMessage: conversationMessage, status: ConversationMessage.MSG_STATUS_READ)
            messageAckSenderTask.publishMessage()
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackground, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackground, borderWidth: 1, color: UIColor(netHex: 0xf0f0f0))
    }
    
    @objc override func showLocationOnMap(_ sender : UITapGestureRecognizer){
        let message = self.conversationMessage
        let urlString = "https://maps.google.com/maps?q=\(message!.latitude),\(message!.longitude)"
        navigateToMap(urlString: urlString)
    }
}
