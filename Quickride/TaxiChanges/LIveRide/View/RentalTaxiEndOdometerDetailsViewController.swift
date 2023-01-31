//
//  RentalTaxiEndOdometerDetailsViewController.swift
//  Quickride
//
//  Created by Rajesab on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalTaxiEndOdometerDetailsViewController: UIViewController {

    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var gotItButtonContainerView: UIView!
    
    private var viewModel = RentalTaxiEndOdometerDetailsViewModel()

    
    func initialiseData(taxiRidePassengerDetails: TaxiRidePassengerDetails, outstationTaxiFareDetails: PassengerFareBreakUp, rentalTaxiOdometerDetails: RentalTaxiOdometerDetails){
        self.viewModel = RentalTaxiEndOdometerDetailsViewModel(taxiRidePassengerDetails: taxiRidePassengerDetails, outstationTaxiFareDetails: outstationTaxiFareDetails, rentalTaxiOdometerDetails: rentalTaxiOdometerDetails)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regesterCells()
        viewModel.getFareBrakeUpData()
        contentTableView.dataSource = self
        contentTableView.reloadData()
        gotItButtonContainerView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
    }
    
    private func regesterCells(){
        contentTableView.register(UINib(nibName: "RentalEndOdometerDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalEndOdometerDetailsTableViewCell")
        contentTableView.register(UINib(nibName: "FareSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "FareSummaryTableViewCell")
        contentTableView.register(UINib(nibName: "DriverAddedChargesTableViewCell", bundle: nil), forCellReuseIdentifier: "DriverAddedChargesTableViewCell")
        contentTableView.register(UINib(nibName: "CashPaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CashPaymentsTableViewCell")
        contentTableView.register(UINib(nibName: "RentalTaxiDropOtpTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalTaxiDropOtpTableViewCell")
        contentTableView.register(UINib(nibName: "TaxiPaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPaymentTableViewCell")
    }
    
    @IBAction func okGotItButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func needHelpButtonTapped(_ sender: Any) {
        AppUtilConnect.callSupportNumber(phoneNumber: ConfigurationCache.getObjectClientConfiguration().quickRideSupportNumberForTaxi, targetViewController: self)
    }
}
extension RentalTaxiEndOdometerDetailsViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if viewModel.isrequiredtoshowFareView {
                return viewModel.estimateFareData.count
            }else {
                return 0
            }
        case 3:
            if viewModel.isrequiredtoshowFareView, viewModel.outstationTaxiFareDetails.taxiTripExtraFareDetails.count > 0{
               return 1 //Charges Added by Driver title
            }else{
               return 0
            }
        case 4:
            if viewModel.isrequiredtoshowFareView {
                return 1
            }
            return 0
        case 5:
            if viewModel.isrequiredtoshowFareView, viewModel.outstationTaxiFareDetails.couponBenefit != 0{
                return 1
            }
            return 0
        case 6:
            if viewModel.isrequiredtoshowFareView {
                return 1
            }
            return 0
        case 7:
            return 1
        default :
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentalEndOdometerDetailsTableViewCell") as! RentalEndOdometerDetailsTableViewCell
            cell.initialiseData(viewModel: viewModel)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPaymentTableViewCell", for: indexPath) as! TaxiPaymentTableViewCell
            cell.initialisePaymentCard(outstationTaxiFareDetails: viewModel.outstationTaxiFareDetails, paymentMode: viewModel.taxiRidePassengerDetails.taxiRidePassenger?.paymentMode){ isCellTapping in
                if isCellTapping {
                    if !self.viewModel.isrequiredtoshowFareView {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: true)
                        
                    } else {
                        self.updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: false)
                        
                    }
                }
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            var currentData = viewModel.estimateFareData[indexPath.row]
            cell.titleLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            cell.amountLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            cell.backGroundView.backgroundColor = .white
            if currentData.key == ReviewScreenViewModel.RIDE_FARE{
                cell.separatorView.isHidden = false
                cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                if viewModel.taxiRidePassengerDetails.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_CAR{
                    currentData.key = "Ride Fare (Excludes GST)"
                }
            }else{
                cell.separatorView.isHidden = true
            }
            cell.updateUIForFare(title: currentData.key ?? "", amount: currentData.value ?? "")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            cell.backGroundView.backgroundColor = .white
            cell.updateUIForFare(title: "Charges Added by Driver" , amount: "")
            cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            cell.backGroundView.backgroundColor = .white
            cell.updateUIForFare(title: "Total Fare" , amount: String(getTotalFareOfTrip()))
            cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            cell.updateUIForFare(title: "Discount" , amount: "- " + String(viewModel.outstationTaxiFareDetails.couponBenefit))
            cell.backGroundView.backgroundColor = .white
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FareSummaryTableViewCell", for: indexPath) as! FareSummaryTableViewCell
            if (viewModel.outstationTaxiFareDetails.pendingAmount ) > 0{
                cell.updateUIForFare(title: "Balance to be paid" , amount: String(viewModel.outstationTaxiFareDetails.pendingAmount ))
            }else{
                cell.updateUIForFare(title: "Paid" , amount: String((viewModel.outstationTaxiFareDetails.initialFare ) - (viewModel.outstationTaxiFareDetails.couponBenefit )))
            }
            cell.separatorView.isHidden = false
            cell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            cell.amountLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            cell.backGroundView.backgroundColor = .white
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentalTaxiDropOtpTableViewCell", for: indexPath) as! RentalTaxiDropOtpTableViewCell
            cell.initialiseData(dropOtp: viewModel.taxiRidePassengerDetails.taxiRidePassenger?.dropOtp ?? "")
            return cell
        default :
            return UITableViewCell()
        }
    }

    private func getTotalFareOfTrip() -> Double{
        var totalFare = viewModel.outstationTaxiFareDetails.initialFare
        for driverExtraFareDetails in viewModel.outstationTaxiFareDetails.taxiTripExtraFareDetails{
            if driverExtraFareDetails.status != TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
                totalFare += driverExtraFareDetails.amount
            }
        }
        return totalFare
    }
    
    private func getCashPaymentDetails(taxiUserAdditionalPaymentDetails: TaxiUserAdditionalPaymentDetails?) -> (String,String,Bool){
        let amount = "- " + String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiUserAdditionalPaymentDetails?.amount)])
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiUserAdditionalPaymentDetails?.creationDateMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? ""
        let title = "Cash paid - " + date
        var isRequiredToShowDisputed = false
        if taxiUserAdditionalPaymentDetails?.status == TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
            isRequiredToShowDisputed = true
        }
        return (title,amount,isRequiredToShowDisputed)
    }
    
    private func updateUIBasedOnTappingOnFare(isrequiredtoshowFareView: Bool){
        viewModel.isrequiredtoshowFareView = isrequiredtoshowFareView
        viewModel.getFareBrakeUpData()
        self.contentTableView.reloadData()
    }
}
