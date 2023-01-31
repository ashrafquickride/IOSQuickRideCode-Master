//
//  PostedProductImagesTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PostedProductImagesTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var perDayView: UIView!
    @IBOutlet weak var perDayRentLabel: UILabel!
    @IBOutlet weak var perMonthView: UIView!
    @IBOutlet weak var perMonthRentLabel: UILabel!
    @IBOutlet weak var sellAmountView: UIView!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var noOfViewsView: UIView!
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var depositView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    //MARK: variables
    private var currentImage = 0
    private var postedProduct =  PostedProduct()
    private var imageList = [String]()
    
    override func awakeFromNib() {
        setGradientBackground(view: topView, colorTop: UIColor.black.withAlphaComponent(0.3), colorBottom: UIColor.black.withAlphaComponent(0.0))
        setGradientBackground(view: bottomView, colorTop: UIColor.black.withAlphaComponent(0.0), colorBottom: UIColor.black.withAlphaComponent(0.3))
    }
    func initialiseProduct(postedProduct: PostedProduct,noOfViews: Int){
        shareIcon.image = shareIcon.image?.withRenderingMode(.alwaysTemplate)
        shareIcon.tintColor = .white
        currentImage = 0
        self.postedProduct = postedProduct
        dateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(postedProduct.creationDate), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)?.uppercased()
        productTitle.text = postedProduct.title
        showTradeType(postedProduct: postedProduct)
        productStatus(postedProduct: postedProduct)
        imageList = postedProduct.imageList?.components(separatedBy: ",") ?? [String]()
        if imageList.count > 1{
            pageControl.numberOfPages = imageList.count
            addSwipeGesture()
            pageControl.isHidden = false
        }else{
            pageControl.isHidden = true
        }
        moveToNextImage()
        if noOfViews > 0{
            noOfViewsView.isHidden = false
            numberOfViewsLabel.text = String(format: Strings.no_of_views, arguments: [String(noOfViews)])
        }else{
            noOfViewsView.isHidden = true
        }
        productImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFullImage(_:))))
    }
    
    private func showTradeType(postedProduct: PostedProduct){
        switch postedProduct.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
            sellAmountView.isHidden = true
            depositView.isHidden = false
            depositLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(postedProduct.deposit)])
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                perDayView.isHidden = false
                return
            }
            
            if postedProduct.pricePerDay != 0{
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                perDayView.isHidden = false
            }else{
                perDayView.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthView.isHidden = false
                perMonthRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
               perMonthView.isHidden = true
            }
            
        case Product.SELL:
            perDayView.isHidden = true
            perMonthView.isHidden = true
            sellView.isHidden = false
            rentView.isHidden = true
            sellAmountView.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
        default:
            sellView.isHidden = false
            rentView.isHidden = false
            sellAmountView.isHidden = false
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)])
            depositView.isHidden = false
            depositLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(postedProduct.deposit)])
            if postedProduct.pricePerDay == 0 && postedProduct.pricePerMonth == 0{
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                perDayView.isHidden = false
                return
            }
            if postedProduct.pricePerDay != 0{
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)])
                perDayView.isHidden = false
            }else{
                perDayView.isHidden = true
            }
            if postedProduct.pricePerMonth != 0{
                perMonthView.isHidden = false
                perMonthRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)])
            }else{
               perMonthView.isHidden = true
            }
        }
    }
    private func productStatus(postedProduct: PostedProduct){
        switch postedProduct.status {
        case PostedProduct.REVIEW:
            statusLabel.text = Strings.in_review.uppercased()
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.ACTIVE:
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusLabel.text = Strings.active.uppercased()
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.REJECTED:
            statusLabel.text = Strings.reject_caps
            statusView.backgroundColor = .red
            statusLabel.textColor = .red
        default:
            statusLabel.text = postedProduct.status
            statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            statusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipe.direction = .left
        productImage.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipe.direction = .right
        productImage.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            productImage.slideInFromRight(duration: 0.5, completionDelegate: nil)
        } else if gesture.direction == .right {
            currentImage -= 2
            if currentImage < 0 {
                currentImage = imageList.count - 1
            }
            productImage.slideInFromLeft(duration: 0.5, completionDelegate: nil)
        }
        moveToNextImage()
    }
    
    @objc private func moveToNextImage(){
        if currentImage >= imageList.count{
            currentImage = 0
        }
        pageControl.currentPage = currentImage
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImage, imageUrl: imageList[currentImage] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }else{
            productImage.image = UIImage(named: "no_photo")
        }
        currentImage += 1
    }
    @objc func showFullImage(_ sender :UITapGestureRecognizer){
        let productImagesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductImagesViewController") as! ProductImagesViewController
        productImagesViewController.initialiseImages(imageList: imageList,currentImage: currentImage - 1)
        parentViewController?.navigationController?.pushViewController(productImagesViewController, animated: false)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        QuickShareUrlHandler.prepareURLForDeepLink(producId: postedProduct.id ?? "", type: QuickShareUrlHandler.PRODUCT_POST) { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_product, arguments: [(postedProduct.title ?? ""),urlString])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        parentViewController?.present(avc, animated: true, completion: nil)
    }
    
    private func setGradientBackground(view: UIView,colorTop: UIColor,colorBottom: UIColor) {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = view.frame.size
        gradientLayer.colors =
            [colorTop.cgColor,colorBottom.cgColor]
        view.layer.addSublayer(gradientLayer)
    }
}
