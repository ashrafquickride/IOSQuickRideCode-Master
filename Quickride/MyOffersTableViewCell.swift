//
//  MyOffersTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 4/9/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MyOffersTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var offerImage: UIImageView!
    
    func reloadData(index: Int, data: Offer) {
        offerImage.image = nil // if image is not there exiting image only its showing means last image
        ImageCache.getInstance().setImageToView(imageView: offerImage, imageUrl: data.offerScreenImageUri ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
    }
}
