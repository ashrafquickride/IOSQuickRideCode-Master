//
//  MyTripsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyTripsViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var myTripsTableView: UITableView!
    @IBOutlet weak var noTripsLabel: UILabel!
    
    //MARK: Variables
    private var myTripsViewModel = MyTripsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        myTripsViewModel.createHashTableForActiveRides()
        relaodTableView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMyTrips), name: .reloadMyTrips, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: .taxiRideCreatedFromTOC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: .taxiDriverAllocationStatusChanged, object: nil)
    }
    
    @objc func reloadMyTrips(_ notification: Notification){
        self.myTripsViewModel.createHashTableForActiveRides()
        self.relaodTableView()
    }
    @objc func reloadTableViewData(_ notification: Notification){
        self.relaodTableView()
    }
    private func relaodTableView(){
        if !myTripsViewModel.activeTrips.isEmpty{
            myTripsTableView.register(UINib(nibName: "MyTripTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTripTableViewCell")
            myTripsTableView.isHidden = false
            noTripsLabel.isHidden = true
            myTripsTableView.reloadData()
        }else{
            myTripsTableView.isHidden = true
            noTripsLabel.isHidden = false
        }
    }
    @IBAction func historyButtonTapped(_ sender: Any) {
        let taxiTripsHistoryViewController  = UIStoryboard(name : StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripsHistoryViewController") as! TaxiTripsHistoryViewController
        self.navigationController?.pushViewController(taxiTripsHistoryViewController, animated: true)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK: UITableViewDataSource
extension MyTripsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if myTripsViewModel.activeTrips.count > 0{
            return myTripsViewModel.activeTrips.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myTripsViewModel.activeTrips.count > 0{
            return myTripsViewModel.activeTrips[section].value.count
        }else{
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "MyTripTableViewCell", for: indexPath) as! MyTripTableViewCell
        if myTripsViewModel.activeTrips[indexPath.section].value.count > 0{
            cell.initialiseTripDetails(taxiRidePassenger: myTripsViewModel.activeTrips[indexPath.section].value[indexPath.row])
        }
        return cell
    }
}
//MARK: UITableViewDelegate
extension MyTripsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myTripsViewModel.activeTrips[indexPath.section].value.count > 0{
            let taxiRidePassenger = myTripsViewModel.activeTrips[indexPath.section].value[indexPath.row]
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: taxiRidePassenger.id ?? 0)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if myTripsViewModel.activeTrips.endIndex - 1 != section{
            return 10
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }
}
