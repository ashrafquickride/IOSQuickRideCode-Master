//
//  ReceivedOrderTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class ReceivedOrderTableViewCell: UITableViewCell {
    
    //MARK: Outltes
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStarImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var productImage: UIImageView!
    
    private var order: Order?
    func initialiseOrder(order: Order){
        self.order = order
        let imageList = order.postedProduct?.imageList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_TINY)
        }
        productTitle.text = order.postedProduct?.title
        updatedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: order.productOrder?.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        userNameLabel.text = order.borrowerInfo?.name
        if let companyName = order.borrowerInfo?.companyName{
            companyNameLabel.text = companyName
        }else{
           companyNameLabel.text = " -"
        }
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  order.borrowerInfo?.imageURI, gender:  order.borrowerInfo?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        verificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData:  order.borrowerInfo?.profileVerificationData)
        if  Int(order.borrowerInfo?.rating ?? 0) > 0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingStarImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(order.borrowerInfo?.rating ?? 0) + "(\(String( order.borrowerInfo?.noOfReviews ?? 0)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            ratingStarImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 2.0
            ratingLabel.layer.masksToBounds = true
        }
        showTradeType()
    }
    
    private func showTradeType(){
        switch order?.productOrder?.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            priceLabel.text = String(format: Strings.perDay_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: order?.productOrder?.pricePerDay)])
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: order?.productOrder?.finalPrice)])
        default:break
        }
    }
    
    @IBAction func AcceptButtonTapped(_ sender: Any) {
        acceptOrder()
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: order?.borrowerInfo?.userId), refId: Strings.profile,  name: order?.borrowerInfo?.name ?? "", targetViewController: parentViewController ?? UIViewController())
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        guard let borrowerInfo = order?.borrowerInfo else { return }
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: borrowerInfo.userId ?? 0, isRideStarted: false, listener: nil)
        self.parentViewController?.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.reject_order, style: .default) { action -> Void in
            self.rejectOrder()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true) {
        }
    }
    private func rejectOrder(){
        QuickShareSpinner.start()
        QuickShareRestClient.rejectRecievedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var userInfo = [String : Any]()
                userInfo["order"] = self.order?.productOrder
                NotificationCenter.default.post(name: .receivedOrderRejected, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func acceptOrder(){
        QuickShareSpinner.start()
        QuickShareRestClient.acceptRecievedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOrder = Mapper<ProductOrder>().map(JSONObject: responseObject!["resultData"])
                self.order?.productOrder = productOrder
                self.moveToDetailsScreen(order: self.order)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func moveToDetailsScreen(order: Order?){
        guard let updatedOrder = order else { return }
        let sellerOrderDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SellerOrderDetailsViewController") as! SellerOrderDetailsViewController
        sellerOrderDetailsViewController.initailiseReceivedOrder(order: updatedOrder,isFromMyOrder: true)
        self.parentViewController?.navigationController?.pushViewController(sellerOrderDetailsViewController, animated: true)
    }
}
