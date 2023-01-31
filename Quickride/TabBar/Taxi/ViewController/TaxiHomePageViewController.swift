//
//  TaxiHomePageViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import CoreLocation
import FloatingPanel

class TaxiHomePageViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var MapView: UIView!
    @IBOutlet weak var pendingNotificationView: UIView!
    @IBOutlet weak var pendingNotificationCountLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!

    //MARK: Variables
    private var viewMap: GMSMapView!
    private var locationManager = CLLocationManager()
    var fpc: FloatingPanelController!
    var taxiHomePageBottomViewController: TaxiHomePageBottomViewController!
    private var taxiMarkers = [GMSMarker]()
    private var taxiHomePageViewModel = TaxiHomePageViewModel()
    var locationFetched = false

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            fpc.surfaceView.cornerRadius = 20.0
        } else {
            fpc.surfaceView.cornerRadius = 0.0
        }
        fpc.surfaceView.shadowHidden = false
        fpc.surfaceView.grabberTopPadding = 10
        taxiHomePageBottomViewController = storyboard?.instantiateViewController(withIdentifier: "TaxiHomePageBottomViewController") as? TaxiHomePageBottomViewController
        taxiHomePageBottomViewController.taxiHomePageViewModel = taxiHomePageViewModel
        fpc.set(contentViewController: taxiHomePageBottomViewController)
        fpc.track(scrollView: taxiHomePageBottomViewController.taxiHomePageCardsTableView)
        fpc.addPanel(toParent: self, animated: true)
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: MapView)
        self.viewMap.delegate = self
        checkTaxiOnbordingStatus()
    }
    
    private func getLocation() {
        
        if locationFetched {
            return
        }
        setUpMap()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        fetchLocation()
    }

    private func fetchLocation() {
        
        if let lastLocation = locationManager.location{
            updateMapLocation(lat: lastLocation.coordinate.latitude, long: lastLocation.coordinate.longitude)
            moveToCurrentLocation(location: lastLocation.coordinate)
        }else if let latlng = SharedPreferenceHelper.getLastLocation(){
            updateMapLocation(lat: latlng.latitude, long: latlng.longitude)
            moveToCurrentLocation(location: CLLocationCoordinate2D(latitude: latlng.latitude, longitude: latlng.longitude))
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
    
    @IBAction func currentlocationBtnTapped(_ sender: UIButton) {
        locationFetched = false
        fetchLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        handleNotificationCountAndDisplay()
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        ContainerTabBarViewController.indexToSelect = 0
        getLocation()
        displayUpdateApplicationIfRequired()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBehalfTaxiBookingData()
        taxiHomePageViewModel.isCheckedForBehalfBooking = false
    }

    private func setUpMap() {
        viewMap = QRMapView.getQRMapView(mapViewContainer: MapView)
        viewMap.padding = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        viewMap.animate(toZoom: 16)
        viewMap.delegate = self
        viewMap.isMyLocationEnabled = false
    }

    @objc func handleApiFailureError(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        let responseError = notification.userInfo?["responseError"] as? ResponseError
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
    }

    private func handleNotificationCountAndDisplay() {
        let pendingNotificationCount = NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0 {
            pendingNotificationView.isHidden = false
            pendingNotificationCountLabel.text = String(pendingNotificationCount)
        } else {
            pendingNotificationView.isHidden = true
        }
    }

    func rideStartLocationChanged(location: Location) {
        AppDelegate.getAppDelegate().log.debug("rideStartLocationChanged()")
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16))
        getAvailableNearbyTaxi(location: location)
    }
    private func getAvailableNearbyTaxi(location : Location){
        removeAllNearbyTaxiMarker()
        taxiHomePageViewModel.getNearbyTaxi(location: location){ (responseError, error)  in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                self.showNearbyTaxi()
            }
        }
    }

    private func checkTaxiOnbordingStatus() {
        if let status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_TAXI_ONBORDING_DETAILS), !status {
            let taxiSignupInfoVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiSignupInfoViewController") as! TaxiSignupInfoViewController

            taxiSignupInfoVC.view.frame = self.view.bounds
            taxiSignupInfoVC.willMove(toParent: self)
            self.view.addSubview(taxiSignupInfoVC.view)
            self.addChild(taxiSignupInfoVC)
            taxiSignupInfoVC.didMove(toParent: self)
        }
    }

    private func showNearbyTaxi(){
        guard let listOfNearbyTaxi = taxiHomePageViewModel.partnerRecentLocationInfo, !listOfNearbyTaxi.isEmpty else {
            return
        }
        removeAllNearbyTaxiMarker()
        for item in listOfNearbyTaxi {
            let taxiMarker = TaxiUtils.getNearbyTaxiMarkers(partnerRecentLocationInfo: item, viewMap: viewMap)
            taxiMarkers.append(taxiMarker)
        }
    }

    func removeAllNearbyTaxiMarker(){
        for item in taxiMarkers{
            item.map = nil
        }
        taxiMarkers.removeAll()
    }
    
    func clearBehalfTaxiBookingData(){
        if taxiHomePageViewModel.isRequiredToClearBehalfBookingData {
            taxiHomePageViewModel.behalfBookingPhoneNumber = nil
            taxiHomePageViewModel.behalfBookingName = nil
        }
    }

    //MARK: Actions
    
    @IBAction func notificationBtnPressed(_ sender: UIButton) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }

    @IBAction func menuButtonTapped(_ sender: Any) {
        let leftMenuViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
        leftMenuViewController.initialiseMenu(Menutype: MenuItem.TAXI_MENU)
        ViewControllerUtils.addSubView(viewControllerToDisplay: leftMenuViewController)
    }

}

