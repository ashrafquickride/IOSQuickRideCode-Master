//
//  CovidCategoryTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CovidCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var categories = [CategoryType]()
    private var isFrom: String?
    func initialiseCovidCategories(isFrom: String){
        self.isFrom = isFrom
        categories = QuickShareCache.getInstance()?.covidCategories ?? [CategoryType]()
        collectionView.register(UINib(nibName: "CovidCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CovidCategoryCollectionViewCell")
        collectionView.reloadData()
        let height = ((self.parentViewController?.view.frame.size.width ?? 375))/3
        if categories.count%3 == 0{
            categoriesCollectionViewHeightConstraint.constant = CGFloat(((categories.count)/3)) * height
        }else{
            categoriesCollectionViewHeightConstraint.constant = CGFloat(((categories.count/3) + 1)) * height
        }
    }
}
//MARK: UICollectionViewDataSource
extension CovidCategoryTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CovidCategoryCollectionViewCell", for: indexPath) as! CovidCategoryCollectionViewCell
        if categories.endIndex <= indexPath.row{
            return cell
        }
        cell.initialiseCategory(categoryType: categories[indexPath.row])
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension CovidCategoryTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFrom == CategoriesViewModel.BUY_PRODUCT{
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
extension CovidCategoryTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375))/3 // 32 leading and trailing space and 36 in between space
        return CGSize(width: width, height: width)
    }
}
