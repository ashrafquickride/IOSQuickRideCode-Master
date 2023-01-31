//
//  LinkedWalletXibTableViewCell.swift
//  Quickride
//
//  Created by iDisha on 27/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol LinkedWalletUpdateDelegate: class {
    func linkedWalletInfoChanged()
}

typealias refreshHandler = (_ refresh : Bool) -> Void


class LinkedWalletXibTableViewCell: UITableViewCell {

    @IBOutlet weak var linkedWalletInfoView: UIView!
    
    @IBOutlet weak var linkedWalletPoints: UILabel!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var linkedWalletImageView: UIImageView!
    
    @IBOutlet weak var linkedWalletText: UILabel!
    
    @IBOutlet weak var expiredLbl: UILabel!
    
    @IBOutlet weak var defaultLabel: UILabel!
    
    @IBOutlet weak var linkWalletTextTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var defaultLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var defaultLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var expiredLblLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    
    private var linkedWallet : LinkedWallet?
    weak var viewController: UIViewController?
    weak var listener : LinkedWalletUpdateDelegate?
    var refreshHandler: refreshHandler?
    
    func initializeDataInCell(linkedWallet: LinkedWallet,showSelectButton: Bool, viewController: UIViewController?, listener: LinkedWalletUpdateDelegate?){
        self.linkedWallet = linkedWallet
        self.viewController = viewController
        self.listener = listener
        setNameAndImage()
        if linkedWallet.balance != nil{
            linkedWalletPoints.isHidden = false
            self.linkedWalletPoints.text = StringUtils.getPointsInDecimal(points: linkedWallet.balance!)
        }else{
            linkedWalletPoints.text = nil
            linkedWalletPoints.isHidden = true
            linkWalletTextTopSpaceConstraint.constant = 15
        }
        if self.linkedWallet!.defaultWallet == false{
            defaultLabel.isHidden = true
            defaultLabelWidthConstraint.constant = 0
        }
        else{
            defaultLabel.isHidden = false
            defaultLabelWidthConstraint.constant = 65
        }
        if linkedWallet.status == Strings.expired_caps{
            expiredLbl.isHidden = false
            expiredLbl.text = Strings.expired_caps
            if defaultLabel.isHidden{
                expiredLblLeadingConstraint.constant = 0
            }
            else{
                expiredLblLeadingConstraint.constant = 5
            }
        }
        else{
            expiredLbl.isHidden = true
            expiredLblLeadingConstraint.constant = 0
            if self.linkedWallet!.defaultWallet && UserDataCache.getInstance()!.getAllLinkedWallets().count > 1{
                menuBtn.isHidden = true
            }
            else{
                menuBtn.isHidden = false
            }
        }
        if tag == 1 || tag == 2{
            menuBtn.isHidden = true
        }
        if showSelectButton{
            menuBtn.isHidden = true
            selectBtn.isHidden = false
            ViewCustomizationUtils.addCornerRadiusToView(view: selectBtn, cornerRadius: 5.0)
            ViewCustomizationUtils.addBorderToView(view: selectBtn, borderWidth: 1.0, color: UIColor(netHex: 0x2196F3))
        }else{
            selectBtn.isHidden = true
        }
        if !linkedWalletPoints.isHidden || !defaultLabel.isHidden || !expiredLbl.isHidden{
            self.linkWalletTextTopSpaceConstraint.constant = 0
        }
        else{
            self.linkWalletTextTopSpaceConstraint.constant = 15
        }
    }
    
    func initialiseHandler(refreshHandler: @escaping refreshHandler){
        self.refreshHandler = refreshHandler
    }
    
    private func setNameAndImage(){
        switch linkedWallet?.type{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            self.linkedWalletText.text = Strings.paytm_wallet
            self.linkedWalletImageView.image = UIImage(named : "paytm_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            self.linkedWalletText.text = Strings.tmw_wallet
            self.linkedWalletImageView.image = UIImage(named : "tmw_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            self.linkedWalletText.text = Strings.simpl_Wallet
            self.linkedWalletImageView.image = UIImage(named : "simpl_new")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            self.linkedWalletText.text = Strings.lazyPay_wallet
            self.linkedWalletImageView.image = UIImage(named : "lazypay_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            self.linkedWalletText.text = Strings.amazon_Wallet
            self.linkedWalletImageView.image = UIImage(named : "apay_linked_wallet")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            self.linkedWalletText.text = Strings.mobikwik_wallet
            self.linkedWalletImageView.image = UIImage(named : "mobikwik_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            self.linkedWalletText.text = Strings.upi
            self.linkedWalletImageView.image = UIImage(named : "upi")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            self.linkedWalletText.text = Strings.frecharge_wallet
            self.linkedWalletImageView.image = UIImage(named : "frecharge_logo")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            self.linkedWalletText.text = Strings.gpay
            self.linkedWalletImageView.image = UIImage(named : "gpay_icon_with_border")
        default:
            self.linkedWalletText.text = ""
            self.linkedWalletImageView.image = nil
        }
    }
    
    @IBAction func menuBtntapped(_ sender: Any) {
        if viewController == nil{
            return
        }
        let alertController = LinkedWalletAlertController(viewController: self.viewController!) { (result) -> Void in
            if result == Strings.make_default
            {
                self.updateDefaultLinkedWallet()
            }
            else if result ==  Strings.remove
            {
                self.removeSelectedLinkedWallet()
            }
            else if result ==  Strings.relink{
                self.relinkSelectedLinkedWallet()
            }
        }
        if self.linkedWallet?.status == Strings.expired_caps{
            alertController.reLinkAlertAction()
        }
        if self.linkedWallet!.defaultWallet == false{
            alertController.defaultAlertAction()
            alertController.removeAlertAction()
            defaultLabel.isHidden = true
        }
        else{
            defaultLabel.isHidden = false
            if UserDataCache.getInstance()?.getAllLinkedWallets().count == 1{
                alertController.removeAlertAction()
            }
        }
        alertController.cancelAlertAction()
        alertController.showAlertController()
    }
    
    private func removeSelectedLinkedWallet(){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.delete_linked_wallet_confirmation, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: nil) { (text) in
            if text == Strings.yes_caps{
                AccountUtils().removeLinkedWallet(linkedWallet: self.linkedWallet!,showError: true, viewController: self.viewController, handler: { (result) in
                    if let handler = self.refreshHandler {
                        handler(true)
                    }
                    self.listener?.linkedWalletInfoChanged()
                    self.walletAddedOrDeleted()
                })
            }
        }
    }
    
    func updateDefaultLinkedWallet() {
        AccountUtils().updateDefaultLinkedWallet(linkedWallet: self.linkedWallet!, viewController: viewController, listener: listener)
    }
    
    private func relinkSelectedLinkedWallet() {
        AccountUtils().linkRequestedWallet(walletType: linkedWallet!.type!) { (walletAdded, walletType) in
            if walletAdded{
                self.walletAddedOrDeleted()
            }
        }
    }
    
    private func walletAddedOrDeleted() {
        if self.viewController != nil && self.viewController!.isKind(of: WalletLinkingViewController.classForCoder()){
            if let walletLinkingViewController = self.viewController as? WalletLinkingViewController{
                walletLinkingViewController.walletAddedOrDeleted()
            }
        }
    }
    @IBAction func selectBtntapped(_ sender: Any) {
        updateDefaultLinkedWallet()
    }
    
}
