//
//  PayToConfirmRideViewController.swift
//  Quickride
//
//  Created by Rajesab on 22/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PayToConfirmRideViewController: UIViewController {

    @IBOutlet weak var rideGiverImageView: CircularImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var payForRideButton: QRCustomButton!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    var payToConfirmRideViewModel = PayToConfirmRideViewModel()
    
    func initialiseData(rideInvitation: RideInvitation){
        payToConfirmRideViewModel = PayToConfirmRideViewModel(rideInvitation: rideInvitation, rideInviteActionCompletionListener: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        var rideFare = payToConfirmRideViewModel.rideInvitation?.points
        if let ridePoints = payToConfirmRideViewModel.rideInvitation?.newFare, ridePoints > 0 {
            rideFare = ridePoints
        }
        subTitleLabel.text = String(format: Strings.pay_for_ride_and_confirm_ride_info, arguments: [StringUtils.getStringFromDouble(decimalNumber: ceil(rideFare ?? 0))])
        payForRideButton.setTitle(String(format: Strings.pay_and_confirm_ride, arguments: [StringUtils.getStringFromDouble(decimalNumber: ceil(rideFare ?? 0))]), for: .normal)
        getRiderDetails()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        
    }
    
    private func getRiderDetails(){
        QuickRideProgressSpinner.startSpinner()
        UserDataCache.getInstance()?.getUserBasicInfo(userId: payToConfirmRideViewModel.rideInvitation?.riderId ?? 0, handler: { userBasicInfo, responseError, error in
            QuickRideProgressSpinner.stopSpinner()
            if let userBasicInfo = userBasicInfo {
                self.payToConfirmRideViewModel.riderBasicInfo = userBasicInfo
                self.setRiderDetailse()
            }else {
                self.closeView()
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
            }
        })
    }
    
    private func setRiderDetailse(){
        titleLabel.text = String(format: Strings.ride_giver_accepted_your_ride_request, arguments: [payToConfirmRideViewModel.riderBasicInfo?.name ?? ""])
        self.rideGiverImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: payToConfirmRideViewModel.riderBasicInfo?.gender ?? "U")
        if let userImageURI = payToConfirmRideViewModel.riderBasicInfo?.imageURI, !userImageURI.isEmpty{
            ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_SMALL, handler : {(image, imageURI) in
                if let image = image , imageURI == userImageURI{
                    ImageCache.getInstance().checkAndSetCircularImage(imageView: self.rideGiverImageView, image: image)
                }
            })
        }
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }

    @IBAction func payForRideButtonTapped(_ sender: Any) {
        payToConfirmRideViewModel.payForRideToConfirmRide()
    }
    
    @IBAction func cancelMyRequestButtonTapped(_ sender: Any) {
        payToConfirmRideViewModel.cancelRideInvitation()
        closeView()
    }
    
}
extension PayToConfirmRideViewController: RideInvitationActionCompletionListener {
    func rideInviteAcceptCompleted(rideInvitationId: Double) {
        closeView()
    }
    
    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        UIApplication.shared.keyWindow?.makeToast( Strings.ride_invite_rejected)
    }
    
    func rideInviteActionFailed(rideInvitationId: Double, responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {
        closeView()
    }
    
    func rideInviteActionCancelled() {
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
