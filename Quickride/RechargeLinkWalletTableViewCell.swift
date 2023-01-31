//
//  RechargeLinkWalletTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 07/08/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class RechargeLinkWalletTableViewCell: UITableViewCell{
    
    @IBOutlet weak var walletImage: UIImageView!
    
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var offerTextLbl: UILabel!
    
    @IBOutlet weak var walletNameTopSpaceConstraint: NSLayoutConstraint!
    
    var walletType : String?
    var viewController : UIViewController?
    
    
    func initializeDataInCell(walletType: String, index: Int, viewController: UIViewController){
        self.walletType = walletType
        self.viewController = viewController
        ViewCustomizationUtils.addCornerRadiusToView(view: linkButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: linkButton, borderWidth: 1.0, color: UIColor(netHex: 0x2196F3))
        setNameAndImage()
        setOffer()
    }
    func setNameAndImage(){
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
        default:
            walletName.text = nil
            walletImage.image = nil
        }
    }
    func setOffer(){
        if let linkWalletOffers = ConfigurationCache.getInstance()?.linkedWalletOffers{
            for linkWallet in linkWalletOffers{
                if walletType == linkWallet.walletType && linkWallet.offerText != nil{
                    offerTextLbl.isHidden = false
                    offerTextLbl.text = linkWallet.offerText
                    walletNameTopSpaceConstraint.constant = -8
                    break
                }else{
                    offerTextLbl.isHidden = true
                    walletNameTopSpaceConstraint.constant = 0
                }
            }
        }
    }
    @IBAction func linkBtnTapped(_ sender: Any) {
        if UserDataCache.getInstance()?.linkedWallet != nil{
            MessageDisplay.displayAlert(messageString: String(format: Strings.linked_wallet_error_msg, arguments: [UserDataCache.getInstance()!.linkedWallet!.type!]), viewController: viewController!, handler: nil)
        }else{
            AccountUtils().linkRequestedWallet(walletType: walletType!, viewController: viewController!){ (walletAdded, walletType) in
                if walletAdded{
                    self.walletAdded()
                }
            }
        }
        
    }
    func walletAdded(){
        if self.viewController!.isKind(of: WalletLinkingViewController.classForCoder()){
            if let walletLinkingViewController = self.viewController as? WalletLinkingViewController{
                walletLinkingViewController.walletAdded()
            }
        }
    }
    
    @IBAction func tmwInfoBtnTapped(_ sender: Any) {
        let tmwRegistrationController : TMWRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWRegistrationViewController") as! TMWRegistrationViewController
        viewController?.navigationController?.view.addSubview(tmwRegistrationController.view)
        viewController?.navigationController?.addChild(tmwRegistrationController)
    }
}
