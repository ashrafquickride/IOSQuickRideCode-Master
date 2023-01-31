//
//  TaxiRideCreationBottomViewController.swift
//  Quickride
//
//  Created by Ashutos on 14/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Lottie

class TaxiRideCreationBottomViewController: UIViewController {

    @IBOutlet weak var taxiRideDetailstableView: UITableView!
    @IBOutlet weak var taxiButton: UIButton!
    @IBOutlet weak var rentalButton: UIButton!
    @IBOutlet weak var taxiMarkerView: UIView!
    @IBOutlet weak var rentalMarkerView: UIView!
    @IBOutlet weak var tableviewBottomHeightConstraints: NSLayoutConstraint!
    
    private var taxiRideCreationViewModel = TaxiRideCreationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        taxiRideDetailstableView.dataSource = self
        taxiRideDetailstableView.delegate = self
        setDateAndTime(carIndex: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(upadteTaxiStartTime), name: .upadteTaxiStartTime, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func upadteTaxiStartTime(_ notification: Notification){
        showDatePicker(isFromDate: true)
    }

    func initialiseData(taxiRideCreationViewModel: TaxiRideCreationViewModel) {
        self.taxiRideCreationViewModel = taxiRideCreationViewModel
    }

    private func registerCell() {
        taxiRideDetailstableView.register(UINib(nibName: "TaxiLocationSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiLocationSelectionTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "TaxiDetailsCardTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiDetailsCardTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "TaxiErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiErrorTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "TaxiPoolJoiningTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolJoiningTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "LoadingTaxiListTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingTaxiListTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "TaxiCreationTimeNotMatchingErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiCreationTimeNotMatchingErrorTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "TaxiCreationServiceErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiCreationServiceErrorTableViewCell")
        taxiRideDetailstableView.register(UINib(nibName: "RentalPackageSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalPackageSelectionTableViewCell")
        taxiRideDetailstableView.estimatedRowHeight = 200
        taxiRideDetailstableView.rowHeight = UITableView.automaticDimension
    }

    func showDatePicker(isFromDate: Bool) {
        let scheduleLater:ScheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        if taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            if isFromDate{
                var defaultDate =  LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: taxiRideCreationViewModel.rideType, fromLatitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0 , fromLongitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0)/1000
                if taxiRideCreationViewModel.isFromScheduleReturnRide{
                    defaultDate = taxiRideCreationViewModel.startTime/1000
                }
                scheduleLater.initializeDataBeforePresentingView(minDate: defaultDate,maxDate: nil, defaultDate: defaultDate, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
            }else{
                let defaultDate = NSDate().addMinutes(minutesToAdd: 24*60)
                scheduleLater.initializeDataBeforePresentingView(minDate : defaultDate.timeIntervalSince1970,maxDate: nil, defaultDate: defaultDate.timeIntervalSince1970, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
            }
        }else if taxiRideCreationViewModel.rideType == TaxiPoolConstants.TRIP_TYPE_LOCAL{
            scheduleLater.delegate = self
            if taxiRideCreationViewModel.isFromScheduleReturnRide{
                scheduleLater.minDate = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: taxiRideCreationViewModel.rideType, fromLatitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0 , fromLongitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0)/1000
                scheduleLater.defaultDate = taxiRideCreationViewModel.startTime/1000
            }else{
                scheduleLater.defaultDate = taxiRideCreationViewModel.startTime/1000
                scheduleLater.minDate = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: taxiRideCreationViewModel.rideType, fromLatitude: taxiRideCreationViewModel.startLocation?.latitude ?? 0 , fromLongitude: taxiRideCreationViewModel.startLocation?.longitude ?? 0)/1000
            }
            scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime
        }else{
            scheduleLater.delegate = self
            scheduleLater.minDate = NSDate().timeIntervalSince1970
            scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime
        }
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
}

extension TaxiRideCreationBottomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1// location selection
        case 1:
            if taxiRideCreationViewModel.isTaxiDetailsFetchingFromServer, taxiRideCreationViewModel.endLocation != nil, taxiRideCreationViewModel.startLocation != nil{
                return 2// loading cell
            }else if taxiRideCreationViewModel.selectedOptionIndex == 1, let rentalPackageCount = taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList.count, rentalPackageCount > 0  {
                return rentalPackageCount
            }else if taxiRideCreationViewModel.detailedEstimateFare?.serviceableArea ?? false, taxiRideCreationViewModel.fareForVehicleDetail.count > 0 {
                return taxiRideCreationViewModel.fareForVehicleDetail.count
            }else if taxiRideCreationViewModel.startLocation == nil || taxiRideCreationViewModel.endLocation == nil {
                return 0
            }else{
                return 1 // error cell
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if taxiRideCreationViewModel.selectedOptionIndex == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RentalPackageSelectionTableViewCell", for: indexPath) as! RentalPackageSelectionTableViewCell
                cell.setupUI(pickup: taxiRideCreationViewModel.startLocation , rentalPackageEstimates: taxiRideCreationViewModel.rentalPackageEstimates, userSelectionDelegate: self, rentalPackageSelectionDelegate: self, selectedIndex: taxiRideCreationViewModel.selectedRentalPackageIndex, isFromHomePage: false, startTime: taxiRideCreationViewModel.startTime )
                return cell
            } else {
                let rideTypeCell = tableView.dequeueReusableCell(withIdentifier: "TaxiLocationSelectionTableViewCell", for: indexPath) as! TaxiLocationSelectionTableViewCell
                var isTollIncluded = false
                if !self.taxiRideCreationViewModel.fareForVehicleDetail.isEmpty, let includedTollCharges = self.taxiRideCreationViewModel.fareForVehicleDetail[0].tollChargesForTaxi,includedTollCharges != 0{
                    isTollIncluded = true
                }
                    rideTypeCell.setUpUI(startLocation: taxiRideCreationViewModel.startLocation, endLocation: taxiRideCreationViewModel.endLocation, rideType: taxiRideCreationViewModel.rideType, isRoundtrip: taxiRideCreationViewModel.isRoundTrip , delegate: self,fromTime: taxiRideCreationViewModel.startTime, toTime: taxiRideCreationViewModel.endTime ?? 0.0, isRequiredToShowAnimationForTime: taxiRideCreationViewModel.isRequiredToShowAnimationForTime, isTollIncluded: isTollIncluded)
                taxiRideCreationViewModel.isRequiredToShowAnimationForTime = false
                return rideTypeCell
            }
        case 1:
            if taxiRideCreationViewModel.isTaxiDetailsFetchingFromServer, taxiRideCreationViewModel.endLocation != nil, taxiRideCreationViewModel.startLocation != nil{
                let loadingTaxiList = tableView.dequeueReusableCell(withIdentifier: "LoadingTaxiListTableViewCell", for: indexPath) as! LoadingTaxiListTableViewCell
                return loadingTaxiList
            }else if taxiRideCreationViewModel.selectedOptionIndex == 1, let rentalPackageEstimates = taxiRideCreationViewModel.rentalPackageEstimates{
                let taxiCardCell = tableView.dequeueReusableCell(withIdentifier: "TaxiDetailsCardTableViewCell", for: indexPath) as! TaxiDetailsCardTableViewCell
                var isSelectedIndex = false
                if taxiRideCreationViewModel.selectedTaxiTypeIndex == indexPath.row {
                    isSelectedIndex = true
                }
                taxiCardCell.setupUI(taxiType: rentalPackageEstimates[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList[indexPath.row].vehicleClass, pkgFare: String(rentalPackageEstimates[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList[indexPath.row].pkgFare ?? 0), isSelectedIndex: isSelectedIndex)
                return taxiCardCell
            }else{
                let errorCode = taxiRideCreationViewModel.detailedEstimateFare?.error?.errorCode
                if taxiRideCreationViewModel.detailedEstimateFare?.serviceableArea ?? false {
                    let taxiCardCell = tableView.dequeueReusableCell(withIdentifier: "TaxiDetailsCardTableViewCell", for: indexPath) as! TaxiDetailsCardTableViewCell
                    var isSelectedIndex = false
                    if taxiRideCreationViewModel.selectedTaxiTypeIndex == indexPath.row {
                        isSelectedIndex = true
                    }
                    taxiCardCell.setUpUI(fareForVehicle: taxiRideCreationViewModel.fareForVehicleDetail[indexPath.row],isSelectedIndex: isSelectedIndex,discountAmount: taxiRideCreationViewModel.userCouponCode?.maxDiscount ?? 0)
                    return taxiCardCell
                }else if errorCode == DetailedEstimateFare.TIME_NOT_MATCHING_ERROR_CODE{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiCreationTimeNotMatchingErrorTableViewCell", for: indexPath) as!  TaxiCreationTimeNotMatchingErrorTableViewCell
                    let timeGap = (ConfigurationCache.getObjectClientConfiguration().outStationInstantBookingThresholdTimeInMins)/60
                    let time = DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: ConfigurationCache.getObjectClientConfiguration().outStationInstantBookingThresholdTimeInMins)
                    let startTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? ""
                    cell.initialiseError(error: String(format: Strings.taxi_time_not_matching_error, arguments: [String(timeGap),String(startTime)]))
                    return cell
                }else if errorCode == DetailedEstimateFare.PICKUP_LOCATION_ERROR_CODE || errorCode == DetailedEstimateFare.DROP_LOCATION_ERROR_CODE || errorCode == DetailedEstimateFare.SERVICE_DROP_LOCATION_ERROR_CODE || errorCode == DetailedEstimateFare.ROUTE_ONEWAY_TRIP_ERROR_CODE || errorCode == DetailedEstimateFare.ROUTE_OUTSTATION_TRIP_ERROR_CODE{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiCreationServiceErrorTableViewCell", for: indexPath) as! TaxiCreationServiceErrorTableViewCell
                    cell.initialiseError()
                    return cell
                }else{
                    let notServicableCell = tableView.dequeueReusableCell(withIdentifier: "TaxiErrorTableViewCell", for: indexPath) as! TaxiErrorTableViewCell
                    if let detailEstimateFare = taxiRideCreationViewModel.detailedEstimateFare,let errorMessge = detailEstimateFare.error?.userMessage{
                        notServicableCell.setUpUI(message: errorMessge)
                    }else{
                        notServicableCell.setUpUI(message: "Quick Ride server is busy or your internet connection is low")
                    }
                    return notServicableCell
                }
            }

        default:
            return UITableViewCell()
        }
    }
}

