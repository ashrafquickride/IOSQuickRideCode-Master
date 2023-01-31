//
//  ResolveRiskAlertViewController.swift
//  Quickride
//
//  Created by Ashraf 1 on 24/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import UIKit

typealias customerResolveRiskCompletionHandler = (_ isReslolvedTapped :Bool?) -> Void

class ResolveRiskAlertViewController: UIViewController{
    
    @IBOutlet weak var customerResolveRiskTableView: UITableView!
    @IBOutlet weak var customerResolveTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: QuickRideCardView!
    @IBOutlet weak var backGroundView: UIView!
    
    var customerAlertViewModel: CustomerAlertViewModel?
    var tableViewHeight = 0.0
        
    func initialiseDataPresentingView(taxiGroupId: Double, rideRiskAssessment: [RideRiskAssessment]){
        customerAlertViewModel = CustomerAlertViewModel(taxiGroupId: taxiGroupId, rideRiskAssessment: rideRiskAssessment)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerResolveRiskTableView.rowHeight = UITableView.automaticDimension
        customerResolveRiskTableView.delegate = self
        customerResolveRiskTableView.dataSource = self
        customerResolveRiskTableView.register(UINib(nibName: "RiskResolveTableViewCell", bundle: nil), forCellReuseIdentifier: "RiskResolveTableViewCell")
        setUpUI()
        setTableViewHeight()
        customerResolveRiskTableView.reloadData()
    }
    
    private func setUpUI(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        self.contentView.layoutIfNeeded()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func setTableViewHeight(){
            tableViewHeight = CGFloat(((customerAlertViewModel?.rideRiskAssessment?.count ?? 0))*36 + 70)
        customerResolveTableViewHeight.constant = tableViewHeight
      
        if (CGFloat(tableViewHeight)) > 550 {
            customerResolveTableViewHeight.constant = 550
            customerResolveRiskTableView.isScrollEnabled = true
        }
    }
}

extension  ResolveRiskAlertViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerAlertViewModel?.rideRiskAssessment?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reasonsResloveCell = tableView.dequeueReusableCell(withIdentifier: "RiskResolveTableViewCell", for: indexPath) as! RiskResolveTableViewCell
        if let rideRiskAssessment = customerAlertViewModel?.rideRiskAssessment {
            reasonsResloveCell.toSetUpUi(rideRiskAssessment: rideRiskAssessment[indexPath.row]) { isReslolvedTapped in
                self.customerAlertViewModel?.customerResolveRiskResons(rideRiskAssessment: rideRiskAssessment[indexPath.row]) { result in
                    if result == true {
                        reasonsResloveCell.markAsResolveHeightCon.constant = 0
                        self.contentView.layoutIfNeeded()
                    }
                }
            }
        }
        return reasonsResloveCell
    }
    
    
    
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}
    
}
