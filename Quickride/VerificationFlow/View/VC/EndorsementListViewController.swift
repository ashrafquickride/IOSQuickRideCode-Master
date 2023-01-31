//
//  EndorsementListViewController.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsementListViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var endoserTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noContactsView: UIView!
    
    //MARK: Properties
    private var endorsementListViewModel = EndorsementListViewModel()
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        endorsementListViewModel.fetchEndorasableUser()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: Methods
    private func setUpUI() {
        noContactsView.isHidden = false
        endoserTableView.isHidden = true
        searchBar.delegate = self
        backButton.changeBackgroundColorBasedOnSelection()
        endoserTableView.estimatedRowHeight = 70
        endoserTableView.rowHeight = UITableView.automaticDimension
        endoserTableView.register(UINib(nibName: "EndorsementListTableViewCell", bundle: nil), forCellReuseIdentifier: "EndorsementListTableViewCell")
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(_:)), name: .reloadEndoserTableView, object: endorsementListViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(requestSucceded(_:)), name: .endoserRequestSucceded, object: nil)
    }
    
    @objc func reloadTableView(_ notification : NSNotification){
        if endorsementListViewModel.searchedEndorsableUsers.isEmpty {
            noContactsView.isHidden = false
            endoserTableView.isHidden = true
        } else {
            noContactsView.isHidden = true
            endoserTableView.isHidden = false
            endoserTableView.reloadData()
        }
    }
    
    @objc func requestSucceded(_ notification : NSNotification){
        endoserTableView.reloadData()
    }
    
    //MARK: Action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func startSharingRidesClicked(_ sender: Any) {
        moveToProperVC(selectedIndex: 0)
    }
    
    private func moveToProperVC(selectedIndex: Int) {
        ContainerTabBarViewController.indexToSelect = selectedIndex
        self.navigationController?.popToRootViewController(animated: false)
    }
}

//MARK: table view data source
extension EndorsementListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return endorsementListViewModel.searchedEndorsableUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EndorsementListTableViewCell", for: indexPath) as! EndorsementListTableViewCell
        if endorsementListViewModel.searchedEndorsableUsers.endIndex <= indexPath.row {
            return cell
        }
        let endorsableUser = endorsementListViewModel.searchedEndorsableUsers[indexPath.row]
        cell.requestButton.tag = indexPath.row
        cell.menuButton.tag = indexPath.row
        cell.tag = 0
        cell.initializeView(endorsableUser: endorsableUser, endorsementVerificationInfo: nil, viewController: self)
        return cell
    }
    
}

//MARK: Search bar delegate
extension EndorsementListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        endorsementListViewModel.searchedEndorsableUsers.removeAll()
        if searchText.isEmpty {
            endorsementListViewModel.searchedEndorsableUsers = endorsementListViewModel.endorsableUsers
        }else{
            for endorsableUser in endorsementListViewModel.endorsableUsers {
                if endorsableUser.name.localizedCaseInsensitiveContains(searchText){
                    endorsementListViewModel.searchedEndorsableUsers.append(endorsableUser)
                }
            }
        }
        NotificationCenter.default.post(name: .reloadEndoserTableView, object: endorsementListViewModel)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
}

