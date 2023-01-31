//
//  MatchingProductTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MatchingProductTableViewCell: UITableViewCell {

    //MARK: Oulets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var perMonthPriceLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var distaceLabel: UILabel!
    
    private var matchingProduct: AvailableProduct?
    func initialiseMatchingProduct(matchingProduct: AvailableProduct){
        self.matchingProduct = matchingProduct
        let imageList = matchingProduct.productImgList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_SMALL)
        }
        productNameLabel.text = matchingProduct.title
        var distance = matchingProduct.distance
        distaceLabel.text = QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2))
        createdDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchingProduct.creationDate, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        showTradeType(postedProduct: matchingProduct)
    }
    
    private func showTradeType(postedProduct: AvailableProduct){
        switch postedProduct.tradeType {
        case Product.RENT:
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                productPriceLabel.isHidden = false
                productPriceLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                productPriceLabel.isHidden = false
                productPriceLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                productPriceLabel.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthPriceLabel.isHidden = false
                perMonthPriceLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthPriceLabel.isHidden = true
            }
        case Product.SELL:
            productPriceLabel.isHidden = false
            productPriceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
        default: break
        }
    }
    
    @IBAction func productDetailsTapped(_ sender: Any) {
        guard let product = matchingProduct else { return }
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: product, isFromOrder: false)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}
