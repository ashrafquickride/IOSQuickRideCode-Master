//
//  BillRideTakersTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 05/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import TrueSDK

typealias handlingactionOfImgView = (_ isFareBreakUpTapped : Bool) -> Void

class BillRideTakersTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var pointsShowingLabel: UILabel!
    @IBOutlet weak var viewFareBreakUpBtn: UIButton!
    @IBOutlet weak var riderWalletButton: UIButton!   
    @IBOutlet weak var dragDownAndUpImageView: UIImageView!
    //MARK: Variables
    private var verifiedImage = UIImage()
    private var companyname = ""
    private var tripReport: TripReport?
    private var rideParticipants = [RideParticipant]()
    private var delegate: UserDetailsTableViewCellDelegate?
    private var viewModel: BillViewModel?
   
    
    func initializeRiderRidePassengers(viewModel: BillViewModel? ,delegate: UserDetailsTableViewCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        if viewModel?.rideBillingDetails?.count ?? 0 > 1{
            viewFareBreakUpBtn.isHidden = true
            dragDownAndUpImageView.isHidden = true
            
        }else {
            viewFareBreakUpBtn.isHidden = false
            dragDownAndUpImageView.isHidden = false
            
        }
        var riderEarnedPoints = 0.0
        if let rideBillingDetails = viewModel?.rideBillingDetails {
            for rideBillingDetail in rideBillingDetails {
                riderEarnedPoints = riderEarnedPoints + (rideBillingDetail.rideGiverNetAmount ?? 0)
            }
        }
        
        if viewModel?.isExpanableBill == true {
            dragDownAndUpImageView.image = UIImage(named: "up_arrow_blue")
        }else {
            dragDownAndUpImageView.image = UIImage(named: "down_arrow_blue")
        }
        
        
        pointsShowingLabel.text = StringUtils.getPointsInDecimal(points: riderEarnedPoints) + " Points Credited"
        if let riderData = UserDataCache.getInstance()?.userProfile {
            verifiedImage =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: riderData.profileVerificationData)
           companyname = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: riderData.profileVerificationData, companyName: riderData.companyName?.capitalized)
        }
        if UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            riderWalletButton.setTitle(getWalletName(type: UserDataCache.getInstance()!.getDefaultLinkedWallet()!.type ?? ""), for: .normal)
        }else{
            riderWalletButton.setTitle(Strings.quickride, for: .normal)
           
        }
        riderWalletButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
    }
    

    
    
   

    
    @IBAction func riderWalletButtonTapped(_ sender: Any) {
        let transactionVC:TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionVC.intialisingData(isFromRewardHistory: false)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: transactionVC, animated: false)
    }
    
    @IBAction func viewfarePressed(_ sender: UIButton) {
        delegate?.viewFareDetailsPressed()
    }
    
    private func getWalletName(type: String) -> String {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            return Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            return Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            return Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            return Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            return Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            return Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            return Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            return Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            return Strings.gpay
        default:
            return ""
        }
    }
    
}
    

extension BillRideTakersTableViewCell: FareDetailsTableViewCellDelegate {
    func insuranceInfoTapped() {
        delegate?.showInsuranceView()
    }
    func routeMapButtonTapped(data: Bool) {
        delegate?.viewMapPressed(data: data)
    }
    
}
