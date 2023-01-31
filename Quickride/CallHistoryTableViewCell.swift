//
//  CallHistoryTableViewCell.swift
//  Quickride
//
//  Created by Admin on 09/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CallHistoryTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var callStatusLabel: UILabel!
    @IBOutlet weak var callStatusImageView: UIImageView!
    @IBOutlet weak var callDateLabel: UILabel!
    
    //MARK: CellLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Methods
    func setData(callHistory: CallHistory) {
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: callHistory.imageUri, gender: callHistory.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)

        userName.text = callHistory.partnerName
        if callHistory.status == CallHistory.INCOMING {
            callStatusLabel.text = Strings.incoming
            callStatusImageView.image = UIImage(named: "incoming_call_arrow")
        } else {
            callStatusLabel.text = Strings.outgoing
            callStatusImageView.image = UIImage(named: "outgoing_call_arrow")
        }
        callDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: callHistory.calltime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    }

}
