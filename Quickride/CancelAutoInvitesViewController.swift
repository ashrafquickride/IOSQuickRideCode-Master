//
//  CancelAutoInvitesViewController.swift
//  Quickride
//
//  Created by Halesh K on 07/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelAutoInvitesViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var invitationsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    
    //MARK: Variables
    private var cancelAutoInvitesViewModel = CancelAutoInvitesViewModel()
    
    func initailizeAutoInvites(autoSentInvites: [RideInvitation],rideType: String?){
        cancelAutoInvitesViewModel.autoSentInvites = autoSentInvites
        cancelAutoInvitesViewModel.rideType = rideType
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        cancelAutoInvitesViewModel.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        showMoreInviteButton()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func showMoreInviteButton(){
        if cancelAutoInvitesViewModel.autoSentInvites.count > 3{
            tableViewHeightConstraint.constant = 205
        }else{
            tableViewHeightConstraint.constant = CGFloat(cancelAutoInvitesViewModel.autoSentInvites.count*60)
        }
    }
    
    //MARK: Actions
    @IBAction func cancelInvitesBtnTapped(_ sender: UIButton) {
        cancelAutoInvitesViewModel.cancelAutoSentInvites(viewController: self)
    }
    
    @IBAction func keepInvitesBtnTapped(_ sender: Any) {
        closeView()
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        cancelAutoInvitesViewModel.moreButtontapped = true
        tableViewHeightConstraint.constant = CGFloat(cancelAutoInvitesViewModel.autoSentInvites.count*60)
        invitationsTableView.reloadData()
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
}

//MARK: UITableViewDataSource
extension CancelAutoInvitesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cancelAutoInvitesViewModel.autoSentInvites.count > 3 && cancelAutoInvitesViewModel.moreButtontapped == false{
            return 3
        }else{
            return cancelAutoInvitesViewModel.autoSentInvites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CancelAutoInvitesTableViewCell", for: indexPath as IndexPath) as! CancelAutoInvitesTableViewCell
        if cancelAutoInvitesViewModel.autoSentInvites.endIndex == indexPath.row{
            return cell
        }
        var userId: Double?
        if cancelAutoInvitesViewModel.rideType == Ride.RIDER_RIDE{
            userId =  cancelAutoInvitesViewModel.autoSentInvites[indexPath.row].passengerId
        }else{
           userId = cancelAutoInvitesViewModel.autoSentInvites[indexPath.row].riderId
        }
        if let userId = userId{
            UserDataCache.getInstance()?.getUserBasicInfo(userId: userId, handler: { (userBasicInfo, responseError, error) in
                if let userBasicInfo = userBasicInfo{
                    cell.initailizeCell(name: userBasicInfo.name, imageUrl: userBasicInfo.imageURI,gender: userBasicInfo.gender, verificationData: userBasicInfo.profileVerificationData, company: userBasicInfo.companyName, routeMatchPer: self.cancelAutoInvitesViewModel.autoSentInvites[indexPath.row].matchPercentageOnRiderRoute)
                }
            })
        }
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension CancelAutoInvitesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !cancelAutoInvitesViewModel.moreButtontapped{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width , height: 35))
            let button = UIButton(frame: CGRect(x: 25, y: 0, width: footerView.bounds.size.width-25, height: 35))
            button.setTitle(String(format: Strings.more_invite, String(cancelAutoInvitesViewModel.autoSentInvites.count - 3)), for: .normal)
            button.setTitleColor(UIColor(netHex: 0x26aa4f), for: .normal)
            button.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 16)
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
            footerView.addSubview(button)
            return footerView
        }else{
           return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        }
    }
}

//MARK: CancelAutoInvitesViewModelDelegate
extension CancelAutoInvitesViewController: CancelAutoInvitesViewModelDelegate{
    func cancelledAllAutoInvites() {
        closeView()
    }
}

