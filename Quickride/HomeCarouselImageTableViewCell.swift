//
//  HomeCarouselImageTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class HomeCarouselImageTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var carouselImage: UIImageView!
    @IBOutlet weak var tradeTypeLabel: UILabel!
    @IBOutlet weak var requestButton: QRCustomButton!
    @IBOutlet weak var postItemButton: QRCustomButton!
    
    //MARK: Variables
    private var timer : Timer?
    private var currentImage = 0
    private var images = ["QS_onboarding_1","QS_onboarding_2","QS_onboarding_3","QS_onboarding_4","QS_onboarding_5","QS_onboarding_6"]
    private var tradeTypesDropDown = DropDown()
    
    func initializeCarouselView(){
        requestButton.showsTouchWhenHighlighted = true
        postItemButton.showsTouchWhenHighlighted = true
        currentImage = 0
        pageControl.numberOfPages = images.count
        moveToNextImage()
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(moveToNextImage), userInfo: nil, repeats: true)
        }
        addSwipeGesture()
    }
    
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipe.direction = .left
        carouselImage.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipe.direction = .right
        carouselImage.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        timer?.invalidate()
        if gesture.direction == .left {
            carouselImage.slideInFromRight(duration: 0.5, completionDelegate: nil)
        } else if gesture.direction == .right {
            currentImage -= 2
            if currentImage < 0 {
                currentImage = images.count - 1
            }
            carouselImage.slideInFromLeft(duration: 0.5, completionDelegate: nil)
        }
        moveToNextImage()
    }
    @objc private func moveToNextImage(){
        if currentImage >= images.count{
            currentImage = 0
        }
        pageControl.currentPage = currentImage
        carouselImage.image = UIImage(named: images[currentImage])
        currentImage += 1
    }
    
    
    @IBAction func tradeTypeSelectionTapped(_ sender: Any) {
        prepareDropDownAndShowTradeTypes()
    }
    private func prepareDropDownAndShowTradeTypes(){
        tradeTypesDropDown.anchorView = tradeTypeLabel
        tradeTypesDropDown.direction = .bottom
        tradeTypesDropDown.dataSource = Strings.tradeTypes
        tradeTypesDropDown.show()
        tradeTypesDropDown.selectionAction = {(index, item) in
            self.tradeTypeLabel.text = item
        }
    }
    
    @IBAction func moveToSearchScreen(_ sender: Any) {
        let searchProductsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SearchProductsViewController") as! SearchProductsViewController
        searchProductsViewController.initialiseSearchView(tradeType: tradeTypeLabel.text ?? "")
        parentViewController?.navigationController?.pushViewController(searchProductsViewController, animated: false)
    }
    @IBAction func requestItemTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.REQUEST_PRODUCT,covidHome: false)
        parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
    
    @IBAction func postItemTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.POST_PRODUCT,covidHome: false)
        parentViewController?.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
}