extension TaxiRideCreationBottomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if taxiRideCreationViewModel.selectedOptionIndex == 0, indexPath.section == 1 && indexPath.row < taxiRideCreationViewModel.fareForVehicleDetail.endIndex{
            setDateAndTime(carIndex: indexPath.row)
        }else if taxiRideCreationViewModel.selectedOptionIndex == 1 {
            taxiRideCreationViewModel.selectedTaxiTypeIndex = indexPath.row
            selectRentalPackageId(index: indexPath.row)
            taxiRideDetailstableView.reloadData()
        }else {
            return
        }
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            if let location = taxiRideCreationViewModel.startLocation {
                taxiRideCreationMapViewController.getAvailableNearbyTaxi(location: location)
            }
        }
    }

    func setDateAndTime(carIndex: Int){
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            if carIndex < taxiRideCreationViewModel.fareForVehicleDetail.endIndex{
                taxiRideCreationViewModel.selectedTaxiTypeIndex = carIndex
                if taxiRideCreationViewModel.validatePickUpTimeAndUpdate(startTimeInMs: taxiRideCreationViewModel.fareForVehicleDetail[carIndex].startTime) {
                    taxiRideCreationViewModel.isRequiredToShowAnimationForTime = true
                }
                taxiRideDetailstableView.reloadData()
                taxiRideCreationMapViewController.updateBookNowButtonUI()
            }
        }
    }

    func selectRentalPackageId(index: Int){
        if taxiRideCreationViewModel.rentalPackageEstimates?.count ?? 0 > taxiRideCreationViewModel.selectedRentalPackageIndex, taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList.count ?? 0 > index
            ,let selectedId = taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList[index].id,
           let taxiVehicleCategory = taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList[index].vehicleClass {
            taxiRideCreationViewModel.rentalPackageId = selectedId
            taxiRideCreationViewModel.taxiVehicleCategory = taxiVehicleCategory
        }
    }

    //MARK: footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        default:
            return 0
        }

    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return footerCell
    }
}

