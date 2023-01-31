//
//  TaxiPoolIntroductionViewController.swift
//  Quickride
//
//  Created by Ashutos on 6/8/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


class TaxiPoolIntroductionViewController: UIViewController {
    
    @IBOutlet weak var taxiPointsShowingTableView: UITableView!
    
    private var ride: Ride?
    private var taxiSharedRide : TaxiShareRide?
    private var status = 0
    private var numberOfSeats = 3
    private var headerTitleLabel = Strings.taxi_pool_introduction_header_text
    
    func initialisationBeforeShowing(ride: Ride?,taxiSharedRide : TaxiShareRide?) {
        self.ride = ride
        self.taxiSharedRide = taxiSharedRide
    }
    
    let headerTitle = [Strings.taxi_joined,Strings.taxi_confirmed,Strings.taxi_alloted,Strings.taxi_started]
    let subtitleLabel = [Strings.taxi_join_sub,Strings.taxi_confirm_sub,Strings.taxi_alloted_sub,Strings.taxi_start_sub]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        taxiPointsShowingTableView.estimatedRowHeight = 40
        taxiPointsShowingTableView.rowHeight = UITableView.automaticDimension
        getTaxiStatusAndUpdateUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func getTaxiStatusAndUpdateUI() {
        guard let taxiShareRide = taxiSharedRide else { return }
        numberOfSeats = Int(taxiSharedRide?.capacity ?? 3)
        switch taxiShareRide.status {
        case TaxiShareRide.TAXI_SHARE_RIDE_STARTED :
            status = 4
            headerTitleLabel = Strings.taxi_started
            break
        case TaxiShareRide.TAXI_SHARE_RIDE_DELAYED,TaxiShareRide.TAXI_SHARE_RIDE_ALLOTTED :
            status = 3
            headerTitleLabel = Strings.taxi_alloted
            break
        case TaxiShareRide.TAXI_SHARE_RIDE_SUCCESSFUL_BOOKING,TaxiShareRide.TAXI_SHARE_RIDE_POOL_IN_PROGRESS :
            headerTitleLabel = Strings.taxi_joined
            status =  1
            break
        case TaxiShareRide.TAXI_SHARE_RIDE_SCHEDULED,TaxiShareRide.TAXI_SHARE_RIDE_POOL_CONFIRMED,TaxiShareRide.TAXI_SHARE_RIDE_BOOKING_IN_PROGRESS :
            status =  2
            headerTitleLabel = Strings.taxi_confirmed
            break
        default:
            status =  0
            headerTitleLabel = Strings.taxi_pool_introduction_header_text
            break
        }
    }
    
    @IBAction func gotItBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func cancelPolicyPressed(_ sender: UIButton) {
        cancelPolicy()
    }
    private func cancelPolicy() {
        let urlcomps = URLComponents(string :  AppConfiguration.taxipool_cancel_url)
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.taxipool_cancel_policy, url: urlcomps!.url! , actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }
    }
}

extension TaxiPoolIntroductionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  headerTitle.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IntroductionImageTableViewCell", for: indexPath) as! IntroductionImageTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiIntroductionTableViewCell", for: indexPath) as! TaxiIntroductionTableViewCell
            
            cell.setUpDataToUI(indexpath: indexPath.row - 1,title: headerTitle[indexPath.row-1], subTitle: subtitleLabel[indexPath.row-1],totalSeats: numberOfSeats, titleHeader: headerTitleLabel)
            cell.updateStatusAndUI(index: indexPath.row, status: status)
            return cell
        }
    }
}
