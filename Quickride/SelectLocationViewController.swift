//
//  SelectLocationViewController.swift
//  Quickride
//
//  Created by Ashutos on 20/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper

class SelectLocationViewController: UIViewController {
    //MARK: OUTLETS
    @IBOutlet weak var findRideView: UIView!
    @IBOutlet weak var offerRideView: UIView!
    @IBOutlet weak var findRideLabel: UILabel!
    @IBOutlet weak var offerRideLabel: UILabel!
    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var AddHomeOfficeCollectionView: UICollectionView!
    @IBOutlet weak var locationListTableView: UITableView!
    @IBOutlet weak var loadMoreView: UIView!
    @IBOutlet weak var lodeMorebutton: UIButton!
    @IBOutlet weak var addHomeOfficeLocationViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var markInMapView: UIView!
    @IBOutlet weak var markInMapButtomConstraintConstant: NSLayoutConstraint!

    private var routeSelectionDelegate : RouteSelectionDelegate?
    private var locationManager:CLLocationManager = CLLocationManager()
    private var selectLocationVM: SelectLocationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        selectLocationVM?.getPreferedLocation()
        selectLocationVM?.getFavoriteLocation()
        selectLocationVM?.getRecentlocation()
        validateFavoriteViewShow()
        locationListTableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    func initialiseData(ride: Ride?) {
        selectLocationVM = SelectLocationViewModel(ride: ride)
    }

    private func setUpUI() {
        addObservers()
        markInMapView.addShadow()
        startLocationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        destinationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        destinationTextField.becomeFirstResponder()
        locationListTableView.register(UINib(nibName: "LocationShowingTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationShowingTableViewCell")
        locationListTableView.register(UINib(nibName: "AddFavoriteoptionTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFavoriteoptionTableViewCell")
        startLocationTextField.text = selectLocationVM?.ride?.startAddress
        changeUIAccodingToRideSelection()
        loadMoreView.isHidden = true
    }

    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func validateFavoriteViewShow(){
        if selectLocationVM?.favouriteLocations.count == 0{
            addHomeOfficeLocationViewHeightConstraints.constant = 45
            AddHomeOfficeCollectionView.isHidden = false
            AddHomeOfficeCollectionView.reloadData()
        } else {
            AddHomeOfficeCollectionView.isHidden = true
            addHomeOfficeLocationViewHeightConstraints.constant = 0
        }
    }

    private func changeUIAccodingToRideSelection() {
        if self.selectLocationVM?.ride?.rideType == Ride.PASSENGER_RIDE {
            findRideView.backgroundColor = UIColor(netHex: 0x555b67)
            findRideLabel.textColor = .white
            offerRideView.backgroundColor = .clear
            offerRideLabel.textColor = UIColor(netHex: 0x606060)
        } else {
            offerRideView.backgroundColor = UIColor(netHex: 0x555b67)
            offerRideLabel.textColor = .white
            findRideView.backgroundColor = .clear
            findRideLabel.textColor = UIColor(netHex: 0x606060)
        }
    }

    private func doSearchOnServer(searchtext: String) {
        if searchtext.count >= 4 {
            readAutoCompletePlacesFromQuickRide(queryString: searchtext)
        }
    }

    private func readAutoCompletePlacesFromQuickRide(queryString : String) {
        let coordinate = getRecentLocationCoordinate()
        RoutePathServiceClient.getAutoCompletePlaces(useCase: "iOS.App.PlacesSearch.LocationSelectionView", forSearchString: queryString, regionLat: coordinate.latitude, regionLong: coordinate.longitude,readFromGoogle : selectLocationVM?.readFromGoogle ?? false) { (responseObject, error) in
            AppDelegate.getAppDelegate().log.error("getAutoCompletePlaces failed \(responseObject), \(error)")
            self.view.endEditing(true)
            if responseObject != nil && responseObject!["result"] as? String  == "SUCCESS"{
                if let results = Mapper<Location>().mapArray(JSONObject: responseObject!["resultData"]){
                    self.selectLocationVM?.predictedPlaces = results
                    var isOfflineData = false
                    for place in self.selectLocationVM!.predictedPlaces {
                        UserCoreDataHelper.saveOrUpdateRecentSearchedLocation(location: place)
                        if place.offline && !isOfflineData{
                            isOfflineData = true
                        }
                    }
                    if isOfflineData{
                        self.loadMoreView.isHidden = false
                    }else{
                        self.loadMoreView.isHidden = true
                    }
                }
                self.locationListTableView.reloadData()
            } else {
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]) {
                    if let userMessage =  responseError.userMessage{
                        UIApplication.shared.keyWindow?.makeToast(message : userMessage)
                    }
                } else if error != nil && error!.code == QuickRideErrors.NetworkConnectionNotAvailable {
                    UIApplication.shared.keyWindow?.makeToast(message : Strings.NetworkConnectionNotAvailable_Msg)
                } else {
                    UIApplication.shared.keyWindow?.makeToast(message : "Somer internal error ,Please try again")
                }
            }
        }
    }

