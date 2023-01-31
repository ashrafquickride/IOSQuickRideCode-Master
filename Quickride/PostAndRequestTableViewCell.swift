//
//  PostAndRequestTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PostAndRequestTableViewCell: UITableViewCell {

    
    
    @IBAction func addItemTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.POST_PRODUCT, covidHome: true)
        parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: true)
    
    }
    @IBAction func requestButtonTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.REQUEST_PRODUCT, covidHome: true)
        parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
    
    
}
