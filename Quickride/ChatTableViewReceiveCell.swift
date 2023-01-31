//
//  ChatTableViewReceiveCell.swift
//  Quickride
//
//  Created by Anki on 22/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ChatTableViewReceiveCell: UITableViewCell {
    
    @IBOutlet weak var txtName: UILabel!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var imgProfileImage: UIImageView!
    
    @IBOutlet weak var showOnMapLabel: UILabel!
    
    @IBOutlet weak var showOnMapLblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chatViewBackground: UIView!
    
    @IBOutlet weak var showOnMapTopConstraint: NSLayoutConstraint!
    
    
    weak var viewController: UIViewController?
    var groupChatMessage : GroupChatMessage?
    
    func initializeReceivedCellData(rideParticipants:[RideParticipant], groupChatMessage: GroupChatMessage?,viewController: UIViewController,isImageHideRequire: Bool){
        self.viewController = viewController
        self.groupChatMessage = groupChatMessage
        
        lblMessage.text = groupChatMessage?.message
        lblMessage.preferredMaxLayoutWidth = viewController.view.frame.width - 120
        lblTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: groupChatMessage?.chatTime,timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackground, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackground, borderWidth: 1, color: UIColor(netHex: 0xf0f0f0))
        if isImageHideRequire{
            txtName.text = ""
            txtName.isHidden = true
            imgProfileImage.isHidden = true
        }else{
            txtName.isHidden = false
            imgProfileImage.isHidden = false
            txtName.text = groupChatMessage?.userName
            let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: groupChatMessage!.phonenumber, rideParticipants: rideParticipants)
            if rideParticipant == nil{
                imgProfileImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
            }
            else{
                imgProfileImage.image = ImageCache.getInstance().getDefaultUserImage(gender: rideParticipant!.gender!)
                ImageCache.getInstance().setImageToView(imageView: self.imgProfileImage, imageUrl: rideParticipant!.imageURI, gender: rideParticipant!.gender!,imageSize: ImageCache.DIMENTION_TINY)
            }
        }
        if(groupChatMessage!.latitude != 0 && groupChatMessage!.longitude != 0)
        {
            lblMessage.textColor = UIColor(netHex: 0x2191F3)
            showOnMapLabel.isHidden = false
            showOnMapLblHeight.constant = 15
            showOnMapTopConstraint.constant = 10
            chatViewBackground.isUserInteractionEnabled = true
            showOnMapLabel.isUserInteractionEnabled = true
            chatViewBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatTableViewReceiveCell.showLocationOnMap(_:))))
            showOnMapLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatTableViewReceiveCell.showLocationOnMap(_:))))
        }
        else
        {
            showOnMapTopConstraint.constant = 3
            lblMessage.textColor = UIColor.black
            showOnMapLabel.isHidden = true
            showOnMapLblHeight.constant = 0
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: chatViewBackground, cornerRadius: 15.0)
        ViewCustomizationUtils.addBorderToView(view: chatViewBackground, borderWidth: 1, color: UIColor(netHex: 0xf0f0f0))
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
            UIApplication.shared.keyWindow?.makeToast("Can't use Google maps in this device.", point: CGPoint(x: viewController!.view.frame.size.width/2, y: viewController!.view.frame.size.height-200), title: nil, image: nil, completion: nil)
        }
    }
}
