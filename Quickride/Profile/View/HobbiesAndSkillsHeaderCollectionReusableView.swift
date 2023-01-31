//
//  HobbiesAndSkillsHeaderCollectionReusableView.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HobbiesAndSkillsHeaderCollectionReusableView: UICollectionReusableView {

    //MARK: Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewHeightConstraint: NSLayoutConstraint!
    
    func setupUI(headerText: String) {
        if tag == 0 && headerText == Strings.add_hobbies {
            infoView.isHidden = false
            infoViewHeightConstraint.constant = 110
        } else {
            infoView.isHidden = true
            infoViewHeightConstraint.constant = 0
        }
        headerLabel.text = headerText.uppercased()
    }
    
}
