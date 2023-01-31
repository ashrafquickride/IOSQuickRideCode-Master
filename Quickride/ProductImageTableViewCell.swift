//
//  ProductImageTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductImageTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var noOfViewsView: UIView!
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    @IBOutlet weak var noOfCommentsView: UIView!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rentPerDayView: UIView!
    @IBOutlet weak var rentPerMonthView: UIView!
    @IBOutlet weak var sellAmountView: UIView!
    @IBOutlet weak var perDayRentLabel: UILabel!
    @IBOutlet weak var perMonthRentLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    @IBOutlet weak var refundableDepositLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationInfoView: QuickRideCardView!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var depositeView: UIView!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tagImagebutton: UIButton!
    @IBOutlet weak var yearOfPurchaseLabel: UILabel!
    
    //MARK: variables
    private var currentImage = 0
    private var imageList = [String]()
    private var availableProduct: AvailableProduct?
    
    override func awakeFromNib() {
        setGradientBackground(view: topView, colorTop: UIColor.black.withAlphaComponent(0.3), colorBottom: UIColor.black.withAlphaComponent(0.0))
        setGradientBackground(view: bottomView, colorTop: UIColor.black.withAlphaComponent(0.0), colorBottom: UIColor.black.withAlphaComponent(0.3))
    }
    
    func initialiseProductImageAndDetails(availableProduct: AvailableProduct,noOfComments: Int){
        self.availableProduct = availableProduct
        currentImage = 0
        if availableProduct.noOfViews > 0{
            noOfViewsView.isHidden = false
            numberOfViewsLabel.text = String(format: Strings.no_of_views, arguments: [String(availableProduct.noOfViews)])
        }else{
            noOfViewsView.isHidden = true
        }
        if noOfComments > 0{
            noOfCommentsView.isHidden = false
            numberOfCommentsLabel.text = String(format: Strings.no_of_comments, arguments: [String(noOfComments)])
        }else{
            noOfCommentsView.isHidden = true
        }
        let yearOfPurchase = DateUtils.getTimeStringFromTimeInMillis(timeStamp: availableProduct.manufacturedDate, timeFormat: DateUtils.DATE_FORMAT_yyyy)
        if let year = yearOfPurchase{
            yearOfPurchaseLabel.text = String(format: Strings.year_of_purchase, arguments: [(year)])
            yearOfPurchaseLabel.isHidden = false
        }else{
            yearOfPurchaseLabel.isHidden = true
        }
        createdDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: availableProduct.creationDate, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        titleLabel.text = availableProduct.title
        conditionLabel.text = availableProduct.productCondition
        if !availableProduct.locations.isEmpty{
            if let areaName = availableProduct.locations[0].areaName,!areaName.isEmpty{
                locationLabel.text = areaName
            }else{
                locationLabel.text = availableProduct.locations[0].address
            }
        }
        var distance = availableProduct.distance
        distanceLabel.text = QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)) + " away"
        showTradeType(availableProduct: availableProduct)
        imageList = availableProduct.productImgList?.components(separatedBy: ",") ?? [String]()
        if imageList.count > 1{
           pageControl.numberOfPages = imageList.count
           addSwipeGesture()
            pageControl.isHidden = false
        }else{
            pageControl.isHidden = true
        }
        moveToNextImage()
        shareIcon.image = shareIcon.image?.withRenderingMode(.alwaysTemplate)
        shareIcon.tintColor = .white
        shareIcon.addShadow()
        noOfCommentsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToComments(_:))))
        productImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFullImage(_:))))
        if availableProduct.categoryCode == AvailableProduct.FREE_CATEGORY{
            tagImagebutton.isHidden = false
            tagImagebutton.setImage(UIImage(named: "free_product_icon"), for: .normal)
        }else if availableProduct.productCondition == AvailableProduct.BRAND_NEW{
            tagImagebutton.isHidden = false
            tagImagebutton.setImage(UIImage(named: "Brand_new_product"), for: .normal)
        }else{
            tagImagebutton.isHidden = true
        }
    }
    
    @objc func goToComments(_ sender :UITapGestureRecognizer){
        NotificationCenter.default.post(name: .goToProductComments, object: nil)
    }
    
    @objc func locationInfo(_ sender :UITapGestureRecognizer){
        if availableProduct?.locations.isEmpty == false{
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(availableProduct?.locations[0].lat ?? 0),\(availableProduct?.locations[0].lng ?? 0)&zoom=14&views=traffic&q=\(availableProduct?.locations[0].lat ?? 0),\(availableProduct?.locations[0].lng ?? 0)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.keyWindow?.makeToast( "Can't open Google maps in this device.")
            }
        }
    }
    
    private func showTradeType(availableProduct: AvailableProduct){
        switch availableProduct.tradeType {
        case Product.RENT:
            sellAmountView.isHidden = true
            sellView.isHidden = true
            depositeView.isHidden = false
            refundableDepositLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(availableProduct.deposit)])
            if availableProduct.pricePerDay == 0 && availableProduct.pricePerMonth == 0{
                rentPerDayView.isHidden = false
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
                return
            }
            if availableProduct.pricePerDay != 0{
                rentPerDayView.isHidden = false
               perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }else{
                rentPerDayView.isHidden = true
            }
            if availableProduct.pricePerMonth != 0{
                rentPerMonthView.isHidden = false
                perMonthRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerMonth)])
            }else{
                rentPerMonthView.isHidden = true
            }
        case Product.SELL:
            rentPerDayView.isHidden = true
            rentPerMonthView.isHidden = true
            rentView.isHidden = true
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
        default:
            sellAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.finalPrice)])
            depositeView.isHidden = false
            refundableDepositLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(availableProduct.deposit)])
            if availableProduct.pricePerDay == 0 && availableProduct.pricePerMonth == 0{
                rentPerDayView.isHidden = false
                perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
                return
            }
            if availableProduct.pricePerDay != 0{
                rentPerDayView.isHidden = false
               perDayRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerDay)])
            }else{
                rentPerDayView.isHidden = true
            }
            if availableProduct.pricePerMonth != 0{
                rentPerMonthView.isHidden = false
                perMonthRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: availableProduct.pricePerMonth)])
            }else{
                rentPerMonthView.isHidden = true
            }
            
        }
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
        pageControl.currentPage = currentImage
        if !imageList.isEmpty{
            ImageCache.getInstance().setImageToView(imageView: productImageView, imageUrl: imageList[currentImage] , placeHolderImg: nil,imageSize: ImageCache.DIMENTION_LARGE)
        }else{
            productImageView.image = UIImage(named: "no_photo")
            productImageView.contentMode = .center
        }
        currentImage += 1
    }
     
    @IBAction func backButtonTapped(_ sender: Any) {
        parentViewController?.navigationController?.popViewController(animated: true)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        QuickShareUrlHandler.prepareURLForDeepLink(producId: availableProduct?.productListingId ?? "", type: QuickShareUrlHandler.PRODUCT_POST) { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_product, arguments: [(availableProduct?.title ?? ""),urlString])
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
    
    @objc func showFullImage(_ sender :UITapGestureRecognizer){
        let productImagesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductImagesViewController") as! ProductImagesViewController
        productImagesViewController.initialiseImages(imageList: imageList,currentImage: currentImage - 1)
        parentViewController?.navigationController?.pushViewController(productImagesViewController, animated: false)
    }
}
