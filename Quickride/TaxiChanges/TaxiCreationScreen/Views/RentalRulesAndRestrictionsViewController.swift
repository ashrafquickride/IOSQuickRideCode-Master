//
//  RentalRulesAndRestrictionsViewController.swift
//  Quickride
//
//  Created by Rajesab on 01/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalRulesAndRestrictionsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var extraFareInfoTableView: UITableView!
    @IBOutlet weak var rentalPackageInfoLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var rentalRulesAndRestrictionsViewModel = RentalRulesAndRestrictionsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        extraFareInfoTableView.register(UINib(nibName: "RentalExtraDurationAndDistanceFareTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalExtraDurationAndDistanceFareTableViewCell")
        if let rentalPackageConfig = rentalRulesAndRestrictionsViewModel.rentalPackageConfig,!rentalPackageConfig.isEmpty, let time = rentalPackageConfig[0].pkgDurationInMins,let distance = rentalPackageConfig[0].pkgDistanceInKm {
            rentalPackageInfoLabel.text = String(format: Strings.rentalPackageInfo, arguments: [String(time/60),String(distance)])
        }
        tableViewHeightConstraint.constant = CGFloat((rentalRulesAndRestrictionsViewModel.rentalPackageConfig?.count ?? 0) * 45)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(RentalRulesAndRestrictionsViewController.backGroundViewTapped(_:))))
        extraFareInfoTableView.delegate = self
        extraFareInfoTableView.dataSource = self
    }
    func initialiseData(rentalPackageConfig: [RentalPackageConfig]?){
        rentalRulesAndRestrictionsViewModel = RentalRulesAndRestrictionsViewModel(rentalPackageConfig: rentalPackageConfig)
    }
    
    @objc func backGroundViewTapped(_ gesture: UITapGestureRecognizer){
        self.closeView()
    }
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    @IBAction func removeButtonTapped(_ sender: Any) {
        closeView()
    }
}
extension RentalRulesAndRestrictionsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rentalRulesAndRestrictionsViewModel.rentalPackageConfig?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RentalExtraDurationAndDistanceFareTableViewCell", for: indexPath) as! RentalExtraDurationAndDistanceFareTableViewCell
        cell.setupUI(carType: rentalRulesAndRestrictionsViewModel.rentalPackageConfig?[indexPath.row].vehicleClass ?? "", extraDuration: String(rentalRulesAndRestrictionsViewModel.rentalPackageConfig?[indexPath.row].extraMinuteFare ?? 0), extraDistance: String(Int(rentalRulesAndRestrictionsViewModel.rentalPackageConfig?[indexPath.row].extraKmFare ?? 0)))
        return cell
    }
}
