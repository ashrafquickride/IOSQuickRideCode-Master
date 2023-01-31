//
//  HobbiesAndSkillsCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HobbiesAndSkillsCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var hobbyOrSkillView: UIView!
    @IBOutlet weak var hobbyOrSkillLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    
    //MARK: Methods
    func setupUI(hobbyOrSkill: String, selectedHobbies: [String], selectedSkills: [String], section: Int) {
        ViewCustomizationUtils.addCornerRadiusToView(view: hobbyOrSkillView, cornerRadius: 18)
        hobbyOrSkillLabel.text = hobbyOrSkill
        if section == 0 {
            if selectedHobbies.contains(hobbyOrSkill) {
                hobbyOrSkillLabel.textColor = UIColor.white
                hobbyOrSkillView.backgroundColor = UIColor(netHex: 0x4F4937)
                cancelButton.isHidden = false
                cancelButtonWidthConstraint.constant = 20
            } else {
                hobbyOrSkillLabel.textColor = UIColor(netHex: 0x9B6C57)
                hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF5F0E1)
                cancelButton.isHidden = true
                cancelButtonWidthConstraint.constant = 0
            }
        } else {
            if selectedSkills.contains(hobbyOrSkill) {
                hobbyOrSkillLabel.textColor = UIColor.white
                hobbyOrSkillView.backgroundColor = UIColor(netHex: 0x303030)
                cancelButton.isHidden = false
                cancelButtonWidthConstraint.constant = 20
            } else {
                hobbyOrSkillLabel.textColor = UIColor(netHex: 0x474747)
                hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF3F3F3)
                cancelButton.isHidden = true
                cancelButtonWidthConstraint.constant = 0
            }
        }
    }

}
