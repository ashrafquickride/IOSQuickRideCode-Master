//
//  ReferAndEarnCollectionViewCell.swift
//  Quickride
//
//  Created by Admin on 11/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ReferAndEarnCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var offerImageView: UIImageView!
    
    
    func setImageToImageView(offer: Offer){
        ImageCache.getInstance().setImageToView(imageView: self.offerImageView, imageUrl: offer.offerImageUri!, placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
    }
}
