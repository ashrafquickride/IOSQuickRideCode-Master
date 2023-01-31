//
//  RegularRideCreationViewController.swift
//  Quickride
//
//  Created by Halesh on 30/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RegularRideCreationViewController: RouteViewController {
    
    @IBOutlet weak var rideTypeCollectionview: UICollectionView!
    
    override func VehicleDetailsUpdated() {
        vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        setVehicleDetails()
        createRide()

}
    
    @IBOutlet weak var seperationVew: UIView!
    
    private var createRideAsRecuringRide = false
    static var HOME_TO_OFFICE = "HOME_TO_OFFICE"
    static var OFFICE_TO_HOME = "OFFICE_TO_HOME"
    
    func initializeView(createRideAsRecuringRide: Bool,ride: Ride?) {
        self.createRideAsRecuringRide = createRideAsRecuringRide
        if createRideAsRecuringRide, let rideObj = ride{
            self.ride = rideObj
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         definesPresentationContext = true
        self.rideTypeCollectionview.dataSource = self
        self.rideTypeCollectionview.delegate = self
        self.rideTypeCollectionview.register(UINib(nibName: "RideCreationRideTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideCreationRideTypeCollectionViewCell")
        isFromRegularRideCreation = true
        if ride == nil{
            initializeViewWhenRideNotPresent()
        }
        isFromRegularRideCreation = true
        initializeDataBeforePresenting(ride: self.ride ?? Ride())
        viewMap = QRMapView.getQRMapView(mapViewContainer: MapContainerView)
        setMapViewPadding()
        viewMap.delegate = self
        viewMap.isMyLocationEnabled = false
        if createRideAsRecuringRide{
            setStartLocation()
            setEndLocation()
            self.noVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addVehicleTapped(_:))))
            let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: ride?.expectedEndTime, time2: ride?.startTime)
            let rideRoute = RideRoute(routeId: ride?.routeId ?? 0,overviewPolyline : ride?.routePathPolyline ?? "",distance :ride?.distance ?? 0,duration : Double(duration), waypoints : ride?.waypoints)
            routePaths.append(rideRoute)
            selectedRouteId = ride?.routeId ?? 0
            if ride?.rideType == UserProfile.PREFERRED_ROLE_RIDER {
                findPassengersOptionSelected()
            }else if ride?.rideType == UserProfile.PREFERRED_ROLE_PASSENGER{
                findRidersOptionSelected()
            }
        }else{
            initializeViewWhenRideNotPresent()
            initializeMatchingOptionsAsPerRecentRideType()
        }
        setUpUi()
        getTimeForWeekDay()
        setEndLocation()
        setStartLocation()
        self.noVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addVehicleTapped(_:))))
    }
    
    func initializeViewWhenRideNotPresent() {
        ride = Ride()
        if (QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus == .User) {
            let userId = QRSessionManager.getInstance()!.getUserId()
            if userId.isEmpty == false{
                ride?.userId = Double(userId)!
            }
            if Ride.RIDER_RIDE == UserDataCache.getInstance()?.getUserRecentRideType(){
                ride?.rideType = Ride.RIDER_RIDE
            }else{
                ride?.rideType = Ride.PASSENGER_RIDE
            }
        }else{
            ride?.rideType = Ride.PASSENGER_RIDE
        }
        ride?.startTime = NSDate().timeIntervalSince1970*1000
        vehicleAndNoOfSeatsBasedOnRideType()
        locationUpdateRequested = true
    }
    
    func setUpUi() {
        RideCreationParentView.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true, cornerRadius: 10.0)
        recurringRideView.isHidden = false
        if (ride?.startTime == 0 || (ride?.startTime)! < NSDate().timeIntervalSince1970*1000) && !createRideAsRecuringRide{
            ride!.startTime = NSDate().timeIntervalSince1970*1000
        }
        rideScheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: ride!.startTime/1000), format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(BaseRouteViewController.updateToCurrentTime), userInfo: nil, repeats: true)
        vehicleDetailsOrNoOfSeatsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRouteViewController.vehicleDetailsOrNoOfSeatsViewTapped(_:))))
        rideScheduleDateView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(BaseRouteViewController.selectScheduleTime(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        drawAllPossibleRoutesWithSelectedRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
     
    }
    
    @objc func addVehicleTaped(_ gesture: UITapGestureRecognizer){
           displayVehicleConfigurationDialog()
       }
        
    override func setStartLocation(){
        AppDelegate.getAppDelegate().log.debug("setStartLocation()")
        if isFromRouteOrLocationSelection{
            isRecurringRideRequiredFrom = nil
        }
        if isRecurringRideRequiredFrom == RegularRideCreationViewController.HOME_TO_OFFICE {
            if let userCache = UserDataCache.getInstance(), let homeLocation = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
                fromLocationLabel.setTitle(homeLocation.address, for: .normal)
                fromLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
                ride?.startAddress = homeLocation.address ?? ""
                ride?.startLatitude = homeLocation.latitude ?? 0.0
                ride?.startLongitude = homeLocation.longitude ?? 0.0
                 getRoutesAvailable()

            }
        } else if isRecurringRideRequiredFrom == RegularRideCreationViewController.OFFICE_TO_HOME {
            if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let officeLocation = userCache.getOfficeLocation() {
                fromLocationLabel.setTitle(officeLocation.address, for: .normal)
                fromLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
                ride?.startAddress = officeLocation.address ?? ""
                ride?.startLatitude = officeLocation.latitude ?? 0.0
                ride?.startLongitude = officeLocation.longitude ?? 0.0
                getRoutesAvailable()
            }
        } else {
            if ride?.startAddress.isEmpty == true{
                fromLocationLabel.setTitle(Strings.enter_start_location, for: .normal)
                fromLocationLabel.setTitleColor(UIColor.lightGray, for: .normal)
                
            }else{
                fromLocationLabel.setTitle(ride?.startAddress, for: .normal)
                fromLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
            }
        }
        scheduleBtnColorChange()
    }
    
    override func setEndLocation(){
        AppDelegate.getAppDelegate().log.debug("setEndLocation()")
        if isFromRouteOrLocationSelection{
            isRecurringRideRequiredFrom = nil
        }
        if isRecurringRideRequiredFrom == RegularRideCreationViewController.HOME_TO_OFFICE {
            if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let officeLocation = userCache.getOfficeLocation() {
                toLocationLabel.setTitle(officeLocation.address, for: .normal)
                toLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
                ride?.endAddress = officeLocation.address ?? ""
                ride?.endLatitude = officeLocation.latitude ?? 0.0
                ride?.endLongitude = officeLocation.longitude ?? 0.0
            }
        } else if isRecurringRideRequiredFrom ==  RegularRideCreationViewController.OFFICE_TO_HOME{
            if let userCache = UserDataCache.getInstance(), let homeLocation = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
                toLocationLabel.setTitle(homeLocation.address, for: .normal)
                toLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
                ride?.endAddress = homeLocation.address ?? ""
                ride?.endLatitude = homeLocation.latitude ?? 0.0
                ride?.endLongitude = homeLocation.longitude ?? 0.0
            }
        } else {
            if ride?.endAddress.isEmpty == true{
                toLocationLabel.setTitle(Strings.enter_end_location, for: .normal)
                toLocationLabel.setTitleColor(UIColor.lightGray, for: .normal)
            }else{
                toLocationLabel.setTitle(ride?.endAddress, for: .normal)
                toLocationLabel.setTitleColor(UIColor(netHex: 0x555555), for: .normal)
            }
        }
        scheduleBtnColorChange()
    }
    
    @IBAction func postRecurringRideTapped(_ sender: Any) {
        guard let ride = self.ride else { return }
        let currentRideRoute = getSelectedRoute()
          if Ride.RIDER_RIDE == ride.rideType {
            createRegularRiderRide(rideRoute: currentRideRoute)
        }else if Ride.PASSENGER_RIDE == ride.rideType{
            createRegularPassengerRide(rideRoute: currentRideRoute)
        }
    }
    
    private func createRegularRiderRide(rideRoute:RideRoute?){
        guard let ride = self.ride else {return}
        var regularRiderRide = RegularRiderRide(riderRide: fillAndGetRiderRideValues(ride: ride))
        regularRiderRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularRiderRide, weekdays: weekdays) as! RegularRiderRide
        regularRiderRide.fromDate = getReccuringRideStartDate()
        regularRiderRide.dayType = self.dayType
        if MyRegularRidesCache.getInstance().checkForDuplicate(regularRide: regularRiderRide){
            UIApplication.shared.keyWindow?.makeToast( Strings.ride_duplication_alert)
            return
        }
        if RecurringRideUtils().isValidDistance(ride: regularRiderRide){
            let message = String(format: Strings.ride_distance_alert, arguments: [StringUtils.getStringFromDouble(decimalNumber: MyRegularRidesCache.MAXIMUM_DISTANCE_ALLOWED_TO_CREATE_RIDE)])
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: message, message2: nil, positiveActnTitle: Strings.update_caps, negativeActionTitle: Strings.confirm_caps, linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.confirm_caps == result{
                    
                    RecurringRideUtils().continueCreatingRegularRiderRide(regularRiderRide: regularRiderRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: { (regularRide,responseError,error) in
                        self.handleRecuringRideCreationResponse(regularRide: regularRide, responseError: responseError, error: error)
                    })
                }
            })
        }
        else{
            let currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        if currentUserVehicle?.vehicleId == 0 || currentUserVehicle?.registrationNumber.isEmpty == true {
              let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
              vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: nil, listener:self)
              self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
            
        } else {
            
            RecurringRideUtils().continueCreatingRegularRiderRide(regularRiderRide: regularRiderRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: { (regularRide,responseError,error) in
                self.handleRecuringRideCreationResponse(regularRide: regularRide, responseError: responseError, error: error)
            })
        }
            
        }
    }
    
    private func createRegularPassengerRide(rideRoute: RideRoute?){
        guard let ride = self.ride else {return}
        var regularPassengerRide = RegularPassengerRide(ride: ride)
        regularPassengerRide = RecurringRideUtils().fillTimeForEachDayInWeek(regularRide: regularPassengerRide, weekdays: weekdays) as! RegularPassengerRide
        regularPassengerRide.fromDate = getReccuringRideStartDate()
        regularPassengerRide.dayType = self.dayType
        if MyRegularRidesCache.getInstance().checkForDuplicate(regularRide: regularPassengerRide){
            UIApplication.shared.keyWindow?.makeToast( Strings.ride_duplication_alert)
            return
        }
        if RecurringRideUtils().isValidDistance(ride: regularPassengerRide){
            let message = String(format: Strings.ride_distance_alert, arguments: [StringUtils.getStringFromDouble(decimalNumber: MyRegularRidesCache.MAXIMUM_DISTANCE_ALLOWED_TO_CREATE_RIDE)])
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: false, message1: message, message2: nil, positiveActnTitle: Strings.update_caps, negativeActionTitle: Strings.confirm_caps, linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.confirm_caps == result{
                    RecurringRideUtils().continueCreatingRegularPassengerRide(regularPassengerRide: regularPassengerRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: { (regularRide,responseError,error) in
                        self.handleRecuringRideCreationResponse(regularRide: regularRide, responseError: responseError, error: error)
                    })
                }
            })
        }else{
            
            RecurringRideUtils().continueCreatingRegularPassengerRide(regularPassengerRide: regularPassengerRide, viewController: self, rideRoute: rideRoute, recurringRideCreatedComplitionHandler: { (regularRide,responseError,error) in
                self.handleRecuringRideCreationResponse(regularRide: regularRide, responseError: responseError, error: error)
            })
        }
    }
    
    private func handleRecuringRideCreationResponse(regularRide : RegularRide?,responseError : ResponseError?, error: NSError?){
        if regularRide != nil{
         
            let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RecurringRideViewController") as! RecurringRideViewController
            recurringRideViewController.initializeDataBeforePresentingView(ride: regularRide!, isFromRecurringRideCreation: true)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: true)
        }else{
            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        //RegularRide creation ViewController can be call from RideCreateViewController, While moving back always should go back to myRideDeatilViewController
        self.navigationController?.popViewController(animated: false)
    }
    
    func getReccuringRideStartDate() -> Double{
        var date : NSDate?
        date = DateUtils.getNSDateFromTimeStamp(timeStamp: startTime)
        date = date!.addDays(daysToAdd: 1)
        if date!.isLessThanDate(dateToCompare: NSDate()){
            date = NSDate()
        }
        let fromDate = DateUtils.getDateStringFromNSDate(date: date, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        return DateUtils.getTimeStampFromString(dateString: fromDate, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!
    }
}


extension RegularRideCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rideTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideCreationRideTypeCollectionViewCell", for: indexPath) as! RideCreationRideTypeCollectionViewCell
        let item = rideTypes[indexPath.row]
        rideTypeCell.rideTypeLabel.text = item.name
        
        if item.selected  {
            rideTypeCell.rideTypeLabel.textColor = UIColor(netHex: 0x00B557)
            rideTypeCell.bottomSeparatorView.backgroundColor = UIColor(netHex: 0x00B557)
        }else{
            rideTypeCell.rideTypeLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            rideTypeCell.bottomSeparatorView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        return rideTypeCell
    }
}

extension RegularRideCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = rideTypes[indexPath.row]
        switch item.type {
        case Ride.RIDER_RIDE://offerPool
            findPassengersOptionSelected()
            
        default://FindPool
            findRidersOptionSelected()
        }
        collectionView.reloadData()
    }
}


extension RegularRideCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: self.rideTypeCollectionview.frame.width/2 , height: self.rideTypeCollectionview.frame.height)
    }
}
