//
//  ReceivedCommentTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReceivedCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentedUserImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chatIcon: UIView!
    
    private var productComment: ProductComment?
    func initialiseComment(productComment: ProductComment,isFromPostedProduct: Bool){
        self.productComment = productComment
        nameLabel.text = productComment.userBasicInfo?.name
        commentLabel.text = productComment.comment
        dateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productComment.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        ImageCache.getInstance().setImageToView(imageView: commentedUserImageView, imageUrl:  productComment.userBasicInfo?.imageURI ?? "", gender:  productComment.userBasicInfo?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        if isFromPostedProduct{
            chatIcon.isHidden = false
        }else{
            chatIcon.isHidden = true
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        var userInfo = [String: String]()
        userInfo["parentId"] = productComment?.id
        NotificationCenter.default.post(name: .replayInitiated, object: nil, userInfo: userInfo)
    }
}
