//
//  RequestProductSuccessViewController.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestProductSuccessViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var requestDetailsTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    private var requestProductSuccessViewModel = RequestProductSuccessViewModel()
    
    func initailseSuccesView(postedRequest: PostedRequest,requestProduct: RequestProduct,covidHome : Bool){
        requestProductSuccessViewModel = RequestProductSuccessViewModel(requestProduct: requestProduct, postedRequest: postedRequest,covidHome : covidHome)
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        requestProductSuccessViewModel.getMatchingProductList()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(matchingProductsReceived), name: .matchingProductsReceived ,object: nil)
    }
    private func prepareUI(){
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        requestDetailsTableView.register(UINib(nibName: "AddProductSuccessTableViewCell", bundle: nil), forCellReuseIdentifier: "AddProductSuccessTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "RequestSuccesDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestSuccesDetailsTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "UpadtesOnWhatsappTableViewCell", bundle: nil), forCellReuseIdentifier: "UpadtesOnWhatsappTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "MatchingProductTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingProductTableViewCell")
        requestDetailsTableView.reloadData()
    }
    
    @objc func footerTapped(_ notification: Notification){
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: nil,title: Strings.matching_products, availableProducts: requestProductSuccessViewModel.matchingProducts)
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
    
    @objc func matchingProductsReceived(_ notification: Notification){
        if !requestProductSuccessViewModel.matchingProducts.isEmpty{
           requestDetailsTableView.reloadData()
        }
    }
    //MARK : Actions
    @IBAction func needHelp(_ sender: UIButton) {
        let supportViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SupportElementViewController") as! SupportElementViewController
        supportViewController.initializeDataBeforePresenting(name: Strings.report_issue)
        self.navigationController?.pushViewController(supportViewController, animated: false)
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    
}
//MARK: UITableViewDataSource
extension RequestProductSuccessViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 1
        }else if section == 2{
            if requestProductSuccessViewModel.matchingProducts.count > 3{
                return 3
            }else{
                return requestProductSuccessViewModel.matchingProducts.count
            }
        }else if section == 3{
            if requestProductSuccessViewModel.matchingProducts.count > 3{
                return 1
            }else{
                return 0
            }
        }else{
            if let whatsAppPreferences = UserDataCache.getInstance()?.getLoggedInUserWhatsAppPreferences(), !whatsAppPreferences.enableWhatsAppPreferences{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddProductSuccessTableViewCell", for: indexPath) as! AddProductSuccessTableViewCell
            cell.initailiseSuccessView(isFromAddProduct: false, title: requestProductSuccessViewModel.postedRequest?.title ?? "")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestSuccesDetailsTableViewCell", for: indexPath) as! RequestSuccesDetailsTableViewCell
            cell.initialiseView(postedRequest: requestProductSuccessViewModel.postedRequest ?? PostedRequest())
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingProductTableViewCell", for: indexPath) as! MatchingProductTableViewCell
            cell.initialiseMatchingProduct(matchingProduct: requestProductSuccessViewModel.matchingProducts[indexPath.row])
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: String(format: Strings.pluse_count_more, arguments: [String(requestProductSuccessViewModel.matchingProducts.count - 3)]))
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpadtesOnWhatsappTableViewCell", for: indexPath) as! UpadtesOnWhatsappTableViewCell
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}
//MARK:UITableViewDelegate
extension RequestProductSuccessViewController: UITableViewDelegate{
    //Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 10
        case 3:
            if !requestProductSuccessViewModel.matchingProducts.isEmpty{
                return 10
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor(netHex: 0xEDEDED)
        return footerView
    }
    //Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && !requestProductSuccessViewModel.matchingProducts.isEmpty{
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 && !requestProductSuccessViewModel.matchingProducts.isEmpty{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = .white
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 200, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            titleLabel.text = Strings.matching_products.uppercased()
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            return nil
        }
    }
}
