//
//  CreateRideHomeViewController.swift
//  Quickride
//
//  Created by Ashutos on 17/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FloatingPanel

class CreateRideHomeViewController: UIViewController {
    //MARK: OUTLETS
    @IBOutlet weak var MapView: UIView!
    @IBOutlet weak var chatIconButton: UIButton!
    @IBOutlet weak var pendingChatMessageCountLabel: UILabel!
    @IBOutlet weak var pendingNotificationOutlet: UILabel!
    @IBOutlet weak var pendingChatView: UIView!
    @IBOutlet weak var pendingNotificationView: UIView!
    @IBOutlet weak var whatsAppIconBtn: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!

    //Variables
    private var viewMap: GMSMapView!
    private var locationManager = CLLocationManager()
    var fpc: FloatingPanelController!
    var createRideBottomViewController: CreateRideBottomViewController!
    private var homeRideButtomViewModel = HomeRideButtomViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        fpc = FloatingPanelController()
        fpc.delegate = self

        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            fpc.surfaceView.cornerRadius = 20.0
        } else {
            fpc.surfaceView.cornerRadius = 0.0
        }
        fpc.surfaceView.shadowHidden = false
        fpc.surfaceView.grabberTopPadding = 10
        createRideBottomViewController = storyboard?.instantiateViewController(withIdentifier: "CreateRideBottomViewController") as? CreateRideBottomViewController

        // Set a content view controller
        fpc.set(contentViewController: createRideBottomViewController)
        fpc.track(scrollView: createRideBottomViewController.rideCreationTableView)
        fpc.addPanel(toParent: self, animated: true)
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: MapView)
        self.viewMap.delegate = self

    }
    var locationFetched = false
    private func getLocation(){

        if locationFetched {
            return
        }
        setUpUI()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        fetchLocation()
    }
    func fetchLocation() {

        if let lastLocation = locationManager.location{

            viewMap.animate(to: GMSCameraPosition.camera(withLatitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude, zoom: 16))
            AppDelegate.getAppDelegate().log.debug("fetchLocation from location manager")
            moveToCurrentLocation(location:  lastLocation.coordinate, updatePrimaryRegionIfnRequired: false)
        }else if let latlng = SharedPreferenceHelper.getLastLocation(){
            viewMap.animate(to: GMSCameraPosition.camera(withLatitude: latlng.latitude, longitude: latlng.longitude, zoom: 16))
            AppDelegate.getAppDelegate().log.debug("fetchLocation from shared preferences")
            moveToCurrentLocation(location:  CLLocationCoordinate2D(latitude: latlng.latitude, longitude: latlng.longitude), updatePrimaryRegionIfnRequired: false)
        }
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse{
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndHandleRemoteNotificationsEnabling()
        checkCarpoolOnbordingStatus()
        ContainerTabBarViewController.indexToSelect = 1

        self.navigationController?.isNavigationBarHidden = true
        getLocation()
        displayUpdateApplicationIfRequired()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        handleNotificationCountAndDisplay()
        handleChatCountDisplay()
        dependingOnPreferencesHideAndUnhideWhatsAppIcon()
    }


    private func setUpUI() {
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: MapView)
        self.viewMap.delegate = self
        self.viewMap.padding = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        self.viewMap.moveCamera(GMSCameraUpdate.zoom(to: 16))
        self.viewMap.isMyLocationEnabled = false
        ViewCustomizationUtils.addCornerRadiusToView(view: pendingChatView, cornerRadius: 10)
        ViewCustomizationUtils.addCornerRadiusToView(view: pendingNotificationView, cornerRadius: 10)
        ViewCustomizationUtils.addBorderToView(view: pendingChatView, borderWidth: 2, color: .white)
        ViewCustomizationUtils.addBorderToView(view: pendingNotificationView, borderWidth: 2, color: .white)
        pendingNotificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pendingNotificationTapped(_:))))
    }
    private func checkCarpoolOnbordingStatus(){
        if let status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_CARPOOL_ONBORDING_DETAILS), !status {
            let carpoolOnboardingVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CarpoolOnboardingViewController") as! CarpoolOnboardingViewController

            carpoolOnboardingVC.view.frame = self.view.bounds
            carpoolOnboardingVC.willMove(toParent: self)
            self.view.addSubview(carpoolOnboardingVC.view)
            self.addChild(carpoolOnboardingVC)
            carpoolOnboardingVC.didMove(toParent: self)
        }
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
            pendingChatView.isHidden = false
            pendingChatMessageCountLabel.text = String(count)
        }else{
            pendingChatView.isHidden = true
        }
    }

    private func dependingOnPreferencesHideAndUnhideWhatsAppIcon(){
        if let whatsAppPreferences = UserDataCache.getInstance()?.getLoggedInUserWhatsAppPreferences(){
            whatsAppIconBtn.isHidden = whatsAppPreferences.enableWhatsAppPreferences
        }else{
            whatsAppIconBtn.isHidden = false
        }
    }

    private func handleNotificationCountAndDisplay(){
        let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0{
            pendingNotificationView.isHidden = false
            pendingNotificationOutlet.text = String(pendingNotificationCount)
        }else{
            pendingNotificationView.isHidden = true
        }
    }

    private func checkAndHandleRemoteNotificationsEnabling(){
        if NotificationStore.isNotificationSettingsRequested && UIApplication.shared.currentUserNotificationSettings?.types == []{
            NotificationStore.isNotificationSettingsRequested = false
            MessageDisplay.displayErrorAlertWithAction(title: Strings.notifiction_permission_title, isDismissViewRequired : true, message1: Strings.notifiction_permission_message, message2: nil, positiveActnTitle: Strings.enable_caps, negativeActionTitle : nil,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.enable_caps == result{
                    let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                    if settingsUrl != nil && UIApplication.shared.canOpenURL(settingsUrl! as URL){
                        UIApplication.shared.open(settingsUrl! as URL, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.keyWindow?.makeToast(Strings.enable_notifications, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                    }
                }
            })
        }
    }

    @objc func pendingNotificationTapped(_ sender: UITapGestureRecognizer) {
        moveToNotificationViewController()
    }



    @IBAction func WhatsAppIconTapped(_ sender: Any){
        let enableWhatsAppMsgSuggestionViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EnableWhatsAppMsgSuggestionViewController") as! EnableWhatsAppMsgSuggestionViewController
        enableWhatsAppMsgSuggestionViewController.initializeDataInView(handler: { (enableWhatsAppMessage) in
            if enableWhatsAppMessage{
                self.whatsAppIconBtn.isHidden = true
            }else{
                self.whatsAppIconBtn.isHidden = false
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: enableWhatsAppMsgSuggestionViewController)
    }

    @IBAction func chatBtnPressed(_ sender: UIButton) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CentralChatViewController") as! CentralChatViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: centralChatViewController, animated: false)
    }

    @IBAction func notificationBtnPressed(_ sender: UIButton) {
        self.moveToNotificationViewController()
    }

    private func moveToNotificationViewController() {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }



    @IBAction func currentLocationButtonAction(_ sender: Any) {
        locationFetched = false
        fetchLocation()

    }

    @IBAction func menuButtonTapped(_ sender: Any) {
        let leftMenuViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
        leftMenuViewController.initialiseMenu(Menutype: MenuItem.CARPOOL_MENU)
        ViewControllerUtils.addSubView(viewControllerToDisplay: leftMenuViewController)
    }
}
extension CreateRideHomeViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        AppDelegate.getAppDelegate().log.debug("idleAt \(position)")
        if homeRideButtomViewModel.isRequiredToGetLocationInfoForLatLng{
            moveToCurrentLocation(location: position.target, updatePrimaryRegionIfnRequired: false)
        }
        if let location = locationManager.location, location.distance(from: CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)) < 10 {
            currentLocationButton.isHidden = true
        }else{
            currentLocationButton.isHidden = false
        }
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{ // if user interacted to map then only getting location address
            homeRideButtomViewModel.isRequiredToGetLocationInfoForLatLng = true
            locationFetched = true
        }else{
            homeRideButtomViewModel.isRequiredToGetLocationInfoForLatLng = false
        }
    }
}
//MARK: Get LocationUpdate
extension CreateRideHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        AppDelegate.getAppDelegate().log.debug(locations)
        locationManager.stopUpdatingLocation()
        if locationFetched {
            return
        }
        self.locationFetched = true
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16))
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        moveToCurrentLocation(location: locations.last!.coordinate,updatePrimaryRegionIfnRequired: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.debug("Location fetching failled \(error) and code: \(error._code)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            fetchLocation()
        }


    }

    private func moveToCurrentLocation(location : CLLocationCoordinate2D,updatePrimaryRegionIfnRequired :  Bool){
        AppDelegate.getAppDelegate().log.debug("moveToCurrentLocation()")

        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.CarpoolHomePage", coordinate: location) { (location,error) -> Void in

            if error != nil &&  error == QuickRideErrors.NetworkConnectionNotAvailableError{
                UIApplication.shared.keyWindow?.makeToast(Strings.DATA_CONNECTION_NOT_AVAILABLE, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                return
            }
            if location == nil || location!.shortAddress == nil{
                UIApplication.shared.keyWindow?.makeToast(Strings.location_not_found, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/3), title: nil, image: nil, completion: nil)
                return
            }
            if updatePrimaryRegionIfnRequired && location!.state != nil{
                self.checkAndUpdatePrimaryRegion(location: location!)
                self.updateRecentLocationOfUser(userPrimaryAreaInfo: UserPrimaryAreaInfo(location: location!))
            }
            self.createRideBottomViewController?.moveToCurrentLocation(location: location!)
        }
    }
    func rideStartLocationChanged(location : Location){
           AppDelegate.getAppDelegate().log.debug("rideStartLocationChanged()")
           viewMap.animate(to: GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16))
       }
    private func checkAndUpdatePrimaryRegion(location :Location){
        if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.currentUser != nil && (UserDataCache.getInstance()!.currentUser!.primaryRegion == nil || UserDataCache.getInstance()!.currentUser!.primaryRegion!.isEmpty){
            updatePrimaryRegionToDB(location: location)
        }
    }
    private func updateRecentLocationOfUser(userPrimaryAreaInfo : UserPrimaryAreaInfo){
        let lastUpdatedTime = SharedPreferenceHelper.getRecentLocationUpdatedTime()
        if lastUpdatedTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastUpdatedTime!) < 24*60{
            return
        }
        SharedPreferenceHelper.setRecentLocationUpdatedTime(time: NSDate())
        UserRestClient.updateUserRecentLocation(userId: UserDataCache.getInstance()?.currentUser?.phoneNumber, locationInfo: userPrimaryAreaInfo.toJSONString(), viewContrller: self) { (responseObject, error) in
            if responseObject == nil || (responseObject != nil && responseObject!["result"] as! String == "FAILURE"){
                SharedPreferenceHelper.setRecentLocationUpdatedTime(time: nil)// if failed to update retry again
            }
        }
    }

    private func updatePrimaryRegionToDB(location : Location){
        if location.state != nil{
            UserRestClient.updateUserPrimaryRegion(userId: UserDataCache.getInstance()!.currentUser!.phoneNumber, primaryRegion: location.state!, primaryLat: location.latitude, primaryLong: location.longitude, country: location.country, state: location.state, city: location.city, streetName: location.streetName, areaName: location.areaName, address: location.completeAddress, viewContrller: self, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.currentUser != nil && (UserDataCache.getInstance()!.currentUser!.primaryRegion == nil || UserDataCache.getInstance()!.currentUser!.primaryRegion!.isEmpty){
                        UserDataCache.getInstance()!.currentUser!.primaryAreaLat = location.latitude
                        UserDataCache.getInstance()!.currentUser!.primaryAreaLng = location.latitude
                        UserDataCache.getInstance()!.currentUser!.primaryArea = location.shortAddress
                        UserDataCache.getInstance()?.currentUser!.primaryRegion = location.state
                    }
                }
            })
        }
    }
}
extension CreateRideHomeViewController: NotificationChangeListener {
    func handleNotificationListChange() {
        handleNotificationCountAndDisplay()
    }
}
extension CreateRideHomeViewController : FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }

    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .full {
                            self.fpc.surfaceView.cornerRadius = 0.0
                            self.fpc.surfaceView.grabberHandle.isHidden = true
                            self.fpc.backdropView.isHidden = true
                            self.fpc.surfaceView.shadowHidden = true
                        }else{
                            if #available(iOS 11, *) {
                                self.fpc.surfaceView.cornerRadius = 20.0
                            } else {
                                self.fpc.surfaceView.cornerRadius = 0.0
                            }
                            self.fpc.surfaceView.grabberHandle.isHidden = false
                            self.fpc.backdropView.isHidden = false
                            self.fpc.surfaceView.shadowHidden = false
                        }
        }, completion: nil)
    }
}
class MyFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 50.0 // A top inset from safe area
            case .half: return 320.0 // A bottom inset from the safe area
            case .tip: return 319.0 // A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
        }
    }
}
