//
//  SetPaymentMethodViewModel.swift
//  Quickride
//
//  Created by Rajesab on 18/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SetPaymentMethodViewModel {

    var paymentMethodslist = [PaymentTypeInfo]()
    var payLaterLinkWalletOptions = [String]()
    var rechargeLinkWalletOptions = [String]()
    var upiLinkWalletOptions = [String]()
    var linkedWallets = [LinkedWallet]()
    var isPayLaterSelected = false
    var isWalletsOrGiftCardsSelected = false
    var isUPISelected = false
    var selectedIndex = -1
    var isDefaultPaymentModeCash = false
    var isRequiredToShowCash = false
    var isRequiredToShowCCDC = false
    var handler: linkedWalletActionCompletionHandler?
    
    init(isDefaultPaymentModeCash: Bool,isRequiredToShowCash: Bool, isRequiredToShowCCDC: Bool?, handler: linkedWalletActionCompletionHandler?){
        self.isDefaultPaymentModeCash = isDefaultPaymentModeCash
        self.isRequiredToShowCash = isRequiredToShowCash
        self.isRequiredToShowCCDC = isRequiredToShowCCDC ?? false
        self.handler = handler
    }

    init(){ }

    func setAvailablePaymentMethods(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        payLaterLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availablePayLaterOptions)
        rechargeLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availableWalletOptions)
        upiLinkWalletOptions = AccountUtils().checkAvailableUPIWalletValidOrNot(linkWallets: clientConfiguration.availableUpiOptions)
    }

    func removeLinkedTypeFromList(){
        guard let linkedWallets = UserDataCache.getInstance()?.getAllLinkedWallets() else { return }
        for linkedWallet in linkedWallets {
            if let index = rechargeLinkWalletOptions.firstIndex(of: linkedWallet.type ?? "") {
                rechargeLinkWalletOptions.remove(at: index)
            }
            if let index = payLaterLinkWalletOptions.firstIndex(of: linkedWallet.type ?? "") {
                payLaterLinkWalletOptions.remove(at: index)
            }
            if let index = upiLinkWalletOptions.firstIndex(of: linkedWallet.type ?? ""){
                upiLinkWalletOptions.remove(at: index)
            }
        }
    }

    func addAvailableWalletsToList(){
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

        let payByOtherModes = PaymentTypeInfo(paymentTypeImage: UIImage(named: "ic_cc_dd_icon")!, paymentType: Strings.pay_By_Other_Modes, paymentNamesList: Strings.pay_By_Other_Modes_Options)
        paymentMethodslist.append(payByOtherModes)

        let cashPayment = PaymentTypeInfo(paymentTypeImage: UIImage(named: "payment_type_cash")!, paymentType: Strings.payment_type_cash , paymentNamesList: "")
        paymentMethodslist.append(cashPayment)

        linkedWallets = UserDataCache.getInstance()!.getAllLinkedWallets()
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

    func isRequiredToShowPayByOtherModes() -> Bool{
        return isRequiredToShowCCDC
    }
}
