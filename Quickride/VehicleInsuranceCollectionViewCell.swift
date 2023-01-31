//
//  VehicleInsuranceCollectionViewCell.swift
//  Quickride
//
//  Created by iDisha on 30/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VehicleInsuranceCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var insuranceImageView: UIImageView!
    
    @IBOutlet weak var insurancePercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    func initializeView(vehicleInsurance: VehicleInsurance) {
        if let url = vehicleInsurance.insuranceImageUrl{
            ImageCache.getInstance().setImageToView(imageView: insuranceImageView, imageUrl: url, placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        }
        self.insurancePercentageLabel.text = vehicleInsurance.offerText
    }
    
    private func setUpUI() {
        self.insurancePercentageLabel.isHidden = false
        self.insuranceImageView.layer.cornerRadius = 5
        self.insuranceImageView.layer.borderWidth = 1.0
        self.insuranceImageView.layer.borderColor = UIColor.clear.cgColor
        self.insuranceImageView.layer.masksToBounds = true
        self.insuranceImageView.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.insuranceImageView.layer.cornerRadius).cgPath
    }
}
