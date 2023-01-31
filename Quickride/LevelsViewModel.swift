//
//  LevelsViewModel.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LevelsViewModel{
    var referralStats: ReferralStats?
    var referralLevels = [ReferralLevel]()
    
    func prepareLevels(){
        referralLevels.append(ReferralLevel(userLevel: referralStats?.level ?? 0, levelImage: UIImage(named: "referral_level_1"), backGroundColor: UIColor(netHex: 0xE5EDEE), totalReferredCount: referralStats?.totalReferralCount ?? 0, requiredReferral: referralStats?.referralLevelConfigList[0].minReferrals ?? 0, levelBenefits: referralStats?.referralLevelConfigList[0].referralBenefits ?? [String]()))
        referralLevels.append(ReferralLevel(userLevel: referralStats?.level ?? 0, levelImage: UIImage(named: "referral_level_2"), backGroundColor: UIColor(netHex: 0xE5E7FB), totalReferredCount: referralStats?.totalReferralCount ?? 0, requiredReferral: referralStats?.referralLevelConfigList[1].minReferrals ?? 0, levelBenefits: referralStats?.referralLevelConfigList[1].referralBenefits ?? [String]()))
        referralLevels.append(ReferralLevel(userLevel: referralStats?.level ?? 0, levelImage:  UIImage(named: "referral_level_3"), backGroundColor: UIColor(netHex: 0xFBE5E5), totalReferredCount: referralStats?.totalReferralCount ?? 0, requiredReferral: referralStats?.referralLevelConfigList[2].minReferrals ?? 0, levelBenefits: referralStats?.referralLevelConfigList[2].referralBenefits ?? [String]()))
        referralLevels.append(ReferralLevel(userLevel: referralStats?.level ?? 0, levelImage:  UIImage(named: "referral_level_4"), backGroundColor: UIColor(netHex: 0xEDF6FB), totalReferredCount: referralStats?.totalReferralCount ?? 0, requiredReferral: referralStats?.referralLevelConfigList[3].minReferrals ?? 0, levelBenefits: referralStats?.referralLevelConfigList[3].referralBenefits ?? [String]()))
        referralLevels.append(ReferralLevel(userLevel: referralStats?.level ?? 0, levelImage:  UIImage(named: "referral_level_5"), backGroundColor: UIColor(netHex: 0xF2F2E3), totalReferredCount: referralStats?.totalReferralCount ?? 0, requiredReferral: referralStats?.referralLevelConfigList[4].minReferrals ?? 0, levelBenefits: referralStats?.referralLevelConfigList[4].referralBenefits ?? [String]()))
    }
}
struct ReferralLevel {
    let userLevel : Int
    let levelImage: UIImage?
    let backGroundColor : UIColor
    let totalReferredCount : Int
    let requiredReferral : Int
    var levelBenefits = [String]()
    
    init(userLevel : Int, levelImage: UIImage?,backGroundColor : UIColor,totalReferredCount: Int,requiredReferral: Int,levelBenefits: [String]){
        
        self.userLevel = userLevel
        self.levelImage = levelImage
        self.backGroundColor = backGroundColor
        self.totalReferredCount = totalReferredCount
        self.requiredReferral = requiredReferral
        self.levelBenefits = levelBenefits
    }
}
