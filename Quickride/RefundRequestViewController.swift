//
//  RefundRequestViewController.swift
//  Quickride
//
//  Created by Vinutha on 07/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RefundRequestViewController: UIViewController {

    //MARK: OUtlets
    @IBOutlet weak var requestFromLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userVerificationImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var userImage1: UIImageView!
    @IBOutlet weak var userImage2: UIImageView!
    @IBOutlet weak var participantCountLabel: UILabel!
    @IBOutlet weak var rideDateView: UIView!
    
    private var refundRequestViewModel = RefundRequestViewModel()
    
    func initializerefundData(RefundRequest: RefundRequest){
        refundRequestViewModel = RefundRequestViewModel(refundRequest: RefundRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refundRequestViewModel.getRefundRideAndParticipants()
        refundRequestViewModel.getUserbasicInfo(delegate: self)
        setUpUi()
        let riderRideId = Double(refundRequestViewModel.refundRequest?.sourceRefId ?? "") ?? 0
        MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipants(riderRideId: riderRideId, rideParticipantsListener: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setUpUi(){
        requestFromLabel.text = String(format: Strings.refund_request_from, arguments: [(refundRequestViewModel.refundRequest?.fromUserName ?? "")])
        reasonLabel.text = String(format: Strings.refund_reason, arguments: [(refundRequestViewModel.refundRequest?.reason ?? "")])
        userNameLabel.text = refundRequestViewModel.refundRequest?.fromUserName
        userImage.image = UIImage(named: "default_contact")
        loadingImage.isHidden = false
        
        //Ride details
        fromLabel.text = refundRequestViewModel.ride?.startAddress
        toLabel.text = refundRequestViewModel.ride?.endAddress
        ViewCustomizationUtils.addBorderToView(view: rideDateView, borderWidth: 1, color: UIColor(netHex: 0xD4D4D4))
        timeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequestViewModel.ride?.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        dayLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequestViewModel.ride?.startTime, timeFormat: DateUtils.DATE_FORMAT_EE)?.uppercased()
        dateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequestViewModel.ride?.startTime, timeFormat: DateUtils.DATE_FORMAT_dd)
        monthLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequestViewModel.ride?.startTime, timeFormat: DateUtils.DATE_FORMAT_MMM)?.uppercased()
        amountLabel.text = String(format: Strings.refund_amount, arguments: [StringUtils.getStringFromDouble(decimalNumber: refundRequestViewModel.refundRequest?.points)])
    }
    
    private func showRideParticipants(rideParticipants : [RideParticipant]){
        var participants = [RideParticipant]()
        for rideParticipant in rideParticipants{
            if StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId) != UserDataCache.getInstance()?.userId{
                participants.append(rideParticipant)
            }
        }
        switch participants.count {
        case 0:
            userImage1.isHidden = true
            userImage2.isHidden = true
            participantCountLabel.isHidden = true
        case 1:
            ImageCache.getInstance().setImageToView(imageView: userImage1, imageUrl: participants[0].imageURI, gender: participants[0].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            userImage1.isHidden = false
            userImage2.isHidden = true
            participantCountLabel.isHidden = true
        case 2:
            ImageCache.getInstance().setImageToView(imageView: userImage1, imageUrl: participants[0].imageURI, gender: participants[0].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            ImageCache.getInstance().setImageToView(imageView: userImage1, imageUrl: participants[0].imageURI, gender: participants[0].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            userImage1.isHidden = false
            userImage2.isHidden = false
            participantCountLabel.isHidden = true
        default:
            ImageCache.getInstance().setImageToView(imageView: userImage1, imageUrl: participants[0].imageURI, gender: participants[0].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            ImageCache.getInstance().setImageToView(imageView: userImage1, imageUrl: participants[0].imageURI, gender: participants[0].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            participantCountLabel.text = "+" + String(participants.count - 2)
            userImage1.isHidden = false
            userImage2.isHidden = false
            participantCountLabel.isHidden = false
        }
    }
    
    @IBAction func approveButtonTapped(_ sender: UIButton){
        refundRequestViewModel.refundToRequestedUser(delagte: self)
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        let refundRejectReasonsViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RefundRejectReasonsViewController") as! RefundRejectReasonsViewController
        let reasons = [String(format: Strings.user_taken_ride, arguments: [(refundRequestViewModel.refundRequest?.fromUserName ?? "")]),Strings.other]
        refundRejectReasonsViewController.initializeReasons(reasons: reasons, actionName: Strings.reject_action_caps, handler: { (rejectReason) in
            self.refundRequestViewModel.rejectRequest(reason: rejectReason ?? "", delegate: self)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: refundRejectReasonsViewController)
    }
}
//RideParticipantsListener
extension RefundRequestViewController: RideParticipantsListener{
    func getRideParticipants(rideParticipants : [RideParticipant]){
        AppDelegate.getAppDelegate().log.debug("\(rideParticipants)")
        loadingImage.isHidden = true
        for rideParticipant in rideParticipants{
            if Int(rideParticipant.userId) == refundRequestViewModel.refundRequest?.fromUserId{
                timeLabel.text = (DateUtils.getTimeStringFromTimeInMillis(timeStamp: refundRequestViewModel.ride?.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? "") + ", \(rideParticipant.noOfSeats) Seat"
            }
        }
        showRideParticipants(rideParticipants: rideParticipants)
    }
    func onFailure(responseObject: NSDictionary?, error: NSError?) {
        loadingImage.isHidden = true
    }
}

extension RefundRequestViewController: RefundRequestApproved{
    func refundApproved() {
        UIApplication.shared.keyWindow?.makeToast( Strings.refund_approved)
       self.navigationController?.popViewController(animated: false)
    }
    
    func refundApprovalFailed(responseObject: NSDictionary?,error: NSError?) {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        self.navigationController?.popViewController(animated: false)
    }
}

extension RefundRequestViewController: GetRequestedUserDetails{
    func recievedRequestedUserInfo() {
        ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: refundRequestViewModel.userBasicInfo?.imageURI, gender: refundRequestViewModel.userBasicInfo?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        userVerificationImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: refundRequestViewModel.userBasicInfo?.profileVerificationData)
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: refundRequestViewModel.userBasicInfo?.profileVerificationData, companyName: refundRequestViewModel.userBasicInfo?.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
    }
}
extension RefundRequestViewController: RefundRequestReject{
    func refundRequestRejected() {
        UIApplication.shared.keyWindow?.makeToast( Strings.refund_rejected)
        self.navigationController?.popViewController(animated: false)
    }
    
    func refundRejectionFailed(responseObject: NSDictionary?,error: NSError?) {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        self.navigationController?.popViewController(animated: false)
    }
}
