//
//  QuickJobsAnimationViewController.swift
//  Quickride
//
//  Created by Rajesab on 18/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class QuickJobsAnimationViewController: UIViewController, UITableViewDataSource {
   
    @IBOutlet weak var contentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTableView.register(UINib(nibName: "HomeScreenLoadingAnimationTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeScreenLoadingAnimationTableViewCell")
        contentTableView.dataSource = self
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        contentTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenLoadingAnimationTableViewCell", for: indexPath) as! HomeScreenLoadingAnimationTableViewCell
        cell.setupUI()
        return cell
    }
   
}
