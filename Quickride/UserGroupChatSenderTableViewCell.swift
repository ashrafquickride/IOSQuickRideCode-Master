//
//  UserGroupChatSenderTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 23/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UserGroupChatSenderTableViewCell: ChatTableViewSenderCell {

    func initializeChatData(chatMessage: GroupConversationMessage?){
        lblMsgSend.text = chatMessage?.message
        lblSendTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: chatMessage?.time,timeFormat: DateUtils.DATE_FORMAT_dd_MMM_H_mm)
        lblMsgSend.preferredMaxLayoutWidth = UIApplication.shared.keyWindow!.frame.width - 120
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackgGround, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackgGround, borderWidth: 1, color: UIColor(netHex: 0xcce7ce))
    }

}
