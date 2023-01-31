//
//  RideCreateViewModel.swift
//  Quickride
//
//  Created by Admin on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
import ObjectMapper

protocol RideCreateViewModelDelegate {
    func startCreateRideButtonAnimation()
    func stopCreateRideButtonAnimation()
}


class RideCreateViewModel{
    
    var locationManager = CLLocationManager()
    var homeLocation,officeLocation : UserFavouriteLocation?
    var homeStartTime : Double?
    var officeStartTime : Double?
    var weekdaysTimeForHomeToOffice = [Int : String?]()
    var weekdaysTimeForOfficeToHome = [Int : String?]()
    var homeToOfficeRegularRidesCreated = false
    var officeToHomeRegularRidesCreated = false
    var responseError : ResponseError?
    var error : NSError?
    var delegate : RideCreateViewModelDelegate?
    var numberOfUsersAtHomeLocation: Double?
    var numberOfUsersAtOfficeLocation: Double?
    var isFromSignUpFlow = true
    
    init(isFromSignUpFlow: Bool) {
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    init() {
    }
    
    func fetchLocationFromLatLng(handler : @escaping LocationNameCompletionHandler){
        let location = locationManager.location
        
        if location == nil{
            UIApplication.shared.keyWindow?.makeToast( Strings.enable_location_service)
            return
        }
        
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.RideCreationView", coordinate: location!.coordinate, handler: handler)
    }
    
    func enableLocationService(delegate : CLLocationManagerDelegate){
        locationManager.delegate = delegate
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
    
    func checkTagAndUpdateLocation(tag : Int,location : Location?){
        if tag == 1{
            updateHomeLocation(location: location)
        }else{
            updateOfficeLocation(location: location)
        }
    }
    func updateOfficeLocation(location : Location?){
        let userProfile = UserDataCache.getInstance()?.userProfile
        self.officeLocation = UserFavouriteLocation()
        self.officeLocation?.address = location!.completeAddress
        self.officeLocation?.shortAddress = location!.shortAddress
        self.officeLocation?.latitude = location!.latitude
        self.officeLocation?.longitude = location!.longitude
        self.officeLocation?.city = location!.city
        self.officeLocation?.country = location!.country
        self.officeLocation?.state = location!.state
        self.officeLocation?.areaName = location!.areaName
        self.officeLocation?.streetName = location!.streetName
        self.officeLocation?.phoneNumber = userProfile?.userId
        self.officeLocation?.name = UserFavouriteLocation.OFFICE_FAVOURITE
        
    }
    
    func updateHomeLocation(location : Location?){
        let userProfile = UserDataCache.getInstance()?.userProfile
        self.homeLocation = UserFavouriteLocation()
        self.homeLocation?.address = location!.completeAddress
        self.homeLocation?.shortAddress = location!.shortAddress
        self.homeLocation?.latitude = location!.latitude
        self.homeLocation?.longitude = location!.longitude
        self.homeLocation?.city = location!.city
        self.homeLocation?.country = location!.country
        self.homeLocation?.state = location!.state
        self.homeLocation?.areaName = location!.areaName
        self.homeLocation?.streetName = location!.streetName
        self.homeLocation?.phoneNumber = userProfile?.userId
        self.homeLocation?.name = UserFavouriteLocation.HOME_FAVOURITE
        self.updatePrimaryRegionAfterFetchingLocFromGoogle(location: location!)
    }
    
    func updatePrimaryRegionAfterFetchingLocFromGoogle(location :Location){
        if let userObj = UserDataCache.getInstance()?.currentUser{
            if userObj.primaryRegion == nil || userObj.primaryRegion!.isEmpty{
                updatePrimaryRegionToDB(location: location, userObj: userObj)
            }
        }
    }
    
    func updatePrimaryRegionToDB(location : Location,userObj: User){
        UserRestClient.updateUserPrimaryRegion(userId: userObj.phoneNumber, primaryRegion: location.state, primaryLat: location.latitude, primaryLong: location.longitude, country: location.country, state: location.state, city: location.city, streetName: location.streetName, areaName: location.areaName, address: location.completeAddress, viewContrller: nil, responseHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                userObj.primaryAreaLat = location.latitude
                userObj.primaryAreaLng = location.longitude
                userObj.primaryArea = location.shortAddress
                userObj.primaryRegion = location.state
                SharedPreferenceHelper.storeUserObject(userObj: userObj)
            }
        })
        
    }
    
