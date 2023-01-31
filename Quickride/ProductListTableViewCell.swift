//
//  ProductListTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var addedProductCollectionView: UICollectionView!
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var availabelProducts = [AvailableProduct]()
    
    func initialiseProductsList(availabelProducts: [AvailableProduct]){
        self.availabelProducts = availabelProducts
        addedProductCollectionView.register(UINib(nibName: "RecentlyAddedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecentlyAddedCollectionViewCell")
        addedProductCollectionView.reloadData()
        let hieghtForOneCell = CGFloat((UIScreen.main.bounds.size.width - 30)/2) + 28.0
        let rows = availabelProducts.count/2
        if availabelProducts.count%2 == 0{
            productsCollectionViewHeightConstraint.constant = hieghtForOneCell * CGFloat(rows)
        }else{
            productsCollectionViewHeightConstraint.constant = hieghtForOneCell * CGFloat(rows+1)
        }
    }
}
//MARK: UICollectionViewDataSource
extension ProductListTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availabelProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyAddedCollectionViewCell", for: indexPath) as! RecentlyAddedCollectionViewCell
        cell.initiliseProduct(availableProduct: availabelProducts[indexPath.row])
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension ProductListTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: availabelProducts[indexPath.row],isFromOrder: false)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}
//MARK: UICollectionViewDelegate
extension ProductListTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 30)/2
        let height = width + 14 // as per design height is higher than width
        return CGSize(width: width, height: height)
    }
}