    private func getRecentLocationCoordinate() -> CLLocationCoordinate2D{
        if let currentLocation = LocationCache.getCacheInstance().getRecentLocationOfUser(){
            return currentLocation.coordinate
        }else{
            return BaseRouteViewController.defaultIndiaLatLngWhenLocationNotFound
        }
    }

    //MARK: Action
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func getCurrentLocationPressed(_ sender: UIButton) {
    }
    @IBAction func findRidePressed(_ sender: UIButton) {
        self.selectLocationVM?.ride?.rideType = Ride.PASSENGER_RIDE
        changeUIAccodingToRideSelection()
    }
    @IBAction func offerRidePressed(_ sender: UIButton) {
        self.selectLocationVM?.ride?.rideType = Ride.RIDER_RIDE
        changeUIAccodingToRideSelection()
    }

    @IBAction func loadMoreButtonPressed(_ sender: UIButton) {
        loadMoreView.isHidden = true
        selectLocationVM?.readFromGoogle = true
        doSearchOnServer(searchtext: selectLocationVM?.currentSearchText ?? "")
    }

    @IBAction func viewonMapBtnPressed(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("selectLocationOnMapAction()")
        var locationtype = ""
        if selectLocationVM?.textFieldTag == 0 {
            locationtype = ChangeLocationViewController.ORIGIN
        }else{
            locationtype = ChangeLocationViewController.DESTINATION
        }
        moveToLocationSelectionOnMap(selectedLocation: selectLocationVM?.locationSelected ?? Location(), LocationType: locationtype)
    }

    private func moveToRideCreationScreen() {
        let vc = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreationViewController") as! RideCreationViewController
        vc.initialiseView(ride: selectLocationVM?.ride, selectedPreferedRoute: selectLocationVM?.selectedPreferedRoute)
        self.navigationController?.pushViewController(vc, animated: false)
    }

    @objc private func keyBoardWillShow(notification : NSNotification) {
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if (!(selectLocationVM?.isKeyboardVisible ?? false)) {
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                markInMapButtomConstraintConstant.constant = keyBoardSize.height
            }
        }
        selectLocationVM?.isKeyboardVisible = true
    }

    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if (selectLocationVM?.isKeyboardVisible ?? false) {
            markInMapButtomConstraintConstant.constant = 0
        }
        selectLocationVM?.isKeyboardVisible = false
    }

    //MARK: DeIntializer
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: CollectionViewDataSource
extension SelectLocationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectLocationVM?.favouriteLocations.count == 0 {
            return 3
        }else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AddHomeOfficeCollectionView.dequeueReusableCell(withReuseIdentifier: "AddHomeOrOfcCollectionViewCell", for: indexPath) as! AddHomeOrOfcCollectionViewCell
        cell.updateUI(indexPath: indexPath.row)
        return cell
    }
}
extension SelectLocationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var locationType = ""
        if indexPath.row == 0{
            locationType = UserFavouriteLocation.HOME_FAVOURITE
        }else if indexPath.row == 1{
            locationType = UserFavouriteLocation.OFFICE_FAVOURITE
        }
        addFavoritelocation(selectedLocation: selectLocationVM?.locationSelected ?? Location(), LocationType: locationType)
    }
}

extension SelectLocationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (AddHomeOfficeCollectionView.frame.size.width-15)/3, height: AddHomeOfficeCollectionView.frame.size.height)
    }
}

