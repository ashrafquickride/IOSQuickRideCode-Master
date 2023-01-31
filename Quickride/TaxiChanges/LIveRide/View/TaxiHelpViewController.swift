//
//  TaxiHelpViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiHelpViewController: UIViewController {
    
    @IBOutlet weak var helpTableView: UITableView!
    
    private var taxiHelpViewModel = TaxiHelpViewModel() 
    
    func initialiseTaxiStatus(tripStatus: String?,tripType: String?,sharing: String?,isfromTaxiLiveRide: Bool){
        taxiHelpViewModel = TaxiHelpViewModel(tripStatus: tripStatus, tripType: tripType, sharing: sharing, isfromTaxiLiveRide: isfromTaxiLiveRide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TaxiHelpDetailsParser.getInstance().getTaxiHelpFaqs { (taxiHelpFaqCategory) in
            if let taxiHelp = taxiHelpFaqCategory{
                self.taxiHelpViewModel.taxiHelpFaqCategory = self.taxiHelpViewModel.filterTaxiHelpFaqs(taxiHelpAllFaqs: taxiHelp.taxiHelp)
                self.helpTableView.reloadData()
            }
        }
        self.setUpUi()
    }
    
    private func setUpUi(){
        helpTableView.register(UINib(nibName: "TaxiHelpFaqTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiHelpFaqTableViewCell")
        helpTableView.register(UINib(nibName: "TaxiTripHelpTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripHelpTableViewCell")
        helpTableView.register(UINib(nibName: "CarpoolContactCustomerCareTableViewCell", bundle: nil), forCellReuseIdentifier: "CarpoolContactCustomerCareTableViewCell")
        helpTableView.register(UINib(nibName: "LegalInTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "LegalInTaxiTableViewCell")
        helpTableView.reloadData()
    }
    
    func toShowLegelView(){
        let legalViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LegalViewController") as! LegalViewController
        self.navigationController?.pushViewController(legalViewController, animated: false)
    }
    
    func toShowFeedbackView(){
        let feedViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as!  FeedbackViewController
        self.navigationController?.pushViewController(feedViewController, animated: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
extension TaxiHelpViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return taxiHelpViewModel.taxiHelpFaqCategory.count
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiHelpFaqTableViewCell") as! TaxiHelpFaqTableViewCell
            if taxiHelpViewModel.taxiHelpFaqCategory.endIndex <= indexPath.row{
                return cell
            }
            cell.infoLabel.text = taxiHelpViewModel.taxiHelpFaqCategory[indexPath.row].name
            return cell
        }else if  indexPath.section == 1 {
            if taxiHelpViewModel.isfromTaxiLiveRide{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolContactCustomerCareTableViewCell", for: indexPath) as! CarpoolContactCustomerCareTableViewCell
                cell.initialiseHelp(title: "NEED HELP", tripStatus: nil, tripType: nil, sharing: nil, isFromTaxiPool: false)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripHelpTableViewCell", for: indexPath) as! TaxiTripHelpTableViewCell
                cell.initialiseHelpView(title: "CONTACT CUSTOMER SUPPORT",taxiRide: nil)
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LegalInTaxiTableViewCell", for: indexPath) as! LegalInTaxiTableViewCell
            
            cell.titleLabel.text = Strings.help_taxi_titles[indexPath.row]
            if indexPath.row == 1 {
                cell.seperatorView.isHidden = true
                cell.lineSeparatorView.isHidden = true
            } else {
                cell.seperatorView.isHidden = false
                cell.lineSeparatorView.isHidden = false
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    }
extension TaxiHelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
           moveFaqInfoView(indexPath: indexPath.row)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
               toShowLegelView()
            } else {
                toShowFeedbackView()
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && !taxiHelpViewModel.taxiHelpFaqCategory.isEmpty{
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = UIColor.white
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 200, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            titleLabel.text = "FAQ"
            headerView.addSubview(titleLabel)
            return headerView
        }
        return nil
    }
    
    func moveFaqInfoView(indexPath: Int){
        let taxiHelpFaqInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiHelpFaqInfoViewController") as! TaxiHelpFaqInfoViewController
        taxiHelpFaqInfoViewController.initialiseFaqsInfo(taxiHelpFaqCategory: taxiHelpViewModel.taxiHelpFaqCategory[indexPath])
        self.navigationController?.pushViewController(taxiHelpFaqInfoViewController, animated: true)
    }
}
