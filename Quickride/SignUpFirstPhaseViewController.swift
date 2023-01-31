//
//  SignUpFirstPhaseViewController.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import AVFoundation

class SignUpFirstPhaseViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var phoneNumberLoginButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var shadowView: UIView!
    //MARK: Properties
    private var signUpFirstPhaseViewModel = SignUpFirstPhaseViewModel()
    private var currentPage = 1
    private var timer : Timer?
    private var eventsTraked = true
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewCustomization()
        generateEvent()
        registerCells()
        shadowView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowColor = UIColor.gray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    //MARK: Methods
    private func handleViewCustomization(){
        addSwipeGesture()
        pageControl.currentPageIndicatorTintColor = UIColor(netHex: 0x7EE4A3)
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        }
    }
    
    private func generateEvent(){
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.APP_OPEN_SIGNUP_WINDOW, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0], uniqueField: AnalyticsUtils.deviceId)
    }
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipe.direction = .left
        collectionView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        timer?.invalidate()
        if gesture.direction == .right {
            currentPage -= 2
            if currentPage < 0{
                currentPage = 2
            }
        }
        moveToNextPage()
        if eventsTraked{
            eventsTraked = false
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.FIRST_PAGE_CAROUSAL_USED, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0], uniqueField: AnalyticsUtils.deviceId)
        }
    }
    
    @objc private func moveToNextPage(){
        if currentPage > 2{
            currentPage = 0
        }
        collectionView.scrollToItem(at:IndexPath(item: currentPage, section: 0), at: .right, animated: true)
        pageControl.currentPage = currentPage
        currentPage += 1
    }
    
    private func navigateToSecondPhaseVC(socialNetworkType : String?){
        let signUpSecondPhaseVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignUpSecondPhaseViewController") as! SignUpSecondPhaseViewController
        self.navigationController?.pushViewController(signUpSecondPhaseVC, animated: false)
    }
    
    @IBAction func phoneNumberButtonTapped(_ sender: UIButton) {
        navigateToSecondPhaseVC(socialNetworkType: nil)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.FIRST_PAGE_CTA_CLICK, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0 ,"Type" : "Phone"], uniqueField: AnalyticsUtils.deviceId)
    }
    
    @IBAction func quickrideTermsButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("termsAndCondPage()")
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  HelpViewController.TERMSURL)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
}

//MARK: OnBoarding Data
extension SignUpFirstPhaseViewController: UICollectionViewDataSource{
    private func registerCells(){
        collectionView.register(UINib(nibName: "FirstOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FirstOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "SecondOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SecondOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "ThirdOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ThirdOnBoardingCollectionViewCell")
//        collectionView.register(UINib(nibName: "FourthOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FourthOnBoardingCollectionViewCell")
//        collectionView.register(UINib(nibName: "FifthOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FifthOnBoardingCollectionViewCell")
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstOnBoardingCollectionViewCell", for: indexPath) as! FirstOnBoardingCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondOnBoardingCollectionViewCell", for: indexPath) as! SecondOnBoardingCollectionViewCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThirdOnBoardingCollectionViewCell", for: indexPath) as! ThirdOnBoardingCollectionViewCell
            cell.imageViewWidthConstraint.constant = self.view.bounds.width
            return cell
//        case 3:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FourthOnBoardingCollectionViewCell", for: indexPath) as! FourthOnBoardingCollectionViewCell
//            return cell
//        case 4:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FifthOnBoardingCollectionViewCell", for: indexPath) as! FifthOnBoardingCollectionViewCell
//            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
extension SignUpFirstPhaseViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
