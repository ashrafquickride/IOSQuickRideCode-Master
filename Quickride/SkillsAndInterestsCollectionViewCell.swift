//
//  SkillsAndInterestsCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SkillsAndInterestsCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var hobbyOrSkillLabel: UILabel!
    
    //MARK: Properties
    private var cellViewModel = SkillsAndInterestsCollectionViewCellModel()
    
    //MARK: Methods
    func setupUI(hobbyOrSkill: String) {
        hobbyOrSkillLabel.text = hobbyOrSkill
    }

}
