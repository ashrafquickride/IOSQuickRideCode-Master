//
//  TaxipoolInviteDetailBottomViewController.swift
//  Quickride
//
//  Created by HK on 20/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxipoolInviteDetailBottomViewController: UIViewController {
    
    @IBOutlet weak var taxiInviteDetailCardTableView: UITableView!
    
    private var viewModel = TaxipoolInviteDetailsViewModel()
    func prepareBottomSheet(viewModel: TaxipoolInviteDetailsViewModel){
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    private func registerCells(){
        taxiInviteDetailCardTableView.register(UINib(nibName: "TaxipoolInviteUserDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxipoolInviteUserDetailsTableViewCell")
        taxiInviteDetailCardTableView.register(UINib(nibName: "TaxipoolJoinedMembersTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxipoolJoinedMembersTableViewCell")
        taxiInviteDetailCardTableView.reloadData()
    }
}
//MARK: UITableViewDataSource
extension TaxipoolInviteDetailBottomViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            if let joinedPassengers = viewModel.matchedTaxiRideGroup?.joinedPassengers,!joinedPassengers.isEmpty{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxipoolInviteUserDetailsTableViewCell", for: indexPath) as! TaxipoolInviteUserDetailsTableViewCell
            cell.showInvitedUserInfo(viewModel: viewModel)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxipoolJoinedMembersTableViewCell", for: indexPath) as! TaxipoolJoinedMembersTableViewCell
            cell.showJoinedMembers(joinedMembers: (viewModel.matchedTaxiRideGroup?.joinedPassengers)!,isFromLiveRide: false,taxiRidePassengerBasicInfos: nil)
            return cell
        }
    }
}
