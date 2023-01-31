//
//  MyReferralLevelAndPointsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 21/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol MyReferralLevelAndPoints: class{
    func levelInfoClicked()
    func referredPeopleClicked()
}

class MyReferralLevelAndPointsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var potentialEarningPointsLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var referredPeopleButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var loadingImage: UIImageView!
    
    //MARK: Variables
    private var userLevel = 0
    weak private var delegate: MyReferralLevelAndPoints?
    private var earnedPoints = 0.0
    
    func initializeLevelAndEarnedPoints(referralStats: ReferralStats?,delegate: MyReferralLevelAndPoints){
        self.userLevel = referralStats?.level ?? 0
        self.earnedPoints = referralStats?.bonusEarned ?? 0
        nameLabel.text = UserDataCache.getInstance()?.getUserName().capitalized
        if let level = referralStats?.level, let bonusEarned = referralStats?.bonusEarned,let potentialEarning = referralStats?.potentialEarning,let totalReferralCount = referralStats?.totalReferralCount{
            self.delegate = delegate
            potentialEarningPointsLabel.isHidden = false
            potentialEarningPointsLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(potentialEarning)])
            levelLabel.isHidden = false
            levelLabel.text = String(format: Strings.category_level, arguments: [String(level)])
            earnedPointsLabel.isHidden = false
            earnedPointsLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: bonusEarned)])
            referredPeopleButton.setTitle(String(format: Strings.referred_people, arguments: [String(totalReferralCount)]), for: .normal)
            referredPeopleButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            slider.maximumValue = Float(referralStats?.potentialEarning ?? 36000)
            loadingImage.isHidden = true
            pointsLabel.isHidden = false
        }else{
            potentialEarningPointsLabel.isHidden = true
            referredPeopleButton.setTitle(Strings.referred_people_loading, for: .normal)
            referredPeopleButton.setTitleColor(UIColor.black.withAlphaComponent(0.4), for: .normal)
            levelLabel.isHidden = true
            earnedPointsLabel.isHidden = true
            loadingImage.isHidden = false
            pointsLabel.isHidden = true
        }
        setupSliderBasedOnPoints()
        assignLevelAndColor()
    }
    
    private func assignLevelAndColor(){
        ViewCustomizationUtils.addCornerRadiusToView(view: levelView, cornerRadius: 10)
        switch userLevel {
        case 1:
            levelView.backgroundColor = UIColor(netHex: 0x3298A5)
        case 2:
            levelView.backgroundColor = UIColor(netHex: 0x636CCE)
        case 3:
            levelView.backgroundColor = UIColor(netHex: 0xE66464)
        case 4:
            levelView.backgroundColor = UIColor(netHex: 0x509CC6)
        case 5:
            levelView.backgroundColor = UIColor(netHex: 0xA1A13F)
        default:
            levelView.backgroundColor = UIColor(netHex: 0xEBEBEB)
        }
    }
    
    private func setupSliderBasedOnPoints(){
        slider.minimumTrackTintColor = UIColor(netHex: 0x00B501)
        slider.maximumTrackTintColor = UIColor(netHex: 0xF2F2F2)
        slider.trackRect(forBounds: CGRect(x: 0, y: 0, width: 25, height: 25))
        if earnedPoints != 0 && earnedPoints < 210{
           slider.setValue(Float(210), animated: false)
        }else{
           slider.setValue(Float(earnedPoints), animated: false)
        }
    }
    
    //MARK: Actions
    @IBAction func referredPeopleClicked(_ sender: Any) {
        delegate?.referredPeopleClicked()
    }
    
    @IBAction func levelsButtonClicked(_ sender: Any) {
        delegate?.levelInfoClicked()
    }
}

//MARK: UISlider
class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 15.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
