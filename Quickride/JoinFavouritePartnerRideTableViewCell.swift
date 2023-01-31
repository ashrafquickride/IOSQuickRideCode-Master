//
//  JoinFavouritePartnerRideTableViewCell.swift
//  Quickride
//
//  Created by HK on 02/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class JoinFavouritePartnerRideTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favouriteRidersCollectionView: UICollectionView!
    
    func initialiseFavouriteRiders(){
        
    }
    
}
//MARK: UICollectionViewDataSource
extension JoinFavouritePartnerRideTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
