//
//  VerificationCategoryCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 03/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VerificationCategoryCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var catergoryImageView: UIImageView!
    @IBOutlet weak var catergoryLabel: UILabel!
    
    //MARK: Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: Methods
    func setupUI(verificationCategory: ProfileVerificationCategory) {
        catergoryImageView.image = UIImage(named: verificationCategory.imageName!)
        catergoryLabel.text = verificationCategory.name
        ViewCustomizationUtils.addBorderToView(view: categoryView, borderWidth: 1, color: UIColor.lightGray)
    }
}
