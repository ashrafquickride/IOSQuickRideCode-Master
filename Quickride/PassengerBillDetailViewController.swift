//
//  PassengerBillDetailViewController.swift
//  Quickride
//
//  Created by iDisha on 26/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerBillDetailViewController: ModelViewController {
    
    @IBOutlet weak var imgPassengerPic: UIImageView!
    
    @IBOutlet weak var labelPassengerName: UILabel!
    
    @IBOutlet weak var labelFare: UILabel!
    
    @IBOutlet weak var labelStartAddress: UILabel!
    
    @IBOutlet weak var labelEndAddress: UILabel!
    
    @IBOutlet weak var labelStartTime: UILabel!
    
    @IBOutlet weak var lableDistance: UILabel!
    
    @IBOutlet weak var labelDesignation: UILabel!
    
    @IBOutlet weak var verificationImageView: UIImageView!
    
    @IBOutlet var buttonRefund: UIButton!
    
    @IBOutlet var backGroundView : UIView!
    
    var rideParticipant : RideParticipant?
    var rideBillingDetails: RideBillingDetails?
    
    func initializeData(rideParticipant : RideParticipant?, rideBillingDetails: RideBillingDetails){
        self.rideParticipant = rideParticipant
        self.rideBillingDetails = rideBillingDetails
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if rideParticipant != nil {
            ImageCache.getInstance().setImageToView(imageView: self.imgPassengerPic, imageUrl: rideParticipant!.imageURI, gender: rideParticipant!.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        } else {
            self.imgPassengerPic.image = UIImage(named: "default_contact")
        }
        
        lableDistance.text = String(rideBillingDetails?.distance ?? 0)+" \(Strings.KM)"
        labelStartAddress.text = rideBillingDetails?.startLocation
        labelStartTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(rideBillingDetails?.startTimeMs ?? 0), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        labelEndAddress.text = rideBillingDetails?.endLocation
        labelFare.text = StringUtils.getStringFromDouble(decimalNumber: rideBillingDetails?.rideFare)
        var userId = 0
        if QRSessionManager.getInstance()!.getUserId() == String(rideBillingDetails?.fromUserId ?? 0) { // ride type: passenger
            labelPassengerName.text = rideBillingDetails?.toUserName
            userId = rideBillingDetails?.toUserId ?? 0
        }else {
            labelPassengerName.text = rideBillingDetails?.fromUserName
            userId = rideBillingDetails?.fromUserId ?? 0
        }
        UserDataCache.getInstance()?.getUserBasicInfo(userId: Double(userId), handler: {(userBasicInfo, responseError, error) in
            self.labelDesignation.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData, companyName: userBasicInfo?.companyName?.capitalized)
            if self.labelDesignation.text == Strings.not_verified {
                self.labelDesignation.textColor = UIColor.black
            }else{
                self.labelDesignation.textColor = UIColor(netHex: 0x24A647)
            }
            self.verificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData)
        })
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideContributionViewController.backGroundViewTapped(_:))))
        ViewCustomizationUtils.addBorderToView(view: buttonRefund, borderWidth: 1, colorCode: 0x0091EA)
    }
    
    @IBAction func refundButtonTapped(_ sender: Any) {
        if let rideParticipant = rideParticipant {
            self.handleRefundAction(rideParticipant : rideParticipant)
        }
    }
    
    func handleRefundAction(rideParticipant : RideParticipant){
        
        let refundAmountRequestAlertController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RefundAmountRequestAlertController") as! RefundAmountRequestAlertController
        refundAmountRequestAlertController.initializeDataBeforePresentingView(points: rideBillingDetails?.rideTakerTotalAmount ?? 0, handler: { (text, result) in
            if result == Strings.done_caps, let points = text{
                QuickRideProgressSpinner.startSpinner()
                AccountRestClient.riderRefundToPassenger(accountTransactionId: nil, points: points, rideId: Double(self.rideBillingDetails?.refId ?? ""), invoiceId: String(self.rideBillingDetails?.rideInvoiceNo ?? 0), viewController: self, completionHandler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                })
            }
        })
        self.navigationController?.view.addSubview(refundAmountRequestAlertController.view!)
        self.navigationController?.addChild(refundAmountRequestAlertController)
    }
    
    @objc func backGroundViewTapped(_ gesture: UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
