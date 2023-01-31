//
//  PreferredRidePartnersCell.swift
//  Quickride
//
//  Created by rakesh on 2/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PreferredRidePartnersCell : UITableViewCell{
    
@IBOutlet weak var menuOptnBtn: UIButton!
@IBOutlet weak var preferredRidePartnerName: UILabel!
@IBOutlet weak var preferredRidePartnerImage: UIImageView!
@IBOutlet weak var favoritePartnerImage: UIImageView!
@IBOutlet weak var favoritePartnerName: UILabel!
@IBOutlet weak var selectFavoritePartner: UIButton!
    
@IBOutlet weak var AutoConfirmSwitch: UISwitch!
    
    var preferredRidePartner : PreferredRidePartner?
    weak var viewController : UIViewController?
    
    func initializeViews(preferredRidePartner : PreferredRidePartner, viewController : UIViewController)
    {
        self.preferredRidePartner = preferredRidePartner
        self.viewController = viewController
        preferredRidePartnerName.text = preferredRidePartner.name
        if preferredRidePartner.gender != nil{
           ImageCache.getInstance().setImageToView(imageView: self.preferredRidePartnerImage, imageUrl: preferredRidePartner.imageUri, gender: preferredRidePartner.gender!,imageSize: ImageCache.DIMENTION_TINY)
        }else{
            preferredRidePartnerImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
    }
}
