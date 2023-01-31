//
//  AddProductSuccessViewController.swift
//  Quickride
//
//  Created by Halesh on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddProductSuccessViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var addProductSuccessTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    //MARK: Varibales
    private var addProductSuccessViewModel = AddProductSuccessViewModel()
    
    func initailseSuccesView(postedProduct: PostedProduct,product: Product,covidCareHome : Bool){
        addProductSuccessViewModel = AddProductSuccessViewModel(postedProduct: postedProduct,product: product, covidCareHome : covidCareHome)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProductSuccessViewModel.getMatchingRequestList()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotification()
        addProductSuccessTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func prepareUI(){
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        addProductSuccessTableView.register(UINib(nibName: "AddProductSuccessTableViewCell", bundle: nil), forCellReuseIdentifier: "AddProductSuccessTableViewCell")
        addProductSuccessTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        addProductSuccessTableView.register(UINib(nibName: "VerifyYourProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "VerifyYourProfileTableViewCell")
        addProductSuccessTableView.register(UINib(nibName: "MatchingRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingRequestTableViewCell")
        addProductSuccessTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        addProductSuccessTableView.reloadData()
    }
    
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(matchingRequestsReceived), name: .matchingRequestsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
    }
    
    @objc func matchingRequestsReceived(_ notification: Notification){
        if !addProductSuccessViewModel.matchingRequests.isEmpty{
           addProductSuccessTableView.reloadData()
        }
    }
    
    @objc func footerTapped(_ notification: Notification){
        let allRequestsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AllRequestsViewController") as! AllRequestsViewController
        allRequestsViewController.initialiseAllRequests(availableRequests: addProductSuccessViewModel.matchingRequests)
        self.navigationController?.pushViewController(allRequestsViewController, animated: true)
    }
    
    //MARK : Actions
    @IBAction func addMoreTapped(_ sender: UIButton) {
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        if addProductSuccessViewModel.covidCareHome {
            ContainerTabBarViewController.indexToSelect = 2
        }else{
            ContainerTabBarViewController.indexToSelect = 2
        }
        
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
}
//MARK: UITableViewDataSource
extension AddProductSuccessViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if addProductSuccessViewModel.matchingRequests.count > 3{// matching requests
                return 3
            }else{
                return addProductSuccessViewModel.matchingRequests.count
            }
        case 3:
            if addProductSuccessViewModel.matchingRequests.count > 3{ // footer
                return 1
            }else{
                return 0
            }
        case 4:
            if UserDataCache.getInstance()?.userProfile?.profileVerificationData?.profileVerified == false{
                return 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddProductSuccessTableViewCell", for: indexPath) as! AddProductSuccessTableViewCell
            cell.initailiseSuccessView(isFromAddProduct: true, title: addProductSuccessViewModel.postedProduct.title ?? "")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
            cell.initialiseAddedProduct(postedProduct: addProductSuccessViewModel.postedProduct)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingRequestTableViewCell", for: indexPath) as! MatchingRequestTableViewCell
            if addProductSuccessViewModel.matchingRequests.endIndex <= indexPath.row{
                return cell
            }
            cell.initialiseMatchingRequest(availableRequest: addProductSuccessViewModel.matchingRequests[indexPath.row])
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: String(format: Strings.pluse_count_more, arguments: [String(addProductSuccessViewModel.matchingRequests.count - 3)]))
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VerifyYourProfileTableViewCell", for: indexPath) as! VerifyYourProfileTableViewCell
            cell.initailiseView()
            return cell
        default: break
        }
        return UITableViewCell()
    }
}

//MARK:UITableViewDelegate
extension AddProductSuccessViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let postedProductDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PostedProductDetailsViewController") as! PostedProductDetailsViewController
            postedProductDetailsViewController.initialiseProductDetails(postedProduct: addProductSuccessViewModel.postedProduct)
            self.navigationController?.pushViewController(postedProductDetailsViewController, animated: false)
        }else if indexPath.section == 4{
            let verifyProfileVC = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
           verifyProfileVC.intialData(isFromSignUpFlow: false)
            self.navigationController?.pushViewController(verifyProfileVC, animated: false)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    //Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1{
            return 10
        }else if section == 3 && !addProductSuccessViewModel.matchingRequests.isEmpty{
            return 10
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }
    //Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && !addProductSuccessViewModel.matchingRequests.isEmpty{
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 && !addProductSuccessViewModel.matchingRequests.isEmpty{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = .white
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 200, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            titleLabel.text = Strings.matching_request.uppercased()
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            return nil
        }
    }
}