extension TaxiRideCreationBottomViewController: TaxiLocationSelectionTableViewCellDelegate {
    func taxiPressed() {

    }

    func outstationPressed() {

    }


    func fromLocationPressed() {
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            taxiRideCreationMapViewController.moveToLocationSelection(locationType:  ChangeLocationViewController.TAXI_PICKUP, location: taxiRideCreationViewModel.startLocation, alreadySelectedLocation: taxiRideCreationViewModel.endLocation)
        }
    }

    func toLocationPressed() {
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            taxiRideCreationMapViewController.moveToLocationSelection(locationType:  ChangeLocationViewController.TAXI_DROP, location: taxiRideCreationViewModel.endLocation, alreadySelectedLocation: taxiRideCreationViewModel.startLocation)
        }
    }

    func swapBtnPressed() {
        taxiRideCreationViewModel.selectedRouteId = -1.0
        let temp = taxiRideCreationViewModel.startLocation
        taxiRideCreationViewModel.startLocation = taxiRideCreationViewModel.endLocation
        taxiRideCreationViewModel.endLocation = temp
        taxiRideCreationViewModel.isRequiredToReloadData = true
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            taxiRideCreationMapViewController.getAvailableRoutes(routeId: nil)
            if let startLocation = taxiRideCreationViewModel.startLocation {
                taxiRideCreationMapViewController.getAvailableNearbyTaxi(location: startLocation)
            }
        }

    }

    func oneWayPressed() {
        taxiRideCreationViewModel.isRoundTrip = false
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController{
            taxiRideCreationMapViewController.getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
        }
    }

    func roundTripPressed() {
        taxiRideCreationViewModel.isRoundTrip = true
        if taxiRideCreationViewModel.endTime == nil {
            taxiRideCreationViewModel.endTime = taxiRideCreationViewModel.getMinDropTimeAcceptedForOutstationTaxi()
            setDateAndTime(carIndex: 0)
        }
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController{
            taxiRideCreationMapViewController.getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
        }
    }

    func fromDatePressed() {
        showDatePicker(isFromDate: true)
    }

    func fromDateUpdated(date: Double) {
        taxiRideCreationViewModel.startTime = date
    }

    func toDatePressed() {
        taxiRideCreationViewModel.isFromDropTime = true
        showDatePicker(isFromDate: false)
    }
}

