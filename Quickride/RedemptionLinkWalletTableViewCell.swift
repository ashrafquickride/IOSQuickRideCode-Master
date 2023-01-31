//
//  RedemptionLinkWalletTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 07/08/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation

class RedemptionLinkWalletTableViewCell: RechargeLinkWalletTableViewCell{
    
    override func initializeDataInCell(walletType: String, index: Int, viewController: UIViewController){
        self.walletType = walletType
        self.viewController = viewController
        ViewCustomizationUtils.addCornerRadiusToView(view: linkButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: linkButton, borderWidth: 1.0, color: UIColor(netHex: 0x2196F3))
        setNameAndImagetoWallet()
    }
    func setNameAndImagetoWallet(){
        infoButton.isHidden = true
        switch walletType{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletName.text = Strings.paytm_wallet
            walletImage.image = UIImage(named: "paytm_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletName.text = Strings.tmw
            walletImage.image = UIImage(named: "tmw_new")
            infoButton.isHidden = false
        default:
            walletName.text = nil
            walletImage.image = nil
        }
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        if UserDataCache.getInstance()?.linkedWallet != nil{
            MessageDisplay.displayAlert(messageString: String(format: Strings.linked_wallet_error_msg, arguments: [UserDataCache.getInstance()!.linkedWallet!.type!]), viewController: nil, handler: nil)
            return
        }
        if self.viewController!.isKind(of: EncashPaymentViewController.classForCoder()){
            if let encashPaymentViewController = self.viewController as? EncashPaymentViewController{
                
                if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
                    encashPaymentViewController.encashConfirmation(encashType: EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM)
                }else{
                    encashPaymentViewController.encashConfirmation(encashType: EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW)
                }
            }
        }
    }
}
