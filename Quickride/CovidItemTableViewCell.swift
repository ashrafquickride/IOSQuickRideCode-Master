//
//  CovidItemTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CovidItemTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var availableProduct: AvailableProduct?
    
    func initiliseProduct(availableProduct: AvailableProduct){
        self.availableProduct = availableProduct
        let imageList = availableProduct.productImgList?.components(separatedBy: ",")
        if !(imageList?.isEmpty ?? false){
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageList?[0] ?? "" , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        productNameLabel.text = availableProduct.title
        var distance = availableProduct.distance
        distanceLabel.text = QuickShareUtils.checkDistnaceInMeterOrKm(distance: (distance.roundToPlaces(places: 2)))
        showTradeType(availableProduct: availableProduct)
    }
    
    private func showTradeType(availableProduct: AvailableProduct){
        switch availableProduct.tradeType{
        case Product.RENT:
            if availableProduct.pricePerDay == 0{
                sellAmountLabel.text = "Free"
            }else{
                sellAmountLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }
        case Product.SELL:
            if availableProduct.finalPrice == 0{
                sellAmountLabel.text = "Free"
            }else{
                sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
            }
        default: break
        }
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        if let receiverId = availableProduct?.userId{
            AppUtilConnect.callNumber(receiverId: String(receiverId), refId: Strings.profile,  name: availableProduct!.userName!, targetViewController: parentViewController ?? UIViewController())
        }
    }
}