//MARK: TableviewDastaSource
extension SelectLocationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if selectLocationVM?.favouriteLocations.count == 0{
                return 0
            }
            return (selectLocationVM?.favouriteLocations.count ?? 0) + 1
        }else if section == 1 {
            return selectLocationVM?.customizedRoutes.count ?? 0
        } else if section == 2 {
            return selectLocationVM?.recentLocations.count ?? 0
        } else{
            return selectLocationVM?.predictedPlaces.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationCell =  locationListTableView.dequeueReusableCell(withIdentifier: "LocationShowingTableViewCell", for: indexPath) as! LocationShowingTableViewCell
        let AddFavoriteCell = locationListTableView.dequeueReusableCell(withIdentifier: "AddFavoriteoptionTableViewCell", for: indexPath) as! AddFavoriteoptionTableViewCell
        if indexPath.section == 0 {
            if indexPath.row == selectLocationVM?.favouriteLocations.count {
                AddFavoriteCell.updateUI()
                return AddFavoriteCell
            } else {
                locationCell.updateUI(location: selectLocationVM!.favouriteLocations[indexPath.row], section: indexPath.section)
            }
        }else if indexPath.section == 1 {
            locationCell.updateUIForCustomPath(location: selectLocationVM!.customizedRoutes[indexPath.row])
        } else if indexPath.section == 2 {
            locationCell.updateUI(location: selectLocationVM!.recentLocations[indexPath.row], section: indexPath.section)
        } else{
            locationCell.updateUI(location: selectLocationVM!.predictedPlaces[indexPath.row], section: indexPath.section)
        }
        locationCell.optionButton.addTarget(self, action: #selector(optionBtntapped(_:)), for: .touchUpInside)
        return locationCell
    }

    @objc private func optionBtntapped(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.locationListTableView)
        guard let indexPath = locationListTableView.indexPathForRow(at: buttonPosition) else { return }
        switch indexPath.section {
        case 0:
            guard let favourites = UserDataCache.getInstance()?.getFavoriteLocations() else { return }
            let selectedLocation = favourites[indexPath.row]
            displayHomeAndOfficePopUpMenu(favouriteLocation: selectedLocation, locationType: selectLocationVM?.favouriteLocations[indexPath.row].locationType ?? "", locationName: selectLocationVM?.favouriteLocations[indexPath.row].address, index: indexPath.row)
        case 1:
            let preferredRoute = selectLocationVM!.customizedRoutes[indexPath.row]
            displayPopUpMenuForPrefferedroute(preferredRoute: preferredRoute, index: indexPath.row)

        default:
            var selectedLocation = Location()
            if indexPath.section == 2 {
                selectedLocation = selectLocationVM!.recentLocations[indexPath.row]
            }else{
                selectedLocation = selectLocationVM!.predictedPlaces[indexPath.row]
            }
            addFavoritelocation(selectedLocation: selectedLocation, LocationType: "")
        }
    }

    private func addFavoritelocation(selectedLocation: Location,LocationType: String) {
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.add_favourite_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddFavoriteLocationViewController") as! AddFavoriteLocationViewController
        addFavoriteLocationViewController.favoriteLocation.name = LocationType
        addFavoriteLocationViewController.favoriteLocation.latitude = selectedLocation.latitude
        addFavoriteLocationViewController.favoriteLocation.longitude = selectedLocation.longitude
        addFavoriteLocationViewController.favoriteLocation.address = selectedLocation.completeAddress
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }

}

