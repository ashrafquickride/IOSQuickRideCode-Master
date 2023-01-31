//
//  PersonalChatTableViewSenderCell.swift
//  Quickride
//
//  Created by Halesh on 16/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PersonalChatTableViewSenderCell: ChatTableViewSenderCell {
    
    var conversationMessage: ConversationMessage?
    
    func initializePersonalSenderCellData(conversationMessage: ConversationMessage, view: UIView){
        self.conversationMessage = conversationMessage
        self.view = view
        
        if(conversationMessage.latitude != 0 && conversationMessage.longitude != 0){
            lblMsgSend.textColor = UIColor(netHex: 0x2191F3)
            showOnMapLbl.isHidden = false
            showOnMapLblHeight.constant = 15
            showOnMapTopSpaceConstraint.constant = 10
            chatViewBackgGround.isUserInteractionEnabled = true
            showOnMapLbl.isUserInteractionEnabled = true
            chatViewBackgGround.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PersonalChatTableViewSenderCell.showLocationOnMap(_:))))
            showOnMapLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PersonalChatTableViewSenderCell.showLocationOnMap(_:))))
        }else{
            lblMsgSend.textColor = UIColor.black
            showOnMapLbl.isHidden = true
            showOnMapLblHeight.constant = 0
            showOnMapTopSpaceConstraint.constant = 3
        }
        lblMsgSend.text = conversationMessage.message
        lblMsgSend.preferredMaxLayoutWidth = view.frame.width - 120
        lblSendTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: conversationMessage.time!,timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
        setMessageStatus(status: conversationMessage.msgStatus!,imageView: imgMsgStatus)
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackgGround, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackgGround, borderWidth: 1, color: UIColor(netHex: 0xcce7ce))
    }
    
    func setMessageStatus(status : Int,imageView : UIImageView)
    {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        imageView.isHidden = false
        if ConversationMessage.MSG_STATUS_FAILED == status{
            imageView.image = UIImage(named: "Red_Exclamation_Dot")
            
        }else if ConversationMessage.MSG_STATUS_DELIVERED == status{
            imageView.image = UIImage(named: "groupchat_delivered")
            
        }else if ConversationMessage.MSG_STATUS_READ == status{
            imageView.image = UIImage(named: "groupchat_read")
            
        }else if(ConversationMessage.MSG_STATUS_SENT == status){
            imageView.image = UIImage(named: "groupChat_sent")
            
        }else{
            imageView.isHidden = true
        }
    }
    
    @objc override func showLocationOnMap(_ sender : UITapGestureRecognizer)
    {
        let message = self.conversationMessage
        let urlString = "https://maps.google.com/maps?q=\(message!.latitude),\(message!.longitude)"
        navigateToMap(urlString: urlString)
    }
}
