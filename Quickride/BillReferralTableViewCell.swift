//
//  BillReferralTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 3/25/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class BillReferralTableViewCell: UITableViewCell {

    @IBOutlet weak var referralLittie: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    private var delegate: ReferralTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpView(title : String, subTitle: String, delegate: ReferralTableViewCellDelegate){
        self.delegate = delegate
        self.title.text = title
        self.subTitle.text = subTitle
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgrounTapped(_:))))
    }

    @objc func backgrounTapped(_ gesture: UITapGestureRecognizer)  {
        if let delegate = delegate {
            delegate.referNowButtonpressed()
        }
    }
    
}
