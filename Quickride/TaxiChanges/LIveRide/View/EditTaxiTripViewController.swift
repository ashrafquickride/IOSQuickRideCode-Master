//
//  EditTaxiTripViewController.swift
//  Quickride
//
//  Created by HK on 02/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias editTaxiTripComplitionHandler = (_ isTripUpdate: Bool) -> Void

class EditTaxiTripViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var destinationLabel: UIButton!
    @IBOutlet weak var startTimeView: UIView!
    @IBOutlet weak var endTimeView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeText: UILabel!
    @IBOutlet weak var dropTimeText: UILabel!
    
    private var editTaxiTripViewModel = EditTaxiTripViewModel()
    
    func editRideView(taxiRide: TaxiRidePassenger,editTaxiTripComplitionHandler: @escaping editTaxiTripComplitionHandler){
        editTaxiTripViewModel = EditTaxiTripViewModel(taxiRide: taxiRide,editTaxiTripComplitionHandler: editTaxiTripComplitionHandler)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        setUpUi()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        confirmObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func confirmObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .stopSpinner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    @objc func stopSpinner(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        editTaxiTripViewModel.editTaxiTripComplitionHandler?(true)
        closeView()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    private func setUpUi(){
        destinationLabel.setTitle(editTaxiTripViewModel.taxiRide?.endAddress, for: .normal)
        if TaxiRidePassenger.STATUS_STARTED == editTaxiTripViewModel.taxiRide?.status{
            startTimeView.isHidden = true
            startTimeText.isHidden = true
        }else{
            startTimeView.isHidden = false
            startTimeText.isHidden = false
            startTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: editTaxiTripViewModel.taxiRide?.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        }
        if editTaxiTripViewModel.taxiRide?.journeyType == TaxiRidePassenger.ROUND_TRIP{
            endTimeView.isHidden = false
            dropTimeText.isHidden = false
            endTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: editTaxiTripViewModel.taxiRide?.dropTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        }else{
            endTimeView.isHidden = true
            dropTimeText.isHidden = true
        }
    }
    
    @IBAction func endLocationBtnPressed(_ sender: UIButton){
        let endLocation = Location(latitude: editTaxiTripViewModel.taxiRide?.endLat ?? 0, longitude: editTaxiTripViewModel.taxiRide?.endLng ?? 0, shortAddress: editTaxiTripViewModel.taxiRide?.endAddress)
        moveToLocationSelection(locationType:  ChangeLocationViewController.DESTINATION, location: endLocation)
    }
    
    func moveToLocationSelection(locationType : String, location : Location?) {
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection()")
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    
    @IBAction func startTimeTapped(_ sender: UIButton) {
        editTaxiTripViewModel.isFromStartTime = true
        showDatePicker()
    }
    
    @IBAction func dropTimeTapped(_ sender: UIButton) {
        editTaxiTripViewModel.isFromStartTime = false
        showDatePicker()
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        if editTaxiTripViewModel.isUpdateRequired{
            QuickRideProgressSpinner.startSpinner()
            editTaxiTripViewModel.getAvailableVehicleClass { (fareForVehicleClass) in
                if let fareVehicleClass = fareForVehicleClass{
                    self.editTaxiTripViewModel.routeId = Double(fareVehicleClass.routeId ?? "")
                    self.editTaxiTripViewModel.updateTaxiTrip(fixedFareId: fareVehicleClass.fixedFareId ?? "")
                }else{
                    QuickRideProgressSpinner.stopSpinner()
                    UIApplication.shared.keyWindow?.makeToast("You can't edit now please try it latter")
                }
            }
        }
    }
    
    private func showDatePicker() {
        let scheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleRideViewController.delegate = self
        if editTaxiTripViewModel.isFromStartTime{
            scheduleRideViewController.minDate = NSDate().timeIntervalSince1970/1000
            scheduleRideViewController.defaultDate = (editTaxiTripViewModel.taxiRide?.startTimeMs ?? 0)/1000
        }else{
            scheduleRideViewController.minDate = (editTaxiTripViewModel.taxiRide?.startTimeMs ?? 0)/1000
            scheduleRideViewController.defaultDate = (editTaxiTripViewModel.taxiRide?.dropTimeMs ?? 0)/1000
        }
        scheduleRideViewController.datePickerMode = UIDatePicker.Mode.dateAndTime
        scheduleRideViewController.modalPresentationStyle = .overCurrentContext
        self.present(scheduleRideViewController, animated: false, completion: nil)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
}
//MARK: SelectDateDelegate
extension EditTaxiTripViewController: SelectDateDelegate {
    func getTime(date: Double) {
        AppDelegate.getAppDelegate().log.debug("getTime")
        let updatedDate = date*1000
        if editTaxiTripViewModel.isFromStartTime{
            if editTaxiTripViewModel.taxiRide?.startTimeMs != updatedDate{
                editTaxiTripViewModel.isUpdateRequired = true
                startTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: updatedDate, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
                editTaxiTripViewModel.taxiRide?.startTimeMs = updatedDate
            }
        }else{
            if editTaxiTripViewModel.taxiRide?.dropTimeMs != updatedDate{
                editTaxiTripViewModel.isUpdateRequired = true
                editTaxiTripViewModel.taxiRide?.dropTimeMs = updatedDate
                endTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: updatedDate, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
            }
        }
    }
}
//MARK: Location selection delegates
extension EditTaxiTripViewController: ReceiveLocationDelegate {
    func locationSelectionCancelled(requestLocationType: String) {}
    
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("receiveSelectedLocation()")
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
    }
    
    func handleselectedLocation(location: Location, requestLocationType: String){
        if requestLocationType == ChangeLocationViewController.DESTINATION{
            let distance = LocationClientUtils.getDistance(fromLatitude: editTaxiTripViewModel.taxiRide?.startLat ?? 0, fromLongitude: editTaxiTripViewModel.taxiRide?.startLng ?? 0, toLatitude: location.latitude, toLongitude: location.longitude)
            if distance < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES{
                UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                return
            }
            
            if editTaxiTripViewModel.taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_LOCAL &&  distance/1000 > ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
                UIApplication.shared.keyWindow?.makeToast("Please change location its look like outstation location")
                return
            }
            
            if editTaxiTripViewModel.taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION &&  distance/1000 < ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
                UIApplication.shared.keyWindow?.makeToast("Please change location its look like local location")
                return
            }
            if location.latitude != editTaxiTripViewModel.taxiRide?.endLat && location.longitude != editTaxiTripViewModel.taxiRide?.endLng{
                editTaxiTripViewModel.isUpdateRequired = true
                editTaxiTripViewModel.taxiRide?.endLat = location.latitude
                editTaxiTripViewModel.taxiRide?.endLng = location.longitude
                editTaxiTripViewModel.taxiRide?.endAddress = location.shortAddress
                destinationLabel.setTitle(location.shortAddress, for: .normal)
            }
        }
    }
}
