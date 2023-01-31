//
//  ChangeLocationViewController.swift
//  Quickride
//
//  Created by QuickRide on 12/11/15.
// Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import ObjectMapper

protocol ReceiveLocationDelegate{
    func receiveSelectedLocation(location : Location,requestLocationType : String)
    func receivePickUPAndDropLocation(pickUpLocation:Location,dropLocation: Location,requestLocationType : String)//Optional Protocol used for TaxiPOOL
    func locationSelectionCancelled(requestLocationType : String)
}
extension ReceiveLocationDelegate{
    func receivePickUPAndDropLocation(pickUpLocation:Location,dropLocation: Location,requestLocationType : String){}
}
protocol ReceiveBehalfBookingDetails{
    func receiveBehalfBookingDetails(commuteContactNo: String?, commutePassengerName: String?)
}

class ChangeLocationViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate,ReceiveLocationDelegate{

    static let DESTINATION : String = "DESTINATION"
    static let ORIGIN : String = "ORIGIN"
    static let HOME : String = "HOME"
    static let OFFICE : String = "OFFICE"
    static let VIAPOINT : String = "VIAPOINT"
    static let TAXI_PICKUP = "TAXI_PICKUP"
    static let TAXI_DROP = "TAXI_DROP"
    static let SELECT_LOCATION_REQUESTCODE = 501

    static let FROM_LOCATION_SELECTION_REQUEST_CODE : Int = 502
    static let TO_LOCATION_SELECTION_REQUEST_CODE : Int = 503

    static let SELECT_HOME_LOCATION_REQUEST_CODE : Int = 1001
    static let SELECT_OFFICE_LOCATION_REQUEST_CODE : Int = 1002
    static let UPDATE_HOME_LOCATION_REQUEST_CODE : Int = 1003
    static let UPDATE_OFFICE_LOCATION_REQUEST_CODE : Int = 1004

    static let PLACES_API_GENUINE_SESSION_TIME_OUT = 5 // MINS


    var isLocationCleared = false

    var receiveLocationDelegate : ReceiveLocationDelegate?
    var allRecentLocations : [Location]?
    var recentLocations = [Location]()
    var favouriteLocations = [Location]()
    var predictedPlaces : [Location] = [Location]()
    var customizedRoutes = [UserPreferredRoute]()
    var isKeyBoardVisible = false
    var requestedLocationType : String?
    var currentSelectedLocation : Location?
    var hideSelectLocationFromMap :Bool = false
    var routeSelectionDelegate : RouteSelectionDelegate?
    var alreadySelectedLocation: Location?

    // behalf booking
    var behalfBookingPhoneNumber: String?
    var behalfBookingName: String?
    var receiveBehalfBookingDetails: ReceiveBehalfBookingDetails?

