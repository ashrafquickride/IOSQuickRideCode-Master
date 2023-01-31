
//
//  RouteViewcontroller.swift
//  Quickride
//
//  Created by KNM Rao on 24/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import GoogleMaps
import CoreLocation
import Lottie
import ObjectMapper

class RouteViewController: BaseRouteViewController{
    
   
    
    @IBOutlet weak var vehicleDetailsOrNoOfSeatsLabel: UILabel!
    
    @IBOutlet weak var vehicleFareLabel: UILabel!
    
    @IBOutlet weak var vehicleCapacityLabel: UILabel!
        
    @IBOutlet var rideVehicleModelIcon: UIImageView!
    
    var isFromRegularRideCreation = false
    private var isServicePopUpShown = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpUI()
    }
    private func setUpUI() {
        scheduleRideButton.backgroundColor = Colors.mainButtonColor
        createRecurringRideSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        checkRecurringRideEnableAndDisableStatus()
        vehicleDetailsOrNoOfSeatsView.isUserInteractionEnabled = true
        vehicleDetailsOrNoOfSeatsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRouteViewController.vehicleDetailsOrNoOfSeatsViewTapped(_:))))
        self.noVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addVehicleTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: scheduleRideButton, cornerRadius: 25.0)
    }
    override func initializeMatchingOptionsAsPerRecentRideType(){
        if Ride.RIDER_RIDE == ride!.rideType{
            findPassengersOptionSelected()
        }else{
            findRidersOptionSelected()
        }
    }
    
     func findPassengersOptionSelected() {//offerPool
        if isFromRegularRideCreation{
            scheduleRideButton.setTitle(Strings.repeat_regular.uppercased(), for: .normal)
        }else{
            scheduleRideButton.setTitle(Strings.offer_pool.uppercased(), for: .normal)
        }
        handleRideTypeViewComponents()
        findPassengersSelected()
        for index in 0..<rideTypes.count {
            rideTypes[index].selected = rideTypes[index].type == Ride.RIDER_RIDE ? true : false
        }
    }
    
     func findRidersOptionSelected() {//findpool
        if isFromRegularRideCreation{
            scheduleRideButton.setTitle(Strings.repeat_regular.uppercased(), for: .normal)
        }else{
            scheduleRideButton.setTitle(Strings.find_pool.uppercased(), for: .normal)
        }
        handleRideTypeViewComponents()
        findRidersSelected()
        for index in 0..<rideTypes.count {
            rideTypes[index].selected = rideTypes[index].type == Ride.PASSENGER_RIDE ? true : false
        }
    }
    
    @objc func addVehicleTapped(_ gesture: UITapGestureRecognizer){
           displayVehicleConfigurationDialog()
       }

    
    
    override func setVehicleModelText(vehicleModel : String, vehicleCapacity: String, vehicleFare: String, image : UIImage){
        vehicleDetailsOrNoOfSeatsLabel.text = vehicleModel
        vehicleFareLabel.text = vehicleFare
        vehicleCapacityLabel.text = vehicleCapacity
        rideVehicleModelIcon.image = image
    }
    override func numberSelected(number : Int) {
        super.numberSelected(number: number)
        rideVehicleModelIcon.image = UIImage(named: "seat_icon_small")
        vehicleDetailsOrNoOfSeatsLabel.text = "\(number) \(Strings.seat_s)"
        vehicleFareLabel.text = ""
        vehicleCapacityLabel.text = ""
    }
    override func prepareStartAndEndMarkers(){
        startMarker?.map = nil
        startMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude:ride!.startLatitude,longitude : ride!.startLongitude), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        startMarker?.zIndex = 12
        endMaker?.map = nil
        endMaker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude:ride!.endLatitude!,longitude : ride!.endLongitude!), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        endMaker?.zIndex = 12
    }
    override func setStartLocation(){
        AppDelegate.getAppDelegate().log.debug("setStartLocation()")
        if ride!.startAddress.isEmpty == true{
            fromLocationLabel.setTitle(Strings.enter_start_location, for: .normal)
            fromLocationLabel.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }else{
            fromLocationLabel.setTitle(ride!.startAddress, for: .normal)
            fromLocationLabel.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        }
        showRecurringRideView()
        scheduleBtnColorChange()
    }
    override func setEndLocation(){
        AppDelegate.getAppDelegate().log.debug("setEndLocation()")
        if ride!.endAddress.isEmpty == true{
            toLocationLabel.setTitle(Strings.enter_end_location, for: .normal)
            toLocationLabel.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }else{
            toLocationLabel.setTitle(ride!.endAddress, for: .normal)
            toLocationLabel.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        }
        showRecurringRideView()
        scheduleBtnColorChange()
    }
    
    
    
    
    @IBAction func allowRecurringRide(_ sender: UISwitch) {
        if sender.isOn{
            getTimeForWeekDay()
            recurringRideDaysButton.setTitle(prepareStringForRecurringRideBasedOnDays(), for: .normal)
        }else{
            recurringRideDaysButton.setTitle(Strings.create_rec_ride, for: .normal)
            SharedPreferenceHelper.setRecurringStatusFromBaseRide(status: true)
        }
    }
    
    @IBAction func ShowDaysTapped(_ sender: Any){
        ride?.startTime = startTime ?? ride!.startTime
        guard let rideObj = ride else { return }
        let recurringRideSettingsViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RecurringRideSettingsViewController") as! RecurringRideSettingsViewController
        recurringRideSettingsViewController.initailizeRecurringRideSettingView(ride: rideObj,dayType: dayType, weekdays: weekdays,editWeekDaysTimeCompletionHandler: { (weekdays,dayType,startTime) in
            self.weekdays = weekdays
            self.dayType = dayType
            self.startTime = startTime
            if self.isFromRegularRideCreation{
                let date = DateUtils.getNSDateFromTimeStamp(timeStamp: startTime)
                self.rideScheduleTimeLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: date!, format: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
            }
            if dayType == Ride.ODD_DAYS{
                self.recurringRideDaysButton.setTitle(Strings.recurring_ride_odd, for: .normal)
            }else if dayType == Ride.EVEN_DAYS{
                self.recurringRideDaysButton.setTitle(Strings.recurring_ride_even, for: .normal)
            }else{
                self.recurringRideDaysButton.setTitle(self.prepareStringForRecurringRideBasedOnDays(), for: .normal)
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: recurringRideSettingsViewController)
    }
    private func showRecurringRideView() {
        
        if ride?.startAddress.isEmpty == false && ride?.endAddress.isEmpty == false && checkCurrentRideIsValidForRecurringRide(ride: ride!){
            recurringRideView.isHidden = false
            recurringRideViewHeightConstraint.constant = 40
            createRecurringRideSwitch.setOn(false, animated: false)
            recurringRideDaysButton.setTitle(Strings.create_rec_ride, for: .normal)
//            let activeRides = MyRegularRidesCache.getInstance().getActiveRegularRiderRides().count + MyRegularRidesCache.getInstance().getActiveRegularPassengerRides().count
//            if activeRides >= 2{
//                createRecurringRideSwitch.setOn(false, animated: false)
//                recurringRideDaysButton.setTitle(Strings.create_rec_ride, for: .normal)
//            }else{
//                getTimeForWeekDay()
//                createRecurringRideSwitch.setOn(true, animated: false)
//                recurringRideDaysButton.setTitle(self.prepareStringForRecurringRideBasedOnDays(), for: .normal)
//            }
        }else if !recurringRideView.isHidden{
            recurringRideView.isHidden = true
            recurringRideViewHeightConstraint.constant = 0
            createRecurringRideSwitch.setOn(false, animated: false)
        }else{
            createRecurringRideSwitch.setOn(false, animated: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
