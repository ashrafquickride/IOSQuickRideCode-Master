//
//  AddFavoriteLocationViewController.swift
//  Quickride
//
//  Created by QuickRide on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import ObjectMapper


class AddFavoriteLocationViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate ,ReceiveLocationDelegate,UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var iboFavLocName: UITextField!
    @IBOutlet weak var locationDetailsView: UIView!
    @IBOutlet weak var iboAddress: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var favouriteNameTableView: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var zoomPointInfoView: UIView!
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var favouriteImageView: UIImageView!
    @IBOutlet weak var confirm: UIButton!
    
    weak var iboMapView: GMSMapView!
    var favoriteLocation:UserFavouriteLocation = UserFavouriteLocation()
    var locationManager = CLLocationManager()
    var locationFromMap = true
    var oldLocation : UserFavouriteLocation?
    var searchData : [String] = []
    var filteredData : [String] = []
    var isSearch : Bool!
    
    func initializeDataBeforePresenting(favLocation: UserFavouriteLocation){
        AppDelegate.getAppDelegate().log.debug("")
        oldLocation = favLocation
        self.favoriteLocation.latitude = favLocation.latitude
        self.favoriteLocation.longitude = favLocation.longitude
        self.favoriteLocation.address = favLocation.address
        self.favoriteLocation.name = favLocation.name
        self.favoriteLocation.locationId = favLocation.locationId
        self.favoriteLocation.city = favLocation.city
        self.favoriteLocation.areaName = favLocation.areaName
        self.favoriteLocation.streetName = favLocation.streetName
        self.favoriteLocation.state = favLocation.state
        self.favoriteLocation.country = favLocation.country
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        getLocation()
        iboFavLocName.delegate = self
        if let address = favoriteLocation.address{
            iboAddress.text = address
        }else{
            iboAddress.text = Strings.select_location
            iboAddress.textColor = Colors.link
        }
        iboFavLocName.text = favoriteLocation.name
        if let locationName = favoriteLocation.name, !locationName.isEmpty {
            favouriteImageView.isHidden = true
        } else {
            favouriteImageView.isHidden = false
        }
        isSearch = false
        searchData = ["Home","Office"]
        favouriteNameTableView.isHidden = true
        favouriteNameTableView.delegate = self
        favouriteNameTableView.dataSource = self
        favouriteNameTableView.reloadData()
        backGroundView.isHidden = true
        handleViewCustomization()
    }
    
    private func getLocation(){
        locationManager.delegate = self
        if let location = locationManager.location{
            showLocationOnMap(location)
        }else if let latlng = SharedPreferenceHelper.getLastLocation(){
            showLocationOnMap(CLLocation(latitude: latlng.latitude, longitude: latlng.longitude))
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            iboMapView.isMyLocationEnabled = true
            locationManager.requestLocation()
        }else{
            LocationClientUtils.checkLocationAutorizationStatus(status: status) { [self] (isConfirmed) in
                if isConfirmed{
                    locationManager.requestAlwaysAuthorization()
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if favoriteLocation.latitude != nil && favoriteLocation.longitude != nil{
            iboMapView.animate(toLocation: CLLocationCoordinate2D(latitude: favoriteLocation.latitude!, longitude: favoriteLocation.longitude!))
            iboMapView.animate(toZoom: 18.0)
            locationFromMap = false
            saveButton.isHidden = false
            confirm.isHidden = true
            zoomPointInfoView.isHidden = true
        }
        self.backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddFavoriteLocationViewController.backGroundTapped(_:))))
    }
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    private func handleViewCustomization() {
        ViewCustomizationUtils.addCornerRadiusToView(view: locationDetailsView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: locationDetailsView, borderWidth: 1.0, color: UIColor(netHex: 0xcecece))
        ViewCustomizationUtils.addCornerRadiusToView(view: iboFavLocName, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: iboFavLocName, borderWidth: 1.0, color: UIColor(netHex: 0xcecece))
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        AppDelegate.getAppDelegate().log.debug("mapView()")
        hideDoneBtnBasedOnZoomLevelOfMap(mapView: mapView)
    }
    
    private func hideDoneBtnBasedOnZoomLevelOfMap(mapView : GMSMapView){
        if mapView.camera.zoom >= 18{
            confirm.isHidden = false
            saveButton.isHidden = true
            zoomPointInfoView.isHidden = true
        }
        else{
            confirm.isHidden = true
            saveButton.isHidden = true
            zoomPointInfoView.isHidden = false
        }
    }
    
    @IBAction func confirmedMarkerPostionTapped(_ sender: Any) {
        favoriteLocation.latitude = iboMapView.camera.target.latitude
        favoriteLocation.longitude = iboMapView.camera.target.longitude
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.FavLocCreationView", coordinate: iboMapView.camera.target, handler: { (location, error) in
            if location != nil{
                self.favoriteLocation.address  = location!.completeAddress
                self.iboAddress.textColor = .black
                self.favoriteLocation.city = location!.city
                self.favoriteLocation.state = location!.state
                self.favoriteLocation.areaName = location!.areaName
                self.favoriteLocation.streetName = location!.streetName
                self.favoriteLocation.country = location!.country
                self.iboAddress.text = location!.completeAddress
                self.saveButton.isHidden = false
                self.confirm.isHidden = true
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
            }
        })
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            currentLocationButton.isHidden = false
        }else{
            currentLocationButton.isHidden = true
        }
    }
    
    @IBAction func saveFavouriteLocation(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("saveFavoriteLocation()")
        
        if !checkIfFavLocationChanged(){
            self.navigationController?.popViewController(animated: false)
            return
        }
        saveFavLocation()
    }
    func saveFavLocation(){
        iboFavLocName.endEditing(false)
        favoriteLocation.name = iboFavLocName.text
        favoriteLocation.phoneNumber = Double((QRSessionManager.getInstance()?.getUserId())!)
        if favoriteLocation.address == nil{
            UIApplication.shared.keyWindow?.makeToast( "favLocation address can't be empty")
            return
        }
        if favoriteLocation.name == nil || favoriteLocation.name!.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.alias_empty)
            return
        }
        if UserFavouriteLocation.HOME_FAVOURITE.caseInsensitiveCompare(favoriteLocation.name!) == ComparisonResult.orderedSame {
            let officeLocation = UserDataCache.getInstance()?.getOfficeLocation()
            if officeLocation != nil{
                LocationClientUtils.checkHomeAndOfficeLocationsSameAndConvey(officeLocation: Location(favouriteLocation: officeLocation!), homeLocation: Location(favouriteLocation: favoriteLocation))
            }
            
        }
        if UserFavouriteLocation.OFFICE_FAVOURITE.caseInsensitiveCompare(favoriteLocation.name!) == ComparisonResult.orderedSame {
            let homeLocation = UserDataCache.getInstance()?.getHomeLocation()
            if homeLocation != nil{
                LocationClientUtils.checkHomeAndOfficeLocationsSameAndConvey(officeLocation: Location(favouriteLocation: favoriteLocation), homeLocation: Location(favouriteLocation: homeLocation!))
            }
        }
        if favoriteLocation.locationId != nil && favoriteLocation.locationId != 0 {
            
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updateFavouriteLocation(favouriteLocation: favoriteLocation, viewController: self, handler: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                    let location = Mapper<UserFavouriteLocation>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as UserFavouriteLocation
                    
                    UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: self.oldLocation!)
                    
                    UserDataCache.getInstance()?.saveFavoriteLocations (favoriteLocations: location)
                    self.navigationController?.popViewController(animated: false)
                }
                else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
        else{
            if checkForDuplicateLocationName() == true{
                return
            }
            if checkFavoriteLocationDuplication() == true{
                return
            }
            
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.createUserFavouriteLocation(userFavouriteLocation: favoriteLocation, viewController: self) { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let location = Mapper<UserFavouriteLocation>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as UserFavouriteLocation
                    UserDataCache.getInstance()?.saveFavoriteLocations(favoriteLocations: location)
                    self.navigationController?.popViewController(animated: false)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
    }
    func checkFavoriteLocationDuplication()->Bool{
        AppDelegate.getAppDelegate().log.debug("checkFavoriteLocationDuplication()")
        iboFavLocName.endEditing(false)
        let favouriteLocations = UserDataCache.getInstance()?.getFavoriteLocations()
        if favouriteLocations == nil || favouriteLocations?.isEmpty == true{
            return false
        }
        for location in favouriteLocations!{
            
            if location.address!.caseInsensitiveCompare(favoriteLocation.address!) == ComparisonResult.orderedSame {
                if location.name!.caseInsensitiveCompare(favoriteLocation.name!) != ComparisonResult.orderedSame {
                    UIApplication.shared.keyWindow?.makeToast( Strings.duplicate_favourite_location)
                    return true
                }
                else {
                    UIApplication.shared.keyWindow?.makeToast( Strings.duplicate_favourite_location_name)
                    return true
                }
            }
        }
        return false
    }
    func checkForDuplicateLocationName()-> Bool
    {
        AppDelegate.getAppDelegate().log.debug("")
        iboFavLocName.endEditing(false)
        let favouriteLocations = UserDataCache.getInstance()?.getFavoriteLocations()
        if favouriteLocations == nil || favouriteLocations?.isEmpty == true{
            return false
        }
        for location in favouriteLocations!{
            
            if location.address!.caseInsensitiveCompare(favoriteLocation.address!) != ComparisonResult.orderedSame {
                if location.name!.caseInsensitiveCompare(favoriteLocation.name!) == ComparisonResult.orderedSame {
                    UIApplication.shared.keyWindow?.makeToast( Strings.duplicate_favourite_location_name)
                    return true
                }
            }
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        self.favouriteNameTableView.isHidden = true
        self.backGroundView.isHidden = true
        return false
    }
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        self.favoriteLocation.latitude = location.latitude
        self.favoriteLocation.longitude = location.longitude
        self.favoriteLocation.address = location.completeAddress
        self.iboAddress.text = location.completeAddress
        iboAddress.textColor = .black
        self.locationFromMap = false
        self.confirm.isHidden = true
        saveButton.isHidden = false
        iboMapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        self.favoriteLocation.city = location.city
        self.favoriteLocation.areaName = location.areaName
        self.favoriteLocation.streetName = location.streetName
        self.favoriteLocation.state = location.state
        self.favoriteLocation.country = location.country
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("locationManager()")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            getLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.debug(error)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        AppDelegate.getAppDelegate().log.debug("locationManager()")
        locationManager.stopUpdatingLocation()
        showLocationOnMap(locations.last)
    }
    func showLocationOnMap(_ location : CLLocation?){
        guard let location = location else { return }
        let locValue = location.coordinate
        iboMapView.animate(to: GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 18))
        locationFromMap = true
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: location)
        if favoriteLocation.latitude != nil && favoriteLocation.longitude != nil && location.distance(from: CLLocation(latitude: favoriteLocation.latitude!, longitude: favoriteLocation.longitude!)) < 20{
            return
        }
    }
    
    @IBAction func selectLocationAction(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("selectLocationAction()")
        favouriteNameTableView.isHidden = true
        backGroundView.isHidden = true
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let changeLocationVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController")as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.ORIGIN, currentSelectedLocation: Location(favouriteLocation: favoriteLocation),hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    
    @IBAction func moveToCurrentLocationAction(_ sender: Any) {
        getLocation()
    }
    @IBAction func currentLocationAction(_ sender: Any) {
        getLocation()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if checkIfFavLocationChanged()
        {
            displayConfirmationDialogueForSavingData()
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    func checkIfFavLocationChanged()-> Bool{
        if oldLocation == nil || oldLocation!.name != iboFavLocName.text || oldLocation!.address != iboAddress.text{
            return true
        }
        return false
    }
    func displayConfirmationDialogueForSavingData(){
        AppDelegate.getAppDelegate().log.debug("")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes , message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.save_caps == result{
                self.saveFavLocation()
            }
            else{
                self.navigationController?.popViewController(animated: false)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func locationSelectionCancelled(requestLocationType: String) {
        
    }
    deinit {
        locationManager.delegate = nil
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        var threshold : Int?
        if textField == iboFavLocName{
            threshold = 100
        }else{
            return true
        }
        if string != ""{
            backGroundView.isHidden = false
            self.getSearchDataContains(textField.text! + string)
        }
        else{
            isSearch = false
            backGroundView.isHidden = true
            favouriteNameTableView.isHidden = true
        }
        if range.location == 0 && textField.text?.isEmpty == false {
            favouriteImageView.isHidden = false
        } else if !string.isEmpty {
            favouriteImageView.isHidden = true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        favouriteImageView.isHidden = false
        return true
    }
    
    func getSearchDataContains(_ text : String) {
        let predicate : NSPredicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", text)
        filteredData = (searchData as NSArray).filtered(using: predicate) as! [String]
        isSearch = true
        favouriteNameTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if isSearch! {
            return filteredData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = favouriteNameTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! FavouriteNameCell
        
        if isSearch! {
            if filteredData.endIndex <= indexPath.row{
                return cell
            }
            favouriteNameTableView.isHidden = false
            cell.favNameLabel.text = filteredData[indexPath.row]
        }
        else{
            favouriteNameTableView.isHidden = true
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.iboFavLocName.text = filteredData[indexPath.row]
        favouriteNameTableView.isHidden = true
        backGroundView.isHidden = true
        tableView.deselectRow(at: indexPath, animated: false)
    }
    @objc func backGroundTapped(_ gesture : UITapGestureRecognizer){
        backGroundView.isHidden = true
        favouriteNameTableView.isHidden = true
    }
}
