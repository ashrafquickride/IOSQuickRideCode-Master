//
//  offersListCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class offersListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var offerImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }
    
    private func setUpUI() {
        contentView.addShadow()
    }
    func offerData(offer: Offer) {
        ImageCache.getInstance().setImageToView(imageView: offerImageView, imageUrl: offer.offerScreenImageUri ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
    }
}
