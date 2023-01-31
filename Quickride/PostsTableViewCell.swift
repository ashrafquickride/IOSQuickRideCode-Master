//
//  PostsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 07/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class PostsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var perDayRentLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var perMonthLabel: UILabel!
    
    private var postedProduct: PostedProduct?
    
    func initialisePostedProduct(postedProduct: PostedProduct){
        self.postedProduct = postedProduct
        menuButton.changeBackgroundColorBasedOnSelection()
        postedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(postedProduct.creationDate), timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        productNameLabel.text = postedProduct.title
        let imageList = postedProduct.imageList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        showTradeType(postedProduct: postedProduct)
        productStatus(postedProduct: postedProduct)
    }
    
    private func showTradeType(postedProduct: PostedProduct){
        switch postedProduct.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            sellAmountLabel.isHidden = true
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayRentLabel.isHidden = false
                perDayRentLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                perDayRentLabel.isHidden = false
                perDayRentLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                perDayRentLabel.isHidden = true
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
            perDayRentLabel.isHidden = true
            perMonthLabel.isHidden = true
            sellAmountLabel.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
        default:
            rentView.isHidden = false
            sellView.isHidden = false
            sellAmountLabel.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayRentLabel.isHidden = false
                perDayRentLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                return
            }
            if postedProduct.pricePerDay != 0{
                perDayRentLabel.isHidden = false
                perDayRentLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
            }else{
                perDayRentLabel.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthLabel.isHidden = false
                perMonthLabel.text = String(format: Strings.perMonth_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
                perMonthLabel.isHidden = true
            }
        }
    }
    
    private func productStatus(postedProduct: PostedProduct){
        switch postedProduct.status {
        case PostedProduct.REVIEW:
            statusLabel.text = Strings.in_review.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.ACTIVE:
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusLabel.text = Strings.active.uppercased()
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.REJECTED:
            statusLabel.text = Strings.reject_caps
            statusView.backgroundColor = .red
            statusLabel.textColor = .red
        default:
            statusLabel.text = postedProduct.status
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    @IBAction func menuTapped(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.delete, style: .default) { action -> Void in
            self.deletePostedProduct()
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.edit_details, style: .default) { action -> Void in
            self.editDeatils()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        if postedProduct?.status != PostedProduct.SOLD{
           actionSheetController.addAction(secondAction)
        }
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true) {
        }
    }
    
    private func deletePostedProduct(){
        QuickShareSpinner.start()
        QuickShareRestClient.deletePostedProduct(ownerId: UserDataCache.getInstance()?.userId ?? "", id: postedProduct?.id ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast("Product Deleted")
                var userInfo = [String : Any]()
                userInfo["postedProduct"] = self.postedProduct
                NotificationCenter.default.post(name: .postedProductDeleted, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    private func editDeatils(){
        guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: postedProduct?.categoryCode ?? "") else { return }
        let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
        addProductStepsViewController.initialiseAddingProductSteps(productType: category.displayName ?? "", isFromEditDetails: true, product: Product(postedProduct: postedProduct ?? PostedProduct()), categoryCode: postedProduct?.categoryCode ?? "", requestId: nil,covidHome: postedProduct!.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
        self.parentViewController?.navigationController?.pushViewController(addProductStepsViewController, animated: false)
    }
}