extension TaxiRideCreationBottomViewController: SelectDateDelegate {
    func getTime(date: Double) {
        if taxiRideCreationViewModel.selectedOptionIndex == 0 {
            AppDelegate.getAppDelegate().log.debug("getTime")
            if taxiRideCreationViewModel.isFromDropTime {
                taxiRideCreationViewModel.endTime = date*1000
                taxiRideCreationViewModel.isFromDropTime = false
            }else{
                taxiRideCreationViewModel.startTime = date*1000
                taxiRideCreationViewModel.userSelectedTime = date*1000
                taxiRideCreationViewModel.isRequiredToReloadData = true
            }
            if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController{
                taxiRideCreationMapViewController.getAvailableRoutes(routeId: taxiRideCreationViewModel.selectedRouteId)
            }
        }else{
            taxiRideCreationViewModel.startTime = date*1000
            taxiRideCreationViewModel.userSelectedTime = date*1000
            taxiRideCreationViewModel.isRequiredToReloadData = true
            taxiRideCreationViewModel.getRentalPackages { (responseError, error) in
                self.taxiRideDetailstableView.reloadData()
                if responseError != nil || error != nil {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }
    }
}
extension TaxiRideCreationBottomViewController: RideLocationSelectionTableViewCellDelegate {
    // for rental
    func fromLocationTapped() {

    }

    func toLocationTapped() {

    }

    func rideTypeChanged(primary: String) {

    }
}

extension TaxiRideCreationBottomViewController: RentalPackageSelectionDelegate{
    func pickUpDateTapped() {
        showDatePickerForRental()
    }

    func selectedRentalPackage(packageDistance: Int, packageDuration: Int) {
        if let index = taxiRideCreationViewModel.rentalPackageEstimates?.firstIndex(where: {$0.packageDistance == packageDistance && $0.packageDuration == packageDuration}) {
            taxiRideCreationViewModel.selectedRentalPackageIndex = index
        }
        taxiRideDetailstableView.reloadData()
    }

    func pickupLocationChanged(){
        if let taxiRideCreationMapViewController = self.parent?.parent as? TaxiRideCreationMapViewController {
            taxiRideCreationMapViewController.moveToLocationSelection(locationType:  ChangeLocationViewController.TAXI_PICKUP, location: taxiRideCreationViewModel.startLocation, alreadySelectedLocation: taxiRideCreationViewModel.endLocation)
        }
    }
    
    func showPackageInfo(){
        let rentalRulesAndRestrictionsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RentalRulesAndRestrictionsViewController") as! RentalRulesAndRestrictionsViewController
        rentalRulesAndRestrictionsViewController.initialiseData(rentalPackageConfig: taxiRideCreationViewModel.rentalPackageEstimates?[taxiRideCreationViewModel.selectedRentalPackageIndex].rentalPackageConfigList)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rentalRulesAndRestrictionsViewController)
    }

    func showDatePickerForRental(){
        let scheduleLater:ScheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970, maxDate: nil, defaultDate: NSDate().timeIntervalSince1970, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
}
