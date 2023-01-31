//
//  TaxiHelpFaqInfoViewController.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiHelpFaqInfoViewController: UIViewController {
    
    @IBOutlet weak var helpTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var taxiHelpFaqInfoViewModel = TaxiHelpFaqInfoViewModel()

    func initialiseFaqsInfo(taxiHelpFaqCategory: TaxiHelpFaqCategory){
        taxiHelpFaqInfoViewModel = TaxiHelpFaqInfoViewModel(taxiHelpFaqCategory: taxiHelpFaqCategory)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = taxiHelpFaqInfoViewModel.taxiHelpFaqCategory.name
        setUpUi()
    }
    
    private func setUpUi(){
        helpTableView.register(UINib(nibName: "FaqInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "FaqInfoTableViewCell")
        helpTableView.register(UINib(nibName: "TaxiTripHelpTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripHelpTableViewCell")
        helpTableView.reloadData()
        self.automaticallyAdjustsScrollViewInsets = false
        helpTableView.estimatedRowHeight = 100
        helpTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TaxiHelpFaqInfoViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return taxiHelpFaqInfoViewModel.faqsElements.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaqInfoTableViewCell") as! FaqInfoTableViewCell
            if taxiHelpFaqInfoViewModel.faqsElements.endIndex <= indexPath.row{
                return cell
            }
            if taxiHelpFaqInfoViewModel.isExpanded[indexPath.row] == nil{
                taxiHelpFaqInfoViewModel.isExpanded[indexPath.row] = false
            }
            cell.setAnswer(content: taxiHelpFaqInfoViewModel.faqsElements[indexPath.row], isExpanded: taxiHelpFaqInfoViewModel.isExpanded[indexPath.row]!)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripHelpTableViewCell", for: indexPath) as! TaxiTripHelpTableViewCell
            cell.initialiseHelpView(title: "CONTACT CUSTOMER SUPPORT",taxiRide: nil)
            return cell
        }
    }
}
extension TaxiHelpFaqInfoViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            taxiHelpFaqInfoViewModel.isExpanded[indexPath.row] = !taxiHelpFaqInfoViewModel.isExpanded[indexPath.row]!
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        helpTableView.reloadData()
    }
}
