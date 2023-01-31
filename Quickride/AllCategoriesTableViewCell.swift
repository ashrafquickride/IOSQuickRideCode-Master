//
//  AllCategoriesTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class AllCategoriesTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var categories = [CategoryType]()
    private var isFrom: String?
    private var covidHome = false
    
    func initialiseCategories(isFrom: String,covidHome : Bool){
        self.isFrom = isFrom
        self.covidHome = covidHome
        if covidHome {
            categories = QuickShareCache.getInstance()?.covidCategories ?? [CategoryType]()
        }else{
            categories = QuickShareCache.getInstance()?.categories ?? [CategoryType]()
        }
        categoriesCollectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCollectionViewCell")
        categoriesCollectionView.reloadData()
        if categories.count%3 == 0{
            categoriesCollectionViewHeightConstraint.constant = CGFloat(((categories.count)/3) * 114)
        }else{
            categoriesCollectionViewHeightConstraint.constant = CGFloat(((categories.count/3) + 1) * 114)
        }
    }
}
//MARK: UICollectionViewDataSource
extension AllCategoriesTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionViewCell", for: indexPath) as! CategoriesCollectionViewCell
        if categories.endIndex <= indexPath.row{
            return cell
        }
        cell.initialiseCategory(categoryType: categories[indexPath.row],isFromAllCategory: true)
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension AllCategoriesTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFrom == CategoriesViewModel.POST_PRODUCT{
            let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
            addProductStepsViewController.initialiseAddingProductSteps(productType: categories[indexPath.row].displayName ?? "", isFromEditDetails: false, product: nil,categoryCode: categories[indexPath.row].code ?? "", requestId: nil,covidHome: covidHome)
            parentViewController?.navigationController?.pushViewController(addProductStepsViewController, animated: true)
        }else if isFrom == CategoriesViewModel.REQUEST_PRODUCT{
            let requestProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductViewController") as! RequestProductViewController
            requestProductViewController.initialiseRequestView(productType: categories[indexPath.row].displayName ?? "",categoryCode: categories[indexPath.row].code ?? "", requestProduct: nil,isFromCovid: covidHome)
            parentViewController?.navigationController?.pushViewController(requestProductViewController, animated: true)
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
extension AllCategoriesTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.parentViewController?.view.frame.size.width ?? 375) - 68)/3 // 32 leading and trailing space and 36 in between space
        let height = width - 2 // 2 as per design
        return CGSize(width: width, height: 102)
    }
}


