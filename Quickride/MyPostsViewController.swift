//
//  MyPostsViewController.swift
//  Quickride
//
//  Created by HK on 08/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyPostsViewController: UIViewController {
    
    //MARK:Outlets
    @IBOutlet weak var postsView: UIView!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var postEmptyView: UIView!
    
    private var viewModel = MyPostsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QuickShareSpinner.start()
        viewModel.getPostedProductsList()
        viewModel.getMyPostedRequestList()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func reloadPostsTableView(){
        if viewModel.postedProductList.isEmpty && viewModel.postedRequstList.isEmpty{
            postEmptyView.isHidden = false
            postsTableView.isHidden = true
        }else{
            postEmptyView.isHidden = true
            postsTableView.isHidden = false
            postsTableView.reloadData()
        }
    }
    
    private func setUpUI(){
        postsTableView.register(UINib(nibName: "RequestPostTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestPostTableViewCell")
        postsTableView.register(UINib(nibName: "PostsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostsTableViewCell")
    }
    
    //MARK: Notifications
    private func confirmNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(myPostReceived), name: .myPostReceived ,object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(postedProductDeleted), name: .postedProductDeleted ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postedRequestDeleted), name: .postedRequestDeleted ,object: nil)
    }
    
    @objc func postedProductDeleted(_ notification: Notification){
        let product = notification.userInfo?["postedProduct"] as? PostedProduct
        var postedProductList = [PostedProduct]()
        for postedProduct in viewModel.postedProductList{
            if product?.id !=  postedProduct.id{
                postedProductList.append(postedProduct)
            }
        }
        viewModel.postedProductList = postedProductList
        reloadPostsTableView()
    }
    
    @objc func postedRequestDeleted(_ notification: Notification){
        let request = notification.userInfo?["postedRequest"] as? PostedRequest
        var postedRequestList = [PostedRequest]()
        for postedRequest in viewModel.postedRequstList{
            if request?.id !=  postedRequest.id{
                postedRequestList.append(postedRequest)
            }
        }
        viewModel.postedRequstList = postedRequestList
        reloadPostsTableView()
    }
    
    @objc func myPostReceived(_ notification: Notification){
        QuickShareSpinner.stop()
        reloadPostsTableView()
    }
    
    @IBAction func postItemNowTapped(_ sender: Any) {
        let categoriesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        categoriesViewController.initialiseCategories(isFrom: CategoriesViewModel.POST_PRODUCT,covidHome: QuickShareCache.getInstance()?.covidCareHome ?? false)
        self.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}
//MARK:UITableViewDataSource
extension MyPostsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return viewModel.postedProductList.count
        }else{
            return viewModel.postedRequstList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as! PostsTableViewCell
            cell.initialisePostedProduct(postedProduct: viewModel.postedProductList[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestPostTableViewCell", for: indexPath) as! RequestPostTableViewCell
            cell.initialiseRequestView(postedRequest: viewModel.postedRequstList[indexPath.row],isFromCovid: false)
            return cell
        }
    }
}
//MARK:Outlets
extension MyPostsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let postedProductDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PostedProductDetailsViewController") as! PostedProductDetailsViewController
            postedProductDetailsViewController.initialiseProductDetails(postedProduct: viewModel.postedProductList[indexPath.row])
            self.navigationController?.pushViewController(postedProductDetailsViewController, animated: true)
        }else if indexPath.section == 1{
            let myRequestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyRequestDetailsViewController") as! MyRequestDetailsViewController
            myRequestDetailsViewController.initialiseRequiremnet(postedRequest: viewModel.postedRequstList[indexPath.row])
            self.navigationController?.pushViewController(myRequestDetailsViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
