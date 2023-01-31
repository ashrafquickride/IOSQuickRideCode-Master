//
//  JoinTaxiRideViewController.swift
//  Quickride
//
//  Created by Ashutos on 4/23/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

protocol JoinTaxiRideViewControllerDelegate {
    func choosenShareType(shareType: String)
}

class JoinTaxiRideViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var popUpView: QuickRideCardView!
    //MARK: number Of Sharing Selection View
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfShareSelectionView: UIView!
    @IBOutlet weak var numberOfSharingTableView: UITableView!
    @IBOutlet weak var createAndJoinButton: UIButton!
    
    private var joinNewTaxiVM: JoinNewTaxiViewModel?
    var delegate: JoinTaxiRideViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func initialiseData(taxiPoolNewCardData : [GetTaxiShareMinMaxFare]?,choosenShareType: String, delegate: JoinTaxiRideViewControllerDelegate?) {
        joinNewTaxiVM = JoinNewTaxiViewModel(taxiPoolNewCardData: taxiPoolNewCardData, choosenShareType: choosenShareType)
        self.delegate = delegate
    }
    
    private func setUpUI() {
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: popUpView, cornerRadius: 20)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.popUpView.center.y -= self.popUpView.bounds.height
            }, completion: nil)
        viewHeightConstraint.constant = CGFloat(135 + (joinNewTaxiVM?.taxiPoolNewCardData?.count ?? 0)*50)
    }
    
    
    @IBAction func createAndJoinButtonPressed(_ sender: UIButton) {
        removeView()
        delegate?.choosenShareType(shareType: joinNewTaxiVM?.getShareType() ?? "")
    }
    
    @objc func backGroundViewTapped(_ sender: AnyObject) {
        removeView()
    }
    
    private func removeView() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension JoinTaxiRideViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinNewTaxiVM?.taxiPoolNewCardData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiSharingShowingTableViewCell", for: indexPath) as! TaxiSharingShowingTableViewCell
        cell.updateUI(data: joinNewTaxiVM?.taxiPoolNewCardData?[indexPath.row])
        if joinNewTaxiVM?.numberOfSharingData.contains(indexPath.row) ?? false {
            cell.radiobuttonImageView.image = UIImage(named: "ic_radio_button_checked")
        }else{
            cell.radiobuttonImageView.image = UIImage(named: "radio_button_1")
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension JoinTaxiRideViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        joinNewTaxiVM?.numberOfSharingData = [indexPath.row]
        numberOfSharingTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }
}
