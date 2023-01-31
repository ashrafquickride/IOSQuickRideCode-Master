//
//  MyReferralTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 8/2/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class MyReferralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var refferalCount: UILabel!
    @IBOutlet weak var pointsEarnedCount: UILabel!
    @IBOutlet weak var currentLevel: UILabel!
    @IBOutlet weak var currentLevelView: UIView!
    @IBOutlet weak var levelProgressSlider: CustomSlider!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var referralLevelIcon: UIImageView!
    @IBOutlet weak var pendingReferralToNextLevelInfo: UILabel!
    
    private weak var viewController : UIViewController?
    
    func intializeViews(referralStats : ReferralStats,viewController : UIViewController){
        self.viewController = viewController
        pointsEarnedCount.text = StringUtils.getStringFromDouble(decimalNumber: referralStats.bonusEarned)
        refferalCount.text = String(referralStats.activatedReferralCount)
        levelProgressSlider.maximumValue = Float(referralStats.potentialEarning)
        setupSliderBasedOnPoints(referralStats: referralStats)
        currentLevel.text = String(format: Strings.category_level, arguments: [String(referralStats.level)])
        assignLevelAndColor(userLevel: referralStats.level)
        let referralLevelConfigs = referralStats.referralLevelConfigList
        for  referralLevelConfig in referralLevelConfigs {
            
            if referralLevelConfig.level == referralStats.level + 1 {
                pendingReferralToNextLevelInfo.isHidden = false
                pendingReferralToNextLevelInfo.text = "\(referralLevelConfig.minReferrals - referralStats.activatedReferralCount) Referrals to Level  \(referralLevelConfig.level)"
            }
        }
    }
    private func assignLevelAndColor(userLevel : Int){
        var color :UIColor
        var nexLevelcolor :UIColor
        switch userLevel {
        case 1:
            color = UIColor(netHex: 0x3298A5)
            nexLevelcolor = UIColor(netHex: 0x636CCE)
        case 2:
            color = UIColor(netHex: 0x636CCE)
            nexLevelcolor = UIColor(netHex: 0xE66464)
        case 3:
            color = UIColor(netHex: 0xE66464)
            nexLevelcolor = UIColor(netHex: 0x509CC6)
        case 4:
            color = UIColor(netHex: 0x509CC6)
            nexLevelcolor = UIColor(netHex: 0xA1A13F)
        case 5:
            color = UIColor(netHex: 0xA1A13F)
            nexLevelcolor = UIColor(netHex: 0xEBEBEB)
        default:
            color = UIColor(netHex: 0xEBEBEB)
            nexLevelcolor = UIColor(netHex: 0xEBEBEB)
        }
        currentLevel.textColor = color
        levelProgressSlider.minimumTrackTintColor  = nexLevelcolor
        var image = UIImage(named: "referral_level_icon")
        image = image?.withRenderingMode(.alwaysTemplate)
        referralLevelIcon.image = image
        referralLevelIcon.tintColor = nexLevelcolor
    }
    private func setupSliderBasedOnPoints(referralStats : ReferralStats){
        levelProgressSlider.trackRect(forBounds: CGRect(x: 0, y: 0, width: 25, height: 25))
        if referralStats.bonusEarned != 0 && referralStats.bonusEarned < 210{
           levelProgressSlider.setValue(Float(210), animated: false)
        }else{
            levelProgressSlider.setValue(Float(referralStats.bonusEarned), animated: false)
        }
    }
    
    @IBAction func cellTapped(_ sender: Any) {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController)
        viewController?.navigationController?.pushViewController(destViewController, animated: true)
    }
}
