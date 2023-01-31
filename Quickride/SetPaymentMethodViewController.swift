//
//  SetPaymentMethodViewController.swift
//  Quickride
//
//  Created by Rajesab on 18/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
enum AddPaymentMethodAction{
    case makeDefault
    case selected
    case removePaymentMethod
    case addPayment
    case ccdcSelected
    case cashSelected
    case success
    case failed
}
typealias linkedWalletActionCompletionHandler = (_ action : AddPaymentMethodAction?) -> Void

class SetPaymentMethodViewController: UIViewController, LinkWalletReceiver {

    @IBOutlet weak var paymentMethodTableView: UITableView!
    @IBOutlet weak var paymentMethodTableViewHeignt: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    var setPaymentMethodViewModel = SetPaymentMethodViewModel()
    var tableViewHeight = 0.0

    func initialiseData(isDefaultPaymentModeCash: Bool,isRequiredToShowCash: Bool,isRequiredToShowCCDC: Bool?, handler: linkedWalletActionCompletionHandler?) {
        setPaymentMethodViewModel = SetPaymentMethodViewModel(isDefaultPaymentModeCash: isDefaultPaymentModeCash, isRequiredToShowCash: isRequiredToShowCash, isRequiredToShowCCDC: isRequiredToShowCCDC, handler: handler)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        setPaymentMethodViewModel.setAvailablePaymentMethods()
        setPaymentMethodViewModel.removeLinkedTypeFromList()
        setPaymentMethodViewModel.addAvailableWalletsToList()
        setTableViewHeight(sectionHeight: 0)
        if setPaymentMethodViewModel.linkedWallets.count > 0{
            viewTitleLabel.text = "Change Payment Method"
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        paymentMethodTableView.register(UINib(nibName: "AllLinkWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "AllLinkWalletXibTableViewCell")
        paymentMethodTableView.register(UINib(nibName: "PaymentMethodTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentMethodTableViewCell")
        paymentMethodTableView.register(UINib(nibName: "LinkedWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "LinkedWalletXibTableViewCell")
        paymentMethodTableView.delegate = self
        paymentMethodTableView.dataSource = self
        updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: nil)
    }

    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }

    private func closeView(){
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    func linkWallet(walletType: String) {
        var newLinkedWallet : LinkedWallet?
        for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
            if linkedWallet.type == walletType{
                newLinkedWallet = linkedWallet
                break
            }
        }
        if newLinkedWallet != nil{
            AccountUtils().updateDefaultLinkedWallet(linkedWallet: newLinkedWallet!, viewController: self, listener: self)
        }else{
            setPaymentMethodViewModel.handler?(.makeDefault)
            closeView()
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        closeView()
    }
}
extension SetPaymentMethodViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.frame.size.width, height: 35))
        headerView.backgroundColor = UIColor.white
        switch section {
        case 1:
            let headerLabel = UILabel(frame: CGRect(x: 22, y: 0, width: tableView.frame.size.width - 10, height: 35))
            headerLabel.text = Strings.other_Methods
            headerLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            headerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            headerView.addSubview(headerLabel)
        default:
            break
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1, setPaymentMethodViewModel.linkedWallets.count > 0 && (setPaymentMethodViewModel.payLaterLinkWalletOptions.count > 0 || setPaymentMethodViewModel.rechargeLinkWalletOptions.count > 0 || setPaymentMethodViewModel.upiLinkWalletOptions.count > 0 || setPaymentMethodViewModel.isRequiredToShowCash){
            return 30
        }else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return setPaymentMethodViewModel.linkedWallets.count
        case 1:
            if setPaymentMethodViewModel.payLaterLinkWalletOptions.count > 0{
                return 1
            } else{
                return 0
            }
        case 2:
            if setPaymentMethodViewModel.isPayLaterSelected {
                setTableViewHeight(sectionHeight: CGFloat(setPaymentMethodViewModel.payLaterLinkWalletOptions.count*70))
                return setPaymentMethodViewModel.payLaterLinkWalletOptions.count
            }else {
                return 0
            }
        case 3:
            if setPaymentMethodViewModel.rechargeLinkWalletOptions.count > 0{
                return 1
            } else{
                return 0
            }
        case 4:
            if setPaymentMethodViewModel.isWalletsOrGiftCardsSelected {
                setTableViewHeight(sectionHeight: CGFloat(setPaymentMethodViewModel.rechargeLinkWalletOptions.count*70))
                return setPaymentMethodViewModel.rechargeLinkWalletOptions.count
            }else {
                return 0
            }
        case 5:
            if setPaymentMethodViewModel.upiLinkWalletOptions.count > 0 {
                return 1
            } else{
                return 0
            }
        case 6:
            if setPaymentMethodViewModel.isUPISelected {
                setTableViewHeight(sectionHeight: CGFloat(setPaymentMethodViewModel.upiLinkWalletOptions.count*70))
                return setPaymentMethodViewModel.upiLinkWalletOptions.count
            }else {
                return 0
            }
        case 7:
            if setPaymentMethodViewModel.isRequiredToShowPayByOtherModes(){
                return 1
            }else {
                return 0
            }
        case 8:
            if setPaymentMethodViewModel.isRequiredToShowCash{
                return 1
            }else {
                return 0
            }
        default:
            return 0
        }
    }

    private func setTableViewHeight(sectionHeight: CGFloat){
        tableViewHeight = Double(setPaymentMethodViewModel.linkedWallets.count * 75)
        if setPaymentMethodViewModel.payLaterLinkWalletOptions.count > 0{
            tableViewHeight = tableViewHeight + 65
        }
        if setPaymentMethodViewModel.rechargeLinkWalletOptions.count > 0 {
            tableViewHeight = tableViewHeight + 65
        }
        if setPaymentMethodViewModel.upiLinkWalletOptions.count > 0 {
            tableViewHeight = tableViewHeight + 65
        }
        if setPaymentMethodViewModel.isRequiredToShowPayByOtherModes(){
            tableViewHeight = tableViewHeight + 65
        }
        if setPaymentMethodViewModel.isRequiredToShowCash {
            tableViewHeight = tableViewHeight + 65
        }
        if setPaymentMethodViewModel.linkedWallets.count > 0 && (setPaymentMethodViewModel.payLaterLinkWalletOptions.count > 0 || setPaymentMethodViewModel.rechargeLinkWalletOptions.count > 0 || setPaymentMethodViewModel.upiLinkWalletOptions.count > 0 || setPaymentMethodViewModel.isRequiredToShowCash) {
            tableViewHeight = tableViewHeight + 30
        }
        if (CGFloat(tableViewHeight) + sectionHeight) > 500{
            paymentMethodTableViewHeignt.constant = 500
        } else{
            paymentMethodTableViewHeignt.constant = CGFloat(tableViewHeight) + 10 + sectionHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedWalletXibTableViewCell", for: indexPath as  IndexPath) as! LinkedWalletXibTableViewCell
            if indexPath.row == 0, !setPaymentMethodViewModel.isDefaultPaymentModeCash {
            cell.initializeDataInCell(linkedWallet: setPaymentMethodViewModel.linkedWallets[indexPath.row],showSelectButton: false, viewController: self, listener: self)
            } else {
                setPaymentMethodViewModel.linkedWallets[indexPath.row].defaultWallet = false
                cell.initializeDataInCell(linkedWallet: setPaymentMethodViewModel.linkedWallets[indexPath.row],showSelectButton: true, viewController: self, listener: self)
            }
            cell.initialiseHandler { refresh in
                if refresh{
                    self.setPaymentMethodViewModel.setAvailablePaymentMethods()
                    self.setPaymentMethodViewModel.removeLinkedTypeFromList()
                    self.setPaymentMethodViewModel.addAvailableWalletsToList()
                    self.setTableViewHeight(sectionHeight: 0)
                    self.updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: nil)
                    self.paymentMethodTableView.reloadData()
                    if let handler = self.setPaymentMethodViewModel.handler {
                        handler(AddPaymentMethodAction.removePaymentMethod)
                    }
                }
            }
            return cell
        case 1:
            let cell = paymentMethodTableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath as  IndexPath) as! PaymentMethodTableViewCell
            if indexPath.section == setPaymentMethodViewModel.selectedIndex {
                cell.initialiseData(paymentTypeInfo: setPaymentMethodViewModel.paymentMethodslist[0], arrowImage: UIImage(named: "left-arrow")!, showDefaultLabel: setPaymentMethodViewModel.isDefaultPaymentModeCash)
            } else {
                cell.initialiseData(paymentTypeInfo: setPaymentMethodViewModel.paymentMethodslist[0], arrowImage: UIImage(named: "arrow-right")!, showDefaultLabel: setPaymentMethodViewModel.isDefaultPaymentModeCash)
            }
            cell.separatorView.isHidden = true
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: setPaymentMethodViewModel.payLaterLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell

        case 3:
            return setupUI(indexPath: indexPath, index: 1)
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: setPaymentMethodViewModel.rechargeLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell

        case 5:
            return setupUI(indexPath: indexPath, index: 2)

        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
            cell.initializeDataInCell(walletType: setPaymentMethodViewModel.upiLinkWalletOptions[indexPath.row], isRedemptionLinkWallet: false, viewController : self,linkWalletReceiver: self)
            cell.walletImageLeadingConstraint.constant = 70
            cell.separatorView.isHidden = true
            return cell
        case 7:
            return setupUI(indexPath: indexPath, index: 3)

        case 8:
            return setupUI(indexPath: indexPath, index: 4)

        default:
            return UITableViewCell()
        }
    }
    func setupUI(indexPath: IndexPath, index: Int) -> UITableViewCell {
        let cell = paymentMethodTableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath as  IndexPath) as! PaymentMethodTableViewCell

        if indexPath.section == setPaymentMethodViewModel.selectedIndex {
            cell.initialiseData(paymentTypeInfo: setPaymentMethodViewModel.paymentMethodslist[index], arrowImage: UIImage(named: "left-arrow")!, showDefaultLabel: setPaymentMethodViewModel.isDefaultPaymentModeCash)
        } else {
            cell.initialiseData(paymentTypeInfo: setPaymentMethodViewModel.paymentMethodslist[index], arrowImage: UIImage(named: "arrow-right")!, showDefaultLabel: setPaymentMethodViewModel.isDefaultPaymentModeCash)
        }
        if index == 1, setPaymentMethodViewModel.payLaterLinkWalletOptions.count == 0{
            cell.separatorView.isHidden = true
        }else if index == 2,setPaymentMethodViewModel.payLaterLinkWalletOptions.count == 0 && setPaymentMethodViewModel.rechargeLinkWalletOptions.count == 0{
            cell.separatorView.isHidden = true
        }else if index == 3, setPaymentMethodViewModel.payLaterLinkWalletOptions.count == 0 && setPaymentMethodViewModel.rechargeLinkWalletOptions.count == 0 && setPaymentMethodViewModel.upiLinkWalletOptions.count == 0{
            cell.separatorView.isHidden = true
        }else {
            cell.separatorView.isHidden = false
        }
        return cell
    }
}
extension SetPaymentMethodViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setPaymentMethodViewModel.selectedIndex = indexPath.section
        switch indexPath.section {
        case 1:
            if !setPaymentMethodViewModel.isPayLaterSelected{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: true, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: nil)
            } else{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: indexPath.section)
            }
        case 3:
            if !setPaymentMethodViewModel.isWalletsOrGiftCardsSelected{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: true, isUPISelected: false, index: nil)
            } else{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: indexPath.section)
            }

        case 5:
            if !setPaymentMethodViewModel.isUPISelected{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: true, index: nil)
            } else{
                updateUIBasedOnSelectedMethod(isPayLaterSelected: false, isWalletsOrGiftCardsSelected: false, isUPISelected: false, index: indexPath.section)
            }
        case 7:
            setPaymentMethodViewModel.handler?(AddPaymentMethodAction.ccdcSelected)
                closeView()
        case 8:
            setPaymentMethodViewModel.handler?(AddPaymentMethodAction.cashSelected)
                closeView()
        default:
            break
        }
    }

    private func handleTapOnCarpoolCcOrDcPayment(){
        setPaymentMethodViewModel.handler?(AddPaymentMethodAction.ccdcSelected)
        closeView()
    }

    func updateUIBasedOnSelectedMethod(isPayLaterSelected: Bool,isWalletsOrGiftCardsSelected: Bool,isUPISelected: Bool, index: Int?){
        setPaymentMethodViewModel.isPayLaterSelected = isPayLaterSelected
        setPaymentMethodViewModel.isWalletsOrGiftCardsSelected = isWalletsOrGiftCardsSelected
        setPaymentMethodViewModel.isUPISelected = isUPISelected
        setTableViewHeight(sectionHeight: 0)
        if setPaymentMethodViewModel.selectedIndex == index{
            setPaymentMethodViewModel.selectedIndex = -1
        }
        paymentMethodTableView.reloadData()
    }

}
extension SetPaymentMethodViewController: LinkedWalletUpdateDelegate{
    func linkedWalletInfoChanged() {
        setPaymentMethodViewModel.handler?(.selected)
        closeView()
    }
}
