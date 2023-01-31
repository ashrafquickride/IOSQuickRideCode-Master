//
//  BillInsurenceViewTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 11/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol BillInsurenceViewTableViewCellDelegate {
    func insuranceClaimedBtnTapped()
}

class BillInsurenceViewTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var insuranceIdShowingLabel: UILabel!
    @IBOutlet weak var insuranceView: UIView!
    @IBOutlet weak var insuranceViewHeightConstraint: NSLayoutConstraint!
    
    private var delegate : BillInsurenceViewTableViewCellDelegate?
    
    func initializeInsuranceView(showInsuranceViw: Bool,claimRefId : String?,delegate: BillInsurenceViewTableViewCellDelegate){
        self.delegate = delegate
        if showInsuranceViw{
            insuranceView.isHidden = false
            insuranceViewHeightConstraint.constant = 100
            insuranceIdShowingLabel.text = claimRefId
        }else{
            insuranceViewHeightConstraint.constant = 0
            insuranceView.isHidden = true
        }
    }
    
    @IBAction func insuranceClaimClicked(_ sender: UIButton) {
        delegate?.insuranceClaimedBtnTapped()
    }
}
