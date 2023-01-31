//
//  CovidCategoryCollectionViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CovidCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    func initialiseCategory(categoryType: CategoryType){
            ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: categoryType.imageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
            categoryLabel.text = categoryType.displayName
    }
}
