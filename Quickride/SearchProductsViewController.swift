//
//  SearchProductsViewController.swift
//  Quickride
//
//  Created by Halesh on 21/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class SearchProductsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var tradeTypeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchProductsTableView: UITableView!
    @IBOutlet weak var numberOfCharacterLeftLabel: UILabel!
    @IBOutlet weak var noProductsView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var noProductsOrRequestFoundLabel: UILabel!
    @IBOutlet weak var noResultsFoundInfoLabel: UILabel!
    @IBOutlet weak var noResultActionButton: QRCustomButton!
    
    //MARK: Variables
    private var tradeTypesDropDown = DropDown()
    private var searchProductsViewModel = SearchProductsViewModel()
    
    func initialiseSearchView(tradeType: String){
        searchProductsViewModel = SearchProductsViewModel(tradeType: tradeType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tradeTypeLabel.text = searchProductsViewModel.tradeType
        spinner.isHidden = true
        searchBar.delegate = self
        productView.backgroundColor = .black
        searchBar.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
       confirmNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func confirmNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSearchedProductTitleList), name: .receivedSearchedProductTitleList ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSearchedProductMatchedList), name: .receivedSearchedProductMatchedList ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSearchedRequestMatchedList), name: .receivedSearchedRequestMatchedList ,object: nil)
    }
    
    @objc func receivedSearchedProductTitleList(_ notification: Notification){
        spinner.stopAnimating()
        spinner.isHidden = true
        if !searchProductsViewModel.searchList.isEmpty{
            searchProductsTableView.isHidden = false
            noProductsView.isHidden = true
            searchProductsTableView.reloadData()
        }else{
            searchProductsTableView.isHidden = true
            noProductsView.isHidden = false
        }
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func receivedSearchedProductMatchedList(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let currentLocation = QuickShareCache.getInstance()?.location
        let searchTitle = String(format: Strings.search_title, arguments: ["'\(searchProductsViewModel.selectedType ?? "")'",currentLocation?.areaName ?? ""])
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: nil,title: searchTitle, availableProducts: searchProductsViewModel.searchQueryMatchedProducts)
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
    
    @objc func receivedSearchedRequestMatchedList(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let allRequestsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AllRequestsViewController") as! AllRequestsViewController
        allRequestsViewController.initialiseAllRequests(availableRequests: searchProductsViewModel.searchQueryMatchedRequest)
        self.navigationController?.pushViewController(allRequestsViewController, animated: true)
    }
    
    @IBAction func showTradeTypes(_ sender: Any) {
        prepareDropDownAndShowTradeTypes()
    }
    
    private func prepareDropDownAndShowTradeTypes(){
        tradeTypesDropDown.anchorView = tradeTypeLabel
        tradeTypesDropDown.direction = .bottom
        tradeTypesDropDown.dataSource = Strings.tradeTypes
        tradeTypesDropDown.show()
        tradeTypesDropDown.selectionAction = {(index, item) in
            self.tradeTypeLabel.text = item
            self.searchProductsViewModel.tradeType = item
            if self.searchBar.text?.count ?? 0 == 3 || (self.searchBar.text?.count ?? 0 > 3 && (self.searchBar.text?.count ?? 0)%2 == 0){
                self.spinner.isHidden = false
                self.spinner.startAnimating()
                self.searchProductsViewModel.getProductsBasedOnEnteredCharacters(query: self.searchBar.text ?? "")
            }
        }
    }
    @IBAction func postRequestTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.REQUEST_PRODUCT,covidHome: false)
        self.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
    
    @IBAction func productsSearchTapped(_ sender: Any) {
        if searchProductsViewModel.searchType != SearchProductsViewModel.PRODUCTS{
            handleView()
        }
        productView.backgroundColor = .black
        requestView.backgroundColor = UIColor(netHex: 0xEAEAEA)
        searchProductsViewModel.searchType = SearchProductsViewModel.PRODUCTS
        noProductsOrRequestFoundLabel.text = "No Products Found"
        noResultsFoundInfoLabel.isHidden = false
        noResultActionButton.isHidden = false
    }
    private func handleView(){
        QuickRideProgressSpinner.stopSpinner()
        searchBar.text = ""
        searchProductsTableView.isHidden = false
        noProductsView.isHidden = true
        searchProductsViewModel.searchList.removeAll()
        searchProductsTableView.reloadData()
    }
    
    @IBAction func requestSearchTapped(_ sender: Any) {
        if searchProductsViewModel.searchType != SearchProductsViewModel.REQUESTS{
            handleView()
        }
        productView.backgroundColor = UIColor(netHex: 0xEAEAEA)
        requestView.backgroundColor = .black
        searchProductsViewModel.searchType = SearchProductsViewModel.REQUESTS
        noProductsOrRequestFoundLabel.text = "No Requests Found"
        noResultsFoundInfoLabel.isHidden = true
        noResultActionButton.isHidden = true
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: UITableViewDataSource
extension SearchProductsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchProductsViewModel.searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchProductTableViewCell", for: indexPath) as! SearchProductTableViewCell
        cell.initialiseList(productTitle: searchProductsViewModel.searchList[indexPath.row])
        return cell
    }
}

//MARK: UITableViewDelegate
extension SearchProductsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QuickRideProgressSpinner.startSpinner()
        searchBar.endEditing(true)
        searchProductsViewModel.getProductsForPerticularTitle(query: searchProductsViewModel.searchList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//MARK: UISearchBarDelegate
extension SearchProductsViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        let queryString = searchBar.text
        if queryString?.count ?? 0 < 3 && queryString?.count ?? 0 > 0{
            numberOfCharacterLeftLabel.isHidden = false
            numberOfCharacterLeftLabel.text = "\(3 - (queryString?.count ?? 0)) more character"
        } else {
            numberOfCharacterLeftLabel.isHidden = true
        }
        
        if queryString?.isEmpty == true{
            searchProductsViewModel.searchList.removeAll()
            searchProductsTableView.isHidden = false
            noProductsView.isHidden = true
            searchProductsTableView.reloadData()
        }else if queryString?.count ?? 0 == 3 || (queryString?.count ?? 0 > 3 && (queryString?.count ?? 0)%2 == 0){
            spinner.isHidden = false
            spinner.startAnimating()
            searchProductsViewModel.getProductsBasedOnEnteredCharacters(query: searchBar.text ?? "")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
}
