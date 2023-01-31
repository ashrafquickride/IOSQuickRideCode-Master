//
//  LevelTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LevelTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var requiredAndReferredDoneLabel: UILabel!
    @IBOutlet weak var currentLavelAndNeedReferralView: UIView!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var currentLavelAndNeedReferralViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var levelBenefits: UILabel!
    @IBOutlet weak var levelBenefitsTableView: UITableView!
    @IBOutlet weak var levelBenefitsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedImage: UIImageView!
    
    //MARK: Variables
    private var referralLevel: ReferralLevel?
    
    func initializeLevelCellData(referralLevel: ReferralLevel,index: Int){
        self.referralLevel = referralLevel
        backGroundView.backgroundColor = referralLevel.backGroundColor
        levelLabel.text = String(format: Strings.category_level, arguments: [String(index)])
        levelBenefits.text = String(format: Strings.level_benefits, arguments: [String(index)])
        levelImage.image = referralLevel.levelImage
        if referralLevel.userLevel > index{
            completedImage.isHidden = false
            requiredAndReferredDoneLabel.isHidden = true
            currentLavelAndNeedReferralView.isHidden = true
            currentLavelAndNeedReferralViewHeightConstraint.constant = 0
        }else if referralLevel.userLevel == index{
            completedImage.isHidden = true
            requiredAndReferredDoneLabel.isHidden = false
            requiredAndReferredDoneLabel.text = String(format: Strings.referrals_done, arguments: [String(referralLevel.totalReferredCount)])
            currentLavelAndNeedReferralView.isHidden = false
            currentLavelAndNeedReferralViewHeightConstraint.constant = 30
            currentLavelAndNeedReferralView.backgroundColor = .white
            currentLevelLabel.text = Strings.your_current_level
        }else if (referralLevel.userLevel + 1) == index{
            completedImage.isHidden = true
            requiredAndReferredDoneLabel.isHidden = false
            requiredAndReferredDoneLabel.text = String(format: Strings.required_referrals, arguments: [String(referralLevel.requiredReferral)])
            currentLavelAndNeedReferralView.isHidden = false
            currentLavelAndNeedReferralViewHeightConstraint.constant = 30
            currentLavelAndNeedReferralView.backgroundColor = UIColor(netHex: 0xE8D100)
            let needReferrals = referralLevel.requiredReferral - referralLevel.totalReferredCount
            currentLevelLabel.text = String(format: Strings.need_referrals, arguments: [String(needReferrals)])
        }else{
           currentLavelAndNeedReferralView.isHidden = true
            currentLavelAndNeedReferralViewHeightConstraint.constant = 0
            completedImage.isHidden = true
            requiredAndReferredDoneLabel.isHidden = false
            requiredAndReferredDoneLabel.text = String(format: Strings.required_referrals, arguments: [String(referralLevel.requiredReferral)])
        }
        levelBenefitsTableView.dataSource = self
        levelBenefitsTableViewHeightConstraint.constant = CGFloat(referralLevel.levelBenefits.count * 48)
    }
}

//MARK: UITableViewDataSource
extension LevelTableViewCell: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referralLevel?.levelBenefits.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelBenefitsTableViewCell", for: indexPath) as! LevelBenefitsTableViewCell
        cell.initializeBenefits(benefit: referralLevel?.levelBenefits[indexPath.row])
        return cell
    }
}

