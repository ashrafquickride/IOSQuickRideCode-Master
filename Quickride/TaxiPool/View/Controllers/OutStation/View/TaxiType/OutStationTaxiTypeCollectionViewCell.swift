//
//  OutStationTaxiTypeCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 15/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutStationTaxiTypeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var taxiImageView: UIImageView!
    @IBOutlet weak var taxiTypeLabel: UILabel!
    @IBOutlet weak var taxiPriceLabel: UILabel!
    @IBOutlet weak var taxiTypeView: QuickRideCardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindDataWithUI(data: AvailableOutstationTaxi) {
        taxiTypeLabel.text = data.vehicleClass
        taxiPriceLabel.text = "₹\(Int(data.estimatedOutstationTaxiFare?.estimatedFare ?? 0.0))"
        ImageCache.getInstance().setImageToView(imageView: taxiImageView, imageUrl: data.taxiTypeImageUri ?? "", placeHolderImg: nil, imageSize: ImageCache.DIMENTION_SMALL)
    }
}
