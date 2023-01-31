//
//  AllRequestsViewController.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AllRequestsViewController: UIViewController {
    
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    
    private var availableRequests = [AvailableRequest]()
    
    func initialiseAllRequests(availableRequests: [AvailableRequest]){
        self.availableRequests = availableRequests
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI(){
        detailsTableView.register(UINib(nibName: "RequestsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestsTableViewCell")
        detailsTableView.estimatedRowHeight = 250
        detailsTableView.rowHeight = UITableView.automaticDimension
        detailsTableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK:UITableViewDataSource
extension AllRequestsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsTableViewCell", for: indexPath) as! RequestsTableViewCell
        cell.initialiseRequirement(availableRequest: availableRequests[indexPath.row])
        return cell
    }
}
//MARK:UITableViewDelegate
extension AllRequestsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let requirementRequestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequirementRequestDetailsViewController") as! RequirementRequestDetailsViewController
        requirementRequestDetailsViewController.initialiseRequiremnet(availableRequest: availableRequests[indexPath.row])
        self.navigationController?.pushViewController(requirementRequestDetailsViewController, animated: true)
    }
}
