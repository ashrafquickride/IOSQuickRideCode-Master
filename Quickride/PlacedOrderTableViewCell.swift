//
//  PlacedOrderTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PlacedOrderTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var updatedDate: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    private var productOrder: ProductOrder?
    func initialisePlacedProduct(postedProduct: PostedProduct,productOrder: ProductOrder){
        self.productOrder = productOrder
        updatedDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        productTitle.text = postedProduct.title
        menuButton.changeBackgroundColorBasedOnSelection()
        let imageList = postedProduct.imageList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }
        showTradeType(productOrder: productOrder)
        orderStatus(productOrder: productOrder)
        if productOrder.status == Order.PLACED || productOrder.status == Order.ACCEPTED{
            menuButton.isHidden = false
        }else{
            menuButton.isHidden = true
        }
    }
    
    private func showTradeType(productOrder: ProductOrder){
        switch productOrder.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            productPriceLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: productOrder.pricePerDay)])
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            productPriceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: productOrder.finalPrice)])
        default: break
        }
    }
    
    private func orderStatus(productOrder: ProductOrder){
        switch productOrder.status {
        case Order.PLACED:
            productStatusLabel.text = Strings.requested.uppercased()
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        case Order.ACCEPTED:
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            productStatusLabel.text = Strings.accepted.uppercased()
        case Order.PICKUP_IN_PROGRESS:
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            productStatusLabel.text = Strings.pickUp_in_progress.uppercased()
        case Order.PICKUP_COMPETE:
            productStatusLabel.text = Strings.rent_in_progress.uppercased()
            productStatusLabel.textColor = Colors.green
            statusView.backgroundColor = Colors.green
        case Order.RETURN_PICKUP_IN_PROGRESS:
            productStatusLabel.text = Strings.return_pickup_in_progress.uppercased()
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case Order.CLOSED:
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            productStatusLabel.text = Strings.closed.uppercased()
        case Order.CANCELLED:
            productStatusLabel.text = Strings.rejecetd.uppercased()
            productStatusLabel.textColor = UIColor(netHex: 0xE20000)
            statusView.backgroundColor = UIColor(netHex: 0xE20000)
        default:
            productStatusLabel.text = productOrder.status?.uppercased()
            productStatusLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.cancel_order, style: .default) { action -> Void in
            self.showReasonsView()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true) {
        }
    }
    
    private func showReasonsView(){
        let orderCancellationViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderCancellationViewController") as! OrderCancellationViewController
        orderCancellationViewController.initialiseOrderCancellationView(userType: Order.BUYER) { (reason) in
            self.cancelOrder(reason: reason)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: orderCancellationViewController)
    }
    
    private func cancelOrder(reason: String){
        QuickShareSpinner.start()
        QuickShareRestClient.cancelMyPlacedOrder(orderId: productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? "", reason: reason){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var userInfo = [String : Any]()
                userInfo["order"] = self.productOrder
                UIApplication.shared.keyWindow?.makeToast(Strings.order_cancelled_succesfully)
                NotificationCenter.default.post(name: .placedOrderCancelled, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
}
