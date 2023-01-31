//
//  InstantTripSearchingDriverTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 17/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

typealias  isCellTapped = (_ isCellTapped : Bool) -> Void
class InstantTripSearchingDriverTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var InstantSeachingDriverCollectionView: UICollectionView!
    @IBOutlet weak var dotAnimationView: AnimationView!
    
    private var timer : Timer?
    private var currentvalue = 0
    var isCellTapped: isCellTapped?
    
    var viewModel = TaxiPoolLiveRideViewModel()
    
    func initialiseInstantTripStatus(viewModel : TaxiPoolLiveRideViewModel, isCellTapped: @escaping isCellTapped){
        self.viewModel = viewModel
        self.isCellTapped = isCellTapped
        handleViewCustomization()
        dotAnimationView.animation = Animation.named("simple-dot-loader")
        dotAnimationView.play()
        dotAnimationView.loopMode = .loop
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationFirstCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationFirstCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationSecondCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationSecondCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationThirdCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationThirdCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationForthCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationForthCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationFifthCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationFifthCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationSixthCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationSixthCollectionViewCell")
        InstantSeachingDriverCollectionView.register(UINib(nibName: "TaxiAnimationSeventhCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaxiAnimationSeventhCollectionViewCell")
        InstantSeachingDriverCollectionView.dataSource = self
        InstantSeachingDriverCollectionView.delegate = self
        InstantSeachingDriverCollectionView.reloadData()
    }
    
    private func handleViewCustomization(){
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func moveToNextPage(){
        currentvalue += 1
        if currentvalue > 6{
            currentvalue = 0
        }
        InstantSeachingDriverCollectionView.scrollToItem(at:IndexPath(item: currentvalue, section: 0), at: .right, animated: true)
        AppDelegate.getAppDelegate().log.debug("currentvalue1 = \(currentvalue)")
    }
    
    @IBAction func rescheduleBtnTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .scheduleInstantRideLater, object: nil)
    }
    
    @IBAction func cancelRideButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .cancelInstantTrip, object: nil)
    }
    
    @IBAction func phoneBtnTapped(_ sender: Any) {
        
        AppUtilConnect.callSupportNumber(phoneNumber: ConfigurationCache.getObjectClientConfiguration().quickRideSupportNumberForTaxi, targetViewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())

    }
}
extension InstantTripSearchingDriverTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationFirstCollectionViewCell", for: indexPath) as! TaxiAnimationFirstCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationSecondCollectionViewCell", for: indexPath) as! TaxiAnimationSecondCollectionViewCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationThirdCollectionViewCell", for: indexPath) as! TaxiAnimationThirdCollectionViewCell
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationForthCollectionViewCell", for: indexPath) as! TaxiAnimationForthCollectionViewCell
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationFifthCollectionViewCell", for: indexPath) as! TaxiAnimationFifthCollectionViewCell
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationSixthCollectionViewCell", for: indexPath) as! TaxiAnimationSixthCollectionViewCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiAnimationSeventhCollectionViewCell", for: indexPath) as! TaxiAnimationSeventhCollectionViewCell
            return cell
        }
        
    }
}
    
extension InstantTripSearchingDriverTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isCellTapped!(true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.minX, y: visibleRect.minY)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        guard let newValue = visibleIndexPath?.row else { return }
        currentvalue = newValue
    }
}
    
extension InstantTripSearchingDriverTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: InstantSeachingDriverCollectionView.frame.size.width , height: InstantSeachingDriverCollectionView.frame.size.height)
    }
        
}
