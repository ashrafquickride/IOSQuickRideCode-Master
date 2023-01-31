//
//  CovidRequestTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CovidRequestTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var requestedUserNameLabel: UILabel!
    @IBOutlet weak var timeAndDistanceLabel: UILabel!
    @IBOutlet weak var requestedUserImageView: UIImageView!
    
    func initialiseRequestedProduct(availableRequest: AvailableRequest){
//        ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: availableRequest.categoryImageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        titleLabel.text = availableRequest.title
        requestedUserNameLabel.text = availableRequest.name
        ImageCache.getInstance().setImageToView(imageView: requestedUserImageView, imageUrl: availableRequest.imageURI, gender: availableRequest.gender ?? "", imageSize: ImageCache.DIMENTION_TINY)
        let requestedTimeInNSDate = DateUtils.getNSDateFromTimeStamp(timeStamp: availableRequest.requestedTime)
        let timeDiff = QuickShareUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: requestedTimeInNSDate)
        var distance = availableRequest.distance
        if timeDiff < 1{
            timeAndDistanceLabel.text = "Today . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }else if timeDiff == 1{
            timeAndDistanceLabel.text = "\(timeDiff) day ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }else{
            timeAndDistanceLabel.text = "\(timeDiff) days ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }
//        showTradeType(availableRequest: availableRequest)
    }
    
    private func showTradeType(availableRequest: AvailableRequest){
        switch availableRequest.tradeType{
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
        default:
            rentView.isHidden = false
            sellView.isHidden = false
        }
    }
}
