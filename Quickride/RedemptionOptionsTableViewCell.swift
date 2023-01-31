//
//  RedemptionOptionsTableViewCell.swift
//  Quickride
//
//  Created by iDisha on 11/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RedemptionOptionsTableViewCell: UITableViewCell{
    
    @IBOutlet weak var encashOptionSelectionImage: UIImageView!
    
    @IBOutlet weak var encashOptionLabel: UILabel!
    
    @IBOutlet weak var infoIconButton: UIButton!
    
    @IBOutlet weak var redeemTypeIconBtn: UIButton!
    
    @IBOutlet weak var cashBackLabel: UILabel!
    
    weak var viewController: UIViewController?
    var option : String?
    var cardStatus : String?
    
    func initializeView(option: String, selectedRow: Int, index: Int,cardStatus: String?,viewController: UIViewController){
        if index == selectedRow{
           encashOptionSelectionImage.image = UIImage(named: "selected")
        }else{
           encashOptionSelectionImage.image = UIImage(named: "unselected")
        }
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if option == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY && clientConfiguration!.amazonPayRedemptionBonusPercent > 0{
            cashBackLabel.isHidden = false
            cashBackLabel.text = String(format: Strings.amazon_pay_cashback_offer, arguments: [String(clientConfiguration!.amazonPayRedemptionBonusPercent),Strings.percentage_symbol])
        }else if option == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            cashBackLabel.isHidden = false
            cashBackLabel.text = Strings.recommended
        }else{
            cashBackLabel.isHidden = true
        }
        setImageAndTextBasedOnEncashOption(encashType: option)
        if option == RedemptionRequest.REDEMPTION_TYPE_TMW {
                infoIconButton.isHidden = false
            }else if option == RedemptionRequest.REDEMPTION_TYPE_SODEXO && cardStatus !=  nil && cardStatus != FuelCardRegistration.ACTIVE {
                infoIconButton.isHidden = false
            }else if option == RedemptionRequest.REDEMPTION_TYPE_HP_CARD && cardStatus != nil && cardStatus == FuelCardRegistration.OPEN{
                infoIconButton.isHidden = false
            }else if option == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD && cardStatus != nil && cardStatus == FuelCardRegistration.OPEN{
                infoIconButton.isHidden = false
            }else if option == RedemptionRequest.REDEMPTION_TYPE_HP_PAY && cardStatus != nil && cardStatus == FuelCardRegistration.OPEN{
                infoIconButton.isHidden = false
            } else if option == RedemptionRequest.REDEMPTION_TYPE_IOCL && cardStatus != nil && cardStatus == FuelCardRegistration.OPEN {
                infoIconButton.isHidden = false
            } else {
                infoIconButton.isHidden = true
            }
        self.viewController = viewController
        self.option = option
        self.cardStatus = cardStatus
    }
    
    @IBAction func tmwInfoBtnTapped(_ sender: Any) {
        if option == RedemptionRequest.REDEMPTION_TYPE_TMW{
            let tmwRegistrationController : TMWRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWRegistrationViewController") as! TMWRegistrationViewController
            self.viewController?.navigationController?.view.addSubview(tmwRegistrationController.view)
            self.viewController?.navigationController?.addChild(tmwRegistrationController)
        }else if option == RedemptionRequest.REDEMPTION_TYPE_HP_CARD{
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.hp_fuel_card, aboutText: Strings.about_hp, stepsTitle: Strings.hp_steps_title, stepsText: Strings.hp_steps, contact: Strings.hp_contact_no, email: Strings.hp_email, fuelCardRegistrationReceiver: nil)
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }else if option == RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD{
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.shell_fuel_card, aboutText: Strings.about_shell, stepsTitle: Strings.shell_steps_title, stepsText: Strings.shell_steps, contact: Strings.shell_contact_no, email: Strings.shell_email){
                (cardRegistered) in
                if cardRegistered{
                    self.refreshTableView()
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }else if option == RedemptionRequest.REDEMPTION_TYPE_SODEXO{
            if cardStatus == FuelCardRegistration.PENDING{
                let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
                sodexoRegistrationViewController.initializeView(cardStatus: cardStatus)
                ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
            }else{
                let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
                fuelCardDetailsViewController.initializeInfoView(title: Strings.sodexo, aboutText: Strings.about_sodexo, stepsTitle: Strings.sodexo_steps_title, stepsText: Strings.sodexo_steps, contact: Strings.sodexo_contact_no, email: Strings.sodexo_email, fuelCardRegistrationReceiver: nil)
                ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
            }
        }else if option == RedemptionRequest.REDEMPTION_TYPE_HP_PAY{
           let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.hp_pay, aboutText: Strings.about_hp_pay, stepsTitle: Strings.hp_pay_steps_title, stepsText: Strings.hp_pay_steps ,contact: Strings.hp_pay_contact_no, email: Strings.hp_pay_email){
                (cardRegistered) in
                if cardRegistered{
                    self.refreshTableView()
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        } else if option == RedemptionRequest.REDEMPTION_TYPE_IOCL {
            let fuelCardDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FuelCardDetailsViewController") as! FuelCardDetailsViewController
            fuelCardDetailsViewController.initializeInfoView(title: Strings.iocl_fuel_card, aboutText: Strings.about_iocl, stepsTitle: Strings.iocl_steps_title, stepsText: Strings.iocl_steps ,contact: RedemptionRequest.iocl_toll_free, email: RedemptionRequest.iocl_email){ (cardRegistered) in
                if cardRegistered{
                    self.refreshTableView()
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: fuelCardDetailsViewController)
        }
    }
    
    func setImageAndTextBasedOnEncashOption(encashType: String){
        switch encashType {
        case RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL:
            encashOptionLabel.text = Strings.paytm_fuel
            redeemTypeIconBtn.setImage(UIImage(named: "paytm_fuel_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_HP_CARD:
            encashOptionLabel.text = Strings.hp
            redeemTypeIconBtn.setImage(UIImage(named: "hp_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD:
            encashOptionLabel.text = Strings.shell
            redeemTypeIconBtn.setImage(UIImage(named: "shell_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_TMW:
            encashOptionLabel.text = Strings.tmw
            redeemTypeIconBtn.setImage(UIImage(named: "tmw_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_PAYTM:
            encashOptionLabel.text = Strings.paytm 
            redeemTypeIconBtn.setImage(UIImage(named: "paytm_icon_for_redeem"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY:
            encashOptionLabel.text = Strings.amazon_pay
            redeemTypeIconBtn.setImage(UIImage(named: "amazon_pay_gift_card_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_SODEXO:
            encashOptionLabel.text = Strings.sodexo
            redeemTypeIconBtn.setImage(UIImage(named: "sodexo"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_HP_PAY:
            encashOptionLabel.text = Strings.hp_pay
            redeemTypeIconBtn.setImage(UIImage(named: "hp_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_IOCL:
            encashOptionLabel.text = RedemptionRequest.REDEMPTION_TYPE_IOCL
            redeemTypeIconBtn.setImage(UIImage(named: "iocl_icon"), for: .normal)
        case RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER:
            encashOptionLabel.text = Strings.bank_transfer_neft
            redeemTypeIconBtn.setImage(UIImage(named: "bank_icon"), for: .normal)
        default:
            encashOptionLabel.text = ""
            redeemTypeIconBtn.setImage(nil, for: .normal)
        }
    }
    func refreshTableView(){
        if self.viewController!.isKind(of: EncashPaymentViewController.classForCoder()){
            if let encashPaymentViewController = self.viewController as? EncashPaymentViewController{
                encashPaymentViewController.getPreferredFuelCompanyAndCardStatus()
            }
        }
    }
}
