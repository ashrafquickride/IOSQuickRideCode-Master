//
//  TaxiEtiquettesCollectionViewCell.swift
//  Quickride
//
//  Created by HK on 08/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiEtiquettesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var etiquetteImage: UIImageView!
    
    func initialiseImage(taxiRideEtiquette: TaxiRideEtiquette){
        ImageCache.getInstance().getImageFromCache(imageUrl: taxiRideEtiquette.imageUri ?? "", imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
            self.etiquetteImage.image = image?.roundedCornerImage
        })
    }
}