//MARK: TableViewDelegate
extension SelectLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        switch indexPath.section {
        case 0:
            if indexPath.row == selectLocationVM?.favouriteLocations.count {
                //TODO: Add New Fav cell pressed
                var locationType = ""
                if UserDataCache.sharedInstance?.getHomeLocation() == nil {
                    locationType = UserFavouriteLocation.HOME_FAVOURITE
                }else if UserDataCache.sharedInstance?.getOfficeLocation() == nil {
                    locationType = UserFavouriteLocation.OFFICE_FAVOURITE
                } else if UserDataCache.sharedInstance?.getHomeLocation() != nil && UserDataCache.sharedInstance?.getHomeLocation() != nil {
                    locationType = ""
                }
                addFavoritelocation(selectedLocation: selectLocationVM?.locationSelected ?? Location(),LocationType: locationType)

            } else {
                getSetLocation(location: selectLocationVM!.favouriteLocations[indexPath.row])
            }
        case 1:
            getSetLocationForCustomisedRoute(preferredRoute: selectLocationVM!.customizedRoutes[indexPath.row])
        case 2:
            getSetLocation(location: selectLocationVM!.recentLocations[indexPath.row])
        default:
            getSetLocation(location: selectLocationVM!.predictedPlaces[indexPath.row])
        }
    }

    private func getSetLocation(location: Location) {

        if location.latitude != 0 && location.longitude != 0 {
            let userDataCache : UserDataCache? = UserDataCache.getInstance()
            let selectedLocation = location
            let recentLocation = UserRecentLocation(recentLocationId : "" , recentAddress : selectedLocation.completeAddress!,recentAddressName :  selectedLocation.shortAddress!, latitude : selectedLocation.latitude, longitude : selectedLocation.longitude, country: selectedLocation.country, state: selectedLocation.state, city: selectedLocation.city, areaName: selectedLocation.areaName, streetName: selectedLocation.streetName)
            if userDataCache != nil{
                userDataCache?.saveRecentLocations(recentLocation: recentLocation)

            }
            self.updateRideAsPerSelectedLocation(location: location)
        } else {
            if location.completeAddress == nil{
                UIApplication.shared.keyWindow?.makeToast(message : Strings.invalid_recent_location)
                let location = UserDataCache.getInstance()?.getRedundantRecentLocation(latitude: location.latitude,longitude: location.longitude)
                if location != nil && location?.location != nil && (location?.index)! >= 0{
                    UserDataCache.getInstance()?.removeRecentLocation(recentLocation: location!.location!, index: location!.index)
                }
                return
            }
            let selectedLocation = location
            LocationCache.getCacheInstance().getLocationInfoForAddress(useCase: "iOS.App.PlaceSelect.LocationSelectionView", address: location.completeAddress!, placeId: location.placeId) { (location, error) in

                if let locationFromCache = location {
                    selectedLocation.country = locationFromCache.country
                    selectedLocation.state = locationFromCache.state
                    selectedLocation.city = locationFromCache.city
                    selectedLocation.areaName = locationFromCache.areaName
                    selectedLocation.streetName = locationFromCache.streetName
                    selectedLocation.latitude = locationFromCache.latitude
                    selectedLocation.longitude = locationFromCache.longitude
                    UserCoreDataHelper.saveOrUpdateRecentSearchedLocation(location: selectedLocation)
                    self.updateRideAsPerSelectedLocation(location: locationFromCache)
                }else{
                    UIApplication.shared.keyWindow?.makeToast(message: Strings.invalid_selected_location)
                }
            }
        }
    }

    private func updateRideAsPerSelectedLocation(location: Location) {
        if self.selectLocationVM?.textFieldTag == 0 {
            self.startLocationTextField.text = location.completeAddress
            selectLocationVM?.ride?.startAddress = location.completeAddress!
            selectLocationVM?.ride?.startLatitude = location.latitude
            selectLocationVM?.ride?.startLongitude = location.longitude
        }else{
            self.destinationTextField.text = location.completeAddress
            selectLocationVM?.ride?.endAddress = location.completeAddress!
            selectLocationVM?.ride?.endLatitude = location.latitude
            selectLocationVM?.ride?.endLongitude = location.longitude
        }
        if selectLocationVM?.ride?.startAddress != "" && selectLocationVM?.ride?.endAddress != "" {
            guard let validation = selectLocationVM?.validLocationSelection(ride: selectLocationVM!.ride!, fromLocation: self.startLocationTextField.text!, toLocation: self.destinationTextField.text, VC: self) else { return }
            if !validation {
                moveToRideCreationScreen()
            }
        }
    }

    private func getSetLocationForCustomisedRoute(preferredRoute: UserPreferredRoute) {
        if preferredRoute.fromLocation != nil && preferredRoute.toLocation != nil {
            selectLocationVM?.ride?.startAddress = preferredRoute.fromLocation!
            selectLocationVM?.ride?.startLatitude = preferredRoute.fromLatitude!
            selectLocationVM?.ride?.startLongitude = preferredRoute.fromLongitude!
            selectLocationVM?.ride?.endAddress = preferredRoute.toLocation!
            selectLocationVM?.ride?.endLatitude = preferredRoute.toLatitude
            selectLocationVM?.ride?.endLongitude = preferredRoute.toLongitude
            startLocationTextField.text = preferredRoute.fromLocation!
            destinationTextField.text = preferredRoute.toLocation
            selectLocationVM?.selectedPreferedRoute = preferredRoute
            moveToRideCreationScreen()
        }
    }
}

