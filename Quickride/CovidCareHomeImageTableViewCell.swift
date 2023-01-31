//
//  CovidCareHomeImageTableViewCell.swift
//  Quickride
//
//  Created by HK on 26/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CovidCareHomeImageTableViewCell: UITableViewCell {

    //MARK: Variables
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var carouselImage: UIImageView!
    private var timer : Timer?
    private var currentImage = 0
    private var images = ["covid_splash_1","covid_splash_2","covid_splash_3"]
    
    func initializeCarouselView(){
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
    
}
