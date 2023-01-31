//
//  ReferralTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 10/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol ReferralTableViewCellDelegate: class {
    func referNowButtonpressed()
    func howItWorksPressed()
    func shareButtonPressed()
}

class ReferralTableViewCell: UITableViewCell {
    //Outlets
    
    @IBOutlet weak var quickRideCardView: QuickRideCardView!
    @IBOutlet weak var referDetailsLabel: UILabel!
    @IBOutlet weak var persentageLbl: UILabel!
    @IBOutlet weak var refferalCodeLabel: UILabel!
    @IBOutlet weak var referButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var referViewLeadindConstant: NSLayoutConstraint!
    @IBOutlet weak var referViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var referViewTralingConstant: NSLayoutConstraint!
    @IBOutlet weak var referViewBottomConstant: NSLayoutConstraint!
    weak var delegate: ReferralTableViewCellDelegate?
    
    

    func updateCellData(referralPoints: String?, percentageNumber: String?, delegate: ReferralTableViewCellDelegate) {
        
        referDetailsLabel.text = String(format: Strings.points_given, arguments: [referralPoints ?? ""])
        persentageLbl.text = String(format: Strings.points_percentage, arguments: [percentageNumber ?? ""])
        self.delegate = delegate
        refferalCodeLabel.text = UserDataCache.getInstance()?.getReferralCode()
    }
    
    @IBAction func copyreferalCodeBtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = UserDataCache.getInstance()?.getReferralCode()
        UIApplication.shared.keyWindow?.makeToast( Strings.refferral_code_copied)
    }
    
    //MARK: Actions
    @IBAction func referBtnPressed(_ sender: UIButton) {
        delegate?.referNowButtonpressed()
    }
    
    @IBAction func howItWorkBtnPressed(_ sender: UIButton) {
        delegate?.howItWorksPressed()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.shareButtonPressed()
    }
    
}
