//
//  NotificationWithActionTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 09/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NotificationWithActionTableViewCell: UITableViewCell {
    @IBOutlet weak var iboNotificationIcon: UIImageView!
    @IBOutlet weak var iboDetail: UILabel!
    
    @IBOutlet weak var iboTimeStamp: UILabel!
    
    @IBOutlet weak var iboTitle: UILabel!
    
    @IBOutlet var positiveButton: UIButton!
    
    @IBOutlet var negativeButton: UIButton!
    
    @IBOutlet var neutralButton: UIButton!
    
    @IBOutlet var notifictionRowBackGround: UIView!
    
    @IBOutlet var actionsView: UIView!
    
    @IBOutlet weak var positiveActnImage: UIImageView!
    
    @IBOutlet weak var negativeActnImage: UIImageView!
    
    @IBOutlet weak var neutralActnImage: UIImageView!
    
    @IBOutlet weak var positiveButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var negativeButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var neutralButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var moderatorImageView: UIImageView!
    @IBOutlet weak var moderatorImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var moderatorTitleView: UIView!
    @IBOutlet weak var moderatorTitleViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializePositiveActnBtn(actionName : String)
    {
        self.positiveButton.setTitle(actionName, for: UIControl.State.normal)
        self.positiveButton.layer.borderColor = UIColor(netHex: 0xdddddd).cgColor
        self.positiveButton.layer.borderWidth = 1.0
        self.positiveButton.layer.cornerRadius = 3.0
    }
    func initializeNegativeActnBtn(actionName : String)
    {
        self.negativeButton.setTitle(actionName, for: UIControl.State.normal)
        self.negativeButton.layer.borderColor = UIColor(netHex: 0xdddddd).cgColor
        self.negativeButton.layer.borderWidth = 1.0
        self.negativeButton.layer.cornerRadius = 3.0
    }
    func initializeNeutralActnBtn(actionName : String)
    {
        self.neutralButton.setTitle(actionName, for: UIControl.State.normal)
        self.neutralButton.layer.borderColor = UIColor(netHex: 0xdddddd).cgColor
        self.neutralButton.layer.borderWidth = 1.0
        self.neutralButton.layer.cornerRadius = 3.0
    }
    func setNotificationIconAndTitle(notificationHandler : NotificationHandler?, notification : UserNotification)
    {
        notificationHandler?.setNotificationIcon(clientNotification: notification, imageView: self.iboNotificationIcon)
        if notification.title != nil && notification.description != nil{
            self.iboDetail.text = notification.title!+". "+"\n"+notification.description!
        }else{
            AppDelegate.getAppDelegate().log.debug("Notification description is nil")
            self.iboDetail.text = notification.title
        }
    }
}
