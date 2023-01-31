//
//  MultipleInvitesStatusController.swift
//  Quickride
//
//  Created by Vinutha on 6/27/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MultipleInvitesStatusController: ModelViewController,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var backGroundView: UIView!

    @IBOutlet weak var alertView: UIView!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    var rideInvites = [RideInviteResponse]()
    var matchedUserMap = [Double: MatchedUser]()
    var heights = [Int]()
    var viewController: UIViewController?
    
    func initializeDataBeforePresenting(rideInvites: [RideInviteResponse], matchedUsers : [MatchedUser], viewController: UIViewController){
        self.rideInvites = rideInvites
        for matchedUser in matchedUsers{
            matchedUserMap[matchedUser.userid!] = matchedUser
        }
        self.viewController = viewController
    }
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MultipleInvitesStatusController.backgroundTapped(sender:))))
        
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideInvites.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteContactStatusTableViewCell") as! InviteContactStatusTableViewCell
        if rideInvites.endIndex <= indexPath.row{
            return cell
        }
        let rideInviteResponse = rideInvites[indexPath.row]
        let matchedUser = matchedUserMap[rideInviteResponse.invitedUserId!]
        cell.userName.text = matchedUser?.name
        if rideInviteResponse.success{
            cell.statusImage.image = UIImage(named: "ride_sch")
            cell.failureMessage.isHidden = true
        }else{
            cell.statusImage.image = UIImage(named: "ride_cncl")
            cell.failureMessage.isHidden = false
            cell.failureMessage.text = rideInviteResponse.error!.userMessage
        }

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rideInviteResponse = rideInvites[indexPath.row]
        
        if rideInviteResponse.success{
            return 50
        }
        else{
            let lines = CGFloat(rideInviteResponse.error!.userMessage!.count * 12)/(self.alertView.frame.size.width - 50)
            var height = lines * CGFloat(ViewCustomizationUtils.ALERT_DIALOG_LABEL_LINE_HEIGHT)
            height = height + 20

            if height < 50{
                height = 50
            }
            return height

        }
    }
    @objc func backgroundTapped(sender : UITapGestureRecognizer){
       removeViewAndNavigate()
    }
    @IBAction func closeBtnClicked(_ sender: UIButton) {
       removeViewAndNavigate()
    }
    func removeViewAndNavigate(){
        self.view.removeFromSuperview()
        self.removeFromParent()
        viewController?.navigationController?.popViewController(animated: false)
    }
    
}



