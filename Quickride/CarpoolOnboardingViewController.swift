//
//  CarpoolOnboardingViewControllerViewController.swift
//  Quickride
//
//  Created by Rajesab on 26/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CarpoolOnboardingViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var letsStartButton: QRCustomButton!
    
    //MARK: Properties
    private var currentPage = 1
    private var timer : Timer?
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewCustomization()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    //MARK: Methods
    
    private func registerCells(){
        collectionView.register(UINib(nibName: "SecondOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SecondOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "CarpoolFirstOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarpoolFirstOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "CarpoolSecondOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarpoolSecondOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "CarpoolThirdOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarpoolThirdOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "CarpoolFourthOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarpoolFourthOnBoardingCollectionViewCell")
        collectionView.register(UINib(nibName: "CarpoolFifthOnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarpoolFifthOnBoardingCollectionViewCell")
        collectionView.reloadData()
    }
    private func handleViewCustomization(){
        addSwipeGesture()
        pageControl.currentPageIndicatorTintColor = UIColor(netHex: 0x7EE4A3)
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        }
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
                currentPage = 5
            }
        }
        moveToNextPage()
    }
    @objc private func moveToNextPage(){
        if currentPage > 5{
            currentPage = 0
        }
        collectionView.scrollToItem(at:IndexPath(item: currentPage, section: 0), at: .right, animated: true)
        pageControl.currentPage = currentPage
        currentPage += 1
    }
    
    @IBAction func letsStartButtonTapped(_ sender: Any) {
        let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePreferenceViewController") as! RidePreferenceViewController
        ridePreferencesViewController.initialiseData(isFromSignUpFlow: false)
        
        self.navigationController?.pushViewController(ridePreferencesViewController, animated: false)
    }

    
}
extension CarpoolOnboardingViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondOnBoardingCollectionViewCell", for: indexPath) as! SecondOnBoardingCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarpoolFirstOnBoardingCollectionViewCell", for: indexPath) as! CarpoolFirstOnBoardingCollectionViewCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarpoolSecondOnBoardingCollectionViewCell", for: indexPath) as! CarpoolSecondOnBoardingCollectionViewCell
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarpoolThirdOnBoardingCollectionViewCell", for: indexPath) as! CarpoolThirdOnBoardingCollectionViewCell
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarpoolFourthOnBoardingCollectionViewCell", for: indexPath) as! CarpoolFourthOnBoardingCollectionViewCell
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarpoolFifthOnBoardingCollectionViewCell", for: indexPath) as! CarpoolFifthOnBoardingCollectionViewCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
extension CarpoolOnboardingViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
