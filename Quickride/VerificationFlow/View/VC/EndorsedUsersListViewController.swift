//
//  EndorsedUsersListViewController.swift
//  Quickride
//
//  Created by Vinutha on 14/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsedUsersListViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var endorsedUserTableView: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    
    //MARK: Properties
    private var endorsedUsersListViewModel = EndorsedUsersListViewModel()
    
    //MARK: Initialiser
    func initialiseData(endorsedUserInfo: [EndorsementVerificationInfo]) {
        endorsedUsersListViewModel.initialiseData(endorsedUserInfo: endorsedUserInfo)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: Methods
    private func setUpUI() {
        endorsedUserTableView.estimatedRowHeight = 70
        endorsedUserTableView.rowHeight = UITableView.automaticDimension
        endorsedUserTableView.register(UINib(nibName: "EndorsementListTableViewCell", bundle: nil), forCellReuseIdentifier: "EndorsementListTableViewCell")
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    @objc private func backGroundViewTapped(_ gesture : UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
//MARK: table view data source
extension EndorsedUsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return endorsedUsersListViewModel.endorsedUserInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EndorsementListTableViewCell", for: indexPath) as! EndorsementListTableViewCell
        if endorsedUsersListViewModel.endorsedUserInfo.endIndex <= indexPath.row {
            return cell
        }
        let endorsedUser = endorsedUsersListViewModel.endorsedUserInfo[indexPath.row]
        cell.tag = 1
        cell.initializeView(endorsableUser: nil, endorsementVerificationInfo: endorsedUser, viewController: self)
        return cell
    }
    
}
