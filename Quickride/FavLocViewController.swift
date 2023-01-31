//
//  FavLocViewController.swift
//  Quickride
//
//  Created by QuickRide on 16/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class FavLocViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, CLLocationManagerDelegate, RemoveFavouriteLocationReciever{
    
  @IBOutlet weak var iboTableView: UITableView!
  
  @IBOutlet weak var noFavLocationView: UIView!
    
  @IBOutlet weak var ibaAddFav: UIButton!
    
  // Not in WeRide
  
  @IBOutlet var favNameView: UIView!
    
  @IBOutlet weak var favoriteLocationTitle: UILabel!
    
  @IBOutlet weak var iboCurrentLocation: UILabel!
    
  @IBOutlet var rightArrow: UIImageView!
    
  // Not in Quick Ride
    
  var isExistingFavLocation = false
  var selectedLocation : Location?
  var receiveLocationDelegate : ReceiveLocationDelegate?
  var requestedLocType : String?
  var favLoc:[UserFavouriteLocation] = [UserFavouriteLocation]()
  var currentLocationRetrieved = false
  var locationManager:CLLocationManager = CLLocationManager()
  
    @objc func ibaAddFavorite(_ sender: UITapGestureRecognizer) {
    
    if isExistingFavLocation{
      UIApplication.shared.keyWindow?.makeToast( Strings.duplicate_favourite_location)
      return
    }
    let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.add_favourite_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddFavoriteLocationViewController") as! AddFavoriteLocationViewController
    addFavoriteLocationViewController.favoriteLocation.latitude = selectedLocation?.latitude
    addFavoriteLocationViewController.favoriteLocation.longitude = selectedLocation?.longitude
    addFavoriteLocationViewController.favoriteLocation.address = selectedLocation?.completeAddress
    self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
  }
  
  func initializeDataBeforePresentingView(location :Location,requestedLocType : String, receiveLocationDelegate : ReceiveLocationDelegate){
    self.selectedLocation = location
    self.receiveLocationDelegate = receiveLocationDelegate
    self.requestedLocType = requestedLocType
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ibaAddFav.isEnabled = true
    handleBrandingChanges()
    iboTableView.delegate = self
    iboTableView.dataSource = self
    getLocation()
    currentLocationRetrieved = false
    
    self.automaticallyAdjustsScrollViewInsets = false
    favNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FavLocViewController.ibaAddFavorite(_:))))
    
    // Do any additional setup after loading the view.
  }
    private func getLocation(){
        locationManager.delegate = self
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
  func handleBrandingChanges(){
    
        iboCurrentLocation.text = Strings.fav_location_not_selected
        favNameView.backgroundColor = Colors.favNameBackGroundColor
        favoriteLocationTitle.textColor = Colors.addFavouriteTextColor
        ibaAddFav.backgroundColor = Colors.mainButtonColor
    
  }
  override func viewWillAppear(_ animated: Bool)
  {
    self.initializeView()
  }
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    AppDelegate.getAppDelegate().log.debug("locationManager()")
    LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
    if currentLocationRetrieved == true{
      return
    }
    currentLocationRetrieved = true
    self.locationManager.stopUpdatingLocation()
    let coordinate = locations.last?.coordinate
    selectedLocation = Location(latitude: coordinate!.latitude, longitude: coordinate!.longitude,shortAddress: nil)
    LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.FavLocView",coordinate: coordinate!) { (location,error) -> Void in

      if error != nil{
        ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
      }else if location == nil{
        self.ibaAddFav.isEnabled = false
        UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
      }else{
        self.selectedLocation = location
        self.ibaAddFav.isEnabled = true
        self.iboCurrentLocation.text = location!.completeAddress
        
      }
    }
  }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        AppDelegate.getAppDelegate().log.debug("")

        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            getLocation()
        }
    }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if favLoc.count > 0{
        iboTableView.isHidden = false
        return favLoc.count
    }else{
        noFavLocationView.isHidden = false
        iboTableView.isHidden = true
    }
    return 0
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:FavoriteLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! FavoriteLocationTableViewCell
    if favLoc.endIndex <= indexPath.row{
        return cell
    }
    let favLocation = favLoc[indexPath.row]
    cell.iboLocationLabel.text = favLocation.name
    cell.iboLocationAddress.text = favLocation.address
    cell.menuOption.tag = indexPath.row

    if favLocation.latitude == selectedLocation?.latitude && favLocation.longitude == selectedLocation?.longitude{
        favoriteLocationTitle.text = favLocation.name!
        isExistingFavLocation = true
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    AppDelegate.getAppDelegate().log.debug("")
    let favLocation = self.favLoc[indexPath.row]
    self.editFavoriteLoaction(favoriteLocation: favLocation)
    tableView.deselectRow(at: indexPath as IndexPath, animated: false)
  }
  
    @IBAction func menuOptionTapped(_ sender: Any) {
        let favoriteLocation = self.favLoc[(sender as AnyObject).tag]
        displayalert(favoriteLocation : favoriteLocation)
    }
    func displayalert(favoriteLocation : UserFavouriteLocation)
    {
        let alertController : FavoriteLocationAlertController = FavoriteLocationAlertController(viewController: self) { (result) -> Void in
            if result == Strings.edit{
                self.editFavoriteLoaction(favoriteLocation: favoriteLocation)
            }
            else if result == Strings.remove{
               RemoveFavoriteLocationTask.removeSelectedFavoriteLocation(favoriteLocation: favoriteLocation, viewController: self, receiver: self)
            }
        }
        alertController.editAlertAction()
        alertController.removeAlertAction()
        alertController.cancelAlertAction()
        
        alertController.showAlertController()
    }
    func editFavoriteLoaction(favoriteLocation : UserFavouriteLocation){
        let favLocation = favoriteLocation
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.add_favourite_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddFavoriteLocationViewController") as! AddFavoriteLocationViewController
        addFavoriteLocationViewController.initializeDataBeforePresenting(favLocation: favLocation)
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }
    func favouriteLocationRemoved() {
        self.initializeView()
    }
    func initializeView()
    {
        if UserDataCache.getInstance()?.getFavoriteLocations() != nil{
            favLoc = (UserDataCache.getInstance()?.getFavoriteLocations())!
            if favLoc.isEmpty == true{
                noFavLocationView.isHidden = false
                iboTableView.isHidden = true
            }else{
                noFavLocationView.isHidden = true
                iboTableView.isHidden = false
                iboTableView.reloadData()
            }
        }
    }

    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
