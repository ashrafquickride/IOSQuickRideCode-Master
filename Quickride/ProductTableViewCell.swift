//
//  ProductTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var perDayLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var perMonthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareImage.image = shareImage.image?.withRenderingMode(.alwaysTemplate)
        shareImage.tintColor = .white
    }
    private var postedProduct: PostedProduct?
    func initialiseAddedProduct(postedProduct: PostedProduct){
        self.postedProduct = postedProduct
        dateAndTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: postedProduct.updatedTime, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        productNameLabel.text = postedProduct.title
        productIdLabel.text = "ID " + String((postedProduct.id?.suffix(10) ?? ""))
        let imageList = postedProduct.imageList?.components(separatedBy: ",")
        let firstImageUrl = imageList?[0] ?? ""
        ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: firstImageUrl, placeHolderImg: nil,imageSize: ImageCache.DIMENTION_SMALL)
        showTradeType(postedProduct: postedProduct)
    }
    private func showTradeType(postedProduct: PostedProduct){
        switch postedProduct.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            sellAmountLabel.isHidden = true
            perMonthLabel.isHidden = true
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayLabel.isHidden = false
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                perDayLabel.isHidden = false
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                perDayLabel.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthLabel.isHidden = false
                perMonthLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthLabel.isHidden = true
            }
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            perDayLabel.isHidden = true
            perMonthLabel.isHidden = true
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
        default:
            rentView.isHidden = false
            sellView.isHidden = false
            sellAmountLabel.isHidden = false
            perMonthLabel.isHidden = true
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayLabel.isHidden = false
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            
            if postedProduct.pricePerDay != 0{
                perDayLabel.isHidden = false
                perDayLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                perDayLabel.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthLabel.isHidden = false
                perMonthLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthLabel.isHidden = true
            }
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any){
        QuickShareUrlHandler.prepareURLForDeepLink(producId: postedProduct?.id ?? "", type: QuickShareUrlHandler.PRODUCT_POST) { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_product, arguments: [(postedProduct?.title ?? ""),urlString])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast(Strings.message_sent)
            } else {
                UIApplication.shared.keyWindow?.makeToast(Strings.message_sending_cancelled)
            }
        }
        parentViewController?.present(avc, animated: true, completion: nil)
    }
}
