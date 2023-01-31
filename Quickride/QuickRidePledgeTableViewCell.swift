//
//  QuickRidePledgeTableViewCell.swift
//  Quickride
//
//  Created by Admin on 08/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class QuickRidePledgeTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var pledgeTypeImageView: UIImageView!
    @IBOutlet weak var pledgeTitleLabel: UILabel!
    @IBOutlet weak var pledgeDetailsLabel: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var pledgeView: UIView!
    
    //MARK: CellLifeCycleMethods
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    //MARK: Initializer
    
    func initializeViews(pledgeTitle : String,pledgeImage : UIImage,pledgeDetails : String){
        pledgeTypeImageView.image = pledgeImage
        pledgeTitleLabel.text = pledgeTitle
        pledgeDetailsLabel.setTitle(pledgeDetails, for: .normal)
        separatorView.addDashedView(color: UIColor.darkGray.cgColor)
    }
    
}
