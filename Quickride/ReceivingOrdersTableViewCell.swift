//
//  ReceivingOrdersTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReceivingOrdersTableViewCell: UITableViewCell {
    
    //MARK: Outlets
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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    
    private var order: Order?
    func initialiseOrder(order: Order){
        self.order = order
        productTitle.text = order.postedProduct?.title
        let imageList = order.postedProduct?.imageList?.components(separatedBy: ",") ?? [String]()
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[0] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_TINY)
        }
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
        updatedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: order.productOrder?.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        showTradeType()
        showStatusOfOrder()
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
    private func showStatusOfOrder(){
        statusLabel.isHidden = false
        statusView.isHidden = false
        switch order?.productOrder?.status {
        case Order.PLACED:
            statusLabel.text = Strings.requested.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case Order.ACCEPTED:
            statusLabel.text = Strings.accepted.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case Order.PICKUP_IN_PROGRESS:
            statusLabel.text = Strings.pickUp_in_progress.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case Order.PICKUP_COMPETE:
            statusLabel.text = Strings.rent_in_progress.uppercased()
            statusLabel.textColor = Colors.green
            statusView.backgroundColor = Colors.green
        case Order.RETURN_PICKUP_IN_PROGRESS:
            statusLabel.text = Strings.return_pickup_in_progress.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case Order.CLOSED,Order.RETURNED:
            statusLabel.text = Strings.closed.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        default:
            statusLabel.isHidden = true
            statusView.isHidden = true
        }
    }
}
