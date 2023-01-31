//
//  CategoriesViewController.swift
//  Quickride
//
//  Created by Halesh on 23/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var searchButton: CustomUIButton!
    @IBOutlet weak var headerLabel: QRHeaderLabel!
    
    //MARK: Variables
    private var categoriesViewModel = CategoriesViewModel()
    
    func initialiseCategories(isFrom: String,covidHome : Bool){
        categoriesViewModel = CategoriesViewModel(isFrom: isFrom,covidHome : covidHome)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI(){
        if categoriesViewModel.isFrom == CategoriesViewModel.POST_PRODUCT{
            headerLabel.text = Strings.what_are_you_offering
        }else if categoriesViewModel.isFrom == CategoriesViewModel.REQUEST_PRODUCT{
            headerLabel.text = Strings.what_are_you_requesting
        }else{
            headerLabel.text = Strings.what_do_you_want
        }
        categoriesTableView.register(UINib(nibName: "AllCategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "AllCategoriesTableViewCell")
        categoriesTableView.register(UINib(nibName: "AddCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCategoryTableViewCell")
        categoriesTableView.register(UINib(nibName: "QuickShareAssuranceTableViewCell", bundle: nil), forCellReuseIdentifier: "QuickShareAssuranceTableViewCell")
        categoriesTableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 0 //Add category card not showing in phase 1
        }else{
            if categoriesViewModel.covidHome{
                return 0
            }else{
                return 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllCategoriesTableViewCell", for: indexPath) as! AllCategoriesTableViewCell
            cell.initialiseCategories(isFrom: categoriesViewModel.isFrom ?? "",covidHome : categoriesViewModel.covidHome)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCategoryTableViewCell", for: indexPath) as! AddCategoryTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuickShareAssuranceTableViewCell", for: indexPath) as! QuickShareAssuranceTableViewCell
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}
