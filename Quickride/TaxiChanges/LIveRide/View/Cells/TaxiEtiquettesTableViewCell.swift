//
//  TaxiEtiquettesTableViewCell.swift
//  Quickride
//
//  Created by HK on 08/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiEtiquettesTableViewCell: UITableViewCell {

    @IBOutlet var etiquettesCollectionView: UICollectionView!
    
    private var taxiEtiquettes = [TaxiRideEtiquette]()
    private var taxiType: String?
    
    func initializeView(taxiType: String?){
        self.taxiType = taxiType
        filterEtiquettes()
        setupUI()
    }
    
    private func setupUI() {
        etiquettesCollectionView.register(UINib(nibName: "TaxiEtiquettesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiEtiquettesCollectionViewCell")
        etiquettesCollectionView.dataSource = self
    }
    
    private func filterEtiquettes(){
        let etiquettes = ConfigurationCache.getObjectClientConfiguration().taxiRideEtiquetteList
        if taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            taxiEtiquettes =  etiquettes.filter {$0.vehicleType == TaxiPoolConstants.TAXI_TYPE_AUTO}
        }else{
            taxiEtiquettes = etiquettes.filter{$0.vehicleType == TaxiPoolConstants.TAXI_TYPE_CAR}
        }
    }
}
extension TaxiEtiquettesTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taxiEtiquettes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiEtiquettesCollectionViewCell", for: indexPath as IndexPath) as! TaxiEtiquettesCollectionViewCell
        if taxiEtiquettes.endIndex <= indexPath.row {
            return cell
        }
        cell.initialiseImage(taxiRideEtiquette: taxiEtiquettes[indexPath.row])
        return cell
    }
}
