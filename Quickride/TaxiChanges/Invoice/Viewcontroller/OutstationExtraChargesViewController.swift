//
//  OutstationExtraChargesViewController.swift
//  Quickride
//
//  Created by HK on 28/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import BottomPopup

class OutstationExtraChargesViewController: BottomPopupViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addPaymentsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    var tableViewHeight = 0.0
    
    private var outstationExtraChargesViewModel = OutstationExtraChargesViewModel()
    
    func initialiseCharges(outstationTaxiFareDetails: PassengerFareBreakUp,showDriverAddedChanges: Bool){
        outstationExtraChargesViewModel = OutstationExtraChargesViewModel(outstationTaxiFareDetails: outstationTaxiFareDetails, showDriverAddedChanges: showDriverAddedChanges)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        if outstationExtraChargesViewModel.showDriverAddedChanges{
            titleLabel.text = "Charges added by driver"
        }else{
            titleLabel.text = "Charges added by me"
        }
        setTableViewHeight()
    }
    
    private func setUpUi(){
        addPaymentsTableView.register(UINib(nibName: "DriverAddedChargesTableViewCell", bundle: nil), forCellReuseIdentifier: "DriverAddedChargesTableViewCell")
        addPaymentsTableView.register(UINib(nibName: "AddedOutStationPaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddedOutStationPaymentsTableViewCell")
        
    }
    
    
    private func setTableViewHeight(){
        if outstationExtraChargesViewModel.showDriverAddedChanges{
            if outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count == 1 {
                tableViewHeight = Double((outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0) * 150)
                updatePopupHeight(to: tableViewHeight)
            } else {
                tableViewHeight = Double((outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0) * 120)
                updatePopupHeight(to: tableViewHeight)
            }
        } else {
            if outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count == 1 {
                
                tableViewHeight = Double((outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) * 150)
                updatePopupHeight(to: tableViewHeight)
            } else {
                tableViewHeight = Double((outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0) * 120)
                updatePopupHeight(to: tableViewHeight)
            }
        }
        if (CGFloat(tableViewHeight)) > 550 {
            tableViewHeightConstraint.constant = 500
            updatePopupHeight(to: 500)
            addPaymentsTableView.isScrollEnabled = true
        }
    }
}
extension OutstationExtraChargesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if outstationExtraChargesViewModel.showDriverAddedChanges{
            return outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails.count ?? 0
        }else{
            return outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if outstationExtraChargesViewModel.showDriverAddedChanges{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverAddedChargesTableViewCell", for: indexPath) as! DriverAddedChargesTableViewCell
            if let taxiTripExtraFareDetails =  outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiTripExtraFareDetails[indexPath.row]{
                cell.driverAddedCharges(viewModel: TaxiPoolLiveRideViewModel(), taxiTripExtraFareDetails: taxiTripExtraFareDetails)
                cell.backView.backgroundColor = .white
                if taxiTripExtraFareDetails.status != TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
                   cell.disputeButton.isHidden = true
                }else{
                    cell.disputeButton.isHidden = false
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddedOutStationPaymentsTableViewCell", for: indexPath) as! AddedOutStationPaymentsTableViewCell
            if let taxiUserAdditionalPaymentDetails =  outstationExtraChargesViewModel.outstationTaxiFareDetails?.taxiUserAdditionalPaymentDetails[indexPath.row]{
                cell.initialiseAddedPayment(taxiUserAdditionalPaymentDetails: taxiUserAdditionalPaymentDetails)
                if taxiUserAdditionalPaymentDetails.status != TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
                   cell.disputeBtn.isHidden = true
                }else{
                    cell.disputeBtn.isHidden = false
                }
            }
            return cell
        }
    }
}

