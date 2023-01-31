//
//  PaymentOutstationViewController.swift
//  Quickride
//
//  Created by Ashutos on 03/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

public typealias ComplitionHandlerForPaymentSelection = (_ doneTapped: Int) -> Void

class PaymentOutstationViewController: UIViewController {
    @IBOutlet weak var paymentTableview: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var paymentTableHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var payBtn: QRCustomButton!
    @IBOutlet weak var popUpView: QuickRideCardView!
    
    private var paymentPopUPViewModel: PaymentPopUPViewModel?
    private var handler: ComplitionHandlerForPaymentSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func getDataBeforeInitialisation(estimateFare: Double, handler: @escaping ComplitionHandlerForPaymentSelection) {
        paymentPopUPViewModel = PaymentPopUPViewModel(estimateFareAmount: estimateFare)
        self.handler = handler
    }
    
    private func registerCells() {
        paymentTableview.register(UINib(nibName: "PercentageAmountShowingTableViewCell", bundle: nil), forCellReuseIdentifier: "PercentageAmountShowingTableViewCell")
        paymentTableview.register(UINib(nibName: "PaymentMethodOutstationTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentMethodOutstationTableViewCell")
        paymentTableview.register(UINib(nibName: "ShowingAddingPaymentMethodTableViewCell", bundle: nil), forCellReuseIdentifier: "ShowingAddingPaymentMethodTableViewCell")
        setUPUI()
    }
    
    private func setUPUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.popUpView.center.y -= self.popUpView.bounds.height
                       }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backGroundViewTapped(_:))))
        paymentTableview.estimatedRowHeight = 70
        paymentTableview.rowHeight = UITableView.automaticDimension
        var cells = 1
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if clientConfiguration.enableOutStationTaxiFullPayment{
            cells = 2
        }
        if paymentPopUPViewModel?.isWalletLinked() ?? false {
            paymentTableHeightConstarint.constant = CGFloat(cells*65 + 130)
        }else{
            paymentTableHeightConstarint.constant = CGFloat((cells+1)*65)
        }
        setPayBtnTitle()
        paymentTableview.reloadData()
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.popUpView.center.y += self.popUpView.bounds.height
            self.popUpView.layoutIfNeeded()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    private func setPayBtnTitle() {
        if paymentPopUPViewModel?.selectedPayAmountIndex == 0 {
            if let outStationTaxiAdvancePaymentPercentage = ConfigurationCache.getInstance()?.getClientConfiguration()?.outStationTaxiAdvancePaymentPercentage {
                let paymentAmt = ((paymentPopUPViewModel?.estimateFareAmount ?? 0)*Double(outStationTaxiAdvancePaymentPercentage)/100)
                payBtn.setTitle("Pay ₹\(Int(paymentAmt.rounded()))", for: .normal)
            }
        }else{
            payBtn.setTitle("Pay ₹\(Int((paymentPopUPViewModel?.estimateFareAmount ?? 0).rounded()))", for: .normal)
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        removeView()
        if let handler = handler{
            handler(paymentPopUPViewModel?.selectedPayAmountIndex ?? 0)
        }
    }
    
    @IBAction func refundOptionPressed(_ sender: UIButton) {
        let urlcomps = URLComponents(string :  PaymentPopUPViewModel.refundAndCancelOutstationURL)
        let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.initializeDataBeforePresenting(titleString: "", url: urlcomps!.url! , actionComplitionHandler: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
    }
}

extension PaymentOutstationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            if clientConfiguration.enableOutStationTaxiFullPayment{
                return 2
            }else{
                return 1
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            if paymentPopUPViewModel?.isWalletLinked() ?? false {
                let paymentMethodCell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodOutstationTableViewCell", for: indexPath) as! PaymentMethodOutstationTableViewCell
                paymentMethodCell.getEstimateFare(estimateFare: paymentPopUPViewModel?.estimateFareAmount ?? 0, delegate: self)
                return paymentMethodCell
            }else{
                let showAddingWalletCell = tableView.dequeueReusableCell(withIdentifier: "ShowingAddingPaymentMethodTableViewCell", for: indexPath) as! ShowingAddingPaymentMethodTableViewCell
                showAddingWalletCell.delagate = self
                return showAddingWalletCell
            }
        default:
            let percentageCell = tableView.dequeueReusableCell(withIdentifier: "PercentageAmountShowingTableViewCell", for: indexPath) as! PercentageAmountShowingTableViewCell
            if indexPath.row == 0 {
                percentageCell.updateUIForminimumPercentagePaymentCell(estimateFare: paymentPopUPViewModel?.estimateFareAmount ?? 0)
            }else{
                percentageCell.updateUIForEstimateFareCell(estimateFare: paymentPopUPViewModel?.estimateFareAmount ?? 0)
            }
            if indexPath.row == paymentPopUPViewModel?.selectedPayAmountIndex {
                percentageCell.selectedShowingImage.image = UIImage(named: "ic_radio_button_checked")
            }else{
                percentageCell.selectedShowingImage.image = UIImage(named: "radio_button_1")
            }
            return percentageCell
        }
    }
}

extension PaymentOutstationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0,1:
            paymentPopUPViewModel?.selectedPayAmountIndex = indexPath.row
            setPayBtnTitle()
            paymentTableview.reloadData()
        default:
            break
        }
    }
}

extension PaymentOutstationViewController: PaymentMethodOutstationTableViewCellDelegate,ShowingAddingPaymentMethodTableViewCellDelegate {
    func updateUI() {
        setUPUI()
    }
}
