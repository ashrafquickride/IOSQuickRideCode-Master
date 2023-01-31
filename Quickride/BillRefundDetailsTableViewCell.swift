//
//  BillRefundDetailsTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 09/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol BillRefundDetailsTableViewCellDelegate {
    func clickedOnSupportMail()
}

class BillRefundDetailsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var sentDateLabel: UILabel!
    @IBOutlet weak var rejectApprovedView: UIView!
    @IBOutlet weak var rejectApprovedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rejectedOrApprovedLabel: UILabel!
    @IBOutlet weak var rejectedOrApprovedBGView: UIView!
    @IBOutlet weak var rejecetdReasonLabel: UILabel!
    @IBOutlet weak var rejectedOrApprovedDateLabel: UILabel!
    @IBOutlet weak var supportmailLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var rejecetdOrApprovedInfoLabel: UILabel!
    @IBOutlet weak var supportmailButton: UIButton!
    
    private var delegate: BillRefundDetailsTableViewCellDelegate?
    
    func initializeRefundDetails(refundRequest: RefundRequest?,delegate: BillRefundDetailsTableViewCellDelegate){
        self.delegate = delegate
        reasonLabel.text = String(format: Strings.refund_reason, arguments: [(refundRequest?.reason ?? "-")])
        idLabel.text = Strings.id + String(refundRequest?.invoiceId ?? 0)
        sentDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequest?.requestTime, timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
        
        switch refundRequest?.status {
        case RefundRequest.REQUEST_STATUS_REJECTED:
            rejectApprovedView.isHidden = false
            rejectApprovedViewHeightConstraint.constant = 130
            rejecetdReasonLabel.text = String(format: Strings.refund_reason, arguments: [(refundRequest?.rejectReason ?? "-")])
            rejectedOrApprovedLabel.text = Strings.rejecetd
            rejectedOrApprovedLabel.textColor = UIColor(netHex: 0xE20000)
            rejectedOrApprovedDateLabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequest?.rejectedTime, timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
            rejectedOrApprovedBGView.backgroundColor = UIColor(netHex: 0xE20000).withAlphaComponent(0.2)
            rejecetdOrApprovedInfoLabel.text = Strings.rejecetd_info
            supportmailLabel.isHidden = false
            supportmailButton.isHidden = false
            progressView.isHidden = false
        case RefundRequest.REQUEST_STATUS_APPROVED:
            rejectApprovedView.isHidden = false
            rejectApprovedViewHeightConstraint.constant = 130
            rejecetdReasonLabel.isHidden = true
            rejectedOrApprovedLabel.text = Strings.approved
            rejectedOrApprovedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequest?.approvedTime, timeFormat: DateUtils.DATE_FORMAT_d_MMM_H_mm)
            rejectedOrApprovedBGView.backgroundColor = UIColor(netHex: 0x00B557).withAlphaComponent(0.2)
            rejecetdOrApprovedInfoLabel.text = Strings.approved_info
            rejectedOrApprovedLabel.textColor = UIColor(netHex: 0x00B557)
            supportmailLabel.isHidden = true
            supportmailButton.isHidden = true
            progressView.isHidden = false
        default:
            rejectApprovedView.isHidden = true
            rejectApprovedViewHeightConstraint.constant = 0
            progressView.isHidden = true
            
        }
    }
    @IBAction func supportMailTapped(_ sender: UIButton) {
        delegate?.clickedOnSupportMail()
    }
}
