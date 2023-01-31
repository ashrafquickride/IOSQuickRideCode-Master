//
//  TaxipoolPassengersViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 13/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxipoolPassengersViewController: UIViewController {
    
    @IBOutlet weak var matchesTableView: UITableView!
    
    @IBOutlet weak var noMatchesView: UIView!
    
    
    private var viewModel = TaxipoolPassengersViewModel()
    
    func initialiseMatches(taxiRide: TaxiRidePassenger?){
        viewModel = TaxipoolPassengersViewModel(taxiRide: taxiRide)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        QuickRideProgressSpinner.startSpinner()
        viewModel.getCarpoolMatches { [weak self] responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            guard let self = self else {
                return
            }
            guard let carpoolMatches = self.viewModel.capoolMatches, carpoolMatches.count > 0 else {
                self.matchesTableView.isHidden = true
                self.noMatchesView.isHidden = false
                return
            }
            self.noMatchesView.isHidden = true
            self.matchesTableView.isHidden = false
            self.matchesTableView.reloadData()
        }
    }
    
    private func setUpUI(){
        matchesTableView.register(UINib(nibName: "CarpoolMatchForTaxipoolTableViewCell", bundle: nil), forCellReuseIdentifier: "CarpoolMatchForTaxipoolTableViewCell")
        self.matchesTableView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(taxiInvitationReceived), name: .taxiInvitationReceived, object: nil)
    }
    @objc func taxiInvitationReceived(_ notification: Notification){
        if !matchesTableView.isHidden{
            self.matchesTableView.reloadData()
        }
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}

//UITableViewDataSource
extension TaxipoolPassengersViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let carpoolMatches = viewModel.capoolMatches else {
            return 0
        }
        if carpoolMatches.count > 0{
            return carpoolMatches.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let carpoolMatches = viewModel.capoolMatches , carpoolMatches.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolMatchForTaxipoolTableViewCell", for: indexPath) as! CarpoolMatchForTaxipoolTableViewCell
            if carpoolMatches.endIndex <= indexPath.row{
                return cell
            }
            cell.showCarpoolMatch(carpoolMatch: carpoolMatches[indexPath.row],viewModel: viewModel)
            return cell
        }
        return UITableViewCell()
        
    }
}

//UITableViewDelegate
extension TaxipoolPassengersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let carpoolMatches = viewModel.capoolMatches else {
            return
        }
        let taxiPoolPassengerDetailViewController  = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolPassengerDetailViewController") as! TaxiPoolPassengerDetailViewController
        taxiPoolPassengerDetailViewController.showTaxipoolPassengers(taxipoolMatches: carpoolMatches, taxiRide: viewModel.taxiRide, selectedIndex: indexPath.row)
        self.navigationController?.pushViewController(taxiPoolPassengerDetailViewController, animated: false)
    }
}