    func saveFavouriteLocation(location : UserFavouriteLocation,locationName : String,viewController : UIViewController,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        
        UserRestClient.createUserFavouriteLocation(userFavouriteLocation: location, viewController: viewController, completionHandler: handler)
        
    }
    
    func createUserFavouriteRoutes(homeLocation : UserFavouriteLocation,officeLocation : UserFavouriteLocation){
        let userFavouriteRouteAsyncTask = UserFavouriteRouteTask(homeLocation: homeLocation, officeLocation: officeLocation)
        userFavouriteRouteAsyncTask.getRoutesBetweenHomeAndOfficeLocation()
    }
    
    func getUserFavouriteLocation(responseObject : NSDictionary?) -> UserFavouriteLocation?{
        return Mapper<UserFavouriteLocation>().map(JSONObject: responseObject?["resultData"])
        
    }
    
    func createRegularRide(homeToOfficeRoute: RideRoute?, officeToHomeRoute: RideRoute?,viewController : UIViewController,handler : @escaping (_ responseError : ResponseError?,_ error : NSError?) -> Void){
        if SharedPreferenceHelper.getUserPreferredRole() == UserProfile.PREFERRED_ROLE_RIDER{
            createRegularRiderRide(homeToOfficeRoute: homeToOfficeRoute, officeToHomeRoute: officeToHomeRoute, viewController: viewController, handler: handler)
        }else{
            createRegularPassengerRide(homeToOfficeRoute: homeToOfficeRoute, officeToHomeRoute: officeToHomeRoute, viewController: viewController, handler: handler)
        }
    }
    
