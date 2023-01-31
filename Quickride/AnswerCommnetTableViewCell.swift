//
//  AnswerCommnetTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AnswerCommnetTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func initialiseAnswerComment(productComment: ProductComment){
        nameLabel.text = productComment.userBasicInfo?.name
        commentLabel.text = productComment.comment
        dateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productComment.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  productComment.userBasicInfo?.imageURI ?? "", gender:  productComment.userBasicInfo?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
    }
}
