//
//  SafeKeeperConfirmationViewController.swift
//  Quickride
//
//  Created by Vinutha on 18/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SafeKeeperConfirmationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet var checkListTableView: UITableView!
    @IBOutlet var positiveActionButton: UIButton!
    @IBOutlet var negativeActionButton: UIButton!
    @IBOutlet var topView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var safeKeeperButton: UIButton!
    @IBOutlet var safeKeeperButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var safeBadgeImageView: UIImageView!
    
    
    //MARK: Properties
    private var checkList = [String]()
    private var handler: clickActionCompletionHandler?
    private var status: String?
    
    //MARK: Initiazer
    func initializeData(checkList: [String], status: String?, handler: clickActionCompletionHandler?) {
        self.checkList = checkList
        self.status = status
        self.handler = handler
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData()
        checkListTableView.dataSource = self
        checkListTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: Methods
    
    private func setUpData() {
        if status == UserSelfAssessmentCovid.FAIL {
            titleLabel.text = Strings.reconfirm_safety_checklist
            safeBadgeImageView.isHidden = false
            safeKeeperButton.isHidden = true
            topView.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.black
            subTitleLabel.textColor = UIColor.black
            safeKeeperButtonHeightConstraint.constant = 180
        } else {
            titleLabel.text = Strings.lets_beat_together
            safeBadgeImageView.isHidden = true
            safeKeeperButton.isHidden = false
            topView.backgroundColor = UIColor(netHex: 0xAAC7E9)
            titleLabel.textColor = UIColor.black
            subTitleLabel.textColor = UIColor.black
            safeKeeperButtonHeightConstraint.constant = 230
        }
    }
    
    //MARK: Actions
    @IBAction func positiveButtonClicked(_ sender: AnyObject) {
        handler?(positiveActionButton.titleLabel?.text)
    }
    
    @IBAction func negativeButtonClicked(_ sender: AnyObject) {
        handler?(negativeActionButton.titleLabel?.text)
    }
}
//MARK: TableViewDelegate
extension SafeKeeperConfirmationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SafeKeeperTableViewCell", for: indexPath as IndexPath) as! SafeKeeperTableViewCell
        if checkList.endIndex <= indexPath.row{
            return cell
        }
        cell.initializeData(message: checkList[indexPath.row])
        return cell
    }
}
