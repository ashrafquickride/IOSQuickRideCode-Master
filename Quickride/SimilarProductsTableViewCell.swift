//
//  SimilarProductsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SimilarProductsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var similarProductsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private var similarProducts = [AvailableProduct]()
    
    func initialiseMostViewedproduct(similarProducts: [AvailableProduct]){
        self.similarProducts = similarProducts
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 30)/2
        collectionViewHeightConstraint.constant = width + 20
        similarProductsCollectionView.register(UINib(nibName: "RecentlyAddedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecentlyAddedCollectionViewCell")
        similarProductsCollectionView.reloadData()
    }
    @IBAction func viewAllTapped(_ sender: Any) {
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: nil, title: Strings.similarProducts, availableProducts: similarProducts)
        parentViewController?.navigationController?.pushViewController(productListViewController, animated: true)
        
    }
}
//MARK: UICollectionViewDataSource
extension SimilarProductsTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyAddedCollectionViewCell", for: indexPath) as! RecentlyAddedCollectionViewCell
        cell.initiliseProduct(availableProduct: similarProducts[indexPath.row])
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension SimilarProductsTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.initialiseView(product: similarProducts[indexPath.row],isFromOrder: false)
        parentViewController?.navigationController?.pushViewController(productViewController, animated: true)
    }
}

//MARK: UICollectionViewDelegate
extension SimilarProductsTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 30)/2 //30 is leading and trailing space for cell
        let height = width + 14 // as per design
        return CGSize(width: width, height: height)
    }
}
