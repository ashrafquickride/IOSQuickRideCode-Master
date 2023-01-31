//
//  etiquttesViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 27/07/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class EtiquttesViewController: UIViewController
    
{
    @IBOutlet weak var etiqutteImage: UIImageView!
    
    @IBOutlet weak var etiqutteTitle: UILabel!
    
    @IBOutlet weak var etiqutteDescription: UILabel!
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var etiqutteView: UIView!
    
    @IBOutlet weak var mapImage: UIImageView!
    
    @IBOutlet weak var descriptionLabelTrailingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var etiqutteHeading: UILabel!
    
    @IBOutlet weak var pageController: UIPageControl!
    var etiquteDescription = [String]()
    var etiquteTitle = [String]()
    var etiquteImage = [UIImage]()
    var rideType : String?
    var currentPage : Int = 0
    var closedButtonVisble : Bool = false
    var timer : Timer?
    var maxPage: Int = 0
    
    func initializeDataBeforePresentingView(rideType : String)
    {
        self.rideType = rideType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: etiqutteView, cornerRadius: 10.0)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EtiquttesViewController.dismissViewClicked(_:))))
        self.pageController.currentPage = 0
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EtiquttesViewController.swiped(_:)))
        leftSwipe.direction = .left
        etiqutteView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EtiquttesViewController.swiped(_:)))
        rightSwipe.direction = .right
        etiqutteView.addGestureRecognizer(rightSwipe)
        
        if Ride.RIDER_RIDE == rideType
        {
            self.pageController.numberOfPages = Strings.riderEtiqutteTitles.count
            self.maxPage = Strings.riderEtiqutteTitles.count
            etiqutteHeading.text = Strings.rider_etiqutte_heading
            etiquteImage = RideEtiqutteImageStore.riderImages
            etiqutteImage.image = etiquteImage[currentPage]
            etiquteDescription = Strings.riderEtiqutteDescription
            etiquteTitle = Strings.riderEtiqutteTitles
            etiqutteDescription.text = etiquteDescription[currentPage]
            etiqutteTitle.text = etiquteTitle[currentPage]
        }
        else
        {
            self.pageController.numberOfPages = Strings.rideTakerEtiqutteTitles.count
            self.maxPage = Strings.rideTakerEtiqutteTitles.count
            etiqutteHeading.text = Strings.passenger_etiqutte_heading
            etiquteImage = RideEtiqutteImageStore.rideTakerImages
            etiqutteImage.image = etiquteImage[currentPage]
            etiquteDescription = Strings.rideTakerEtiqutteDescription
            etiquteTitle = Strings.rideTakerEtiqutteTitles
            etiqutteDescription.text = etiquteDescription[currentPage]
            etiqutteTitle.text = etiquteTitle[currentPage]
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(EtiquttesViewController.moveToNextPage), userInfo: nil, repeats: true)
        
    }
    @objc func moveToNextPage (){
        if Ride.RIDER_RIDE == rideType{
            if currentPage >= self.maxPage - 1 || currentPage < 0{
                currentPage = 0
            }else{
                currentPage += 1
            }
        }
        else{
            if currentPage >= self.maxPage - 1 || currentPage < 0{
                currentPage = 0
            }else{
                currentPage += 1
            }
        }
         initiliazeViewsBasedOnCurrentPage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    deinit{
        timer?.invalidate()
    }
    @objc func swiped(_ gesture : UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("swiped()")
        if gesture.direction == .left{
            if Ride.RIDER_RIDE == rideType{
                currentPage += 1
                if currentPage > self.maxPage - 1{
                    currentPage = self.maxPage - 1
                }
            }
            else{
                currentPage += 1
                if currentPage > self.maxPage - 1{
                    currentPage = self.maxPage - 1
                }
            }
        }else if gesture.direction == .right{
            currentPage -= 1
            if currentPage < 0{
                currentPage = 0
            }
        }
        initiliazeViewsBasedOnCurrentPage()
    }
    
    func initiliazeViewsBasedOnCurrentPage(){
        self.pageController.currentPage = self.currentPage
        etiqutteImage.image = etiquteImage[currentPage]
        etiqutteDescription.text = etiquteDescription[currentPage]
        etiqutteTitle.text = etiquteTitle[currentPage]
        adjustTheWidthOfDescription()
        
    }
    func adjustTheWidthOfDescription()
    {
        if etiqutteTitle.text == Strings.follow_agreed_route || etiqutteTitle.text == Strings.follow_pickup_drop
        {
            descriptionLabelTrailingSpace.constant = 90
            mapImage.isHidden = false
        }
        else
        {
            descriptionLabelTrailingSpace.constant = 20
            mapImage.isHidden = true
        }
        
    }
    @objc func dismissViewClicked(_ sender: UITapGestureRecognizer)
    {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