//MARK: Text Field Value changed
extension SelectLocationViewController: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        selectLocationVM!.textFieldTag = textField.tag
        if textField.text?.count ?? 0 >= 4 {
            selectLocationVM?.currentSearchText = textField.text!
            doSearchOnServer(searchtext: selectLocationVM?.currentSearchText ?? "")
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == destinationTextField{
            selectLocationVM?.textFieldTag = 1
        } else {
            selectLocationVM?.textFieldTag = 0
        }
        UIApplication.shared.sendAction(#selector(selectAll(_:)), to: nil, from: nil, for: nil)
    }
}
//MARK: LocationUpdate
extension SelectLocationViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        //TODO: getLocation from selectfrom Map
        updateRideAsPerSelectedLocation(location: location)
    }

    func locationSelectionCancelled(requestLocationType: String) {
        //TODO: Cancel location
        UIApplication.shared.keyWindow?.makeToast(message: Strings.invalid_selected_location)
    }

    private func moveToLocationSelectionOnMap(selectedLocation : Location,LocationType: String){
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectLocationFromMap = storyboard.instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location :selectedLocation, locationType: LocationType, actnBtnTitle: Strings.done_caps, isFromEditRoute: true)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }
}

//MARK: favorite/Coustom Route remove or Update
extension SelectLocationViewController {
    //MARK:FavoriteLocation update
    private func displayHomeAndOfficePopUpMenu( favouriteLocation : UserFavouriteLocation, locationType : String,locationName : String?,index: Int){
        AppDelegate.getAppDelegate().log.debug("displayHomeAndOfficePopUpMenu()")
        let alertController : HomeAndOfficeLocationAlertController = HomeAndOfficeLocationAlertController(viewController: self) { (result) -> Void in
            if result == Strings.update{
                guard let favoriteLocation = UserDataCache.getInstance()?.getFavoriteLocations()[index] else { return }
                self.editFavoriteLocation(favoriteLocation: favoriteLocation)

            }else if result == Strings.delete{
                QuickRideProgressSpinner.startSpinner()
                UserRestClient.deleteFavouriteLocations(id: favouriteLocation.locationId!, viewController: self, completionHandler: { (responseObject, error) -> Void in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject == nil || responseObject!["result"] as! String == "FAILURE" {
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self, handler: nil)
                    }else if responseObject!["result"] as! String == "SUCCESS"{

                        UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: favouriteLocation)
                        if locationType == ChangeLocationViewController.HOME {
                            SharedPreferenceHelper.storeHomeLocation(homeLocation: nil)
                        }else{
                            SharedPreferenceHelper.storeOfficeLocation(officeLocation: nil)
                        }
                        self.selectLocationVM?.getFavoriteLocation()
                        self.validateFavoriteViewShow()
                        self.locationListTableView.reloadData()
                    }
                })
            }
        }
        alertController.updateAlertAction()
        alertController.deleteAlertAction()
        alertController.addRemoveAlertAction()
        alertController.showAlertController()
    }

    private func editFavoriteLocation(favoriteLocation : UserFavouriteLocation){
        let favLocation = favoriteLocation
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.add_favourite_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddFavoriteLocationViewController") as! AddFavoriteLocationViewController
        addFavoriteLocationViewController.initializeDataBeforePresenting(favLocation: favLocation)
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }

    // MARK: CustomeRoute Update
    private func displayPopUpMenuForPrefferedroute(preferredRoute : UserPreferredRoute,index : Int) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: Strings.edit_route, style: .default) { [unowned self](action) in
            self.moveToRouteSelection(preferredRoute: preferredRoute)
        }
        let deleteAction = UIAlertAction(title: Strings.delete, style: .destructive) { [unowned self](action) in
            self.deleteUserPreferredRoute(preferredRoute: preferredRoute, index: index)
        }
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(removeUIAlertAction)
        ViewControllerUtils.getCenterViewController().present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    //MARK: DeleteCoustom route
    private func deleteUserPreferredRoute(preferredRoute : UserPreferredRoute,index : Int) {
        QuickRideProgressSpinner.startSpinner()
        RoutePathServiceClient.deleteUserPreferredRoute(id: preferredRoute.id!, userId: preferredRoute.userId!, viewController: self) {[weak self] (responseObject, error) in
            guard let self = `self` else { return }
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UserDataCache.getInstance()?.deleteUserPreferredRoute(userPreferredRoute: preferredRoute)
                self.selectLocationVM?.customizedRoutes.remove(at: index)
                self.locationListTableView.reloadData()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }

    //MARK: move to update route Selection for coustom location
    private func moveToRouteSelection(preferredRoute : UserPreferredRoute){
        guard let userId = QRSessionManager.getInstance()?.getUserId(),let fromLatitude = preferredRoute.fromLatitude,let fromLongitude = preferredRoute.fromLongitude,let fromLocation = preferredRoute.fromLocation,let toLocation = preferredRoute.toLocation,let toLatitude = preferredRoute.toLatitude,let toLongitude = preferredRoute.toLongitude, let delegate = routeSelectionDelegate else{
            return
        }
        let ride = Ride(userId: userId.toDouble(), rideType: "", startAddress: fromLocation, startLatitude: fromLatitude, startLongitude: fromLongitude, endAddress: toLocation, endLatitude: toLatitude, endLongitude: toLongitude, startTime: 0)
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: ride, rideRoute: MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId)!, routeSelectionDelegate: delegate)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: routeSelectionViewController, animated: false)
    }
}

