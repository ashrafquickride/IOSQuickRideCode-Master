//
//  CategoriesCollectionViewCell.swift
//  Quickride
//
//  Created by Halesh on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var categoriesImage: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var moreView: QuickRideCardView!
    @IBOutlet weak var moreImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    func initialiseCategory(categoryType: CategoryType?, isFromAllCategory: Bool){
        if let category = categoryType{
            moreView.isHidden = true
            categoriesImage.isHidden = false
            categoriesLabel.isHidden = false
            ImageCache.getInstance().setImageToView(imageView: categoriesImage, imageUrl: category.imageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
            categoriesLabel.text = category.displayName
        }else{
            moreView.isHidden = false
            moreImage.image = moreImage.image?.withRenderingMode(.alwaysTemplate)
            moreImage.tintColor = Colors.link
        }
        if isFromAllCategory{
            backView.backgroundColor = .white
        }else{
            backView.backgroundColor = UIColor(netHex: 0xf6f6f6)
        }
    }
}
