//
//  CommonWalletImageTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CommonWalletImageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var walletImgView: UIImageView!
    
    func intialiseDataForImg(walletType: String){
        
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            walletImgView.image = UIImage(named: "paytm_logo")
        }
        else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_TMW{
            walletImgView.image = UIImage(named: "tmw")
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
            walletImgView.image = UIImage(named: "mobikwik_logo_with_text")
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
            walletImgView.image = UIImage(named: "frecharge_with_text")
        } else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL {
            walletImgView.image =  UIImage(named: "simpl_logo_with_text")
        } else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY {
            walletImgView.image =  UIImage(named: "lazypay_logo_with_text")
        } else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
            walletImgView.image =  UIImage(named: "amazon_pay")
        } else if  walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE {
            walletImgView.image =  UIImage(named: "gpay_icon")
        }  else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
            walletImgView.image = UIImage(named : "UPI_Image")
        }
    }
}
    

