//
//  CancelRideBillViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol GetOppositeUser{
    func preparedOppositeUserList()
}

class CancelRideBillViewModel{
    
    var ride: Ride?
    var rideCancellationReports = [RideCancellationReport]()
    var invoices = [Invoice]()
    var limitedTxnWallets = [LimitedWalletTransactions]()
    var shareAndEarnOffers = [ShareAndEarnOffer]()
    var rewardsTermsAndConditions = [String : [String]]()
    var userBasicInfos = [UserBasicInfo]()
    var shownReports = 0
    var compensetionNotApplied = false
    
    //Passenger data
    var reservedPoints: String?
    var cancellationFee: String?
    var totalRefundPoints: String?
    var rideTakerWalletAmounts = [String: Double]()
    var showedWallets = 0
    var oppositeUsers = [OppositeUser]()
    
    
    func checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: GetOppositeUser){
        oppositeUsers.removeAll()
        shownReports = 0
        showedWallets = 0
        for report in rideCancellationReports{
            var userId = 0.0
            if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                userId = Double(report.cancelledFromUserId ?? 0)
            }else{
                userId = Double(report.cancelledUserId ?? 0)
            }
            var user: UserBasicInfo?
            for userBasicInfo in userBasicInfos{
                if userBasicInfo.userId == userId{
                    user = userBasicInfo
                    break
                }
            }
            var cancellationFeeType: String?
            var color = UIColor.black.withAlphaComponent(0.6)
            if ride?.rideType == Ride.RIDER_RIDE{
                compensetionNotApplied = false
                if report.waveOff == RideCancellationReport.WAVEOFF_BY_SYSTEM || report.waveOff == Ride.PASSENGER_RIDE || report.waveOff == Ride.RIDER_RIDE{
                    cancellationFeeType = Strings.waived_off
                    color = UIColor(netHex: 0x00b557)
                }else if report.compensationCanBeApplied == true && report.waveOff == RideCancellationReport.WAVEOFF_BY_FREE_CANCELLATIONS{
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = Strings.lost_free_cancel
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }
                        }else{
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }
                        }
                    }
                }else if report.compensationCanBeApplied && report.waveOff == nil{
                    let invoice = getInvoiceForCancelReport(passengerRideId: report.passengerRideId ?? 0)
                    var amount = ""
                    if invoice != nil{
                        if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.amount)
                        }else{
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.netAmountPaid)
                        }
                    }
                    
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = String(format: Strings.charged_points, arguments: [amount])
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        cancellationFeeType = String(format: Strings.got_points, arguments: [amount])
                    }
                }else{
                    compensetionNotApplied = true
                }
            }else{
                if report.waveOff == RideCancellationReport.WAVEOFF_BY_SYSTEM{
                    cancellationFeeType = Strings.waived_off
                    color = UIColor(netHex: 0x00b557)
                }else if report.waveOff == Ride.PASSENGER_RIDE || report.waveOff == Ride.RIDER_RIDE{
                    cancellationFeeType = String(format: Strings.waived_off_opposite, arguments: [(user?.name ?? "")])
                    color = UIColor(netHex: 0x00b557)
                }else if report.compensationCanBeApplied == true && report.waveOff == RideCancellationReport.WAVEOFF_BY_FREE_CANCELLATIONS{
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = Strings.lost_free_cancel
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }
                        }else{
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }
                        }
                    }
                }else if report.compensationCanBeApplied && report.waveOff == nil{
                    let invoice = getInvoiceForCancelReport(passengerRideId: report.passengerRideId ?? 0)
                    var amount = ""
                    if invoice != nil{
                        if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.amount)
                        }else{
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.netAmountPaid)
                        }
                    }
                    
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = String(format: Strings.charged_points, arguments: [amount])
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        cancellationFeeType = String(format: Strings.got_points, arguments: [amount])
                    }
                }else{
                    compensetionNotApplied = true
                }
            }
            if !compensetionNotApplied{
                oppositeUsers.append(OppositeUser(name: user?.name, imageUrl: user?.imageURI, gender: user?.gender, type: "Unjoined", feeType: cancellationFeeType, color: color))
            }
        }
        delegate.preparedOppositeUserList()
    }
    
    private func getInvoiceForCancelReport(passengerRideId: Int) -> Invoice?{
        for invoice in invoices{
            if Int(invoice.refId ?? "") == passengerRideId{
                return invoice
            }
        }
        return nil
    }
    
    func getUserBasicInfo(delegate: GetOppositeUser){
        var reports = 0
        for report in rideCancellationReports{
            var userId = 0.0
            if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                userId = Double(report.cancelledFromUserId ?? 0)
            }else{
                userId = Double(report.cancelledUserId ?? 0)
            }
            UserRestClient.getUserBasicInfo(userId: userId, viewController: nil) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let userBasicInfo = Mapper<UserBasicInfo>().map(JSONObject: responseObject!["resultData"]){
                        self.userBasicInfos.append(userBasicInfo)
                    }
                    reports += 1
                    if reports == self.rideCancellationReports.count{
                       self.checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: delegate)
                    }
                }
            }
        }
    }
    
    func cancellationAmountOnRiderCheckWallet(delegate: GetOppositeUser){
        for lmtdTxnWallet in limitedTxnWallets{
            if lmtdTxnWallet.walletType == LimitedWalletTransactions.QRWALLET{
                rideTakerWalletAmounts[Strings.quickride_wallet] = lmtdTxnWallet.amount
            }else if let otherWallet = lmtdTxnWallet.walletProvider{
                rideTakerWalletAmounts[otherWallet] = lmtdTxnWallet.amount
            }
            if lmtdTxnWallet.txnType == LimitedWalletTransactions.RESERVED{
                reservedPoints = StringUtils.getStringFromDouble(decimalNumber: lmtdTxnWallet.amount)
            }else if lmtdTxnWallet.txnType == LimitedWalletTransactions.RELEASED{
                totalRefundPoints = StringUtils.getStringFromDouble(decimalNumber: lmtdTxnWallet.amount)
            }
        }
        checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: delegate)
    }
    
    func getLimitedWalletTransactions(delegate: GetOppositeUser){
        QuickRideProgressSpinner.startSpinner()
        BillRestClient.getRideCancellationWalletTransaction(userId: UserDataCache.getInstance()?.userId ?? "" , passengerRideId: ride?.rideId ?? 0, completionHandler: {(responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.limitedTxnWallets = Mapper<LimitedWalletTransactions>().mapArray(JSONObject: responseObject!["resultData"]) ?? [LimitedWalletTransactions]()
                self.cancellationAmountOnRiderCheckWallet(delegate: delegate)
            }
        })
    }
    
    func getInvoiceForCancelledRide(delegate: GetOppositeUser){
        QuickRideProgressSpinner.startSpinner()
        BillRestClient.getRideCancellationInvoice(userId: UserDataCache.getInstance()?.userId ?? "", rideId: ride?.rideId ?? 0, rideType: ride?.rideType ?? "", completionHandler: {(responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.invoices = Mapper<Invoice>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Invoice]()
                self.checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: delegate)
            }
        })
    }
    
    func getNoOfRows() -> Int{
        if rideCancellationReports.isEmpty || compensetionNotApplied{
            return 2
        }else if ride?.rideType == Ride.RIDER_RIDE{
            return 3 + oppositeUsers.count
        }else{
            if rideTakerWalletAmounts.keys.count > 0{
                return 5 + rideTakerWalletAmounts.keys.count
            }else{
                return 4
            }
        }
    }
    
    func prepareOfferListAndUpdateUI() {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        ReferAndRewardsTermsAndConditionDetailsParser.getInstance().getRewardsTermsAndConditionElement{ (rewardsTermsAndConditions) in
            for termsAndCondtion in rewardsTermsAndConditions!.referAndRewardsTermsAndConditions!{
                self.rewardsTermsAndConditions.updateValue(termsAndCondtion.terms_and_conditions!, forKey: termsAndCondtion.type!)
            }
            if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                self.shareAndEarnOffers.append(ShareAndEarnOffer(type: RewardsTermsAndConditions.REFER_FRIENDS, title:String(format: Strings.refer_and_earn_title, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), rewardDetailIamge: UIImage(named: "refer_earn_image")!, backGroundColor: [UIColor(netHex: 0xF50364)], buttonText: Strings.refer_now, termsAndCondition: self.rewardsTermsAndConditions[RewardsTermsAndConditions.REFER_FRIENDS]!, stepOneTitle: String(format: Strings.refer_earn_title1, arguments: [String(pointsAfterVerification)]), stepTwoTitle: String(format: Strings.refer_earn_title2, arguments: [String(pointsAfterFirstRide)]), stepThreeTitle: String(format: Strings.refer_earn_title3, arguments: [String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), stepOneText: Strings.refer_earn_desc1, stepThreeText: Strings.refer_earn_desc3, referralCode: true, sampleEmail: false,stepTwoText: Strings.refer_earn_desc2))
            }
        }
    }
}
struct OppositeUser {
    var name: String?
    var imageUrl: String?
    var gender: String?
    var type: String?
    var feeType: String?
    var color: UIColor?
    
    init(name: String?,imageUrl: String?,gender: String?,type: String?,feeType: String?,color: UIColor) {
        self.name = name
        self.imageUrl = imageUrl
        self.gender = gender
        self.type = type
        self.feeType = feeType
        self.color = color
    }
}
