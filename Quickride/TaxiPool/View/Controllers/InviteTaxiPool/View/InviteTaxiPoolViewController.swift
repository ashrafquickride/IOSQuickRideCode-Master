//
//  InviteTaxiPoolViewController.swift
//  Quickride
//
//  Created by Ashutos on 8/7/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InviteTaxiPoolViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var InviteListTaxiPoolTableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var inviteTaxiPoolViewModel: InviteTaxiPoolViewModel?
    private var quickRideProgressBar : QuickRideProgressBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initisation(ride: Ride?, taxiShareRide: TaxiShareRide?) {
        inviteTaxiPoolViewModel = InviteTaxiPoolViewModel(taxiShareRide: taxiShareRide, ride: ride)
    }
    
    private func setUpUI() {
        quickRideProgressBar = QuickRideProgressBar(progressBar: progressBar)
    }
    
    private func getData() {
        quickRideProgressBar?.startProgressBar()
        inviteTaxiPoolViewModel?.getMatchingList(completionHandler: {
            [weak self] result in
            self?.quickRideProgressBar?.stopProgressBar()
            if result {
                self?.InviteListTaxiPoolTableView.isHidden = false
                self?.InviteListTaxiPoolTableView.reloadData()
            }else{
                self?.InviteListTaxiPoolTableView.isHidden = true
            }
        })
        inviteTaxiPoolViewModel?.getInvitedList(completionHandler: { [weak self] (result) in
            self?.InviteListTaxiPoolTableView.reloadData()
        })
    }
    
    private func registerCell() {
        InviteListTaxiPoolTableView.register(UINib(nibName: "InviteTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteTableViewCell")
        InviteListTaxiPoolTableView.register(UINib(nibName: "EmptyMatchedUserTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyMatchedUserTableViewCell")
        InviteListTaxiPoolTableView.estimatedRowHeight = 150
        InviteListTaxiPoolTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}

extension InviteTaxiPoolViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if progressBar.isHidden {
          return inviteTaxiPoolViewModel?.matchedPassengerList?.count ?? 0
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if progressBar.isHidden {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell", for: indexPath) as! InviteTableViewCell
            cell.setUpUIWithData(data: inviteTaxiPoolViewModel?.matchedPassengerList?[indexPath.row], ride: inviteTaxiPoolViewModel?.ride, row: indexPath.row, allInvites: inviteTaxiPoolViewModel?.allInvitedUsers)
            return cell
        }else {
           let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyMatchedUserTableViewCell", for: indexPath) as! EmptyMatchedUserTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension InviteTaxiPoolViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if inviteTaxiPoolViewModel?.matchedPassengerList == []  || !progressBar.isHidden {
            return
        }
         let taxiPoolInviteDetails = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolPassengerDetailsInviteViewController") as! TaxiPoolPassengerDetailsInviteViewController
        taxiPoolInviteDetails.dataBeforePresent(selectedIndex: indexPath.row, matchedPassengerRide:inviteTaxiPoolViewModel!.matchedPassengerList ?? [] , taxiShareRide: inviteTaxiPoolViewModel!.taxiShareRide!, ride: inviteTaxiPoolViewModel?.ride, allInvitedUsers: inviteTaxiPoolViewModel?.allInvitedUsers)
               self.navigationController?.pushViewController(taxiPoolInviteDetails, animated: false)
    }
}
