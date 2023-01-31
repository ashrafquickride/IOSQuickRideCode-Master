//
//  RecentlyAddedTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RecentlyAddedTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var addedProductCollectionView: UICollectionView!
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var availabelProducts = [AvailableProduct]()
    
    func initialiseAddedProducts(availabelProducts: [AvailableProduct]){
        self.availabelProducts = availabelProducts
        addedProductCollectionView.register(UINib(nibName: "RecentlyAddedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecentlyAddedCollectionViewCell")
        addedProductCollectionView.reloadData()
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 30) // 30 is leading and trailing space for cell
        let hieghtForOneCell = Int((width/2) + 30) // 30 is top and bottom space for cell
        if availabelProducts.count < 6{
            if availabelProducts.count%2 == 0{
                productsCollectionViewHeightConstraint.constant = CGFloat(hieghtForOneCell*(availabelProducts.count/2))
            }else{
                productsCollectionViewHeightConstraint.constant = CGFloat(hieghtForOneCell*((availabelProducts.count+1)/2))
            }
        }else{
            productsCollectionViewHeightConstraint.constant = CGFloat(hieghtForOneCell*3)
        }
    }
    
    @IBAction func viewAllTapped(_ sender: Any) {
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: nil,title: Strings.recentlyAddedProducts, availableProducts: availabelProducts)
        parentViewController?.navigationController?.pushViewController(productListViewController, animated: true)
    }
}
//MARK: UICollectionViewDataSource
extension RecentlyAddedTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if availabelProducts.count < 6{
            return availabelProducts.count
        }else{
            return 6
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyAddedCollectionViewCell", for: indexPath) as! RecentlyAddedCollectionViewCell
        cell.initiliseProduct(availableProduct: availabelProducts[indexPath.row])
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension RecentlyAddedTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: availabelProducts[indexPath.row], isFromOrder: false)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}
//MARK: UICollectionViewDelegate
extension RecentlyAddedTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 30)/2 //30 is leading and trailing space for cell
        let height = width + 14 // as per design
        return CGSize(width: width, height: height)
    }
}
