//
//  WalletLinkingViewController.swift
//  Quickride
//
//  Created by Admin on 09/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import SimplZeroClick


class WalletLinkingViewController : UIViewController{
    
    
    @IBOutlet weak var redemptionLinkWalletTableView: UITableView!
    
    @IBOutlet weak var redemptionLinkWalletTableViewHieghtConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkedWalletTableView: UITableView!
    
    @IBOutlet weak var linkedWalletTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkedWalletTitle: UILabel!
    
    var walletOptions = [String]()
    var rechargeLinkWalletOptions = [String]()
    var payLaterLinkWalletOptions = [String]()
    var redemptionLinkWalletOptions = [String]()
    var upiLinkWalletOptions = [String]()
    var linkedWallets = [LinkedWallet]()
    var paymentMethodslist = [PaymentTypeInfo]()
    var selectedWalletSection = ""

    func checkWhetherWalletLinkedAndAdjustViews(){
        linkedWallets = UserDataCache.getInstance()!.getAllLinkedWallets()
//        if linkedWallets.isEmpty == false{
            linkedWalletTitle.isHidden = false
            addAllWalletsToList()
            handleAddWallet()
            removeLinkedTypeFromList()
            addAvailableWalletsToList()
            linkedWalletTableView.reloadData()
            var linkedWalletTypes = [String]()
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
                if clientConfiguration.availablePayLaterOptions.contains(linkedWallet.type!) || clientConfiguration.availableUpiOptions.contains(linkedWallet.type!){
                    continue
                }
                linkedWalletTypes.append(linkedWallet.type!)
            }
            let linkedWalletTypesInString = linkedWalletTypes.joined(separator: ",")
            AccountRestClient.getLinkedWalletBalancesOfUser(userId: QRSessionManager.getInstance()!.getUserId(), types: linkedWalletTypesInString, viewController: self, handler: { (responseObject, error) in
                self.handleLinkedWalletResponse(responseObject: responseObject, error: error, clientConfiguration: clientConfiguration)
            })
            
//        }else{
//            linkedWalletTitle.isHidden = true
//            addAllWalletsToList()
////            linkedWalletTableView.isHidden = true
////            linkedWalletTableViewHeightConstraint.constant = 0
//        }
        handleTableViewAfterLinkAndDelete()
    }
    func handleAddWallet(){
    
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
    
    func handleLinkedWalletResponse(responseObject : NSDictionary?,error : NSError?, clientConfiguration: ClientConfigurtion){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
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
            linkedWalletTableView.reloadData()
        }else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
        
    }
    func handleTableViewAfterLinkAndDelete(){
        
    }
    func handleSimplWalletError(errorResponse : ResponseError){
     
    }

    func removeLinkedTypeFromList(){
        for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
            if let index = rechargeLinkWalletOptions.firstIndex(of: linkedWallet.type!) {
                rechargeLinkWalletOptions.remove(at: index)
            }
            if let index = payLaterLinkWalletOptions.firstIndex(of: linkedWallet.type!) {
                payLaterLinkWalletOptions.remove(at: index)
            }
            if let index = redemptionLinkWalletOptions.firstIndex(of: linkedWallet.type!){
                redemptionLinkWalletOptions.remove(at: index)
            }
            if let index = upiLinkWalletOptions.firstIndex(of: linkedWallet.type!){
                upiLinkWalletOptions.remove(at: index)
            }
        }
    }
    
    func addAllWalletsToList(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        self.rechargeLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availableWalletOptions)
        self.payLaterLinkWalletOptions = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availablePayLaterOptions)
        self.redemptionLinkWalletOptions = AccountUtils().checkAvailableRedemptionWalletsValidOrNot(linkWallets: clientConfiguration.availableRedemptionWalletOptions)
        self.upiLinkWalletOptions = AccountUtils().checkAvailableUPIWalletValidOrNot(linkWallets: clientConfiguration.availableUpiOptions)
    }
    
    func walletAddedOrDeleted(){
        checkWhetherWalletLinkedAndAdjustViews()
    }
    
    func setTableViewHeight() -> CGFloat{
        var tableViewHeight = 0.0
        if linkedWallets.count > 0{
            tableViewHeight = Double((linkedWallets.count * 72) + 60)
        } else if selectedWalletSection == AccountPaymentViewController.PAY_LATER  {
            tableViewHeight = Double((payLaterLinkWalletOptions.count * 71) + (65 * 3))
        }else if selectedWalletSection == AccountPaymentViewController.WALLETS_OR_GIFT_CARDS{
            tableViewHeight = Double((rechargeLinkWalletOptions.count * 71) + (65 * 3))
        }else if selectedWalletSection == AccountPaymentViewController.U_P_I {
            tableViewHeight = Double((upiLinkWalletOptions.count * 71) + (65 * 3))
        }else {
            tableViewHeight =  65 * 3
        }
        return tableViewHeight
    }
}
