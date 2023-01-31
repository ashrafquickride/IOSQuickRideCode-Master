//
//  SelectLocationOnMapViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 15/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class SelectLocationOnMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate,ReceiveLocationDelegate {
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet weak var LocationDetailsView: UIView!
    @IBOutlet weak var gotoCurrentLocBtn: UIButton!
    @IBOutlet weak var navBarSubtitleLbl: UILabel!
    @IBOutlet weak var navBarTitleLbl: UILabel!
    @IBOutlet weak var navBarTitleTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var viaPointInfoView: UIView!
    @IBOutlet weak var viaPointInfoViewHeightConstraint: NSLayoutConstraint!
    //MARK: TaxiPool
    @IBOutlet weak var pickupDropSelectionView: QuickRideCardView!
    @IBOutlet weak var locationTypeImageView: UIImageView!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationSelectedLabel: UILabel!
    @IBOutlet weak var choosedLocationButton: UIButton!
    @IBOutlet weak var currentLocationBottomConstraint: NSLayoutConstraint!

    weak var mapView: GMSMapView!
    var receiveLocationDelegate : ReceiveLocationDelegate?
    var locationType : String?
    var location : Location?
    var locationManager = CLLocationManager()
    var actnBtnTitle : String?
    var isFromEditRoute = false
    var dropLocation: Location?//TaxiPool
    var isPickUpLocationPicked = false
    func initializeDataBeforePresenting(receiveLocationDelegate : ReceiveLocationDelegate,location : Location?,locationType : String, actnBtnTitle : String,isFromEditRoute : Bool, dropLocation: Location?){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.receiveLocationDelegate = receiveLocationDelegate
        self.locationType = locationType
        self.location = location
        self.actnBtnTitle = actnBtnTitle
        self.isFromEditRoute = isFromEditRoute
        self.dropLocation = dropLocation
    }

    override func viewDidLoad() {
      AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        locationManager.delegate = self

        mapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        handleBrandingChanges()
        doneButton.setTitle(self.actnBtnTitle, for: .normal)
        self.mapView.delegate = self
        self.LocationDetailsView.layer.cornerRadius = 2.0
        if location == nil{
            location = Location()
            updateLocation()
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: LocationDetailsView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: LocationDetailsView, borderWidth: 1.0, color: .lightGray)

        
    }

    private func updateLocation(){
        
        locationManager.delegate = self
        if let location = locationManager.location{
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 18)
        }else if let latlng = SharedPreferenceHelper.getLastLocation(){
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: latlng.latitude, longitude: latlng.longitude))
            mapView.animate(toZoom: 18)
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

    override func viewWillAppear(_ animated: Bool) {
        if location != nil{
            let coordinate = CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
            mapView.animate(toLocation: coordinate)
            mapView.animate(toZoom: 18)
            if location!.shortAddress != nil{
                if self.dropLocation == nil {
                    self.locationNameLabel.text = location!.completeAddress
                }else{
                    if isPickUpLocationPicked {
                    self.locationSelectedLabel.text = dropLocation!.completeAddress
                    }else{
                      self.locationSelectedLabel.text = location!.completeAddress
                    }
                }
            }else{
                getLocationName(coordinate)
            }
        }

        if isFromEditRoute{
            self.navBarTitleLbl.text = Strings.add_via_point
            self.navBarSubtitleLbl.isHidden = false
            self.navBarTitleTopSpaceConstraint.constant = 7

        }else{
            self.navBarTitleLbl.text = Strings.select_location
            self.navBarSubtitleLbl.isHidden = true
            self.navBarTitleTopSpaceConstraint.constant = 15
        }
        setTaxiPoolPickDropLocationSelectionUI()
    }

    func setTaxiPoolPickDropLocationSelectionUI() {
        if dropLocation != nil {
            pickupDropSelectionView.isHidden = false
            LocationDetailsView.isHidden = true
            doneButton.isHidden = true
            self.mapView?.isMyLocationEnabled = true
            currentLocationBottomConstraint.constant = 130
            if isPickUpLocationPicked {
                locationTypeImageView.image = UIImage(named: "icon_drop_location_new")
                locationTypeLabel.text = Strings.set_drop_spot_taxi_pool
                locationTypeLabel.textColor = UIColor(netHex: 0xE20000)
                choosedLocationButton.setTitle(Strings.set_drop_button_taxi_pool, for: .normal)
            } else {
                locationTypeImageView.image = UIImage(named: "green_dot")
                locationTypeLabel.text = Strings.set_pick_up_spot_taxi_pool
                locationTypeLabel.textColor = UIColor(netHex: 0x00B557)
                choosedLocationButton.setTitle(Strings.set_pick_up_button_taxi_pool, for: .normal)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {

        if isFromEditRoute{
            viaPointInfoView.isHidden = false
            viaPointInfoViewHeightConstraint.constant = 30
            ViewCustomizationUtils.addCornerRadiusToView(view: viaPointInfoView, cornerRadius: 5.0)
            doneButton.isHidden = true
        }else{
            doneButton.isHidden = false
            viaPointInfoView.isHidden = true
            viaPointInfoViewHeightConstraint.constant = 0
        }
       CustomExtensionUtility.changeBtnColor(sender: self.doneButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
       self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool){
        self.navigationController?.isNavigationBarHidden = false
    }

    func handleBrandingChanges(){
        doneButton.backgroundColor = Colors.mainButtonColor
    }

    func getLocationName(_ position: CLLocationCoordinate2D) {
        if dropLocation != nil{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.LocationFromMapView", coordinate: position) { (location,error) -> Void in
                if location == nil{
                    UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                }else{
                    if self.dropLocation == nil {
                        self.locationNameLabel.text = location!.completeAddress
                        self.location = location
                    }else{
                        self.locationSelectedLabel.text = location!.completeAddress
                        if self.isPickUpLocationPicked {
                            self.dropLocation = location
                        }else{
                            self.location = location
                        }
                    }
                }

            }
        }
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        AppDelegate.getAppDelegate().log.debug("mapView()")
        if isPickUpLocationPicked {
            self.dropLocation?.latitude = position.target.latitude
            self.dropLocation!.longitude = position.target.longitude
        } else {
            self.location!.latitude = position.target.latitude
            self.location!.longitude = position.target.longitude
        }
        getLocationName(position.target)
        if isFromEditRoute{
            hideDoneBtnBasedOnZoomLevelOfMap(mapView: mapView)
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      AppDelegate.getAppDelegate().log.debug("locationManager()")
        locationManager.stopUpdatingLocation()
        if gotoCurrentLocBtn.isHidden {
            return
        }
      LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        if location != nil && locations.last!.distance(from: CLLocation(latitude: location!.latitude, longitude: location!.longitude)) < 20{
            return
        }
        mapView.animate(toLocation: (locations.last?.coordinate)!)
        mapView.animate(toZoom: 18)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppDelegate.getAppDelegate().log.debug(error)

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            updateLocation()
        }

    }

    @IBAction func moveToCurrentLocationAction(_ sender: Any) {
        gotoCurrentLocBtn.isHidden = false
        updateLocation()
    }


    @IBAction func selectLocationAction(_ sender: Any) {
      AppDelegate.getAppDelegate().log.debug("selectLocationAction()")
        if location!.latitude == 0 || location!.longitude == 0 || location!.completeAddress == nil || location!.completeAddress!.isEmpty == true{
            UIApplication.shared.keyWindow?.makeToast( Strings.location_not_selected)
            return
        }
        moveToChangeLocationViewController(hideSelectLocationFromMap: true)
    }
    @IBAction func ibaDone(_ sender: Any) {
        self.sendSelectedLocationDetailsToCalledViewController()
    }

    func moveToChangeLocationViewController(hideSelectLocationFromMap: Bool){
        AppDelegate.getAppDelegate().log.debug("moveToChangeLocationViewController()")

        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let changeLocationVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController")as! ChangeLocationViewController
        let currentLocation: Location?
        if isPickUpLocationPicked {
            currentLocation = dropLocation
        } else {
            currentLocation = location
        }
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType!, currentSelectedLocation: currentLocation,hideSelectLocationFromMap: hideSelectLocationFromMap, routeSelectionDelegate: nil, isFromEditRoute: false)
        self.navigationController?.pushViewController(changeLocationVC, animated: false)
    }

    func sendSelectedLocationDetailsToCalledViewController(){
        AppDelegate.getAppDelegate().log.debug("sendSelectedLocationDetailsToCalledViewController()")
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.LocationFromMapView", coordinate: mapView.camera.target) { (location,error) -> Void in
            if location?.latitude == 0 || location?.longitude == 0 || location?.shortAddress == nil || location?.shortAddress?.isEmpty == true ||
                location?.completeAddress == nil || location?.completeAddress!.isEmpty == true{
                UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
                return
            }else{
                guard let selectedLocation = location else { return }
                if let userDataCache = UserDataCache.getInstance(){
                    userDataCache.saveRecentLocations(recentLocation: UserRecentLocation(recentLocationId : "" , recentAddress : selectedLocation.completeAddress!,recentAddressName : Location.getConsolidatedNameFromFormattedAddress(name:  selectedLocation.completeAddress!), latitude : selectedLocation.latitude, longitude : selectedLocation.longitude, country: selectedLocation.country, state: selectedLocation.state, city: selectedLocation.city, areaName: selectedLocation.areaName, streetName: selectedLocation.streetName))
                }
                if self.navigationController == nil{
                    self.dismiss(animated: false, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: false)
                }
                self.receiveLocationDelegate?.receiveSelectedLocation(location: selectedLocation, requestLocationType: self.locationType!)
                self.locationNameLabel.text = location!.completeAddress
                self.location = location
            }
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
       self.navigationController?.popViewController(animated: false)
    }

    override func didReceiveMemoryWarning() {
      AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
        super.didReceiveMemoryWarning()
    }

    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        self.location = location
    }

    func locationSelectionCancelled(requestLocationType: String) {

    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            gotoCurrentLocBtn.isHidden = false
        }else{
            gotoCurrentLocBtn.isHidden = true
        }
    }

    func hideDoneBtnBasedOnZoomLevelOfMap(mapView : GMSMapView){
        if mapView.camera.zoom >= 18{
            doneButton.isHidden = false
            viaPointInfoView.isHidden = true
            viaPointInfoViewHeightConstraint.constant = 0
        }
        else{
            doneButton.isHidden = true
            viaPointInfoView.isHidden = false
            viaPointInfoViewHeightConstraint.constant = 25
        }
    }
    //MARK: Pickup drop location confirm TaxiPool
    @IBAction func locationSelectedBtnPressed(_ sender: UIButton) {
        if isPickUpLocationPicked {//call delegate
            self.navigationController?.popViewController(animated: false)
            self.receiveLocationDelegate?.receivePickUPAndDropLocation(pickUpLocation: location!, dropLocation: dropLocation!, requestLocationType: self.locationType!)
        } else {
            isPickUpLocationPicked = true
            setTaxiPoolPickDropLocationSelectionUI()
            setPickUpLocation()
        }
    }

    private func setPickUpLocation() {
        if dropLocation != nil{
            let coordinate = CLLocationCoordinate2D(latitude: (dropLocation?.latitude)!, longitude: (dropLocation?.longitude)!)
            mapView.animate(toLocation: coordinate)
            mapView.animate(toZoom: 18)
            if dropLocation!.shortAddress != nil{
                self.locationSelectedLabel.text = dropLocation!.completeAddress
            }
        }
    }
}
