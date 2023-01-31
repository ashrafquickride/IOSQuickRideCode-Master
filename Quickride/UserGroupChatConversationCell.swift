//
//  UserGroupChatConversationCell.swift
//  Quickride
//
//  Created by QuickRideMac on 3/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserGroupChatConversationCell: UITableViewCell{
    
    @IBOutlet weak var unreadMessagesView: UIView!
       
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var groupIcon: UIImageView!
    
    @IBOutlet weak var lastMessage: UILabel!
    
    @IBOutlet weak var unreadMessagesCount: UILabel!
    
    @IBOutlet weak var userImageButton: UIButton!
}
