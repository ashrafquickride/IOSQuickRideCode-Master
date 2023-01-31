//
//  VehicleInsuranceTableViewCell.swift
//  Quickride
//
//  Created by iDisha on 06/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VehicleInsuranceTableViewCell: UITableViewCell{
    
    @IBOutlet weak var insuranceOfferTitle: UILabel!
    
    @IBOutlet weak var insuranceOfferCollectionView: UICollectionView!
    
    @IBOutlet weak var insuranceOfferCollectionViewHeightConstraint: NSLayoutConstraint!
}
extension VehicleInsuranceTableViewCell {
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDelegate & UICollectionViewDataSource>
        (_ dataSourceDelegate: D, forRow row: Int){
        insuranceOfferCollectionView.delegate = dataSourceDelegate
        insuranceOfferCollectionView.dataSource = dataSourceDelegate
        insuranceOfferCollectionView.reloadData()
    }
}
