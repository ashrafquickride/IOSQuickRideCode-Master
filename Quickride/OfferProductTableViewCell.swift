//
//  OfferProductTableViewCell.swift
//  Quickride
//
//  Created by HK on 05/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OfferProductTableViewCell: UITableViewCell {
    
    //MARK: outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var perMonthLabel: UILabel!
    @IBOutlet weak var radioButttonImage: UIImageView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var rentView: QuickRideCardView!
    
    func initialisePostedProductView(postedProduct: PostedProduct){
        let imageList = postedProduct.imageList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        productTitleLabel.text = postedProduct.title
        showTradeType(postedProduct: postedProduct)
    }
    
    private func showTradeType(postedProduct: PostedProduct){
        switch postedProduct.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            perMonthLabel.text = ""
            priceLabel.text = ""
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                priceLabel.text = ""
            }
            if postedProduct.pricePerMonth != 0{
                perMonthLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthLabel.text = ""
            }
            
        case Product.SELL:
            sellView.isHidden = false
            rentView.isHidden = true
            perMonthLabel.text = ""
            priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
        default:
            sellView.isHidden = false
            rentView.isHidden = false
            perMonthLabel.text = ""
            priceLabel.text = ""
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                priceLabel.text = ""
            }
            if postedProduct.pricePerMonth != 0{
                perMonthLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthLabel.text = ""
            }
        }
    }
}
