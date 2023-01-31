//
//  AddCategoryTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 15/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddCategoryTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var isFrom: String?
    private var categoryCode: String?
    
    func initialiseView(isFrom: String,categoryCode: String?){
        self.isFrom = isFrom
        self.categoryCode = categoryCode
        if isFrom == CategoriesViewModel.POST_PRODUCT{
            titleButton.setTitle(Strings.add_here.uppercased(), for: .normal)
            buttonWidthConstraint.constant = 100
        }else if isFrom == CategoriesViewModel.REQUEST_PRODUCT{
            titleButton.setTitle(Strings.post_your_requirement.uppercased(), for: .normal)
            buttonWidthConstraint.constant = 210
        }else if isFrom == CategoriesViewModel.PRODUCT_LIST{
            titleButton.setTitle(Strings.search_products.uppercased(), for: .normal)
            buttonWidthConstraint.constant = 150
        }
    }
    
    @IBAction func addHereOrPostRequirement(_ sender: UIButton) {
        if let code = categoryCode{
            guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: code) else { return }
            let requestProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductViewController") as! RequestProductViewController
            requestProductViewController.initialiseRequestView(productType: category.displayName ?? "", categoryCode: code, requestProduct: nil,isFromCovid: false)
            self.parentViewController?.navigationController?.pushViewController(requestProductViewController, animated: false)
        }else{
            let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
            categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.REQUEST_PRODUCT,covidHome: false)
            parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: false)
        }
    }
}
