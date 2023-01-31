//
//  RecentlyAddedCollectionViewCell.swift
//  Quickride
//
//  Created by Halesh on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RecentlyAddedCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var perDayLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var tagImageButton: UIButton!
    
    func initiliseProduct(availableProduct: AvailableProduct){
        let imageList = availableProduct.productImgList?.components(separatedBy: ",")
        if !(imageList?.isEmpty ?? false){
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageList?[0] ?? "" , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        productNameLabel.text = availableProduct.title
        var distance = availableProduct.distance
        distanceLabel.text = QuickShareUtils.checkDistnaceInMeterOrKm(distance: (distance.roundToPlaces(places: 2)))
        showTradeType(availableProduct: availableProduct)
        if availableProduct.categoryCode == AvailableProduct.FREE_CATEGORY{
            tagImageButton.isHidden = false
            tagImageButton.setImage(UIImage(named: "free_product_icon"), for: .normal)
        }else if availableProduct.productCondition == AvailableProduct.BRAND_NEW{
            tagImageButton.isHidden = false
            tagImageButton.setImage(UIImage(named: "Brand_new_product"), for: .normal)
        }else{
            tagImageButton.isHidden = true
        }
    }
    
    private func showTradeType(availableProduct: AvailableProduct){
        switch availableProduct.tradeType{
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            sellAmountLabel.isHidden = true
            perDayLabel.isHidden = false
            if availableProduct.pricePerDay == 0 && availableProduct.pricePerMonth == 0{
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
                return
            }
            if availableProduct.pricePerDay != 0{
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }else{
                perDayLabel.isHidden = true
            }
            if availableProduct.pricePerMonth != 0{
                sellAmountLabel.isHidden = false
                sellAmountLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerMonth)])
            }
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            sellAmountLabel.isHidden = false
            perDayLabel.isHidden = true
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
        default:
            rentView.isHidden = false
            sellView.isHidden = false
            sellAmountLabel.isHidden = false
            perDayLabel.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
            if availableProduct.pricePerDay != 0{
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }else if availableProduct.pricePerMonth != 0{
                perDayLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerMonth)])
            }else{
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }
        }
    }
}
