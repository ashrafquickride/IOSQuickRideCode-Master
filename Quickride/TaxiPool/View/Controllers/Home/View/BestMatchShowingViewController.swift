//
//  BestMatchShowingViewController.swift
//  Quickride
//
//  Created by Ashutos on 9/5/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol BestMatchShowingViewControllerDelegate {
    func joinPressed(index: Int)
    func createTaxiPoolPressed()
}

class BestMatchShowingViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var popUpView: QuickRideCardView!
    @IBOutlet weak var bestMatchTableView: UITableView!
    @IBOutlet weak var bestMatchTableViewHeightConstraints: NSLayoutConstraint!
    
    var delegate : BestMatchShowingViewControllerDelegate?
    private var matchedTaxiShareRide: [MatchedShareTaxi?] = []
    private var shareType: String?
    private var price: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        // Do any additional setup after loading the view.
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
        bestMatchTableView.register(UINib(nibName: "BestMatchTableViewCell", bundle: nil), forCellReuseIdentifier: "BestMatchTableViewCell")
        bestMatchTableView.estimatedRowHeight  = 100
        bestMatchTableView.rowHeight = UITableView.automaticDimension
        bestMatchTableViewHeightConstraints.constant  = CGFloat((matchedTaxiShareRide.count + 1)*150)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    func prepareDataBeforePresent(matchedTaxiShareRide: [MatchedShareTaxi?],shareType: String,price: String) {
        self.matchedTaxiShareRide = matchedTaxiShareRide
        self.shareType = shareType
        self.price = price
    }
}

extension BestMatchShowingViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if matchedTaxiShareRide.isEmpty {
            return  0
        }else {
            return matchedTaxiShareRide.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BestMatchTableViewCell", for: indexPath) as! BestMatchTableViewCell
        cell.joinBtn.tag = indexPath.row
        cell.joinBtn.addTarget(self, action: #selector(joinBtn(_:)), for: .touchUpInside)
        if indexPath.row < matchedTaxiShareRide.count  {
            cell.showRideParticipentDetails(taxiShare: matchedTaxiShareRide[indexPath.row],shareType: shareType ?? "")
        } else {
            cell.showShareType(shareType: shareType ?? "", price: price ?? "")
        }
        return cell
    }
    
    @objc private func joinBtn(_ sender: AnyObject) {
        removeView()
        if sender.tag == matchedTaxiShareRide.count {
            delegate?.createTaxiPoolPressed()
        } else {
            delegate?.joinPressed(index: sender.tag)
        }
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        self.dismiss(animated: false, completion: nil)
    }
}

