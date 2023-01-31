//
//  AccountPaymentViewModel.swift
//  Quickride
//
//  Created by Rajesab on 04/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AccountPaymentViewModel {
    var accountTransactionDetails : [AccountTransaction] = [AccountTransaction]()
    var linkedWallets = [LinkedWallet]()
    var rechargeLinkWalletOptions = [String]()
    var payLaterLinkWalletOptions = [String]()
    var upiLinkWalletOptions = [String]()
    var paymentMethodslist = [PaymentTypeInfo]()
    var selectedWalletSection = ""
    
    init() {
    }
    
    
    func addAllWalletsToList(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        self.rechargeLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availableWalletOptions)
        self.payLaterLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availablePayLaterOptions)
        self.upiLinkWalletOptions = AccountUtils().checkAvailableUPIWalletValidOrNot(linkWallets: clientConfiguration.availableUpiOptions)
    }
    
    func removeLinkedTypeFromList(){
        for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
            if let index = rechargeLinkWalletOptions.firstIndex(of: linkedWallet.type!) {
                rechargeLinkWalletOptions.remove(at: index)
            }
            if let index = payLaterLinkWalletOptions.firstIndex(of: linkedWallet.type!) {
                payLaterLinkWalletOptions.remove(at: index)
            }
            if let index = upiLinkWalletOptions.firstIndex(of: linkedWallet.type!){
                upiLinkWalletOptions.remove(at: index)
            }
        }
    }
    
    func isWalletAdded() -> Bool {
        if linkedWallets.count > 0 {
            return true
        }
        return false
    }
    
    func addAvailableWalletsToList(){
        paymentMethodslist.removeAll()
        let capitalizedPayLaterLinkWalletOptions = payLaterLinkWalletOptions.map {setNameForAllWallet(walletName: $0)}
        let payLaterOptions = capitalizedPayLaterLinkWalletOptions.joined(separator: ", ")
        let payLater = PaymentTypeInfo(paymentTypeImage: UIImage(named: "payments_pay_later")!, paymentType: Strings.pay_later_nonCaps, paymentNamesList: payLaterOptions)
        paymentMethodslist.append(payLater)
        
        let capitalizedRechargeLinkWalletOptions = rechargeLinkWalletOptions.map { setNameForAllWallet(walletName: $0)}
        let walletOrGiftCardsOptions = capitalizedRechargeLinkWalletOptions.joined(separator: ", ")
        let walletOrGiftCards = PaymentTypeInfo(paymentTypeImage: UIImage(named: "wallets_gift_cards")!, paymentType: Strings.wallets_or_gift_cards, paymentNamesList: walletOrGiftCardsOptions)
        paymentMethodslist.append(walletOrGiftCards)
        
        let capitalizedUpiLinkWalletOptions = upiLinkWalletOptions.map { setNameForAllWallet(walletName: $0)}
        let upiPaymentsOptions = capitalizedUpiLinkWalletOptions.joined(separator: ", ")
        let upiPayments = PaymentTypeInfo(paymentTypeImage: UIImage(named: "payment_method_upi")!, paymentType: Strings.upi, paymentNamesList: upiPaymentsOptions)
        paymentMethodslist.append(upiPayments)
    }
    
    private func setNameForAllWallet(walletName: String) -> String{
        switch walletName{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            return Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            return Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            return Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            return Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            return Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            return Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            return Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            return Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            return Strings.gpay
        default:
            return ""
        }
    }
    
    func getTransactionDetails(complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()) {
        AppDelegate.getAppDelegate().log.debug("getTransactionDetails()")
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getTransactionDetails(userId: UserDataCache.getCurrentUserId()) { (responseObject, error) -> Void in
            DispatchQueue.main.async(execute: {
                QuickRideProgressSpinner.stopSpinner()
            })
            let result = RestResponseParser<AccountTransaction>().parseArray(responseObject: responseObject, error: error)
            if let accountTransactionDetails = result.0 {
                self.filterTransactions(accountTransactions: accountTransactionDetails) { complition in
                    complitionHandler(result.1,result.2)
                }
            }
            complitionHandler(result.1,result.2)
        }
    }
    
    private func filterTransactions(accountTransactions: [AccountTransaction], handler: @escaping(_ complition: Bool)-> () ){
        let dateString = ConfigurationCache.getObjectClientConfiguration().accountTransactionsDisplayStartDate
        if let timestamp = DateUtils.getTimeStampFromString(dateString: dateString, dateFormat: DateUtils.DATE_FORMAT_DD_MM_YYYY){
            for transaction in accountTransactions{
                if let date = transaction.date, date > timestamp{
                    accountTransactionDetails.append(transaction)
                }
            }
        }else{
            accountTransactionDetails = accountTransactions
        }
        
        if !accountTransactionDetails.isEmpty {
        accountTransactionDetails = self.accountTransactionDetails.reversed()
            handler(true)
            return
        }
        handler(false)
    }
    
    func getAllLinkedWalletByUser(complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()){
        var linkedWalletTypes = [String]()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
            if clientConfiguration.availablePayLaterOptions.contains(linkedWallet.type!) || clientConfiguration.availableUpiOptions.contains(linkedWallet.type!){
                continue
            }
            linkedWalletTypes.append(linkedWallet.type!)
        }
        let linkedWalletTypesInString = linkedWalletTypes.joined(separator: ",")
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: QRSessionManager.getInstance()!.getUserId(), types: linkedWalletTypesInString, viewController: nil, handler: { (responseObject, error) in
            
            let result = RestResponseParser<LinkedWalletBalance>().parseArray(responseObject: responseObject, error: error)
            if let linkedWalletBalances = result.0 {
                for linkedWallet in self.linkedWallets{
                    if clientConfiguration.availablePayLaterOptions.contains(linkedWallet.type!) || clientConfiguration.availableUpiOptions.contains(linkedWallet.type!){
                        continue
                    }
                    for linkedWalletBalance in linkedWalletBalances{
                        if linkedWallet.type == linkedWalletBalance.type{
                            linkedWallet.balance = linkedWalletBalance.balance
                            break
                        }
                    }
                }
            }
            complitionHandler(result.1,result.2)
        })
    }
    
    func getTaxiTripInvoice(taxiRide: TaxiRidePassenger, complitionHandler: @escaping( _ taxiRideInvoice: TaxiRideInvoice?, _ cancelTaxiInvoices: [CancelTaxiRideInvoice]?, _ responseError: ResponseError?,_ error: NSError?)-> ()){
        if taxiRide.status == TaxiRidePassenger.STATUS_COMPLETED{
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getTaxiPoolInvoice(refId: taxiRide.id ?? 0) {(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                let result = RestResponseParser<TaxiRideInvoice>().parse(responseObject: responseObject, error: error)
                if let taxiRideInvoice = result.0 {
                    complitionHandler(taxiRideInvoice,nil,nil,nil)
                    return
                }
                
                complitionHandler(nil,nil,result.1,result.2)
            }
        }else{
            QuickRideProgressSpinner.startSpinner()
            TaxiPoolRestClient.getCancelTripInvoice(taxiRideId: taxiRide.id ?? 0 , userId: UserDataCache.getInstance()?.userId ?? "") {  (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                let result = RestResponseParser<CancelTaxiRideInvoice>().parseArray(responseObject: responseObject, error: error)
                if let cancelTaxiInvoices = result.0, !cancelTaxiInvoices.isEmpty {
                    var feeAppliedTaxiRides = [CancelTaxiRideInvoice]()
                    for cancelRideInvoice in cancelTaxiInvoices{
                        if cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER || cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
                            feeAppliedTaxiRides.append(cancelRideInvoice)
                        }
                    }
                    if !feeAppliedTaxiRides.isEmpty{
                        complitionHandler(nil,feeAppliedTaxiRides,nil,nil)
                        return
                    }
                }
                complitionHandler(nil,nil,result.1,result.2)
            }
        }
    }
    func getRiderBill(id : String, userId : String, complitionHandler: @escaping(_ rideBillingDetails: [RideBillingDetails]?, _ responseError: ResponseError?,_ error: NSError?)-> ()){
        BillRestClient.getRiderRideBillingDetails(id: id, userId: userId) { (responseObject, error) -> Void in
            let result = RestResponseParser<RideBillingDetails>().parseArray(responseObject: responseObject, error: error)
            if let rideBillingDetailslist = result.0 {
                complitionHandler(rideBillingDetailslist,nil,nil)
                return
            }
            complitionHandler(nil,result.1,result.2)
        }
    }
    
    func getPassengerBill(id : String,userId : String,complitionHandler: @escaping(_ rideBillingDetails: [RideBillingDetails]?, _ responseError: ResponseError?,_ error: NSError?)-> ()){
        BillRestClient.getPassengerRideBillingDetails(id: id , userId: userId, completionHandler: { (responseObject, error) in
            let result = RestResponseParser<RideBillingDetails>().parse(responseObject: responseObject, error: error)
            if let rideBillingDetails = result.0 {
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                complitionHandler(rideBillingDetailslist,nil,nil)
                return
            }
            complitionHandler(nil,result.1,result.2)
        })
    }
}

