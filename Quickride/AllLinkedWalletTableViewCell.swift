//
//  AllLinkedWalletTableViewCell.swift
//  Quickride
//
//  Created by iDisha on 23/08/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation

class AllLinkedWalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewLinkedWallet: UIImageView!
    
    @IBOutlet weak var labelLinkedWalletOffer: UILabel!
    
    @IBOutlet weak var viewLinkedWallet: UIView!
    
    func initializeDataBasedOnWalletType(linkedWalletType: String){
        ViewCustomizationUtils.addBorderToView(view: viewLinkedWallet, borderWidth: 1, color: UIColor(netHex: 0xD6D6D6))
        for linkWallet in ConfigurationCache.getInstance()!.linkedWalletOffers{
            if linkedWalletType == linkWallet.walletType && linkWallet.offerText != nil{
                labelLinkedWalletOffer.isHidden = false
                labelLinkedWalletOffer.text = linkWallet.offerText
                break
            }else{
                labelLinkedWalletOffer.isHidden = true
            }
        }
        switch linkedWalletType {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            imageViewLinkedWallet.image = UIImage(named: "paytm_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            imageViewLinkedWallet.image = UIImage(named: "tmw_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            imageViewLinkedWallet.image = UIImage(named: "simpl_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            imageViewLinkedWallet.image = UIImage(named: "lazypay_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            imageViewLinkedWallet.image = UIImage(named : "amazon_pay")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            imageViewLinkedWallet.image = UIImage(named : "mobikwik_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            imageViewLinkedWallet.image = UIImage(named : "UPI_Image")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            imageViewLinkedWallet.image = UIImage(named : "frecharge_with_text")
        default:
            imageViewLinkedWallet.image = nil
            
        }
    }
    
}