extension SelectLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        AppDelegate.getAppDelegate().log.debug("locationManager()")
        self.locationManager.stopUpdatingLocation()
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        moveToCurrentLocation(location: locations.last!.coordinate,updatePrimaryRegionIfnRequired: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.debug("locationManager()")
        if error._code == CLError.denied.rawValue{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.enable_location_service, message2: nil, positiveActnTitle: Strings.go_to_settings, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if result == Strings.go_to_settings{
                    let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                    if settingsUrl != nil && UIApplication.shared.canOpenURL(settingsUrl! as URL){
                        UIApplication.shared.open(settingsUrl! as URL, options: [:], completionHandler: nil)
                    }
                }
            })
        }
    }

    private func moveToCurrentLocation(location : CLLocationCoordinate2D,updatePrimaryRegionIfnRequired :  Bool){
        AppDelegate.getAppDelegate().log.debug("moveToCurrentLocation()")

        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.RideCreationView", coordinate: location) { (location,error) -> Void in

            if error != nil{
                if error == QuickRideErrors.NetworkConnectionNotAvailableError{
                    UIApplication.shared.keyWindow?.makeToast(message: Strings.DATA_CONNECTION_NOT_AVAILABLE, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300))
                }
            }else if location == nil || location!.shortAddress == nil{
                UIApplication.shared.keyWindow?.makeToast(message: Strings.location_not_found, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/3))
            }else{
                self.selectLocationVM?.locationSelected.address = location?.shortAddress ?? ""
                self.selectLocationVM?.locationSelected.latitude = location?.latitude ?? 0.0
                self.selectLocationVM?.locationSelected.longitude = location?.longitude ?? 0.0

                if self.selectLocationVM?.ride?.startAddress == "" || self.selectLocationVM?.ride?.startAddress == nil {
                    self.startLocationTextField.text = location?.shortAddress ?? ""
                    self.selectLocationVM?.ride?.startAddress = location?.shortAddress ?? ""
                    self.selectLocationVM?.ride?.startLatitude = location?.latitude ?? 0.0
                    self.selectLocationVM?.ride?.startLongitude = location?.longitude ?? 0.0
                }
            }
        }
    }
}