    private func createRegularRiderRide(homeToOfficeRoute: RideRoute?, officeToHomeRoute: RideRoute?,viewController : UIViewController,handler : @escaping (_ responseError : ResponseError?,_ error : NSError?) -> Void){
        delegate?.startCreateRideButtonAnimation()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            if !self.homeToOfficeRegularRidesCreated && self.homeLocation!.leavingTime != nil
            {
                let regularRiderRide = RegularRiderRide(userId: Double(QRSessionManager.getInstance()!.getUserId())!, userName: UserDataCache.getInstance()!.getUserName(), startAddress : self.homeLocation!.address!, startLatitude : self.homeLocation!.latitude!, startLongitude : self.homeLocation!.longitude!, endAddress : self.officeLocation!.address!, endLatitude: self.officeLocation!.latitude!, endLongitude : self.officeLocation!.longitude!, dayType : Ride.ALL_DAYS, startTime  : self.homeLocation!.leavingTime!, fromDate : self.homeLocation!.leavingTime!, toDate : nil, sunday : self.weekdaysTimeForHomeToOffice[6] ?? nil, monday :  self.weekdaysTimeForHomeToOffice[0] ?? nil, tuesday : self.weekdaysTimeForHomeToOffice[1] ?? nil, wednesday :  self.weekdaysTimeForHomeToOffice[2] ?? nil, thursday : self.weekdaysTimeForHomeToOffice[3] ?? nil, friday :  self.weekdaysTimeForHomeToOffice[4] ?? nil, saturday : self.weekdaysTimeForHomeToOffice[5] ?? nil, vehicle: UserDataCache.getInstance()!.getCurrentUserVehicle() )
                
                self.createRegularRiderRide(regularRiderRide: regularRiderRide, rideRoute: homeToOfficeRoute, viewController: viewController, handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide)  in
                    
                    if responseError == nil && error == nil{
                        self.homeToOfficeRegularRidesCreated = true
                        self.responseError = nil
                        self.error = nil
                    }else{
                        self.responseError = responseError
                        self.error = error
                    }
                    group.leave()
                })
            }else{
                group.leave()
            }
        }
        group.enter()
        queue.async(group: group) {
            if !self.officeToHomeRegularRidesCreated && self.officeLocation!.leavingTime != nil
            {
                let returnRegularRiderRide = RegularRiderRide(userId: Double(QRSessionManager.getInstance()!.getUserId())!, userName: UserDataCache.getInstance()!.getUserName(), startAddress : self.officeLocation!.address!, startLatitude : self.officeLocation!.latitude!, startLongitude : self.officeLocation!.longitude!, endAddress : self.homeLocation!.address!, endLatitude: self.homeLocation!.latitude!, endLongitude : self.homeLocation!.longitude!, dayType : Ride.ALL_DAYS, startTime  : self.officeLocation!.leavingTime!, fromDate : self.officeLocation!.leavingTime!, toDate : nil, sunday : self.weekdaysTimeForOfficeToHome[6] ?? nil, monday : self.weekdaysTimeForOfficeToHome[0] ?? nil, tuesday : self.weekdaysTimeForOfficeToHome[1] ?? nil, wednesday : self.weekdaysTimeForOfficeToHome[2] ?? nil, thursday : self.weekdaysTimeForOfficeToHome[3] ?? nil, friday : self.weekdaysTimeForOfficeToHome[4] ?? nil, saturday : self.weekdaysTimeForOfficeToHome[5] ?? nil, vehicle : UserDataCache.getInstance()!.getCurrentUserVehicle())
                self.createRegularRiderRide(regularRiderRide: returnRegularRiderRide, rideRoute:
                    officeToHomeRoute, viewController: viewController, handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide) in
                        
                        if responseError == nil && error == nil{
                            self.officeToHomeRegularRidesCreated = true
                            self.responseError = nil
                            self.error = nil
                        }else{
                            self.responseError = responseError
                            self.error = error
                        }
                        group.leave()
                })
            }else{
                group.leave()
            }
        }
        group.notify(queue: queue) { [weak self] in
            self?.delegate?.stopCreateRideButtonAnimation()
            if self?.responseError != nil || self?.error != nil {
                handler(self?.responseError,self?.error)
            }else{
                self?.moveToAddProfilePictureScreen(viewController: viewController)
            }
         }
    }
    
    private func createRegularRiderRide(regularRiderRide : RegularRiderRide, rideRoute : RideRoute?,viewController : UIViewController,handler : @escaping regularRideCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("")
        let createRegularRiderRideTask : CreateRegularRiderRideTask = CreateRegularRiderRideTask(regularriderRide: regularRiderRide, riderRideId: regularRiderRide.rideId, viewController: viewController,rideRoute: rideRoute, isFromSignUpFlow: true)
        createRegularRiderRideTask.createRegularRiderRide(handler: handler)
    }
    
    private func createRegularPassengerRide(homeToOfficeRoute: RideRoute?, officeToHomeRoute: RideRoute?,viewController : UIViewController,handler : @escaping (_ responseError : ResponseError?,_ error : NSError?) -> Void){
        delegate?.startCreateRideButtonAnimation()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            if !self.homeToOfficeRegularRidesCreated && self.homeLocation!.leavingTime != nil
            {
                
                let regularPassengerRide = RegularPassengerRide(userId: Double(QRSessionManager.getInstance()!.getUserId())!, userName: UserDataCache.getInstance()!.getUserName(), startAddress : self.homeLocation!.address!, startLatitude : self.homeLocation!.latitude!, startLongitude : self.homeLocation!.longitude!, endAddress : self.officeLocation!.address!, endLatitude: self.officeLocation!.latitude!, endLongitude : self.officeLocation!.longitude!, dayType : Ride.ALL_DAYS, startTime  : self.homeLocation!.leavingTime!, fromDate : self.homeLocation!.leavingTime!, toDate : nil, sunday : self.weekdaysTimeForHomeToOffice[6] ?? nil, monday : self.weekdaysTimeForHomeToOffice[0] ?? nil, tuesday : self.weekdaysTimeForHomeToOffice[1] ?? nil, wednesday : self.weekdaysTimeForHomeToOffice[2] ?? nil, thursday : self.weekdaysTimeForHomeToOffice[3] ?? nil, friday : self.weekdaysTimeForHomeToOffice[4] ?? nil, saturday : self.weekdaysTimeForHomeToOffice[5] ?? nil)
                self.createRegularPassengerRide(regularPassengerRide: regularPassengerRide, rideRoute: homeToOfficeRoute, viewController: viewController, handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide) in
                    if responseError == nil && error == nil{
                        self.homeToOfficeRegularRidesCreated = true
                        self.responseError = nil
                        self.error = nil
                    }else{
                        self.responseError = responseError
                        self.error = error
                    }
                    group.leave()
                })
            }else{
                group.leave()
            }
        }
        group.enter()
        queue.async(group: group) {
            if !self.officeToHomeRegularRidesCreated && self.officeLocation!.leavingTime != nil
            {
                let returnRegularPassengerRide = RegularPassengerRide(userId: Double(QRSessionManager.getInstance()!.getUserId())!, userName: UserDataCache.getInstance()!.getUserName(), startAddress : self.officeLocation!.address!, startLatitude : self.officeLocation!.latitude!, startLongitude : self.officeLocation!.longitude!, endAddress : self.homeLocation!.address!, endLatitude: self.homeLocation!.latitude!, endLongitude : self.homeLocation!.longitude!, dayType : Ride.ALL_DAYS, startTime  : self.officeLocation!.leavingTime!, fromDate : self.officeLocation!.leavingTime!, toDate : nil, sunday : self.weekdaysTimeForOfficeToHome[6] ?? nil, monday : self.weekdaysTimeForOfficeToHome[0] ?? nil, tuesday : self.weekdaysTimeForOfficeToHome[1] ?? nil, wednesday : self.weekdaysTimeForOfficeToHome[2] ?? nil, thursday : self.weekdaysTimeForOfficeToHome[3] ?? nil, friday : self.weekdaysTimeForOfficeToHome[4] ?? nil, saturday : self.weekdaysTimeForOfficeToHome[5] ?? nil)
                self.createRegularPassengerRide(regularPassengerRide: returnRegularPassengerRide, rideRoute: officeToHomeRoute, viewController: viewController, handler: { (responseError,error,newRegularRiderRide,newRegularPassengerRide) in
                    if responseError == nil && error == nil{
                        self.officeToHomeRegularRidesCreated = true
                        self.responseError = nil
                        self.error = nil
                    }else{
                        self.responseError = responseError
                        self.error = error
                    }
                    group.leave()
                })
            }else{
                group.leave()
            }
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.delegate?.stopCreateRideButtonAnimation()
            if self?.responseError != nil || self?.error != nil{
              handler(self?.responseError,self?.error)
            }
            else{
                self?.moveToAddProfilePictureScreen(viewController: viewController)
            }
        }
    }
    
    private func createRegularPassengerRide(regularPassengerRide : RegularPassengerRide, rideRoute : RideRoute?,viewController : UIViewController,handler : @escaping regularRideCompletionHandler){
          AppDelegate.getAppDelegate().log.debug("")
          let createRegularPassengerRideTask : CreateRegularPassengerRideTask = CreateRegularPassengerRideTask(regularPassengerRide: regularPassengerRide, passengerRideId: regularPassengerRide.rideId, viewController: viewController,rideRoute: rideRoute, isFromSignUpFlow: true)
          createRegularPassengerRideTask.createRegularPassengerRide(handler: handler)
    }
    
    
    func createRide(viewController : UIViewController){
        
        if var homeLeavingTime = homeLocation?.leavingTime,var officeLeavingTime = officeLocation?.leavingTime{
            if homeLeavingTime < NSDate().timeIntervalSince1970*1000 && officeLeavingTime >= NSDate().timeIntervalSince1970*1000{
                homeLeavingTime = DateUtils.addMinutesToTimeStamp(time: homeLeavingTime, minutesToAdd: 24*60)
            }else if officeLeavingTime < NSDate().timeIntervalSince1970*1000{
                homeLeavingTime = DateUtils.addMinutesToTimeStamp(time: homeLeavingTime, minutesToAdd: 24*60)
                officeLeavingTime = DateUtils.addMinutesToTimeStamp(time: officeLeavingTime, minutesToAdd: 24*60)
            }
            
            checkWhetherSpecifiedDateIsWeekendAndCreateRides(homeLeavingTime: homeLeavingTime, officeLeavingTime: officeLeavingTime, viewController: viewController)
        }
    }
    
    private func checkWhetherSpecifiedDateIsWeekendAndCreateRides(homeLeavingTime : Double,officeLeavingTime : Double,viewController : UIViewController) {
        let startDay = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: homeLeavingTime/1000), format: DateUtils.DATE_FORMAT_EE)
        var newHomeLeavingTime = homeLeavingTime
        if startDay == "Sat"{
            newHomeLeavingTime = DateUtils.addMinutesToTimeStamp(time: newHomeLeavingTime, minutesToAdd: 48*60)
        }else if startDay == "Sun"{
            newHomeLeavingTime = DateUtils.addMinutesToTimeStamp(time: newHomeLeavingTime, minutesToAdd: 24*60)
        }
        
        let returnDay = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: homeLeavingTime/1000), format: DateUtils.DATE_FORMAT_EE)
        var newOfficeLeavingTime = officeLeavingTime
        if returnDay == "Sat"{
            newOfficeLeavingTime = DateUtils.addMinutesToTimeStamp(time: newOfficeLeavingTime, minutesToAdd: 48*60)
        }else if returnDay == "Sun"{
            newOfficeLeavingTime = DateUtils.addMinutesToTimeStamp(time: newOfficeLeavingTime, minutesToAdd: 24*60)
        }
        
        createTwoRides(homeLeavingTime: newHomeLeavingTime, officeLeavingTime: newOfficeLeavingTime, viewController: viewController)
    }
    
    private func createTwoRides(homeLeavingTime: Double, officeLeavingTime: Double, viewController: UIViewController){
        if UserDataCache.getInstance()?.userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
            createTwoRiderRides(homeLeavingTime: homeLeavingTime, officeLeavingTime: officeLeavingTime, viewController: viewController)
        }else{
            createTwoPassengerRides(homeLeavingTime: homeLeavingTime, officeLeavingTime: officeLeavingTime, viewController: viewController)
        }
    }
    
    private func createRiderRide(viewController : UIViewController,startTime : Double,group : DispatchGroup,isHomeToOfficeRide : Bool){
        let ride = Ride()
        if let userId = QRSessionManager.getInstance()?.getUserId(){
           ride.userId = Double(userId)!
        }
        ride.rideType = Ride.RIDER_RIDE
        ride.startTime = startTime
        if isHomeToOfficeRide{
            
            if let startAddress = homeLocation?.address{
                ride.startAddress = startAddress
            }
            if let startLatitude = homeLocation?.latitude{
                ride.startLatitude = startLatitude
            }
            if let startLongitude = homeLocation?.longitude{
                ride.startLongitude = startLongitude
            }
            if let endLatitude = officeLocation?.latitude{
                ride.endLatitude = endLatitude
            }
            if let endLongitude = officeLocation?.longitude{
                ride.endLongitude = endLongitude
            }
            if let endAddress = officeLocation?.address{
                ride.endAddress = endAddress
            }
        }else{
            if let startAddress = officeLocation?.address{
                ride.startAddress = startAddress
            }
            if let startLatitude = officeLocation?.latitude{
                ride.startLatitude = startLatitude
            }
            if let startLongitude = officeLocation?.longitude{
                ride.startLongitude = startLongitude
            }
            if let endLatitude = homeLocation?.latitude{
                ride.endLatitude = endLatitude
            }
            if let endLongitude = homeLocation?.longitude{
                ride.endLongitude = endLongitude
            }
            if let endAddress = homeLocation?.address{
                ride.endAddress = endAddress
            }
        }
        let riderRide = RiderRide(ride: ride)
        if let vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle(){
            riderRide.availableSeats = vehicle.capacity
            riderRide.capacity = vehicle.capacity
            riderRide.vehicleModel = vehicle.vehicleModel
            riderRide.vehicleType = vehicle.vehicleType
            riderRide.vehicleNumber = vehicle.registrationNumber
            riderRide.farePerKm = vehicle.fare
            riderRide.additionalFacilities = vehicle.additionalFacilities
            riderRide.makeAndCategory = vehicle.makeAndCategory
            riderRide.vehicleId = vehicle.vehicleId
            riderRide.vehicleImageURI = vehicle.imageURI
            riderRide.riderHasHelmet = vehicle.riderHasHelmet
        }
        
        let createRiderRideHandler : CreateRiderRideHandler = CreateRiderRideHandler(ride: riderRide,rideRoute : nil, isFromInviteByContact: false, targetViewController: viewController)
               createRiderRideHandler.createRiderRide(handler: { (riderRide, error) -> Void in
                   if error != nil{
                       self.responseError = error
                   }
                group.leave()
        })

    }
    
    private func createTwoRiderRides(homeLeavingTime : Double,officeLeavingTime : Double,viewController : UIViewController){
        delegate?.startCreateRideButtonAnimation()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group){
            self.createRiderRide(viewController: viewController, startTime: homeLeavingTime, group: group, isHomeToOfficeRide: true)
        }
        group.enter()
        queue.async(group: group){
            self.createRiderRide(viewController: viewController, startTime: officeLeavingTime, group: group, isHomeToOfficeRide: false)
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.delegate?.stopCreateRideButtonAnimation()
            if self?.responseError == nil{
                self?.moveToAddProfilePictureScreen(viewController: viewController)
            }else{
                if let responseError = self?.responseError{
                   MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: viewController, handler: nil)
                }
                
            }
        }
    }
    
    
    private func createPassengerRide(viewController : UIViewController,startTime : Double,group : DispatchGroup,isHomeToOfficeRide : Bool){
        let ride = Ride()
        if let userId = QRSessionManager.getInstance()?.getUserId(){
           ride.userId = Double(userId)!
        }
        ride.rideType = Ride.PASSENGER_RIDE
        ride.startTime = startTime
        if isHomeToOfficeRide{
            
            if let startAddress = homeLocation?.address{
                ride.startAddress = startAddress
            }
            if let startLatitude = homeLocation?.latitude{
                ride.startLatitude = startLatitude
            }
            if let startLongitude = homeLocation?.longitude{
                ride.startLongitude = startLongitude
            }
            if let endLatitude = officeLocation?.latitude{
                ride.endLatitude = endLatitude
            }
            if let endLongitude = officeLocation?.longitude{
                ride.endLongitude = endLongitude
            }
            if let endAddress = officeLocation?.address{
                ride.endAddress = endAddress
            }
        }else{
            if let startAddress = officeLocation?.address{
                ride.startAddress = startAddress
            }
            if let startLatitude = officeLocation?.latitude{
                ride.startLatitude = startLatitude
            }
            if let startLongitude = officeLocation?.longitude{
                ride.startLongitude = startLongitude
            }
            if let endLatitude = homeLocation?.latitude{
                ride.endLatitude = endLatitude
            }
            if let endLongitude = homeLocation?.longitude{
                ride.endLongitude = endLongitude
            }
            if let endAddress = homeLocation?.address{
                ride.endAddress = endAddress
            }
        }
        
        let passengerRide = PassengerRide(ride: ride)
        let createPassengerRideHandler : CreatePassengerRideHandler = CreatePassengerRideHandler(ride: passengerRide,rideRoute: nil, isFromInviteByContact: false, targetViewController: viewController, parentRideId: nil,relayLegSeq: nil)
        createPassengerRideHandler.createPassengerRide(handler: { (passengerRide, error) -> Void in
            if error != nil{
                self.responseError = error
            }
            group.leave()
        })
    }
    
    private func createTwoPassengerRides(homeLeavingTime : Double,officeLeavingTime : Double,viewController : UIViewController){
        delegate?.startCreateRideButtonAnimation()
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group){
            self.createPassengerRide(viewController: viewController, startTime: homeLeavingTime, group: group, isHomeToOfficeRide: true)
        }
        group.enter()
        queue.async(group: group){
            self.createPassengerRide(viewController: viewController, startTime: officeLeavingTime, group: group, isHomeToOfficeRide: false)
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.delegate?.stopCreateRideButtonAnimation()
            if self?.responseError == nil{
                self?.moveToAddProfilePictureScreen(viewController: viewController)
            }else{
                if let responseError = self?.responseError{
                  MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: viewController, handler: nil)
                }
            }
        }
    }
    
    private func moveToAddProfilePictureScreen(viewController: UIViewController){
        let addProfilePictureViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProfilePictureViewController") as! AddProfilePictureViewController
        viewController.navigationController?.pushViewController(addProfilePictureViewController, animated: true)
        viewController.navigationController?.viewControllers.remove(at: (viewController.navigationController?.viewControllers.count ?? 0) - 2)
    }
    
    func getNumberOfUsersAtStartAndEndLocation(startLatitude: Double, startLongitude: Double, endLatitude: Double,endLongitude: Double, rideType: String?, complition: @escaping(_ result: Bool)->()){
        if startLatitude > 0 && startLongitude > 0{
            RouteMatcherServiceClient.getNumberOfUsersAtLocation(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: 0, endLongitude: 0, rideType: SharedPreferenceHelper.getUserPreferredRole()) {(responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.numberOfUsersAtHomeLocation = responseObject?["resultData"] as? Double
                    complition(true)
                }
            }
        }
        if endLatitude > 0 && endLongitude > 0 {
            RouteMatcherServiceClient.getNumberOfUsersAtLocation(startLatitude: 0, startLongitude: 0, endLatitude: endLatitude, endLongitude: endLongitude, rideType: SharedPreferenceHelper.getUserPreferredRole()) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.numberOfUsersAtOfficeLocation = responseObject?["resultData"] as? Double
                    complition(true)
                }
            }
        }
    }
}
