//
//  TaxiNextStepShowingViewController.swift
//  Quickride
//
//  Created by Ashutos on 9/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiNextStepShowingViewController: UIViewController {
    
    @IBOutlet weak var popUpView: QuickRideCardView!
    @IBOutlet weak var taxiPoolStepsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    
    private var taxiPoolNextStepViewModel: TaxiPoolNextStepViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpUI()
        taxiPoolStepsTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func prepareData(taxiRidePassengerDetails: TaxiRidePassengerDetails) {
        taxiPoolNextStepViewModel = TaxiPoolNextStepViewModel(taxiRidePassengerDetails: taxiRidePassengerDetails)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func registerCell() {
        taxiPoolStepsTableView.register(UINib(nibName: "NextStepTableViewCell", bundle: nil), forCellReuseIdentifier: "NextStepTableViewCell")
        
    }
    
    private func setUpUI() {
        tableViewHeightConstraint.constant = CGFloat((taxiPoolNextStepViewModel?.getNumberOfCells() ?? 0)*93)
        taxiPoolStepsTableView.estimatedRowHeight  = 90
        taxiPoolStepsTableView.rowHeight = UITableView.automaticDimension
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        
        if tableViewHeightConstraint.constant > self.view.bounds.height {
            taxiPoolStepsTableView.isScrollEnabled = true
        }else{
            taxiPoolStepsTableView.isScrollEnabled = false
        }
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
extension TaxiNextStepShowingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxiPoolNextStepViewModel?.getNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NextStepTableViewCell", for: indexPath) as! NextStepTableViewCell
        cell.updateUI(taxiRidePassengerDetails: taxiPoolNextStepViewModel?.taxiRidePassengerDetails, index: indexPath.row, headerString: taxiPoolNextStepViewModel?.taxiShareHeaders[indexPath.row] ?? "", subTitle: taxiPoolNextStepViewModel?.taxiShareSubTitles[indexPath.row] ?? "")
        return cell
    }
}
