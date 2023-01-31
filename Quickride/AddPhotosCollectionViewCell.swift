//
//  AddPhotosCollectionViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddPhotosCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    func initialisePhoto(image: UIImage?){
        if image != nil{
            productImage.image = image
            productImage.contentMode = .scaleAspectFill
            cancelButton.isHidden = false
        }else{
            productImage.image = UIImage(named: "no_photo") ?? UIImage()
            productImage.contentMode = .center
            cancelButton.isHidden = true
        }
    }
    func initialiseAddedPhoto(imageURl: String?){
        ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageURl ?? "", placeHolderImg: nil,imageSize: ImageCache.DIMENTION_SMALL)
        cancelButton.isHidden = false
    }
    
    @IBAction func removePhotoClicked(_ sender: UIButton) {
        var userInfo = [String: Int]()
        userInfo["index"] = sender.tag
        NotificationCenter.default.post(name: .removeAddedProductPicture, object: nil, userInfo: userInfo)
    }
    
}
