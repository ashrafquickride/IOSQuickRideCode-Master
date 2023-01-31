//
//  QuickShareHomePageViewController.swift
//  Quickride
//
//  Created by Halesh on 19/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class QuickShareHomePageViewController: UIViewController {
    
    //MARK:Outlets
    @IBOutlet weak var pendingNotificationView: UIView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var chatUnreadCountView: UIView!
    @IBOutlet weak var chatUnreadCountLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var browseView: UIView!
    @IBOutlet weak var browseTableView: UITableView!
    @IBOutlet weak var radiusButton: UIButton!
    
    //MARK:Variables
    private var locationManager = CLLocationManager()
    private var viewModel = QuickShareHomePageViewModel()
    
    func initialseQuickShareHomePage(covidCareHome : Bool){
        viewModel.covidCareHome = covidCareHome
        QuickShareCache.getInstance()?.covidCareHome = covidCareHome
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        locationManager.delegate = self
        let catgories = QuickSharePersistanceHelper.getAvailableCategoryList()
        QuickShareCache.getInstance()?.storeAvailableCategoryList(categories: catgories)
        radiusButton.setTitle(String(format: Strings.market_radius, arguments: [StringUtils.getStringFromDouble(decimalNumber: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS)]), for: .normal)
        setUpUI()
    }
    
    private func getLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            locationManager.requestLocation()
        }else{
            LocationClientUtils.checkLocationAutorizationStatus(status: status) { [self] (isConfirmed) in
                if isConfirmed{
                    locationManager.requestAlwaysAuthorization()
                    locationManager.requestWhenInUseAuthorization()
                }else{
                    selectLocation()
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        getLocation()
        confirmNotifications()
        handleChatCountDisplay()
        handleNotificationCountAndDisplay()
        viewModel.getAllRequiredData()
        browseTableView.reloadData()
        displayUpdateApplicationIfRequired()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI(){
        browseTableView.register(UINib(nibName: "HomeCarouselImageTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeCarouselImageTableViewCell")
        browseTableView.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoriesTableViewCell")
        browseTableView.register(UINib(nibName: "RecentlyAddedTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentlyAddedTableViewCell")
        browseTableView.register(UINib(nibName: "RecentRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentRequestTableViewCell")
        browseTableView.register(UINib(nibName: "CovidCareHomeImageTableViewCell", bundle: nil), forCellReuseIdentifier: "CovidCareHomeImageTableViewCell")
        browseTableView.register(UINib(nibName: "CovidCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CovidCategoryTableViewCell")
        browseTableView.register(UINib(nibName: "PostAndRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "PostAndRequestTableViewCell")
        browseTableView.register(UINib(nibName: "CovidItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CovidItemTableViewCell")
        browseTableView.register(UINib(nibName: "HomeScreenLoadingAnimationTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeScreenLoadingAnimationTableViewCell")
    }
    
    func displayUpdateApplicationIfRequired(){
        AppDelegate.getAppDelegate().log.debug("displayUpdateApplicationIfRequired()")
        let configurationCache = ConfigurationCache.getInstance()
        if configurationCache == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        let updateStatus = ConfigurationCache.getInstance()!.appUpgradeStatus
        if updateStatus == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        if updateStatus == User.UPDATE_REQUIRED{
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : false, message1: Strings.upgrade_version, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : nil,linkButtonText : nil,viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }else if updateStatus == User.UPDATE_AVAILABLE {
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : true, message1: Strings.new_version_available, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : Strings.later_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }
    }
    
    private func moveToAppStore(){
        AppDelegate.getAppDelegate().log.debug("moveToAppStore()")
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.please_upgrade_from_app_store, duration: 3.0, position: .center)
        }
    }
    
    private func handleChatCountDisplay(){
        let count = MessageUtils.getUnreadCountOfChat()
        if count > 0{
            chatUnreadCountView.isHidden = false
            chatUnreadCountLabel.text = String(count)
        }else{
            chatUnreadCountView.isHidden = true
        }
    }
    
    private func handleNotificationCountAndDisplay(){
        let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0{
            pendingNotificationView.isHidden = false
            notificationCountLabel.text = String(pendingNotificationCount)
        }else{
            pendingNotificationView.isHidden = true
        }
    }
    
    
    private func getCurrentLocationAndShow(location: CLLocationCoordinate2D){
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.QuickShare", coordinate: location) { (location,error) -> Void in
            if error != nil &&  error == QuickRideErrors.NetworkConnectionNotAvailableError{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE, duration: 3)
                return
            }
            if location == nil || location!.shortAddress == nil{
                return
            }
            self.viewModel.currentLocation = location
            if let areaName = location?.areaName, !areaName.isEmpty{
                self.currentLocationLabel.text = location?.areaName
            }else{
                self.currentLocationLabel.text = location?.shortAddress
            }
            if self.viewModel.currentLocation != nil  && !self.viewModel.isQuickShareAvailabilityChecked{
                self.viewModel.isDataFetchingFromServer = true
                self.browseTableView.isScrollEnabled = false
                self.browseTableView.reloadData()
                self.viewModel.getAvailableCategoryList()
                self.viewModel.getAllRequiredData()
                self.viewModel.isQuickShareAvailabilityChecked = true
            }
            QuickShareCache.getInstance()?.storeUserLocation(location: location)
        }
    }
    
    //MARK: Notifications
    private func confirmNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(recentlyAddedItemListReceived), name: .recentlyAddedItemListReceived ,object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(recentlyRequestedListReceived), name: .recentlyRequestedListReceived ,object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .stopSpinner ,object: nil)
    }
    
    @objc func stopSpinner(_ notification: Notification){
        viewModel.isDataFetchingFromServer = false
        self.browseTableView.isScrollEnabled = true
        browseTableView.reloadData()
    }
    
    @objc func recentlyAddedItemListReceived(_ notification: Notification){
        viewModel.isDataFetchingFromServer = false
        self.browseTableView.isScrollEnabled = true
        browseTableView.reloadData()
    }
    
    @objc func recentlyRequestedListReceived(_ notification: Notification){
        browseTableView.reloadData()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        viewModel.isDataFetchingFromServer = false
        self.browseTableView.isScrollEnabled = true
        browseTableView.reloadData()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    //MARK: Actions
    @IBAction func chatBtnPressed(_ sender: UIButton) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.centralChatViewController)
        self.navigationController?.pushViewController(centralChatViewController, animated: false)
    }
    
    @IBAction func notificationBtnPressed(_ sender: UIButton) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }
    
    @IBAction func changeLocationTapped(_ sender: UIButton) {
        selectLocation()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let leftMenuViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
        leftMenuViewController.initialiseMenu(Menutype: MenuItem.BAZAARY_MENU)
        ViewControllerUtils.addSubView(viewControllerToDisplay: leftMenuViewController)
    }
    
    private func selectLocation(){
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: "", currentSelectedLocation: nil, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        self.navigationController?.pushViewController(changeLocationViewController, animated: false)
    }
}

//MARK:UITableViewDataSource
extension QuickShareHomePageViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.isDataFetchingFromServer {
            return 1
        }else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.covidCareHome {
            if section == 3{
                if viewModel.availableProducts.count > 5{
                    return 5
                }else{
                    return viewModel.availableProducts.count
                }
            }else{
                return 1
            }
        }else{
            switch section {
            case 0:
                return 1
            case 1:
                if QuickShareCache.getInstance()?.categories.count ?? 0 > 0{
                    return 1
                }else{
                    return 0
                }
            case 2:
                if !viewModel.availableProducts.isEmpty{
                    return 1
                }else{
                    return 0
                }
            case 3:
                if viewModel.availableRequests.count > 2{
                    return 2
                }else{
                    return viewModel.availableRequests.count
                }
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.covidCareHome {
            switch indexPath.section {
            case 0:
                if viewModel.isDataFetchingFromServer {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenLoadingAnimationTableViewCell", for: indexPath) as! HomeScreenLoadingAnimationTableViewCell
                    cell.setupUI()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CovidCareHomeImageTableViewCell", for: indexPath) as! CovidCareHomeImageTableViewCell
                    cell.initializeCarouselView()
                    return cell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CovidCategoryTableViewCell", for: indexPath) as! CovidCategoryTableViewCell
                cell.initialiseCovidCategories(isFrom: CategoriesViewModel.BUY_PRODUCT)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostAndRequestTableViewCell", for: indexPath) as! PostAndRequestTableViewCell
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CovidItemTableViewCell", for: indexPath) as! CovidItemTableViewCell
                if indexPath.row >= viewModel.availableProducts.count{
                    return UITableViewCell()
                }
                cell.initiliseProduct(availableProduct: viewModel.availableProducts[indexPath.row])
                return cell
            default:
                return UITableViewCell()
            }
        }else{
            switch indexPath.section {
            case 0:
                if viewModel.isDataFetchingFromServer {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenLoadingAnimationTableViewCell", for: indexPath) as! HomeScreenLoadingAnimationTableViewCell
                    cell.setupUI()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCarouselImageTableViewCell", for: indexPath) as! HomeCarouselImageTableViewCell
                    cell.initializeCarouselView()
                    return cell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as! CategoriesTableViewCell
                cell.initialiseCategories()
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecentlyAddedTableViewCell", for: indexPath) as! RecentlyAddedTableViewCell
                if indexPath.row >= viewModel.availableProducts.count{
                    return UITableViewCell()
                }
                cell.initialiseAddedProducts(availabelProducts: viewModel.availableProducts)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecentRequestTableViewCell", for: indexPath) as! RecentRequestTableViewCell
                if indexPath.row >= viewModel.availableRequests.count{
                    return UITableViewCell()
                }
                cell.initialiseRequestedProduct(availableRequest: viewModel.availableRequests[indexPath.row])
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
}

//MARK:Outlets
extension QuickShareHomePageViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == browseTableView && section == 3 && !viewModel.availableRequests.isEmpty{
            return 60
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        if tableView == browseTableView && section == 3 && ((viewModel.covidCareHome && !viewModel.availableProducts.isEmpty) || !viewModel.availableRequests.isEmpty){
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
            headerView.backgroundColor = UIColor.white
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 200, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            if viewModel.covidCareHome {
                titleLabel.text = "Recent Products".uppercased()
                headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAllProductsTapped(_:))))
            }else{
                titleLabel.text = Strings.recent_requests.uppercased()
                headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAllRequestTapped(_:))))
            }
            let subTitleLabel = UILabel(frame: CGRect(x: self.view.frame.width - 70, y: 15, width: 80, height: 35))
            subTitleLabel.textColor = UIColor(netHex: 0x007aff)
            subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
            subTitleLabel.text = Strings.view_all
            
            subTitleLabel.isUserInteractionEnabled = true
            headerView.addSubview(titleLabel)
            headerView.addSubview(subTitleLabel)
            return headerView
        }
        return nil
    }
    
    @objc func viewAllRequestTapped(_ gestureRecognizer: UITapGestureRecognizer){
        let allRequestsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AllRequestsViewController") as! AllRequestsViewController
        allRequestsViewController.initialiseAllRequests(availableRequests: viewModel.availableRequests)
        self.navigationController?.pushViewController(allRequestsViewController, animated: true)
    }
    @objc func viewAllProductsTapped(_ gestureRecognizer: UITapGestureRecognizer){
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.initialiseProductsListing(categoryCode: nil,title: Strings.recentlyAddedProducts, availableProducts: viewModel.availableProducts)
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if QuickShareCache.getInstance()?.categories.count ?? 0 > 0{
                return 10
            }else{
                return 0
            }
        case 2:
            if !viewModel.availableProducts.isEmpty{
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3{
            if viewModel.covidCareHome {
                let productViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
                productViewController.initialiseView(product: viewModel.availableProducts[indexPath.row], isFromOrder: false)
                self.navigationController?.pushViewController(productViewController, animated: true)
            }else{
                let requirementRequestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequirementRequestDetailsViewController") as! RequirementRequestDetailsViewController
                requirementRequestDetailsViewController.initialiseRequiremnet(availableRequest: viewModel.availableRequests[indexPath.row])
                self.navigationController?.pushViewController(requirementRequestDetailsViewController, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
//MARK: Get LocationUpdate
extension QuickShareHomePageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        AppDelegate.getAppDelegate().log.debug("")
        getCurrentLocationAndShow(location: locations.last?.coordinate ?? locValue)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .denied{
            selectLocation()
        }else if status == .authorizedAlways || status == .authorizedWhenInUse{
            getLocation()
        }
    }
}
//ReceiveLocationDelegate
extension QuickShareHomePageViewController: ReceiveLocationDelegate{
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        viewModel.currentLocation = location
        if let areaName = location.areaName,!areaName.isEmpty{
          currentLocationLabel.text = location.areaName
        }else{
            currentLocationLabel.text = location.shortAddress
        }
        locationManager.stopUpdatingLocation()
        QuickShareCache.getInstance()?.storeUserLocation(location: location)
        viewModel.availableProducts.removeAll()
        viewModel.availableRequests.removeAll()
        viewModel.getAvailableCategoryList()
        viewModel.getAllRequiredData()
    }
    func locationSelectionCancelled(requestLocationType: String) {}
}

