//
//  RequirementDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequirementDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var dateAndDistanceLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sellOrBuyTextLabel: UILabel!
    
    func initialiseDetails(title: String?,description: String?,categoryCode: String?,categoryImageURL: String?,requestedTime: Double,distance: Double?,tradeType: String,sellOrBuyText: String){
        let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: categoryCode ?? "")
        if let imageURl = categoryImageURL{
            ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: imageURl, placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        }else{
            ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: category?.imageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        }
        titleLabel.text = title
        descriptionLabel.text = description
        categoryNameLabel.text = category?.displayName
        let requestedTimeInNSDate = DateUtils.getNSDateFromTimeStamp(timeStamp: requestedTime)
        let timeDiff = QuickShareUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: requestedTimeInNSDate)
        if var dist = distance{
            if timeDiff < 1{
                dateAndDistanceLabel.text = "Today . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: dist.roundToPlaces(places: 2)))"
            }else if timeDiff == 1{
                dateAndDistanceLabel.text = "\(timeDiff) day ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: dist.roundToPlaces(places: 2)))"
            }else{
                dateAndDistanceLabel.text = "\(timeDiff) days ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: dist.roundToPlaces(places: 2)))"
            }
        }else{
            if timeDiff < 1{
                dateAndDistanceLabel.text = "Today"
            }else if timeDiff == 1{
                dateAndDistanceLabel.text = "\(timeDiff) day ago"
            }else{
                dateAndDistanceLabel.text = "\(timeDiff) days ago"
            }
        }
        showTradeType(tradeType: tradeType,sellOrBuyText: sellOrBuyText)
    }
    
    private func showTradeType(tradeType: String,sellOrBuyText: String){
        switch tradeType{
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
            sellOrBuyTextLabel.text = sellOrBuyText
        default:
            rentView.isHidden = false
            sellView.isHidden = false
        }
    }
    
}
