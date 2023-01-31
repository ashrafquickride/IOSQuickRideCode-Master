//
//  MostViewedProductsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MostViewedProductsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var mostViewdCollectionView: UICollectionView!
    private var availabelProducts = [AvailableProduct]()
    
    func initialiseMostViewedproduct(availabelProducts: [AvailableProduct]){
        self.availabelProducts = availabelProducts
        mostViewdCollectionView.register(UINib(nibName: "MostViewedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MostViewedCollectionViewCell")
        mostViewdCollectionView.reloadData()
    }
}
//MARK: UICollectionViewDataSource
extension MostViewedProductsTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availabelProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostViewedCollectionViewCell", for: indexPath) as! MostViewedCollectionViewCell
        cell.initialiseMostViewedProduct(availableProduct: availabelProducts[indexPath.row])
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension MostViewedProductsTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: availabelProducts[indexPath.row],isFromOrder: false)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}

//MARK: UICollectionViewDelegate
extension MostViewedProductsTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 188)
    }
}
