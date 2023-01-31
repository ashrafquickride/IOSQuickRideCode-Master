//
//  AllLinkWalletXibTableViewCell.swift
//  Quickride
//
//  Created by iDisha on 03/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol LinkWalletReceiver: class {
    func linkWallet(walletType: String)
}

class AllLinkWalletXibTableViewCell: UITableViewCell {

    @IBOutlet weak var walletImage: UIImageView!
    
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var offerTextLbl: UILabel!
    
    @IBOutlet weak var walletNameCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var walletImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var separatorView: UIView!
    
    private var walletType : String?
    weak var viewController : UIViewController?
    weak var linkWalletHandler: LinkWalletReceiver?
    private var isRedemptionLinkWallet = false
    
    func initializeDataInCell(walletType: String, isRedemptionLinkWallet: Bool, viewController: UIViewController, linkWalletReceiver: LinkWalletReceiver?){
        self.walletType = walletType
        self.isRedemptionLinkWallet = isRedemptionLinkWallet
        self.viewController = viewController
        self.linkWalletHandler = linkWalletReceiver
        if self.viewController!.isKind(of: EncashPaymentViewController.classForCoder()){
            setNameAndImageForRedemptionWallet()
        }
        else{
            setOffer()
            setNameAndImageForAllWallet()
        }
        
    }
    
    private func setNameAndImageForAllWallet(){
        infoButton.isHidden = true
        switch walletType{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletName.text = Strings.paytm_wallet
            walletImage.image = UIImage(named: "paytm_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletName.text = Strings.tmw
            walletImage.image = UIImage(named: "tmw_new")
            infoButton.isHidden = false
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletName.text = Strings.simpl_Wallet
            walletImage.image = UIImage(named: "simpl_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletName.text = Strings.lazyPay_wallet
            walletImage.image = UIImage(named: "lazypay_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletName.text = Strings.amazon_Wallet
            walletImage.image = UIImage(named : "apay_linked_wallet")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletName.text = Strings.mobikwik_wallet
            walletImage.image = UIImage(named : "mobikwik_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletName.text = Strings.upi
            walletImage.image = UIImage(named : "upi")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletName.text = Strings.frecharge_wallet
            walletImage.image = UIImage(named: "frecharge_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletName.text = Strings.gpay
            walletImage.image = UIImage(named : "gpay_icon_with_border")
        default:
            walletName.text = nil
            walletImage.image = nil
        }
    }
    private func setNameAndImageForRedemptionWallet(){
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
            walletName.text = ""
            walletImage.image = nil
        }
    }
    private func setOffer(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        for linkWallet in clientConfiguration.linkedWalletOffers{
            if walletType == linkWallet.walletType && linkWallet.offerText != nil{
                offerTextLbl.isHidden = false
                offerTextLbl.text = linkWallet.offerText
                walletNameCenterYConstraint.constant = -8
                break
            }else{
                offerTextLbl.isHidden = true
                walletNameCenterYConstraint.constant = 0
            }
        }
    }
    @IBAction func linkBtnTapped(_ sender: AnyObject) {
        if self.viewController == nil{
            return
        }
       continueLinkingWallet(linkButtonTag: sender.tag)
    }
    
    private func continueLinkingWallet(linkButtonTag: Int){
        if linkButtonTag == 1{
            self.linkWalletHandler?.linkWallet(walletType: self.walletType!)
            return
        }
            AccountUtils().linkRequestedWallet(walletType: self.walletType!){ (walletAdded, walletType) in
                if walletAdded{
                    self.linkWalletHandler?.linkWallet(walletType: self.walletType!)
                    self.walletAdded()
                }
            }
    }
    private func walletAdded(){
        if self.viewController != nil && self.viewController!.isKind(of: WalletLinkingViewController.classForCoder()){
            if let walletLinkingViewController = self.viewController as? WalletLinkingViewController{
                walletLinkingViewController.walletAddedOrDeleted()
            }
        }
    }
    
    @IBAction func tmwInfoBtnTapped(_ sender: Any) {
        let tmwRegistrationController : TMWRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWRegistrationViewController") as! TMWRegistrationViewController
        viewController?.navigationController?.view.addSubview(tmwRegistrationController.view)
        viewController?.navigationController?.addChild(tmwRegistrationController)
    }
}
