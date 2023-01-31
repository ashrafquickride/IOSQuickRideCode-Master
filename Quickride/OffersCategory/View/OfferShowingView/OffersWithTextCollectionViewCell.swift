//
//  OffersWithTextCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 27/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OffersWithTextCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var categoryShowingView: QuickRideCardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(offerData: Offer) {
        titleLabel.text = offerData.offerTitle ?? ""
        subTitleLabel.text = offerData.offerSubTitle ?? ""
        descriptionLabel.text = offerData.offerMessage ?? ""
        ImageCache.getInstance().setImageToView(imageView: offerImageView, imageUrl: offerData.inAppOffersSmallImageUri ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        categoryTypeLabel.text = offerData.category ?? ""
    }
}
