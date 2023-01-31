//
//  BuyingOrRentProductTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BuyingOrRentProductTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var sellOrBuyTextLabel: UILabel!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var perMonthRentLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    func initialiseProduct(modifiedTime: Double?,title: String,id: String?,productImgList: String?,requiredTradetype: String,pricePerDay: Double,rentPerMonth: Double,finalPrice: Double,deposite: Int,sellOrBuyText: String){
        navigationButton.isUserInteractionEnabled = false
        dateAndTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: modifiedTime, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)?.uppercased()
        productNameLabel.text = title
        productIdLabel.text = "ID " + String((id?.suffix(8) ?? ""))
        let imageList = productImgList?.components(separatedBy: ",")
        if imageList?.isEmpty == false{
            let firstImageUrl = imageList?[0] ?? ""
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: firstImageUrl, placeHolderImg: nil,imageSize: ImageCache.DIMENTION_SMALL)
        }
        switch requiredTradetype {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            if pricePerDay != 0 && rentPerMonth != 0{
                seperatorView.isHidden = false
            }else{
                seperatorView.isHidden = true
            }
            if pricePerDay == 0 && rentPerMonth == 0{
               amountLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: pricePerDay)])
                return
            }
            if pricePerDay != 0{
               amountLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: pricePerDay)])
            }else{
                amountLabel.text = ""
            }
            if rentPerMonth != 0{
                perMonthRentLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: rentPerMonth)])
            }else{
                perMonthRentLabel.text = ""
            }
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            seperatorView.isHidden = true
            sellOrBuyTextLabel.text = sellOrBuyText
            amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: finalPrice)])
        default:
          rentView.isHidden = true
          sellView.isHidden = true
        }
    }
    private var availableProduct = AvailableProduct() // Its uing only for buyer side showing product details in order screen
    func showingProductDetails(postedProduct: PostedProduct?,sellerInfo: UserBasicInfo?){
        guard let product = postedProduct,let userInfo = sellerInfo else { return }
        navigationButton.isUserInteractionEnabled = true
        availableProduct = AvailableProduct(postedProduct: product, sellerInfo: userInfo)
    }
    
    @IBAction func moveToProductDetails(_ sender: Any) {
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: availableProduct, isFromOrder: true)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}
