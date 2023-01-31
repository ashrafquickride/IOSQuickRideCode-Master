//
//  ProductListViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductListViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var productLIstTableView: UITableView!
    @IBOutlet weak var backbutton: CustomUIButton!
    @IBOutlet weak var titleLabel: QRHeaderLabel!
    @IBOutlet weak var emptyScreenView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var postProductButton: UIButton!
    
    private var productListViewModel = ProductListViewModel()
    
    func initialiseProductsListing(categoryCode: String?,title: String,availableProducts: [AvailableProduct]){
        productListViewModel = ProductListViewModel(categoryCode: categoryCode,title: title,availabelProducts: availableProducts)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        confirmNotifications()
    }
    
    private func prepareUI(){
        titleLabel.text = productListViewModel.screenTitle
        if productListViewModel.availabelProducts.isEmpty{
            QuickShareSpinner.start()
            productListViewModel.getProductListForThisCategory()
        }else{
            emptyScreenView.isHidden = true
            productLIstTableView.isHidden = false
            reloadTableView()
        }
        if productListViewModel.categoryCode != nil{
            postProductButton.isHidden = false
        }else{
            postProductButton.isHidden = true
        }
    }
    //MARK: Notifications
    private func confirmNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(productsReceived), name: .productsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
    }
    
    @objc func productsReceived(_ notification: Notification){
        QuickShareSpinner.stop()
        if productListViewModel.availabelProducts.isEmpty{
            emptyScreenView.isHidden = false
            productLIstTableView.isHidden = true
            let category = productListViewModel.getCategoryObjectForCategoryCode()
            ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: category?.imageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        }else{
            reloadTableView()
        }
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func reloadTableView(){
        productLIstTableView.register(UINib(nibName: "ProductListTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductListTableViewCell")
        productLIstTableView.register(UINib(nibName: "MostViewedProductsTableViewCell", bundle: nil), forCellReuseIdentifier: "MostViewedProductsTableViewCell")
        productLIstTableView.register(UINib(nibName: "AddCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCategoryTableViewCell")
        productLIstTableView.dataSource = self
        productLIstTableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postRequestTapped(_ sender: Any) {
        let requestProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductViewController") as! RequestProductViewController
        requestProductViewController.initialiseRequestView(productType: productListViewModel.screenTitle ?? "",categoryCode: productListViewModel.categoryCode ?? "", requestProduct: nil,isFromCovid: false)
        self.navigationController?.pushViewController(requestProductViewController, animated: true)
    }
    
    @IBAction func postProductTapped(_ sender: Any) {
        let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
        addProductStepsViewController.initialiseAddingProductSteps(productType: productListViewModel.screenTitle ?? "", isFromEditDetails: false, product: nil,categoryCode: productListViewModel.categoryCode ?? "", requestId: nil,covidHome: false)
        self.navigationController?.pushViewController(addProductStepsViewController, animated: true)
    }
}
extension ProductListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //in Phase 1 not shwoing most viewd
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if !productListViewModel.availabelProducts.isEmpty{
                return 1
            }else{
                return 0
            }
        case 1:
            return 1
        case 2:
            if !productListViewModel.mostViewedProducts.isEmpty{
                return 0
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListTableViewCell", for: indexPath) as! ProductListTableViewCell
            cell.initialiseProductsList(availabelProducts: productListViewModel.availabelProducts)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCategoryTableViewCell", for: indexPath) as! AddCategoryTableViewCell
            cell.initialiseView(isFrom: CategoriesViewModel.REQUEST_PRODUCT, categoryCode: productListViewModel.categoryCode)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MostViewedProductsTableViewCell", for: indexPath) as! MostViewedProductsTableViewCell
            cell.initialiseMostViewedproduct(availabelProducts: productListViewModel.mostViewedProducts)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