//MARK: NotificationChangeListener
extension TaxiHomePageViewController: NotificationChangeListener {
    func handleNotificationListChange() {
        handleNotificationCountAndDisplay()
    }
}

//MARK: GMSMapViewDelegate
extension TaxiHomePageViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if taxiHomePageViewModel.isRequiredToGetLocationInfoForLatLng {
            moveToCurrentLocation(location: position.target)
        }
        if let location = locationManager.location, location.distance(from: CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)) < 10 {
            currentLocationButton.isHidden = true
        } else {
            currentLocationButton.isHidden = false
        }
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            taxiHomePageViewModel.isRequiredToGetLocationInfoForLatLng = true
            locationFetched = true
        } else {
            taxiHomePageViewModel.isRequiredToGetLocationInfoForLatLng = false
        }
    }
}

//MARK: Get LocationUpdate
extension TaxiHomePageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if locationFetched {
            return
        }
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        self.locationFetched = true
        updateMapLocation(lat: locValue.latitude, long: locValue.longitude)
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        moveToCurrentLocation(location: locations.last!.coordinate)
    }
    func updateMapLocation(lat: Double, long: Double){
        viewMap.animate(to: GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 16))
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

    private func moveToCurrentLocation(location: CLLocationCoordinate2D) {
        AppDelegate.getAppDelegate().log.debug("moveToCurrentLocation()")

        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.TaxiHomePage", coordinate: location) { (location, error) -> Void in

            if error != nil && error == QuickRideErrors.NetworkConnectionNotAvailableError {
                UIApplication.shared.keyWindow?.makeToast(Strings.DATA_CONNECTION_NOT_AVAILABLE, point: CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height - 300), title: nil, image: nil, completion: nil)
                return
            }
            if location == nil || location!.shortAddress == nil {
                UIApplication.shared.keyWindow?.makeToast(Strings.location_not_found, point: CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3), title: nil, image: nil, completion: nil)
                return
            }
            self.taxiHomePageBottomViewController?.moveToCurrentLocation(location: location!)
            self.getAvailableNearbyTaxi(location: location!)
        }
    }
}

//MARK: FloatingPanelControllerDelegate
extension TaxiHomePageViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let taxiFloatingPanelLayout = TaxiFloatingPanelLayout()
        return taxiFloatingPanelLayout
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
                    } else {
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

class TaxiFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full:
            return 50.0 // A top inset from safe area
        case .half:
            return 300.0 // A bottom inset from the safe area
        case .tip: return 299.5 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}
