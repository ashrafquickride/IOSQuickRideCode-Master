//
//  RiskResolveTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RiskResolveTableViewCell: UITableViewCell {

    
    @IBOutlet weak var customerRiskReasons: UILabel!
    @IBOutlet weak var riskResolveType: UILabel!
    @IBOutlet weak var markAsResolveBtn: UIButton!
//    @IBOutlet weak var stackViewHeightConstant: UIStackView!
    
    @IBOutlet weak var markAsResolveHeightCon: NSLayoutConstraint!
    var complitionHandler: customerResolveRiskCompletionHandler?
    var rideRiskAssessment: RideRiskAssessment?
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
     
    
    func toSetUpUi(rideRiskAssessment: RideRiskAssessment, complitionHandler: @escaping customerResolveRiskCompletionHandler){
        self.complitionHandler = complitionHandler
        self.rideRiskAssessment = rideRiskAssessment
        customerRiskReasons.text = rideRiskAssessment.description
        riskResolveType.text =  rideRiskAssessment.status
        if rideRiskAssessment.status == "Closed" {
            riskResolveType.textColor = UIColor(netHex: 0x00B557)
            markAsResolveBtn.isHidden = true
            markAsResolveHeightCon.constant = 0
        } else {
            riskResolveType.textColor = UIColor(netHex: 0x000000)
            markAsResolveBtn.isHidden = false
            markAsResolveHeightCon.constant = 10
        }
    }
    
   
    @IBAction func markAsResolveTapped(_ sender: Any) {
      markAsResolveBtn.isHidden = true
        riskResolveType.text = "Closed"
        markAsResolveHeightCon.constant = 0
        riskResolveType.textColor = UIColor(netHex: 0x00B557)
        complitionHandler?(true)
        
    }
    
    
}
