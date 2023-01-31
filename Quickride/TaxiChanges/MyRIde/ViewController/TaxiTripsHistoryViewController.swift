//
//  TaxiTripsHistoryViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripsHistoryViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tripHistoryTableView: UITableView!
    @IBOutlet weak var noTripsLabel: UILabel!
    //MARK: Variables
    private var taxiTripsHistoryModel = TaxiTripsHistoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripHistoryTableView.register(UINib(nibName: "TripHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "TripHistoryTableViewCell")
        taxiTripsHistoryModel.createHashTableForClosedRides()
        if !taxiTripsHistoryModel.closedTripsHashTable.isEmpty{
            tripHistoryTableView.reloadData()
            tripHistoryTableView.isHidden = false
            noTripsLabel.isHidden = true
        }else{
            tripHistoryTableView.isHidden = true
            noTripsLabel.isHidden = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: UITableViewDataSource
extension TaxiTripsHistoryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return taxiTripsHistoryModel.closedTripsHashTable.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taxiTripsHistoryModel.closedTripsHashTable.count > 0 {
            return taxiTripsHistoryModel.closedTripsHashTable[section].value.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripHistoryTableViewCell", for: indexPath) as! TripHistoryTableViewCell
        if taxiTripsHistoryModel.closedTripsHashTable[indexPath.section].value.count > 0 {
            let taxiTrip = taxiTripsHistoryModel.closedTripsHashTable[indexPath.section].value[indexPath.row]
            cell.initialiseTaxiTrip(taxiRidePassenger: taxiTrip)
            if indexPath.row == 0 {
                cell.setSectionHeader(isHeaderShow: true, taxiRidePassenger: taxiTrip)
            } else {
                cell.setSectionHeader(isHeaderShow: false, taxiRidePassenger: taxiTrip)
            }
            return cell
        } else {
            tripHistoryTableView.isHidden = true
            noTripsLabel.isHidden = false
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDelegate
extension TaxiTripsHistoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taxiTrips =  taxiTripsHistoryModel.closedTripsHashTable[indexPath.section].value
        getTripInvoiceForTaxiPool(taxiRide: taxiTrips[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xececec)
        return view
    }
    private func getTripInvoiceForTaxiPool(taxiRide: TaxiRidePassenger) {
        if taxiRide.status == Ride.RIDE_STATUS_COMPLETED{
            taxiTripsHistoryModel.getTaxiTripInvoice(taxiPassengerRide: taxiRide) { [weak self] (taxiRideInvoice) in
                if let taxiInvoice = taxiRideInvoice{
                    let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                    taxiBillVC.initialiseData(taxiRideInvoice: taxiInvoice,taxiRide: taxiRide, cancelTaxiRideInvoice: [CancelTaxiRideInvoice]())
                    self?.navigationController?.pushViewController(taxiBillVC, animated: true)
                }
            }
        }else{
            taxiTripsHistoryModel.getCanceTaxiTripInvoice(taxiPassengerRide: taxiRide) { (cancelTaxiRideInvoices) in
                if let cancelTaxiInvoices = cancelTaxiRideInvoices,!cancelTaxiInvoices.isEmpty{
                    var feeAppliedTaxiRides = [CancelTaxiRideInvoice]()
                    for cancelRideInvoice in cancelTaxiInvoices{
                        if cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER || cancelRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
                            feeAppliedTaxiRides.append(cancelRideInvoice)
                        }
                    }
                    if !feeAppliedTaxiRides.isEmpty{
                        let taxiBillVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripReportViewController") as! TaxiTripReportViewController
                        taxiBillVC.initialiseData(taxiRideInvoice: nil,taxiRide: taxiRide, cancelTaxiRideInvoice: feeAppliedTaxiRides)
                        self.navigationController?.pushViewController(taxiBillVC, animated: true)
                    }else{
                        UIApplication.shared.keyWindow?.makeToast( Strings.ride_cancelled)
                    }
                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.ride_cancelled)
                }
            }
        }
    }
}
