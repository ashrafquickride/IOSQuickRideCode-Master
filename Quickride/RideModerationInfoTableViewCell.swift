//
//  RideModerationInfoTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 30/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideModerationInfoTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var moderationImageView: UIImageView!
    @IBOutlet weak var moderationTitleLabel: UILabel!
    @IBOutlet weak var moderationSubTitleLabel: UILabel!
    
    //MARK: CellLifeCycleMethods
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    //MARK: Initializer
    func initaialiseView(infoImage: UIImage, infoTitle: String, infoSubTitle: String) {
        moderationImageView.image = infoImage
        moderationTitleLabel.text = infoTitle
        moderationSubTitleLabel.text = infoSubTitle
    }

}
