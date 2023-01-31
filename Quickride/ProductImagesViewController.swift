//
//  ProductImagesViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductImagesViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var totalImageCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productImageView: UIImageView!
    
    //MARK: variables
    private var imageList = [String]()
    private var currentImage = 0
    
    func initialiseImages(imageList: [String],currentImage: Int){
        self.imageList = imageList
        self.currentImage = currentImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        if imageList.count > 1{
            addSwipeGesture()
            totalImageCountLabel.isHidden = false
        }else{
            totalImageCountLabel.isHidden = true
        }
        moveToNextImage()
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        productImageView.addGestureRecognizer(doubleTapGest)
    }
    
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipe.direction = .left
        productImageView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipe.direction = .right
        productImageView.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            productImageView.slideInFromRight(duration: 0.5, completionDelegate: nil)
        } else if gesture.direction == .right {
            currentImage -= 2
            if currentImage < 0 {
                currentImage = imageList.count - 1
            }
            productImageView.slideInFromLeft(duration: 0.5, completionDelegate: nil)
        }
        moveToNextImage()
    }
    
    @objc private func moveToNextImage(){
        if currentImage >= imageList.count{
            currentImage = 0
        }
        totalImageCountLabel.text = "\(currentImage + 1)/\(imageList.count)"
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[currentImage] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }else{
            productImageView.image = UIImage(named: "no_photo")
            productImageView.contentMode = .center
        }
        currentImage += 1
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = productImageView.frame.size.height / scale
        zoomRect.size.width  = productImageView.frame.size.width  / scale
        let newCenter = productImageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
//MARK: UIScrollViewDelegate
extension ProductImagesViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return productImageView
    }
}
