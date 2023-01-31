//
//  UserGroupChatReceiveTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 23/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UserGroupChatReceiveTableViewCell: ChatTableViewReceiveCell {

    func initailseChatData(chatMessage: GroupConversationMessage?){
        lblMessage.text = chatMessage?.message
        lblTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: chatMessage?.time,timeFormat: DateUtils.DATE_FORMAT_dd_MMM_H_mm)
        txtName.text = chatMessage?.senderName
        lblMessage.preferredMaxLayoutWidth = UIApplication.shared.keyWindow!.frame.width - 120
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackground, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackground, borderWidth: 1, color: UIColor(netHex: 0xf0f0f0))
    }
}
