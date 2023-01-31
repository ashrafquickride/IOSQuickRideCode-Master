//
//  CentralChatTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 19/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CentralChatTableViewCell: UITableViewCell {
    
    //MARK:Outlets
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var unreadCountView: UIView!
    
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var lastUpdatedTimeLabel: UILabel!
    
    @IBOutlet weak var sourceApplicationView: UIView!
    
    func initializeChatCell(centralChat: CentralChat,contactGender: String?){
        userNameLabel.text = centralChat.name
        lastMessageLabel.text = centralChat.lastMessage
        let lastUpdateTimeinNSDate = DateUtils.getNSDateFromTimeStamp(timeStamp: centralChat.lastUpdateTime)
        let timeDiff = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: lastUpdateTimeinNSDate, date2: NSDate())
        if timeDiff < 1{
            lastUpdatedTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: centralChat.lastUpdateTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        }else{
            lastUpdatedTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: centralChat.lastUpdateTime, timeFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
        }
        if let count = centralChat.unreadCount, count > 0{
            unreadCountView.isHidden = false
            unreadCountLabel.text = String(count)
            lastUpdatedTimeLabel.textColor = UIColor(netHex: 0x007AFF)
        }else{
            unreadCountView.isHidden = true
            lastUpdatedTimeLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        if centralChat.chatType == CentralChat.PERSONAL_CHAT{
            if let gender = contactGender{
                ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: centralChat.imageURI, gender: gender,imageSize: ImageCache.DIMENTION_TINY)
            }else{
                userImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
            }
        }else if centralChat.chatType == CentralChat.USER_GROUP_CHAT{
            if let imageURI = centralChat.imageURI{
                ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: imageURI, placeHolderImg: UIImage(named: "group_circle"),imageSize: ImageCache.DIMENTION_TINY)
            }else{
                userImageView.image = UIImage(named : "group_circle")
            }
        }else if centralChat.chatType == CentralChat.RIDE_JOIN_GROUP_CHAT{
            userImageView.image = UIImage(named: "group_chat_icon")
        }
        if centralChat.sourceApplication == ConversationMessage.SOURCE_APPLICATION_P2P{
            sourceApplicationView.isHidden = false
        }else{
            sourceApplicationView.isHidden = true
        }
    }
}