    let indiaBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 8.081525, longitude: 68.149904), coordinate: CLLocationCoordinate2D(latitude: 37.833238, longitude: 97.588283))

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var iboSearchLocation: UISearchBar!
    @IBOutlet weak var iboTableView: UITableView!

    @IBOutlet weak var selectLocationFromMapView: UIView!

    @IBOutlet weak var selectLocationFromMapViewText: UILabel!

    @IBOutlet weak var locationImage: UIImageView!

    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var loadMoreView: UIView!

    @IBOutlet weak var loadMoreButton: UIButton!

    @IBOutlet weak var numberOfCharacterLeftLabel: UILabel!

    @IBOutlet weak var selectFromMapViewHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var behalfButton: QRCustomButton!

    @IBOutlet weak var behalfNameShowingLabel: UILabel!

    @IBOutlet weak var behalfButtonContainingView: UIView!

    var searchActive:Bool = false
    var isFromEditRoute = false


    func initializeDataBeforePresenting(receiveLocationDelegate : ReceiveLocationDelegate,requestedLocationType : String,currentSelectedLocation : Location?,hideSelectLocationFromMap :Bool,routeSelectionDelegate : RouteSelectionDelegate?, isFromEditRoute : Bool){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.receiveLocationDelegate = receiveLocationDelegate
        self.routeSelectionDelegate = routeSelectionDelegate
        self.requestedLocationType =  requestedLocationType
        self.currentSelectedLocation  = currentSelectedLocation
        self.hideSelectLocationFromMap = hideSelectLocationFromMap
        self.isFromEditRoute = isFromEditRoute
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ChangeLocationViewController.handleSwipes(_:)))
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        ViewCustomizationUtils.addBorderToView(view: selectLocationFromMapView, borderWidth: 1, colorCode: 0xe8e8e8)
        loadMoreView.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChangeLocationViewController.selectLocationOnMapAction(_:)))
        self.selectLocationFromMapView.addGestureRecognizer(tapGesture)
        self.selectLocationFromMapView.isHidden = hideSelectLocationFromMap
        if hideSelectLocationFromMap{
            selectFromMapViewHeight.constant = 0
        }
        let favourites = UserDataCache.getInstance()?.getFavoriteLocations()
        if favourites != nil{
            for favouriteLocation in favourites!{
                let location = Location(latitude: favouriteLocation.latitude!,longitude: favouriteLocation.longitude!, shortAddress: favouriteLocation.address, completeAddress: favouriteLocation.address, placeId: nil, locationType: Location.FAVOURITE_LOCATION, country: favouriteLocation.country, state: favouriteLocation.state, city: favouriteLocation.city, areaName: favouriteLocation.areaName, streetName: favouriteLocation.streetName)
                location.name = favouriteLocation.name
                favouriteLocations.append(location)
            }
        }

        allRecentLocations = getLocationsFromRecentLocations()
        if allRecentLocations != nil{
            for recentLocation in allRecentLocations!{
                if recentLocations.count == 5{
                    break
                }
                recentLocations.append(recentLocation)
            }
        }
        setupTitleUI()
        if let selectedLocation = currentSelectedLocation, let completeAddress = selectedLocation.completeAddress, !completeAddress.isEmpty {
            iboSearchLocation.text = completeAddress
        }
        iboSearchLocation.delegate = self


        self.iboTableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeLocationViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeLocationViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        spinner.isHidden = true
        iboSearchLocation.backgroundColor = UIColor(red: 131, green: 131, blue: 131, alpha: 1)
        if let preferredRoutes = UserDataCache.getInstance()?.getUserPreferredRoutes(){
            for preferredRoute in preferredRoutes{
                if preferredRoute.routeName != nil{
                    self.customizedRoutes.append(preferredRoute)
                }
            }
        }
        setupTripTypeButtonUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("handleSwipes()")
        iboSearchLocation.endEditing(true)
        self.resignFirstResponder()

    }
    override  func viewDidAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewDidAppear()")
        self.navigationController?.isNavigationBarHidden = true
        if ((self.customizedRoutes.count + self.favouriteLocations.count + self.recentLocations.count) <= 3 ) || self.currentSelectedLocation != nil {
            iboSearchLocation.becomeFirstResponder()
        }
    }
    override  func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ChangeLocationViewController.selectSearchBarText), userInfo: nil, repeats: false)
    }

    @objc func selectSearchBarText() {
        UIApplication.shared.sendAction(#selector(selectAll(_:)), to: nil, from: nil, for: nil)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        isLocationCleared = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.endEditing(true)
        resignFirstResponder()

    }
    func textFieldShouldReturn(searchBar: UISearchBar) -> Bool {
        searchBar.endEditing(true)
        resignFirstResponder()
        return false
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            tableViewBottomSpaceConstraint.constant = keyBoardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            return
        }
        tableViewBottomSpaceConstraint.constant = 0
        isKeyBoardVisible = false
    }

    private func setupTripTypeButtonUI(){
        if let behalfBookingName = behalfBookingName, behalfBookingPhoneNumber != nil {
            behalfNameShowingLabel.text = behalfBookingName
        }else {
            behalfNameShowingLabel.text = "My Self"
        }
    }

    private func setupTitleUI(){
        behalfButtonContainingView.isHidden = true
        if isFromEditRoute{
            iboSearchLocation.placeholder = Strings.search_via_point
            titleLabel.text = Strings.add_via_point
        }else{
            titleLabel.text = Strings.select_location
            if requestedLocationType == ChangeLocationViewController.ORIGIN  {
                iboSearchLocation.placeholder = Strings.enter_start_location
                titleLabel.text = Strings.pick_up
            }else if requestedLocationType == ChangeLocationViewController.DESTINATION {
                iboSearchLocation.placeholder =  Strings.enter_end_location
                titleLabel.text =  Strings.drop.capitalized
            }else if requestedLocationType == ChangeLocationViewController.HOME {
                iboSearchLocation.placeholder =  Strings.enter_home_location
            }else if requestedLocationType == ChangeLocationViewController.OFFICE{
                iboSearchLocation.placeholder =  Strings.enter_office_location
            }else if requestedLocationType == ChangeLocationViewController.TAXI_PICKUP {
                iboSearchLocation.placeholder = Strings.enter_start_location
                titleLabel.text = Strings.pick_up
                behalfButtonContainingView.isHidden = false
            }else if requestedLocationType == ChangeLocationViewController.TAXI_DROP {
                iboSearchLocation.placeholder =  Strings.enter_end_location
                titleLabel.text =  Strings.drop.capitalized
                behalfButtonContainingView.isHidden = false
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
    var triggeredTime : DispatchTime = .now()

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        numberOfCharacterLeftLabel.isHidden = true
        guard let queryString = self.iboSearchLocation.text else {
            return
        }
        if queryString.isEmpty{
            predictedPlaces.removeAll()
            iboTableView.reloadData()
            isLocationCleared = true
            return
        }
        if queryString.count < 4{
            numberOfCharacterLeftLabel.isHidden = false
            numberOfCharacterLeftLabel.text = "\(4 - queryString.count) more character"
        } else {
            numberOfCharacterLeftLabel.isHidden = true
        }
        let places = UserCoreDataHelper.getRecentSearchedLocations(searchText: queryString)
        if !places.isEmpty {
            predictedPlaces = places
            iboTableView.reloadData()
        }
        triggeredTime = .now()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            AppDelegate.getAppDelegate().log.debug("SearchForLocation triggeredTime,currentTime \(self.triggeredTime) \(DispatchTime.now() )")
            if (DispatchTime.now() - 1) < self.triggeredTime {
                AppDelegate.getAppDelegate().log.debug("SearchForLocation Min Time not satisfied")
                return
            }
            AppDelegate.getAppDelegate().log.debug("SearchForLocation Min Time satisfied")
            self.doSearchOnServer()
        }
    }
    var readFromGoogle = false
    func doSearchOnServer(){

        guard let queryString = self.iboSearchLocation.text else {
            return
        }
        if queryString.count >= 4 {
            if !spinner.isHidden{
                return
            }
            readAutoCompletePlacesFromQuickRide(queryString: queryString)
            self.readFromGoogle = false
        }
    }
    func readAutoCompletePlacesFromQuickRide(queryString : String){
        let coordinate = getRecentLocationCoordinate()
        spinner.startAnimating()
        RoutePathServiceClient.getAutoCompletePlaces(useCase: "iOS.App.PlacesSearch.LocationSelectionView", forSearchString: queryString, regionLat: coordinate.latitude, regionLong: coordinate.longitude,readFromGoogle :readFromGoogle) { (responseObject, error) in
            self.spinner.stopAnimating()
            AppDelegate.getAppDelegate().log.error("getAutoCompletePlaces failed \(responseObject), \(error)")

            if responseObject != nil && responseObject!["result"] as? String  == "SUCCESS"{
                if let results = Mapper<Location>().mapArray(JSONObject: responseObject!["resultData"]){
                    self.predictedPlaces = results
                    var isOfflineData = false
                    for place in self.predictedPlaces {
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

                if(self.predictedPlaces.count == 0){
                    self.searchActive = false
                } else {
                    self.searchActive = true
                }
                self.iboTableView.reloadData()
            }else{
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]){
                    if let userMessage =  responseError.userMessage{
                        UIApplication.shared.keyWindow?.makeToast(userMessage)
                    }
                }else if error != nil && error!.code == QuickRideErrors.NetworkConnectionNotAvailable{
                    UIApplication.shared.keyWindow?.makeToast(Strings.NetworkConnectionNotAvailable_Msg)
                }else{
                    UIApplication.shared.keyWindow?.makeToast("Some internal error ,Please try again")
                }
            }

        }
    }

    func getLocationsFromRecentLocations() -> [Location]{
        if allRecentLocations != nil{
            return allRecentLocations!
        }
        var recents : [UserRecentLocation]?
        if UserDataCache.getInstance() != nil{
            recents = UserDataCache.getInstance()?.getRecentLocations()
        }
        else{
            recents = UserCoreDataHelper.getuserRecentLocationObject()
        }
        allRecentLocations = [Location]()
        if recents != nil{
            recents!.sort(by: {$0.time > $1.time})
            for recentLocation in recents!{
                let location = Location(latitude: recentLocation.latitude!,longitude: recentLocation.longitude!, shortAddress: recentLocation.recentAddressName, completeAddress: recentLocation.recentAddress, placeId: nil, locationType: Location.RECENT_LOCATION, country: recentLocation.country, state: recentLocation.state, city: recentLocation.city, areaName: recentLocation.areaName, streetName: recentLocation.streetName)
                location.name = recentLocation.recentAddressName
                allRecentLocations!.append(location)
            }
        }
        return allRecentLocations!
    }
    func toBounds() -> GMSCoordinateBounds{
        var latlngBounds = indiaBounds
        if let recentLocation = LocationCache.getCacheInstance().getRecentLocationOfUser() {
            AppDelegate.getAppDelegate().log.debug("RecentLocation:\(recentLocation)")
            let southWest = GMSGeometryOffset(recentLocation.coordinate,GoogleMapUtils.LATLONG_BOUNDS_RADIUS * 1.41421356237,225)
            let northEast = GMSGeometryOffset(recentLocation.coordinate,GoogleMapUtils.LATLONG_BOUNDS_RADIUS * 1.41421356237,45)
            latlngBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        }
        if !latlngBounds.isValid{
            latlngBounds = indiaBounds
        }
        return latlngBounds
    }
    func numberOfSections(in tableView: UITableView) -> Int {

        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0{
            return self.predictedPlaces.count
        }else if section == 1{

            if routeSelectionDelegate == nil {
                return 0
            }
            self.customizedRoutes.removeAll(where: {$0.fromLocation == nil || $0.toLocation == nil})
            return self.customizedRoutes.count
        } else if section == 2{
            if (isFromEditRoute || iboSearchLocation.text?.count != 0) && iboSearchLocation.text != currentSelectedLocation?.completeAddress{
                return 0
            }
            return self.recentLocations.count
        } else{
            if (isFromEditRoute || iboSearchLocation.text?.count != 0) && iboSearchLocation.text != currentSelectedLocation?.completeAddress{
                return 0
            }
            return self.favouriteLocations.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListLocationTableViewCell)!
        var location : Location?
        if indexPath.section == 0{
            if indexPath.row >= predictedPlaces.count{
                return cell
            }
            location = predictedPlaces[indexPath.row]
            cell.iboTitleLabel!.text = location!.name
            cell.iboIcon.image = UIImage(named: "location_marker_light_gray")
            cell.iboSubTitleLabel!.text = location!.completeAddress
            cell.menuBtn.isHidden = true
            cell.menuBtnWidthConstraint.constant = 0
            cell.menuBtnTrailingSpaceConstraint.constant = 20
        }else if indexPath.section == 1{
            if indexPath.row >= customizedRoutes.count{
                return cell
            }
            let customRoute = customizedRoutes[indexPath.row]
            cell.iboTitleLabel.text = customRoute.routeName
            cell.iboIcon.image = UIImage(named: "ic_pin_drop")
            cell.iboSubTitleLabel.text = customRoute.fromLocation!.prefix(25) + " " + Strings.to + " " + customRoute.toLocation!.prefix(25)
            cell.menuBtn.isHidden = false
            cell.menuBtnWidthConstraint.constant = 50
            cell.menuBtnTrailingSpaceConstraint.constant = 20
            cell.menuBtn.tag = indexPath.row
        }else if indexPath.section == 2{
            if indexPath.row >= recentLocations.count{
                return cell
            }
            location = recentLocations[indexPath.row]
            cell.iboTitleLabel!.text = Location.getConsolidatedNameFromFormattedAddress(name: location!.shortAddress)
            cell.iboIcon.image = UIImage(named: "ic_time")
            cell.iboSubTitleLabel!.text = location!.completeAddress
            cell.menuBtn.isHidden = true
            cell.menuBtnWidthConstraint.constant = 0
            cell.menuBtnTrailingSpaceConstraint.constant = 20
        }else {
            location = favouriteLocations[indexPath.row]
            cell.iboTitleLabel!.text = location!.name
            cell.iboIcon.image = UIImage(named: "ic_favorite_border")
            cell.iboSubTitleLabel!.text = location!.completeAddress
            cell.menuBtn.isHidden = true
            cell.menuBtnWidthConstraint.constant = 0
            cell.menuBtnTrailingSpaceConstraint.constant = 20
        }

        return cell
    }

    func getFormattedAddress(address:[String], order:Int) -> (String, String){
        AppDelegate.getAppDelegate().log.debug("getFormattedAddress()")
        var titles:[String] = address
        let title = titles[0]
        titles.remove(at: 0)
        var address:String = ""
        for subTitle in titles{
            address = address.appending(subTitle) + ", "
            AppDelegate.getAppDelegate().log.debug(address)
        }
        let subTitle = address
        return (title,subTitle)
    }

    func sendSelectedLocationDetailsToCalledViewController( selectedLocation : Location){

        AppDelegate.getAppDelegate().log.debug("sendSelectedLocationDetailsToCalledViewController()")
        self.navigationController?.popViewController(animated: false)
        let userDataCache : UserDataCache? = UserDataCache.getInstance()
        let recentLocation = UserRecentLocation(recentLocationId : "" , recentAddress : selectedLocation.completeAddress!,recentAddressName :  selectedLocation.shortAddress!, latitude : selectedLocation.latitude, longitude : selectedLocation.longitude, country: selectedLocation.country, state: selectedLocation.state, city: selectedLocation.city, areaName: selectedLocation.areaName, streetName: selectedLocation.streetName)
        if userDataCache != nil{
            userDataCache?.saveRecentLocations(recentLocation: recentLocation)

        }
        else{
            recentLocation.time = NSDate().getTimeStamp()
            let redundantRecentLocation =  UserDataCache.getRedundantRecentLocation(selectLocation: recentLocation, recentLocations: [])
            if redundantRecentLocation == nil{
                UserCoreDataHelper.saveRecentLocation(userRecentLocation: recentLocation)
            }
        }
        if selectedLocation.locationType == Location.RECENT_LOCATION{
            selectedLocation.shortAddress = selectedLocation.completeAddress
        }
        self.receiveLocationDelegate?.receiveSelectedLocation(location: selectedLocation,requestLocationType: self.requestedLocationType!)

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath() \(indexPath)")
        self.iboSearchLocation.delegate = nil
        self.view.endEditing(false)
        if indexPath.section == 0 && indexPath.row >= predictedPlaces.count{
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        var selectedLocation = Location()
        if indexPath.section == 0{
            selectedLocation = predictedPlaces[indexPath.row]
        }else if indexPath.section == 1 {
            let customRoute = customizedRoutes[indexPath.row]
            self.navigationController?.popViewController(animated: false)
            self.routeSelectionDelegate?.recieveSelectedPreferredRoute(ride: nil, preferredRoute: customRoute)
            return
        }else if indexPath.section == 2{
            selectedLocation = recentLocations[indexPath.row]
        }else{
            selectedLocation = favouriteLocations[indexPath.row]
        }
        if alreadySelectedLocation?.latitude != 0 && alreadySelectedLocation?.longitude != 0 && selectedLocation.latitude == alreadySelectedLocation?.latitude && selectedLocation.longitude == alreadySelectedLocation?.longitude{
            UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff)
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        if selectedLocation.latitude != 0 && selectedLocation.longitude != 0 {
            sendSelectedLocationDetailsToCalledViewController(selectedLocation: selectedLocation)
            RoutePathServiceClient.updateUsageCount(address: selectedLocation.completeAddress!) { responseObject, error in
                
            }
        }else{
            if selectedLocation.completeAddress == nil{
                UIApplication.shared.keyWindow?.makeToast(Strings.invalid_recent_location)
                let location = UserDataCache.getInstance()?.getRedundantRecentLocation(latitude: selectedLocation.latitude,longitude: selectedLocation.longitude)
                if location != nil && location?.location != nil && (location?.index)! >= 0{
                    UserDataCache.getInstance()?.removeRecentLocation(recentLocation: location!.location!, index: location!.index)
                }
                return
            }
            LocationCache.getCacheInstance().getLocationInfoForAddress(useCase: "iOS.App.PlaceSelect.LocationSelectionView", address: selectedLocation.completeAddress!, placeId: selectedLocation.placeId) { (location, error) in
                if location != nil{
                    selectedLocation.country = location!.country
                    selectedLocation.state = location!.state
                    selectedLocation.city = location!.city
                    selectedLocation.areaName = location!.areaName
                    selectedLocation.streetName = location!.streetName
                    selectedLocation.latitude = location!.latitude
                    selectedLocation.longitude = location!.longitude
                    UserCoreDataHelper.saveOrUpdateRecentSearchedLocation(location: selectedLocation)
                    self.sendSelectedLocationDetailsToCalledViewController(selectedLocation: selectedLocation)

                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.invalid_selected_location)
                }
            }
        }
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("cancelButtonClicked()")
        self.navigationController?.popViewController(animated: false)
        receiveLocationDelegate?.locationSelectionCancelled(requestLocationType: requestedLocationType!)
    }

    func moveToLocationSelectionOnMap(selectedLocation : Location){
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectLocationFromMap = storyboard.instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location :selectedLocation, locationType: "", actnBtnTitle: Strings.done_caps, isFromEditRoute: true, dropLocation: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }

    @objc func selectLocationOnMapAction(_ sender: UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("selectLocationOnMapAction()")
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectLocationFromMap = storyboard.instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location :currentSelectedLocation, locationType: requestedLocationType!, actnBtnTitle: Strings.done_caps, isFromEditRoute: isFromEditRoute, dropLocation: nil)

        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }

    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
        AppDelegate.getAppDelegate().initialiseLogger()
        super.didReceiveMemoryWarning()
    }
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        self.navigationController?.popViewController(animated: false)
        receiveLocationDelegate?.receiveSelectedLocation(location: location, requestLocationType: requestLocationType)
    }

    func locationSelectionCancelled(requestLocationType: String) {
        self.navigationController?.popViewController(animated: false)
        receiveLocationDelegate?.locationSelectionCancelled(requestLocationType: requestLocationType)
    }

    @IBAction func menuBtnClicked(_ sender: UIButton) {
        self.view.endEditing(false)
        let preferredRoute = customizedRoutes[sender.tag]
        displayPopUpMenu(preferredRoute: preferredRoute, index: sender.tag)
    }


    @IBAction func loadMoreTapped(_ sender: UIButton) {
        loadMoreView.isHidden = true
        readFromGoogle = true
        spinner.stopAnimating()
        doSearchOnServer()


    }

    @IBAction func behalfButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        moveToTaxiBookingSomeOneView()
    }

    private func moveToTaxiBookingSomeOneView(){
        let tripTypeViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_behalf_someone_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TripTypeViewController") as! TripTypeViewController
        tripTypeViewController.initialiseData(behalfBookingPhoneNumber: behalfBookingPhoneNumber, behalfBookingName: behalfBookingName){  contactName, contactNumber in
                self.behalfBookingName = contactName
                self.behalfBookingPhoneNumber = contactNumber
                self.setupTripTypeButtonUI()
                self.receiveBehalfBookingDetails?.receiveBehalfBookingDetails(commuteContactNo: contactNumber, commutePassengerName: contactName)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: tripTypeViewController)
    }


    private func displayPopUpMenu(preferredRoute : UserPreferredRoute,index : Int)
    {
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

    private func moveToRouteSelection(preferredRoute : UserPreferredRoute){
        guard let userId = QRSessionManager.getInstance()?.getUserId(),let fromLatitude = preferredRoute.fromLatitude,let fromLongitude = preferredRoute.fromLongitude,let fromLocation = preferredRoute.fromLocation,let toLocation = preferredRoute.toLocation,let toLatitude = preferredRoute.toLatitude,let toLongitude = preferredRoute.toLongitude, let delegate = routeSelectionDelegate else{
            return
        }
        let ride = Ride(userId: userId.toDouble(), rideType: "", startAddress: fromLocation, startLatitude: fromLatitude, startLongitude: fromLongitude, endAddress: toLocation, endLatitude: toLatitude, endLongitude: toLongitude, startTime: 0)
        guard let rideRoute = MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId) else { return }
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: ride, rideRoute: rideRoute, routeSelectionDelegate: delegate)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeSelectionViewController, animated: false)
    }

    private func deleteUserPreferredRoute(preferredRoute : UserPreferredRoute,index : Int){
        QuickRideProgressSpinner.startSpinner()
        RoutePathServiceClient.deleteUserPreferredRoute(id: preferredRoute.id!, userId: preferredRoute.userId!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{

                UserDataCache.getInstance()?.deleteUserPreferredRoute(userPreferredRoute: preferredRoute)
                self.customizedRoutes.remove(at: index)
                self.iboTableView.reloadData()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self,handler: nil)
            }
        }
    }
    fileprivate func checkOverQueryLimitAndSwitchGenuinePlacesKey(_ error: Error?,searchText : String) {
        let userInfo = (error! as NSError).userInfo
        if let errorReason = userInfo["NSUnderlyingError"] as? Error{
            if errorReason.localizedDescription.contains("exceeded your daily request quota"){
                ConfigurationCache.getInstance()?.setPlacesAPIGenuineUsageStartTime(date: NSDate())
            }
        }
    }
}
