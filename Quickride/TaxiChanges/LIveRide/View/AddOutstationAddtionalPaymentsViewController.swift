//
//  AddOutstationAddtionalPaymentsViewController.swift
//  Quickride
//
//  Created by HK on 13/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddOutstationAddtionalPaymentsViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addPaymentsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var viewModel = AddOutstationAddtionalPaymentsViewModel()
    private var isKeyBoardVisible = false
    
    func addPaymentHere(taxiRidePassengerDetails: TaxiRidePassengerDetails?){
        viewModel.taxiRidePassengerDetails = taxiRidePassengerDetails
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        viewModel.getAddedPaymentsForThisTrip()
        tableViewHeightConstraint.constant = 335
        setUpUi()
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func setUpUi(){
        addPaymentsTableView.register(UINib(nibName: "AddPaymentsOnTheWayTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPaymentsOnTheWayTableViewCell")
        addPaymentsTableView.register(UINib(nibName: "AddedOutStationPaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddedOutStationPaymentsTableViewCell")
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recievedAddedCashPayments), name: .recievedAddedCashPayments, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(passengerCashAdded), name: .passengerCashAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            tableViewHeightConstraint.constant = keyBoardSize.height + 300
            
        }
    }
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        if self.viewModel.addedPaymentsList.isEmpty {
            self.tableViewHeightConstraint.constant = 335
        }else{
            self.tableViewHeightConstraint.constant = 420
        }
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func recievedAddedCashPayments(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        if self.viewModel.addedPaymentsList.isEmpty {
            self.tableViewHeightConstraint.constant = 335
        }else{
            self.addPaymentsTableView.reloadData()
            self.tableViewHeightConstraint.constant = 420
        }
    }
    @objc func passengerCashAdded(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        closeView()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        closeView()
    }
}

extension AddOutstationAddtionalPaymentsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return viewModel.addedPaymentsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPaymentsOnTheWayTableViewCell", for: indexPath) as! AddPaymentsOnTheWayTableViewCell
            cell.initialiseAddPayment(viewModel: viewModel)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddedOutStationPaymentsTableViewCell", for: indexPath) as! AddedOutStationPaymentsTableViewCell
            let taxiUserAdditionalPaymentDetails = viewModel.addedPaymentsList[indexPath.row]
                cell.initialiseAddedPayment(taxiUserAdditionalPaymentDetails: taxiUserAdditionalPaymentDetails)
                if taxiUserAdditionalPaymentDetails.status != TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
                   cell.disputeBtn.isHidden = true
                }else{
                    cell.disputeBtn.isHidden = false
                }
            return cell
        }
    }
}
extension AddOutstationAddtionalPaymentsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !viewModel.addedPaymentsList.isEmpty{
            return 70
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && !viewModel.addedPaymentsList.isEmpty{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 15, width: tableView.frame.size.width, height: 35))
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            titleLabel.text = "Added Charges"
            let subTitleLabel = UILabel(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 35))
            subTitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
            subTitleLabel.text = "Included in the bill"
            titleLabel.textAlignment = .center
            subTitleLabel.textAlignment = .center
            headerView.addSubview(titleLabel)
            headerView.addSubview(subTitleLabel)
            return headerView
        }
        return nil
    }
}
