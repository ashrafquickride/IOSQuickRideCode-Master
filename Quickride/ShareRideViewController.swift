//
//  ShareRideViewController.swift
//  Quickride
//
//  Created by Vinutha on 25/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class ShareRideViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet var backGroundView: UIView!
    @IBOutlet var shareRideView: UIView!
    
    //MARK: Properties
    private var viewController: UIViewController?
    private var rideObj: Ride?
    private var riderRide: RiderRide?
    
    //MARK: Initializer
    func initializeData(rideObj: Ride?, riderRide: RiderRide?, viewController: UIViewController?) {
        self.rideObj = rideObj
        self.riderRide = riderRide
        self.viewController = viewController
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }

    private func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                   animations: { [weak self] in
                    guard let self = `self` else {return}
                    self.shareRideView.center.y -= self.shareRideView.bounds.height
        }, completion: nil)
    }
    
    @objc private func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.shareRideView.center.y += self.shareRideView.bounds.height
            self.shareRideView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
//    @IBAction func shareRideTapped(_ sender: UIButton) {
//        guard let ride = rideObj, let userId = QRSessionManager.getInstance()?.getUserId() else { return }
//        let joinMyRide =  JoinMyRide()
//        joinMyRide.prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber: ride.rideId), riderId: userId,from: ride.startAddress, to: ride.endAddress, startTime: ride.startTime, vehicleType: riderRide?.vehicleType ?? "", viewController: viewController)
//    }
    
    @IBAction func inviteByContactTapped(_ sender: UIButton) {
        guard let ride = rideObj else { return }
        removeView()
        let inviteContactsAndGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteContactsAndGroupViewController") as! InviteContactsAndGroupViewController
        inviteContactsAndGroupViewController.initailizeView(ride: ride,taxiRide: nil)
        self.navigationController?.pushViewController(inviteContactsAndGroupViewController, animated: true)
    }
}
