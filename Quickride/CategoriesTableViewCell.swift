//
//  CategoriesTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class CategoriesTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var categories = [CategoryType]()
    
    func initialiseCategories(){
        let categoryTypes = QuickShareCache.getInstance()?.categories ?? [CategoryType]()
        if categoryTypes.count > 8{
            categories = Array(categoryTypes.prefix(upTo: 8))
        }else{
            categories = categoryTypes
        }
        categoriesCollectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCollectionViewCell")
        categoriesCollectionView.reloadData()
        if categories.count%3 == 0{
            categoriesCollectionViewHeightConstraint.constant = CGFloat((categories.count/3) * 114)
        }else{
            categoriesCollectionViewHeightConstraint.constant = CGFloat(((categories.count/3) + 1) * 114)
        }
    }
}
//MARK: UICollectionViewDataSource
extension CategoriesTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count + 1 // count + 1 more cell
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionViewCell", for: indexPath) as! CategoriesCollectionViewCell
        if categories.endIndex + 1 <= indexPath.row{
            return cell
        }
        if indexPath.row == categories.count{
            cell.initialiseCategory(categoryType: nil,isFromAllCategory: false)
        }else{
            cell.initialiseCategory(categoryType: categories[indexPath.row],isFromAllCategory: false)
        }
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension CategoriesTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == categories.endIndex{
            let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
            categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.BUY_PRODUCT,covidHome: false)
            parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: true)
        }else{
            getProductsBasedOnCategory(index: indexPath.row)
        }
    }
    private func getProductsBasedOnCategory(index: Int){
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: parentViewController ?? UIViewController(), handler: nil)
            return
        }
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: self.categories[index].code,title: self.categories[index].displayName ?? "", availableProducts: [AvailableProduct]())
        self.parentViewController?.navigationController?.pushViewController(productListViewController, animated: true)
    }
}

//MARK: UICollectionViewDelegate
extension CategoriesTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 68)/3 // 32 leading and trailing space and 36 in between space
        let height = width - 2 // 2 as per design
        return CGSize(width: width, height: 102)
    }
}
