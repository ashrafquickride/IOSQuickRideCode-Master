//
//  CoRidersTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 01/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CoRidersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coRiderCollectionView: UICollectionView!
    
}

extension CoRidersTableViewCell {
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDelegate & UICollectionViewDataSource>
        (_ dataSourceDelegate: D, forRow row: Int){
        coRiderCollectionView.delegate = dataSourceDelegate
        coRiderCollectionView.dataSource = dataSourceDelegate
        coRiderCollectionView.reloadData()
    }
}
