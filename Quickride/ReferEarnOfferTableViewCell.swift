//
//  ReferEarnOfferTableViewCell.swift
//  Quickride
//
//  Created by Admin on 25/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ReferEarnOfferTableViewCell: UITableViewCell{
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var onGoingOfferTitle: UILabel!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
}

extension ReferEarnOfferTableViewCell {
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDelegate & UICollectionViewDataSource>
        (_ dataSourceDelegate: D, forRow row: Int){
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.reloadData()
    }
}

