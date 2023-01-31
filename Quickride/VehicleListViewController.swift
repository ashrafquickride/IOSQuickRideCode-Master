//
//  vehicleListViewController.swift
//  Quickride
//
//  Created by KNM Rao on 20/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.

import UIKit

class VehicleListViewController : UIViewController,UITableViewDelegate,UITableViewDataSource, VehicleDetailsUpdateListener, VehicleUpdateDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var vehicleTableView: UITableView!
    
    var userVehicles = [Vehicle]()
    var vehicleInsurances = [VehicleInsurance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userVehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil
        {
            clientConfiguration = ClientConfigurtion()
        }
        self.vehicleInsurances = clientConfiguration!.vehicleInsuranceList
        self.vehicleTableView.delegate = self
        self.vehicleTableView.dataSource = self
    }
    
    func VehicleDetailsUpdated() {
        self.userVehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        self.vehicleTableView.delegate = self
        self.vehicleTableView.dataSource = self
        self.vehicleTableView.reloadData()
    }
    
    func userVehicleInfoChanged(){
        self.userVehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        self.vehicleTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.userVehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        self.vehicleTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        AppDelegate.getAppDelegate().log.debug("")
        if !vehicleInsurances.isEmpty{
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0{
            return userVehicles.count
        }else{
            if section == 2{
                let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData
                if profileVerificationData != nil && (profileVerificationData!.persVerifSource == nil || !profileVerificationData!.persVerifSource!.contains("DL")){
                    return 1
                }
                return 0
            }
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
            return 150
        }
        else if indexPath.section == 1
        {
            if userVehicles.isEmpty{
                return 220
            }
            else{
                return 60
            }
        }
        else if indexPath.section == 2{
            let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData
            if profileVerificationData != nil && (profileVerificationData!.persVerifSource == nil || !profileVerificationData!.persVerifSource!.contains(PersonalIdDetail.DL)){
                return 120
            }
            return 0
        }else{
            return 200
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if  indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! VehicleTableViewCell
            if self.userVehicles.endIndex <= indexPath.row{
                return cell
            }
            let vehicle  = self.userVehicles[indexPath.row]
            cell.initializeViews(vehicle: vehicle, isRiderProfile: false, isFromProfile : false, userVehiclesCount: self.userVehicles.count, viewController: self, listener: self)
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Add Vehicle Cell", for: indexPath as IndexPath) as! AddVehicleTableViewCell
            cell.initializeViews(isEmptyVehicle: userVehicles.count == 0)
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DrivingLicenseTableViewCell", for: indexPath as IndexPath) as! DrivingLicenseTableViewCell
            cell.initializeViews()
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Insurance Offer Cell", for: indexPath as IndexPath) as! VehicleInsuranceTableViewCell
            if self.vehicleInsurances.endIndex <= indexPath.row{
                return cell
            }
            cell.insuranceOfferTitle.isHidden = false
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  indexPath.section == 0
        {
            let vehicle = self.userVehicles[indexPath.row]
            let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VehicleSavingViewController") as! VehicleSavingViewController
            vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: vehicle, listener: self)
            self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
        }
        else if indexPath.section == 1
        {
            self.addVehicle()
        }
        else if indexPath.section == 2{
            self.navigateToDlVerificationView()
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.width - 25) / 3, height: (collectionView.bounds.width - 25) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vehicleInsurances.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! VehicleInsuranceCollectionViewCell
        if vehicleInsurances.endIndex <= indexPath.row{
            return cell
        }
        let insurance = vehicleInsurances[indexPath.row]
        cell.initializeView(vehicleInsurance: insurance)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if vehicleInsurances.endIndex <= indexPath.row{
            return
        }
        let insurance = vehicleInsurances[indexPath.row]
        moveToWebViewBasedOnInsuranceUrl(insurance: insurance)
    }
    
    private func moveToWebViewBasedOnInsuranceUrl(insurance: VehicleInsurance){
        guard let linkUrl = insurance.link else {
            return
        }
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string : linkUrl)
         var existingQueryItems = urlcomps?.queryItems ?? []
        if !existingQueryItems.isEmpty {
            existingQueryItems.append(queryItems)
        }else {
            existingQueryItems = [queryItems]
        }
        urlcomps?.queryItems = existingQueryItems
        if urlcomps != nil && urlcomps!.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.offers, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }
        
    }
    
    func addVehicle()
    {
        let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
        vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: nil, listener: self)
        self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
    }
    
    func navigateToDlVerificationView(){
        let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.initialiseData(isFromProfile: true, verificationType: PersonalIdDetail.DL) { [weak self] in
            self?.vehicleTableView.reloadData()
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: personalIdVerificationViewController, animated: false)
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
}
extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let cells = self.visibleCells
        var delayCounter = 0.0
        var delayCounter1 = 1.0
        for cell in cells {
            let vehicleCell = cell as? VehicleTableViewCell
            if vehicleCell != nil{
                vehicleCell!.contentView.layer.opacity = 0
                vehicleCell!.transform = CGAffineTransform(translationX: 0, y: 0)
                UIView.animate(withDuration: 1, delay: (0.5 * delayCounter), options: .curveLinear, animations: {
                    vehicleCell!.contentView.layer.opacity = 1
                    vehicleCell!.transform = CGAffineTransform(translationX: 531, y: 0)
                    vehicleCell!.vehicleImage.center.x = -80
                    UIView.animate(withDuration: 1, delay: 1 * delayCounter1, options: .curveLinear, animations: {
                        vehicleCell!.vehicleImage.center.x = 85
                        vehicleCell!.vehicleImage.layoutIfNeeded()
                    }, completion: nil)
                }, completion: nil)
                delayCounter += 1.5
                delayCounter1 += 0.5
            }
        }
    }
    
    
}
