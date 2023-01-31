//
//  MostViewedCollectionViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MostViewedCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var pricePerDay: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func initialiseMostViewedProduct(availableProduct: AvailableProduct){
        let imageList = availableProduct.productImgList?.components(separatedBy: ",")
        if !(imageList?.isEmpty ?? false){
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList?[0] ?? "" , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        productTitle.text = availableProduct.title
        var distance = availableProduct.distance
        distanceLabel.text = "\(distance.roundToPlaces(places: 2)) km"
        showTradeType(availableProduct: availableProduct)
    }
    
    private func showTradeType(availableProduct: AvailableProduct){
        switch availableProduct.tradeType{
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            sellAmountLabel.isHidden = true
            pricePerDay.isHidden = false
            pricePerDay.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            pricePerDay.isHidden = true
            sellAmountLabel.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
        default:
            rentView.isHidden = false
            sellView.isHidden = false
            sellAmountLabel.isHidden = false
            pricePerDay.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
            pricePerDay.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
        }
    }
    
}
