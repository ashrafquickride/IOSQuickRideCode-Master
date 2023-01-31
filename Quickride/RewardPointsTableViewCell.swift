//
//  RewardPointsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 15/09/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RewardPointsTableViewCell: UITableViewCell {

    @IBOutlet weak var totalRefundPoints: UILabel!
    
    @IBAction func howToUseTapped(_ sender: Any) {
        
        let referalPointsUsageViewController = UIStoryboard(name: StoryBoardIdentifiers.accountsb_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ReferalPointsUsageViewController") as! ReferalPointsUsageViewController


        referalPointsUsageViewController.modalPresentationStyle = .overCurrentContext
        self.parentViewController?.navigationController?.view.addSubview(referalPointsUsageViewController.view)
        self.parentViewController?.navigationController?.addChild(referalPointsUsageViewController)
        
    }
}
