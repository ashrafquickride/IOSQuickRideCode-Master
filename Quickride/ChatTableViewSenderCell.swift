//
//  ChatTableViewSenderCell.swift
//  Quickride
//
//  Created by Anki on 24/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ChatTableViewSenderCell: UITableViewCell {
    
    @IBOutlet weak var lblSendTime: UILabel!
    
    @IBOutlet weak var lblMsgSend: UILabel!
    
    @IBOutlet weak var showOnMapLbl: UILabel!
    
    @IBOutlet weak var showOnMapLblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chatViewBackgGround: UIView!
    
    @IBOutlet weak var imgMsgStatus: UIImageView!
    
    @IBOutlet weak var msgStatusImageView: UIImageView!
    
    @IBOutlet weak var showOnMapTopSpaceConstraint: NSLayoutConstraint!
    
    var groupChatMessage : GroupChatMessage?
    var view: UIView?
    
    func initializeSenderCellData(groupChatMessage: GroupChatMessage,view: UIView){
        self.view = view
        self.groupChatMessage = groupChatMessage
        
        lblMsgSend.text = groupChatMessage.message
        lblMsgSend.preferredMaxLayoutWidth = view.frame.width - 120
        lblSendTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: groupChatMessage.chatTime,timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackgGround, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackgGround, borderWidth: 1, color: UIColor(netHex: 0xcce7ce))
        if(groupChatMessage.latitude != 0 && groupChatMessage.longitude != 0)
        {
            lblMsgSend.textColor = UIColor(netHex: 0x2191F3)
            showOnMapLbl.isHidden = false
            showOnMapLblHeight.constant = 15
            showOnMapTopSpaceConstraint.constant = 10
            chatViewBackgGround.isUserInteractionEnabled = true
            showOnMapLbl.isUserInteractionEnabled = true
            chatViewBackgGround.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatTableViewSenderCell.showLocationOnMap(_:))))
            showOnMapLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatTableViewSenderCell.showLocationOnMap(_:))))
        }else{
            lblMsgSend.textColor = UIColor.black
            showOnMapLbl.isHidden = true
            showOnMapLblHeight.constant = 0
            showOnMapTopSpaceConstraint.constant = 3
        }
    }
    
    @objc func showLocationOnMap(_ sender : UITapGestureRecognizer)
    {
        let message = self.groupChatMessage
        let urlString = "https://maps.google.com/maps?q=\(message!.latitude),\(message!.longitude)"
        navigateToMap(urlString: urlString)
    }
    func navigateToMap(urlString: String){
        let url = URL(string: urlString)
        if url != nil && UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast("Can't use Google maps in this device.", point: CGPoint(x: self.view!.frame.size.width/2, y: self.view!.frame.size.height-200), title: nil, image: nil, completion: nil)
        }
    }
}
