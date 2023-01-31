//
//  FaqInfoTableViewCell.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FaqInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func setAnswer(content: TaxiHelpFaq, isExpanded: Bool){
        self.infoLabel.text = content.question
        if content.answer == nil || content.answer?.isEmpty == true{
            self.arrowImage.isHidden = true
            self.descriptionLabel.isHidden = true
            return
        }
        self.arrowImage.isHidden = false
        if isExpanded{
            self.descriptionLabel.isHidden = false
            self.descriptionLabel.text = content.answer
            self.arrowImage.image = UIImage(named: "arrow_up_grey")
        }else{
            self.descriptionLabel.isHidden = true
            self.descriptionLabel.text = ""
            self.arrowImage.image = UIImage(named: "down arrow")
        }
    }
}
